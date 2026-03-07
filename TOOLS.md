# TOOLS.md — Full Toolset Reference

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

---

## Claude Code Native Tools

These are the built-in tools available in every Claude Code session.

### File Operations
| Tool | Purpose |
|------|---------|
| **Read** | Read files (code, images, PDFs, notebooks). Supports line offsets, page ranges. |
| **Write** | Create new files or fully overwrite existing ones. |
| **Edit** | Precise string replacement edits in existing files. Preferred over Write for modifications. |
| **NotebookEdit** | Insert, replace, or delete cells in Jupyter `.ipynb` notebooks. |
| **Glob** | Fast file pattern matching (e.g., `**/*.ts`, `src/**/*.py`). Use instead of `find`. |
| **Grep** | Regex content search powered by ripgrep. Supports context lines, file filtering, multiline. Use instead of `grep`/`rg`. |

### Execution & System
| Tool | Purpose |
|------|---------|
| **Bash** | Execute shell commands. For system ops, git, builds, tests — anything that needs a terminal. |
| **Agent** | Launch specialized sub-agents for complex/parallel tasks. Types: `general-purpose`, `Explore`, `Plan`, `claude-code-guide`, `statusline-setup`. |

### Web & Research
| Tool | Purpose |
|------|---------|
| **WebFetch** | Fetch a URL, convert HTML→markdown, and process with AI. Good for APIs, docs, web pages. |
| **WebSearch** | Search the web for current information. Returns links and summaries. |

### Interaction & Planning
| Tool | Purpose |
|------|---------|
| **AskUserQuestion** | Present questions with selectable options to the user. Supports multi-select and previews. |
| **TodoWrite** | Create/update a structured task list to track progress on multi-step work. |
| **ExitPlanMode** | Signal that a plan is ready for user approval (plan mode only). |

### Skills (User-Invocable)
| Skill | Trigger |
|-------|---------|
| **simplify** | Review changed code for quality, reuse, efficiency. |
| **claude-api** | Build apps with Claude/Anthropic SDK. Triggers on `anthropic` imports. |
| **session-start-hook** | Set up SessionStart hooks for Claude Code on the web. |

---

## Agent Sub-Types

| Type | Use Case | Tools Available |
|------|----------|-----------------|
| **general-purpose** | Research, search, multi-step tasks | All tools |
| **Explore** | Fast codebase exploration, file/keyword search | All except Agent, Edit, Write, NotebookEdit |
| **Plan** | Design implementation strategies, architecture | All except Agent, Edit, Write, NotebookEdit |
| **claude-code-guide** | Answer questions about Claude Code, Agent SDK, Claude API | Glob, Grep, Read, WebFetch, WebSearch |
| **statusline-setup** | Configure status line settings | Read, Edit |

---

## Environment-Specific Notes

### Git
- Remote: `HouseofAllen/dynasty-os` (GitHub, via local proxy)
- Branch: `master` (single branch detected)
- `gh` CLI: **not available** in this environment
- Git operations: push/pull/fetch via `git` command

### Platform
- OS: Linux 4.4.0
- Shell: bash
- Model: Claude Opus 4.6

### HouseofAllen Repos (verified 2026-03-07)
| Repo | Visibility |
|------|-----------|
| `landing-pages` | Private |
| `DynastyOS` | Private |
| `AgentOS` | Private |
| `The_Akashic_Record` | Private |
| `dynasty-os` | Public |
| `mission-control` | Private |

- **"AgentOS"** exists but is **private** — not accessible via API or WebFetch without auth
- **"voidphoenix":** Not found in repo list — may be a different name, different account, or not yet created
- **Note:** WebFetch/WebSearch can only see public repos. Private repos require authenticated `gh` CLI (not available here)

---

## What Else Goes Here

Things like:
- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.
