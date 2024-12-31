# summarize-standups

This is a small script I wrote while learning [Janet](https://janet-lang.org/) <img src="https://github.com/user-attachments/assets/13452c87-dadb-40c3-9825-2022037c6d59" alt="janet-script" width="30px" />
. It reads all daily markdown files in my [Obsidian](https://obsidian.md/) vault, extracts standup notes, summarizes them using [Fabric](https://github.com/danielmiessler/fabric) and writes the summary to a new markdown file in the Obsidian vault. 

## Setup

Requires that the following environment variables are set:
- `DAILIES_DIR` - The location in the Obsidian vault where dailies are stored. Dailies must be stored in YYYY/MM/YYYY-MM-DD.md directory and file structure.
- `SPRINTS_DIR` - The location to write the summaries. Summary output files are titles YYYY-MM-DD-summary.md, where YYYY-MM-DD is the end date input (see Usage).

## Usage
e.g.: `./summarize-standups.janet 11/24 12/15`
