#!/usr/bin/env python3
"""
Overnight File Loader for Case Repository
Purpose: Load files from local OneDrive ticket work directory into case repository
Date: 2026-02-27
"""

import os
import shutil
import logging
from pathlib import Path
from datetime import datetime
import zipfile
import json

# Configuration
SOURCE_DIR = r"C:\Users\Kylie.Dare\OneDrive - MYOB\Documents\!!!_Ticket Work"
REPO_DIR = os.getcwd()  # Local repository directory
CASES_DIR = os.path.join(REPO_DIR, "cases")
LOG_DIR = os.path.join(REPO_DIR, "logs")
LOG_FILE = os.path.join(LOG_DIR, f"load_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log")

# Configure logging
os.makedirs(LOG_DIR, exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


def normalize_case_name(name):
    """Convert ticket names to case folder format"""
    # Remove special characters and spaces, create case name
    clean_name = name.strip().upper()
    # For ticket numbers like CE00064372, use as-is; for others, create slug
    if clean_name.startswith('CE'):
        return f"case-{clean_name}"
    else:
        slug = clean_name.replace(' ', '-').replace('_', '-')
        slug = ''.join(c for c in slug if c.isalnum() or c == '-').lower()
        return f"case-{slug}"


def create_case_structure(case_name, case_path):
    """Create the standard case folder structure"""
    required_dirs = ['scripts', 'notes']
    for dir_name in required_dirs:
        dir_path = os.path.join(case_path, dir_name)
        os.makedirs(dir_path, exist_ok=True)
    
    # Create README if it doesn't exist
    readme_path = os.path.join(case_path, 'README.md')
    if not os.path.exists(readme_path):
        with open(readme_path, 'w') as f:
            f.write(f"""# {case_name}

**Date Created**: {datetime.now().strftime('%Y-%m-%d')}  
**Status**: ACTIVE  
**Source**: Automated overnight load from MYOB OneDrive  

## Overview

Case loaded from ticket work directory.

## Contents

- **Scripts**: Loaded scripts and diagnostics
- **Notes**: Documentation and configuration files

## Load Date

Loaded on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

""")
    logger.info(f"Created case structure: {case_path}")


def extract_zip_files(case_path, source_folder):
    """Extract zip files to a 'archives' subfolder within case"""
    archives_dir = os.path.join(case_path, 'archives')
    os.makedirs(archives_dir, exist_ok=True)
    
    for item in os.listdir(source_folder):
        item_path = os.path.join(source_folder, item)
        
        if item.endswith('.zip'):
            try:
                extract_to = os.path.join(archives_dir, item.replace('.zip', ''))
                os.makedirs(extract_to, exist_ok=True)
                with zipfile.ZipFile(item_path, 'r') as zip_ref:
                    zip_ref.extractall(extract_to)
                logger.info(f"Extracted: {item} to {extract_to}")
                # Also keep original zip
                shutil.copy2(item_path, os.path.join(archives_dir, item))
            except Exception as e:
                logger.error(f"Failed to extract {item}: {e}")


def copy_files(case_path, source_folder):
    """Copy files to appropriate directories"""
    scripts_dir = os.path.join(case_path, 'scripts')
    notes_dir = os.path.join(case_path, 'notes')
    
    for item in os.listdir(source_folder):
        item_path = os.path.join(source_folder, item)
        
        if os.path.isfile(item_path):
            if item.endswith(('.txt', '.md', '.log', '.doc', '.docx')):
                # Copy documentation to notes
                dest = os.path.join(notes_dir, item)
                shutil.copy2(item_path, dest)
                logger.info(f"Copied to notes: {item}")
            elif item.endswith(('.py', '.ps1', '.sh', '.bat', '.sql')):
                # Copy scripts to scripts
                dest = os.path.join(scripts_dir, item)
                shutil.copy2(item_path, dest)
                logger.info(f"Copied to scripts: {item}")
            elif item.endswith('.zip'):
                # Skip zips here, handled separately
                pass
            else:
                # Copy other files to scripts by default
                dest = os.path.join(scripts_dir, item)
                shutil.copy2(item_path, dest)
                logger.info(f"Copied to scripts: {item}")


def process_directory(source_path, parent_case=None):
    """Recursively process directory structure"""
    try:
        if not os.path.exists(source_path):
            logger.error(f"Source path does not exist: {source_path}")
            return
        
        for item in os.listdir(source_path):
            item_path = os.path.join(source_path, item)
            
            if os.path.isdir(item_path):
                # Skip certain directories
                if item.startswith('.'):
                    continue
                
                # Create case name
                case_name = normalize_case_name(item)
                case_path = os.path.join(CASES_DIR, case_name)
                
                logger.info(f"Processing: {item} -> {case_name}")
                
                # Create case structure
                create_case_structure(case_name, case_path)
                
                # Check if this directory contains files directly
                has_files = False
                for sub_item in os.listdir(item_path):
                    sub_path = os.path.join(item_path, sub_item)
                    if os.path.isfile(sub_path):
                        has_files = True
                        break
                
                if has_files:
                    # Process files in this directory
                    copy_files(case_path, item_path)
                    extract_zip_files(case_path, item_path)
                else:
                    # Recurse into subdirectories
                    process_directory(item_path, case_name)
        
        logger.info("Load process completed successfully")
        
    except Exception as e:
        logger.error(f"Error processing directory: {e}")


def create_load_report():
    """Create a summary report of the load"""
    report_path = os.path.join(REPO_DIR, 'LOAD_REPORT.md')
    with open(report_path, 'w') as f:
        f.write(f"""# Overnight Load Report

**Load Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Source**: {SOURCE_DIR}  
**Destination**: {CASES_DIR}  

## Summary

Files have been loaded from the Ticket Work directory into organized case folders.

## Cases Created

""")
        
        # List created cases
        if os.path.exists(CASES_DIR):
            for case in sorted(os.listdir(CASES_DIR)):
                case_path = os.path.join(CASES_DIR, case)
                if os.path.isdir(case_path):
                    f.write(f"- `{case}/`\n")
    
    logger.info(f"Load report created: {report_path}")


def main():
    """Main function"""
    logger.info("=" * 60)
    logger.info("Starting Overnight File Load Process")
    logger.info("=" * 60)
    logger.info(f"Source Directory: {SOURCE_DIR}")
    logger.info(f"Repository Directory: {REPO_DIR}")
    
    try:
        process_directory(SOURCE_DIR)
        create_load_report()
        logger.info("=" * 60)
        logger.info("Overnight load process completed successfully")
        logger.info("=" * 60)
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        return 1
    
    return 0


if __name__ == "__main__":
    exit(main())