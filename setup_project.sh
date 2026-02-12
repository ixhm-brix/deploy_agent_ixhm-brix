#!/bin/bash

# setup_project.sh - Automated Project Bootstrapping Script
# Student Attendance Tracker - Project Factory

# Color 
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' 

#Declaring global variable
project_dir=""

#TRAP HANDLER - Catches SIGINT (Ctrl+C)

signal-trap() { 
    echo ""
    echo -e "${RED}Script interrupted!${NC}"
    echo "bundling the current state of the project directory into an archive .... "
    if [ -d "$project_dir" ]; then 
        archive_dir="${project_dir}_archive"
        tar -czf "${archive_dir}.tar.gz" "$project_dir" 2>/dev/null
        echo -e "${GREEN}Archive created: ${archive_dir}.tar.gz${NC}"
        #removing uncomplete directory
        rm -rf "$project_dir"
        echo -e "${GREEN}Incomplete directory '${project_dir}' has been removed.${NC}"
    else
       echo -e "${RED}NO project directory to archive ${NC}"
    fi

    exit 1   
    
}
trap signal-trap SIGINT

# Get user input for directory name
read -p "Enter a project identifier (e.g., c1, cohort2): " project_id
if [ -z "$project_id" ]; then
   echo -e "${RED}No input provided. Exiting ${NC}" 
   exit 1
fi
project_dir="attendance_tracker_${project_id}"
if [ -d "$project_dir" ]; then
    echo -e "Warning: Directory '${project_dir}' already exists."
    exit 1
    
fi
#Creating Directory Architecture
echo ""
echo "===creating ridectory strature==="
mkdir -p "$project_dir/Helpers"
mkdir -p "$project_dir/reports"

cat > "$project_dir/attendance_checker.py" << 'PYEOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
PYEOF
echo -e "${GREEN}attendance_checker.py Created${NC}"  

cat > "$project_dir/Helpers/assets.csv" << 'CSVEOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
CSVEOF
echo -e "${GREEN}assets.csv Created${NC}"    

cat > "$project_dir/Helpers/config.json" << 'JSONEOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
JSONEOF
echo -e "${GREEN}config.json created${NC}"

cat > "$project_dir/reports/reports.log" << 'LOGEOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
LOGEOF
echo -e "${GREEN}reports.log Created${NC}" 

#Dynamic Configuration(reports.config)

echo ""
echo "Dynamic Configuration"
echo ""
read -p "Do you want to update attendance thresholds? (y/n): " update_config
if [ "$update_config" = "y" ]; then   
echo ""
echo "Current thresholds: Warning = 75%, Failure = 50%"
echo ""
read -p "Enter new Warning threshold (default 75): " new_warning
read -p "Enter new Failure threshold (default 50): " new_failure
# Use defaults if empty
new_warning=${new_warning:-75}
new_failure=${new_failure:-50}
 # Validate that inputs are numbers
 if ! [[ "$new_warning" =~ ^[0-9]+$ ]] || ! [[ "$new_failure" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: Thresholds must be numeric values. Using defaults.${NC}"
    new_warning=75
    new_failure=50
fi

# Use sed for in-place editing of config.json
sed -i "s/\"warning\": [0-9]*/\"warning\": $new_warning/" "$project_dir/Helpers/config.json"
sed -i "s/\"failure\": [0-9]*/\"failure\": $new_failure/" "$project_dir/Helpers/config.json"

echo ""
echo -e "${GREEN}    Updated config.json:${NC}"
echo -e "${GREEN}    Warning threshold: ${new_warning}%${NC}"
echo -e "${GREEN}    Failure threshold: ${new_failure}%${NC}"
else
    echo -e "Skipped. Using default thresholds (Warning: 75%, Failure: 50%)."
fi

#Environment Validation (Health Check)
echo ""
echo "Environment Validation (Health Check)"
echo ""
echo "Running health check ......"
#ptyhon avialability check
echo "Checking for Python3..."
if python3 --version ; then
  py_version=$(python3 --version 2>&1)
  echo -e "${GREEN} python3 is intalled. ${py_version}${NC} "
else  
  echo -e "${RED}  WARNING: Python3 is NOT installed on this system.${NC}"
  echo -e "${RED} PLEASE install to run The attendance_checker.py ${NC}"
  fi
#validity of files structure
exists=true
  
if [ ! -f "$project_dir/attendance_checker.py" ]; then
    echo -e "${RED}   Missing: attendance_checker.py${NC}"
    exists=false
fi

if [ ! -d "$project_dir/Helpers" ]; then
    echo -e "${RED}   Missing: Helpers/${NC}"
    exists=false
fi

if [ ! -f "$project_dir/Helpers/assets.csv" ]; then
    echo -e "${RED}   Missing: Helpers/assets.csv${NC}"
    exists=false
fi

if [ ! -f "$project_dir/Helpers/config.json" ]; then
    echo -e "${RED}   Missing: Helpers/config.json${NC}"
    exists=false
fi

if [ ! -d "$project_dir/reports" ]; then
    echo -e "${RED}   Missing: reports/${NC}"
    exists=false
fi

if [ ! -f "$project_dir/reports/reports.log" ]; then
    echo -e "${RED}   Missing: reports/reports.log${NC}"
    exists=false
fi

if [ "$exists" = true ]; then
    echo -e "${GREEN}   All files and directories are in place.${NC}"
else
    echo -e "${RED}   Some files or directories are missing!${NC}"
fi


