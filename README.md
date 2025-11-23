# summarize-standups

**❗️NOTE❗️**: This project is mostly outdated now that coding agents like Claude Code, etc. are a thing.

**summarize-standups** is a small [Janet](https://janet-lang.org/) script that extracts stand-up logs from [Obsidian](https://obsidian.md/) daily notes, summarizes them with an LLM, and writes out a clean weekly summary per team member.

It's designed to support team leads who:
- Use Obsidian to track daily standups
- Want lightweight weekly summaries for reviews or retros
- Prefer scripting tools that are fast, minimalist, and REPL-friendly

---

## ✨ What it does

- Reads `.md` files from a folder of Obsidian daily notes
- Extracts the `## Standup` section from each day's file
- Groups all updates by team member across the week
- Sends the grouped content to a local LLM (via [Fabric](https://github.com/gggervais/fabric))
- Writes a weekly summary file to disk

---

## 📁 Expected folder structure

Your Obsidian daily notes should be organized by date, like:

```text
~/vault/periodic/daily/
├── 2024/
│   └── 12/
│       ├── 2024-12-10.md
│       ├── 2024-12-11.md
```

Each `.md` file should include a section like:

```markdown
## Standup

### Alex
- Investigated integration issues in the payment service

### Taylor
- Implemented pagination in the dashboard UI

### Jordan
- On PTO

---
```

---

## 🧑‍💻 Installation

Requires:
- [Janet](https://janet-lang.org/)
- [Fabric](https://github.com/gggervais/fabric) installed and configured with a `summarize_standups` pattern

Clone the repo:

```bash
git clone https://github.com/glpayson/summarize-standups
cd summarize-standups
```

Set required environment variables:

```bash
export DAILIES_DIR=~/vault/periodic/daily
export SPRINTS_DIR=~/vault/summaries
```

---

## 🚀 Usage

To generate a summary for Nov 24 through Dec 16:

```bash
janet summarize-standups.janet 11/24 12/16
```

This will produce something like:

```text
~/vault/summaries/2024-12-16-summary.md
```

---


## ⚙️ Notes

- Date inputs can be in `MM/DD` or `YYYY/MM/DD` format.
- If no year is specified, the current year is assumed (with logic to handle year rollover for late December to early January).
- Files are expected to be named `YYYY-MM-DD.md`.


---

## 🛍️ Future ideas

- Slack or email integration
- Support for other Obsidian section formats (callouts, tags, etc.)
- Switching LLM backends

---

## 👥 License

MIT
