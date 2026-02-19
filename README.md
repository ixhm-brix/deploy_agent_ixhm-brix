# Student Attendance Tracker — Automated Project Setup

A shell script that automates the creation of a complete Student Attendance Tracker workspace. It builds the directory structure, generates all source files, lets you configure thresholds from the command line, and handles interruptions.

## Prerequisites

- **Bash** 
- **Python 3** (for running the attendance checker after setup)

## How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/ixhm-brix/deploy_agent_ixhm-brix.git
   cd deploy_agent_ixhm-brix.git
   ```

2. Make the script executable:
   ```bash
   chmod +x setup_project.sh
   ```

3. Run the script:
   ```bash
   ./setup_project.sh
   ```

4. Follow the prompts:
   - **Enter a project identifier** — for example `v1`, `cohort2`, or `team_alpha`. This creates a directory named `attendance_tracker_<your_input>/`
   - **Update thresholds (optional)** — if you choose `y`, you can enter new Warning and Failure percentages. The script uses `sed` to edit `config.json` in-place. Press Enter to keep defaults (Warning: 75%, Failure: 50%)

5. After setup, run the attendance checker:
   ```bash
   cd attendance_tracker_<your_input>
   python3 attendance_checker.py
   ```

## Generated Directory Structure

```
attendance_tracker_<input>/
├── attendance_checker.py       # Main Python application
├── Helpers/
│   ├── assets.csv              # Student attendance data
│   └── config.json             # Configurable thresholds
└── reports/
    └── reports.log             # Generated attendance reports
```

## How to Trigger the Archive Feature (Ctrl+C Trap)

The script implements a **signal trap** for `SIGINT` (Ctrl+C). If you interrupt the script at any point during execution:

1. The script catches the signal instead of terminating abruptly
2. It bundles the current state of the project directory into a compressed archive named `attendance_tracker_<input>_archive.tar.gz`
3. It deletes the incomplete directory to keep your workspace clean

## Script Features

- **Directory Creation** — Creates the full project tree with `mkdir -p`
- **File Generation** — Embeds all source files using heredocs, making the script self-contained
- **Dynamic Config** — Uses `read` to capture new thresholds and `sed -i` to edit `config.json` in-place
- **Signal Trap** — Catches `SIGINT` (Ctrl+C), archives with `tar -czf`, and cleans up with `rm -rf`
- **Health Check** — Verifies `python3` is installed and validates the complete directory structure

## Repository Contents

- **`setup_project.sh`** — The master shell script that creates the project, configures it, and handles signals
- **`README.md`** — This file, explains how to run the script and use the archive feature

## Walkthrough Video

[Walkthrough Video](https://drive.google.com/file/d/1tTqBq9257ORDsw19Gdw9QVyMqeDbY8vr/view?usp=drive_link)


