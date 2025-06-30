#!/bin/bash
LOG_FILE="create_test_cases_$(date +%Y%m%d%H%M).log"

./create_test_cases.sh "advocate@example.com" "34" "12" "POFBPPCOC_12.2" "8010101012" "true" "2025-06-09" "1" "1" "Leading junior" "FIRST" "SMITH" "1954-06-19" "2025-06-09" "2161851" "1" "0" "BABAF" >> "$LOG_FILE" 2>&1

echo "Log file created: $LOG_FILE"