#!/bin/bash

# setup_project.sh - Automated Project Bootstrapping Script
# Student Attendance Tracker - Project Factory

# ---- Color Definitions ----
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' 

#Declaring global variable
project_dir=""

#TRAP HANDLER - Catches SIGINT (Ctrl+C)

signal-trap() { 
    echo ""
    echo e- "${RED}Scrip interupted!${NC}"
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

