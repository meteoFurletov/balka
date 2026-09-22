#!/usr/bin/env python3
"""The balka board — every change in this repo, in every worktree, as a kanban.

Read-only by design. A card moves because a stage finished and its owner
accepted it, never because someone dragged it, so the board offers the next
command to run instead of a way to change a status.

State is read fresh on every request: the change directories in each worktree
and on the default branch, the Status line in each artefact, the claims under
the shared .git, and pull requests from `gh` when it is there. Nothing is
written anywhere, so there is nothing for parallel agents to fight over.

    board.py              serve it on localhost ($PORT, else --port, else 4717)
    board.py --text       print it as markdown
    board.py --json       print the state the page renders

python3 stdlib only; `gh` is optional.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import quote

COLUMNS = ("intent", "design", "plan", "build", "deploy", "done")
TITLES = {"intent": "Intent", "design": "Design", "plan": "Plan",
          "build": "Build", "deploy": "Deploy", "done": "Done"}
ARTEFACTS = ("intent", "spec", "plan")
CHANGE_DIR = re.compile(r"^\d+-.+")
STATUS = re.compile(r"Status:\s*([a-z]+)")


def git(repo: Path, *args: str) -> str:
    out = subprocess.run(["git", "-C", str(repo), *args],
                         capture_output=True, text=True)
    return out.stdout if out.returncode == 0 else ""


def status_of(text: str) -> str | None:
    m = STATUS.search(text)
    return m.group(1) if m else None


def title_of(text: str) -> str:
    first = text.splitlines()[0] if text else ""
    return re.sub(r"^#\s*(Intent:\s*)?", "", first).replace("`", "").strip()


# ---------------------------------------------------------------------------
# Where changes live: worktrees on disk, and the default branch in git.
# ---------------------------------------------------------------------------

def load_config(top: Path) -> dict:
    for name in ("balka.json", "sdlc.json"):
        f = top / ".claude" / name
        if f.is_file():
            try:
                return json.loads(f.read_text())
            except json.JSONDecodeError:
                return {}
    return {}


def worktrees(top: Path) -> list[dict]:
    trees, cur = [], {}
    for line in git(top, "worktree", "list", "--porcelain").splitlines():
        if line.startswith("worktree "):
            cur = {"path": line[9:], "branch": None}
            trees.append(cur)
        elif line.startswith("branch "):
            cur["branch"] = line[7:].removeprefix("refs/heads/")
    return [t for t in trees if Path(t["path"]).is_dir()]


def default_branch(top: Path) -> str:
    ref = git(top, "symbolic-ref", "--short", "refs/remotes/origin/HEAD").strip()
    if ref:
        return ref.removeprefix("origin/")
    for name in ("main", "master"):
        if git(top, "rev-parse", "--verify", "--quiet", name).strip():
            return name
    return ""


def changes_on_disk(root: Path, artifact_dir: str) -> dict[str, dict]:
    found = {}
    base = root / artifact_dir
    if not base.is_dir():
        return found
    for d in sorted(base.iterdir()):
        if not (d.is_dir() and CHANGE_DIR.match(d.name)):
            continue
        texts = {a: (d / f"{a}.md").read_text(errors="replace")
                 for a in ARTEFACTS if (d / f"{a}.md").is_file()}
        found[d.name] = texts
    return found


def changes_in_ref(top: Path, ref: str, artifact_dir: str) -> dict[str, dict]:
    found = {}
    names = git(top, "ls-tree", "--name-only", f"{ref}:{artifact_dir}").split()
    for name in names:
        if not CHANGE_DIR.match(name):
            continue
        texts = {}
        for a in ARTEFACTS:
            out = subprocess.run(
                ["git", "-C", str(top), "show", f"{ref}:{artifact_dir}/{name}/{a}.md"],
                capture_output=True, text=True)
            if out.returncode == 0:
                texts[a] = out.stdout
        if texts:
            found[name] = texts
    return found


def claims(top: Path) -> dict[str, str]:
    common = git(top, "rev-parse", "--path-format=absolute", "--git-common-dir").strip()
    d = Path(common) / "balka" / "claims" if common else None
    if not d or not d.is_dir():
        return {}
    return {p.name: os.readlink(p) for p in d.iterdir() if p.is_symlink()}


# ---------------------------------------------------------------------------
# Pull requests, when gh is there. Cached: the page polls every few seconds.
# ---------------------------------------------------------------------------

_pr_cache: dict = {"at": 0.0, "top": None, "prs": None, "note": ""}


def pull_requests(top: Path, use_gh: bool) -> tuple[dict[str, dict], str]:
    if not use_gh:
        return {}, "pull requests off"
    if not shutil.which("gh"):
        return {}, "gh not installed: no pull request data"
    if _pr_cache["top"] == top and time.time() - _pr_cache["at"] < 30:
        return _pr_cache["prs"], _pr_cache["note"]
    try:
        out = subprocess.run(
            ["gh", "pr", "list", "--state", "all", "--limit", "200", "--json",
             "number,state,headRefName,url,isDraft,reviewDecision"],
            cwd=top, capture_output=True, text=True, timeout=8)
        rows = json.loads(out.stdout) if out.returncode == 0 else None
    except (subprocess.TimeoutExpired, json.JSONDecodeError):
        rows = None
    if rows is None:
        prs, note = {}, "gh could not list pull requests here"
    else:
        # Newest first from gh; keep the newest per branch.
        prs, note = {}, ""
        for r in rows:
            prs.setdefault(r["headRefName"], r)
    _pr_cache.update(at=time.time(), top=top, prs=prs, note=note)
    return prs, note


# ---------------------------------------------------------------------------
# One card per change.
# ---------------------------------------------------------------------------

def column_of(st: dict) -> str:
    i, s, p = st.get("intent"), st.get("spec"), st.get("plan")
    if i in ("parked", "rejected"):
        return "parked"
    if i == "split":
        return "split"
    if p == "built":
        return "deploy"
    if p == "accepted":
        return "build"
    if s == "accepted":
        return "plan"
    if i == "accepted":
        return "design"
    return "intent"


def next_step(card: dict) -> dict | None:
    cid, col, pr = card["id"], card["column"], card.get("pr")
    if col == "intent":
        if card["statuses"].get("intent"):
            return {"say": "waiting for the owner to accept the intent"}
        return {"cmd": "/balka:intent"}
    if col == "design":
        return {"cmd": f"/balka:spec {cid}"}
    if col == "plan":
        return {"cmd": f"/balka:plan {cid}"}
    if col == "build":
        return {"cmd": f"/balka:build {cid}", "then": f"/balka:test {cid}"}
    if col == "deploy":
        if pr and pr["state"] == "OPEN":
            return {"say": f"in review: PR #{pr['number']}", "url": pr["url"]}
        return {"cmd": f"/balka:deploy {cid}"}
    if col == "done" and card.get("worktree") and not card["worktree"]["main"]:
        return {"say": "merged: archive its session to remove the worktree"}
    return None


def collect(repo: Path, use_gh: bool = True) -> dict:
    top = Path(git(repo, "rev-parse", "--show-toplevel").strip() or repo)
    cfg = load_config(top)
    artifact_dir = cfg.get("artifactDir") or "docs/balka"
    trees = worktrees(top)
    main_path = trees[0]["path"] if trees else str(top)
    default = default_branch(top)
    held = claims(top)
    live = {t["path"] for t in trees}
    prs, pr_note = pull_requests(top, use_gh)

    # Every copy of every change: one per worktree that has it, plus the
    # default branch if no worktree has it checked out. A worktree branched
    # from the default carries a copy of every finished change too, so only a
    # copy that differs from the default's is work in flight.
    on_default = changes_in_ref(top, default, artifact_dir) if default else {}
    copies: dict[str, list[dict]] = {}
    for t in trees:
        for cid, texts in changes_on_disk(Path(t["path"]), artifact_dir).items():
            copies.setdefault(cid, []).append({"tree": t, "texts": texts})
    if default and default not in {t["branch"] for t in trees}:
        for cid, texts in on_default.items():
            copies.setdefault(cid, []).append({"tree": None, "texts": texts})

    cards = []
    for cid, cs in copies.items():
        num = cid.split("-", 1)[0]
        owner = held.get(num)

        # The copy that speaks for the change: the claim holder's, else work in
        # flight on another branch, else the default branch's own.
        def rank(c):
            t = c["tree"]
            if t and owner and t["path"] == owner:
                return 0
            if t and t["branch"] != default:
                return 1 if c["texts"] != on_default.get(cid) else 4
            return 2 if t else 3
        home = min(cs, key=rank)
        t, texts = home["tree"], home["texts"]
        in_flight = rank(home) <= 1 and (t is None or t["branch"] != default)
        statuses = {a: status_of(texts[a]) for a in texts}
        col = column_of(statuses)
        branch = t["branch"] if t and in_flight else default
        pr = prs.get(branch) if in_flight and branch else None
        if col == "deploy" and (not in_flight or (pr and pr["state"] == "MERGED")):
            col = "done"
        last = git(Path(t["path"]) if t else top, "log", "-1", "--format=%ct|%cr",
                   *([] if t else [default]), "--", f"{artifact_dir}/{cid}").strip()
        card = {
            "id": cid,
            "num": num,
            "title": title_of(texts.get("intent", "")) or cid,
            "column": col,
            "statuses": statuses,
            "branch": branch,
            "worktree": ({"path": t["path"], "name": Path(t["path"]).name,
                          "main": t["path"] == main_path} if t else None),
            "owner": owner,
            "stale_claim": bool(owner) and owner not in live,
            "pr": pr,
            "last": last.split("|")[1] if "|" in last else "",
            "last_ts": int(last.split("|")[0]) if "|" in last else 0,
        }
        card["next"] = next_step(card)
        cwd = card["worktree"]["path"] if card["worktree"] else str(top)
        if card["next"] and card["next"].get("cmd"):
            card["next"]["link"] = (f"claude-cli://open?cwd={quote(cwd, safe='')}"
                                    f"&q={quote(card['next']['cmd'], safe='')}")
        cards.append(card)

    cards.sort(key=lambda c: c["num"])
    return {
        "repo": top.name,
        "path": str(top),
        "artifactDir": artifact_dir,
        "defaultBranch": default,
        "configured": bool(cfg),
        "worktrees": [{"path": t["path"], "branch": t["branch"],
                       "main": t["path"] == main_path} for t in trees],
        "prNote": pr_note,
        "changes": cards,
        "at": int(time.time()),
    }


# ---------------------------------------------------------------------------
# Output: markdown, JSON, or the page.
# ---------------------------------------------------------------------------

def as_text(state: dict) -> str:
    n = len(state["worktrees"])
    lines = [f"**{state['repo']}** — {len(state['changes'])} changes, "
             f"{n} worktree{'' if n == 1 else 's'}"]
    for col in COLUMNS:
        cs = [c for c in state["changes"] if c["column"] == col]
        if col == "done":
            lines.append(f"\n**Done** — {len(cs)}")
            continue
        lines.append(f"\n**{TITLES[col]}**" + ("" if cs else " — none"))
        for c in cs:
            where = c["worktree"]["name"] if c["worktree"] else c["branch"]
            nxt = c["next"] or {}
            step = nxt.get("cmd") or nxt.get("say") or ""
            pr = f", PR #{c['pr']['number']} {c['pr']['state'].lower()}" if c["pr"] else ""
            lines.append(f"- `{c['id']}` {c['title']} ({where}{pr})"
                         + (f" → {step}" if step else ""))
    rest = [c for c in state["changes"] if c["column"] in ("parked", "split")]
    if rest:
        lines.append("\n**Parked or split** — " + ", ".join(f"`{c['id']}`" for c in rest))
    return "\n".join(lines)


PAGE = r"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>balka board</title>
<style>
:root {
  --bg: #f6f5f2; --panel: #ecebe6; --card: #ffffff; --ink: #1d1d1b;
  --muted: #6b6a64; --line: #dcdad3; --accent: #3a6ea5; --warn: #b5541c;
  --ok: #2f7d4f; --chip: #f0efe9;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #161615; --panel: #1f1f1d; --card: #2a2a27; --ink: #ecebe6;
    --muted: #a09f98; --line: #3a3a36; --accent: #7aa7d6; --warn: #e08a52;
    --ok: #6cc08e; --chip: #33332f;
  }
}
* { box-sizing: border-box; }
body { margin: 0; background: var(--bg); color: var(--ink);
  font: 13px/1.4 ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif; }
header { display: flex; align-items: baseline; gap: 12px; flex-wrap: wrap;
  padding: 14px 16px 10px; }
header h1 { font-size: 16px; margin: 0; }
header .meta { color: var(--muted); }
header .note { color: var(--warn); }
main { display: grid; gap: 8px; padding: 0 16px 16px; overflow-x: auto; }
section { background: var(--panel); border-radius: 8px; padding: 8px;
  min-height: 120px; }
section h2 { font-size: 12px; text-transform: uppercase; letter-spacing: .04em;
  color: var(--muted); margin: 2px 4px 8px; display: flex; justify-content: space-between;
  gap: 6px; }
section h2 span:first-child { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.card { background: var(--card); border: 1px solid var(--line); border-radius: 6px;
  padding: 8px; margin-bottom: 8px; }
.card .title { margin: 0 0 6px; }
.card .num { font: 600 12px ui-monospace, SFMono-Regular, Menlo, monospace;
  color: var(--accent); margin-right: 4px; }
.card .row { display: flex; flex-wrap: wrap; gap: 4px; color: var(--muted); font-size: 11px; }
.chip { background: var(--chip); border-radius: 4px; padding: 1px 5px; }
.chip.warn { color: var(--warn); }
.chip.ok { color: var(--ok); }
.dots { letter-spacing: 2px; }
.next { margin-top: 7px; padding-top: 6px; border-top: 1px dashed var(--line);
  display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }
.next code { font: 11px ui-monospace, SFMono-Regular, Menlo, monospace;
  background: var(--chip); padding: 1px 4px; border-radius: 3px; }
.next button, .next a.btn { font: inherit; font-size: 11px; border: 1px solid var(--line);
  background: transparent; color: var(--accent); border-radius: 4px; padding: 1px 6px;
  cursor: pointer; text-decoration: none; }
.next .say { color: var(--muted); font-size: 11px; }
.more { color: var(--muted); font-size: 11px; padding: 2px 4px; }
footer { color: var(--muted); padding: 0 16px 16px; font-size: 11px; }
@media (max-width: 600px) { main { grid-template-columns: 1fr !important; } }
</style>
</head>
<body>
<header><h1 id="repo">balka board</h1><span class="meta" id="meta"></span>
<span class="note" id="note"></span></header>
<main id="board"></main>
<footer id="foot"></footer>
<script>
const COLS = [["intent","Intent"],["design","Design"],["plan","Plan"],
              ["build","Build"],["deploy","Deploy"],["done","Done"]];
const DONE_SHOWN = 8;
const el = (tag, cls, text) => { const e = document.createElement(tag);
  if (cls) e.className = cls; if (text != null) e.textContent = text; return e; };
const dot = s => s === "accepted" || s === "built" ? "●" : s ? "◐" : "○";

function card(c) {
  const d = el("div", "card");
  const t = el("div", "title"); t.title = c.id;
  t.append(el("span", "num", c.num), document.createTextNode(c.title));
  d.append(t);
  const row = el("div", "row");
  const st = c.statuses;
  const dots = el("span", "chip dots", dot(st.intent) + dot(st.spec) + dot(st.plan));
  dots.title = `intent ${st.intent || "—"} · spec ${st.spec || "—"} · plan ${st.plan || "—"}`;
  row.append(dots);
  if (c.worktree && !c.worktree.main) row.append(el("span", "chip", c.worktree.name));
  if (c.branch) row.append(el("span", "chip", c.branch));
  if (c.pr) row.append(el("span", "chip" + (c.pr.state === "MERGED" ? " ok" : ""),
                          `PR #${c.pr.number} ${c.pr.state.toLowerCase()}`));
  if (c.stale_claim) row.append(el("span", "chip warn", "claim's worktree gone"));
  if (c.last) row.append(el("span", "", c.last));
  d.append(row);
  const n = c.next;
  if (n) {
    const box = el("div", "next");
    if (n.cmd) {
      const code = el("code", "", n.cmd.split(" ")[0]); code.title = n.cmd;
      box.append(code);
      const b = el("button", "", "copy");
      b.onclick = () => navigator.clipboard.writeText(n.cmd).then(
        () => { b.textContent = "copied"; setTimeout(() => b.textContent = "copy", 1200); });
      box.append(b);
      if (n.link) { const a = el("a", "btn", "terminal"); a.href = n.link;
        a.title = "Open a Claude Code terminal session in this worktree"; box.append(a); }
    }
    if (n.say) box.append(el("span", "say", n.say));
    if (n.url) { const a = el("a", "btn", "open"); a.href = n.url; a.target = "_blank"; box.append(a); }
    d.append(box);
  }
  return d;
}

function render(s) {
  document.getElementById("repo").textContent = s.repo;
  const trees = s.worktrees.length;
  document.getElementById("meta").textContent =
    `${s.changes.length} changes · ${trees} worktree${trees === 1 ? "" : "s"} · ${s.artifactDir}`;
  document.getElementById("note").textContent =
    (s.configured ? "" : "no .claude/balka.json · ") + (s.prNote || "");
  const board = document.getElementById("board");
  board.replaceChildren();
  // Empty columns stay narrow so a small pane still shows the whole flow.
  board.style.gridTemplateColumns = COLS.map(([key]) =>
    s.changes.some(c => c.column === key) ? "minmax(150px, 1fr)" : "minmax(64px, .35fr)").join(" ");
  for (const [key, name] of COLS) {
    let cs = s.changes.filter(c => c.column === key);
    if (key === "done") cs = cs.sort((a, b) => b.num.localeCompare(a.num));
    const sec = el("section");
    const h = el("h2"); h.append(el("span", "", name), el("span", "", String(cs.length)));
    sec.append(h);
    const shown = key === "done" ? cs.slice(0, DONE_SHOWN) : cs;
    shown.forEach(c => sec.append(card(c)));
    if (cs.length > shown.length) sec.append(el("div", "more", `+${cs.length - shown.length} more`));
    board.append(sec);
  }
  const rest = s.changes.filter(c => c.column === "parked" || c.column === "split");
  document.getElementById("foot").textContent =
    (rest.length ? "Parked or split: " + rest.map(c => c.id).join(", ") + " · " : "") +
    "updated " + new Date(s.at * 1000).toLocaleTimeString();
}

async function tick() {
  try { render(await (await fetch("api/board")).json()); }
  catch (e) { document.getElementById("note").textContent = "board server not reachable"; }
}
tick();
setInterval(tick, 5000);
</script>
</body>
</html>
"""


def serve(repo: Path, port: int, use_gh: bool) -> None:
    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path.split("?")[0] in ("/api/board", "/api/board/"):
                body = json.dumps(collect(repo, use_gh)).encode()
                ctype = "application/json"
            elif self.path.split("?")[0] == "/":
                body, ctype = PAGE.encode(), "text/html; charset=utf-8"
            else:
                self.send_error(404)
                return
            self.send_response(200)
            self.send_header("Content-Type", ctype)
            self.send_header("Cache-Control", "no-store")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            try:
                self.wfile.write(body)
            except (BrokenPipeError, ConnectionResetError):
                pass  # the page navigated away mid-response

        def log_message(self, *args):
            pass

    # Loopback only: the board shows repo paths and branch names.
    httpd = ThreadingHTTPServer(("127.0.0.1", port), Handler)
    print(f"balka board: http://localhost:{httpd.server_address[1]}", flush=True)
    httpd.serve_forever()


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--repo", default=".", help="any directory inside the repo")
    ap.add_argument("--port", type=int, default=int(os.environ.get("PORT", 4717)))
    ap.add_argument("--text", action="store_true", help="print the board as markdown")
    ap.add_argument("--json", action="store_true", help="print the board state")
    ap.add_argument("--no-gh", action="store_true", help="skip pull request lookups")
    args = ap.parse_args(argv)
    repo = Path(args.repo).resolve()
    if not git(repo, "rev-parse", "--show-toplevel").strip():
        print(f"balka board: {repo} is not inside a git repository", file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps(collect(repo, not args.no_gh), indent=2))
    elif args.text:
        print(as_text(collect(repo, not args.no_gh)))
    else:
        serve(repo, args.port, not args.no_gh)
    return 0


if __name__ == "__main__":
    sys.exit(main())
