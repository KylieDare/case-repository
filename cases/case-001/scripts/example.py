#!/usr/bin/env python3
"""
Script name: example.py
Case: 001
Purpose: Example Python script demonstrating basic structure
Author: Agent
Date: 2026-02-27
"""

import sys
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def main():
    """Main function"""
    logger.info("Starting example script")
    print("This is an example Python script")
    logger.info("Script completed successfully")


if __name__ == "__main__":
    main()