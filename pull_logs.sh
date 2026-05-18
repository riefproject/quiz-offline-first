#!/bin/bash
# pull_logs.sh — Pull debug logs from Android device to laptop
# Usage: ./pull_logs.sh [output_dir]

PACKAGE="com.example.py_4"
REMOTE_PATH="/data/data/${PACKAGE}/app_flutter/kahoof_debug.log"
OUTPUT_DIR="${1:-.}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_DIR}/kahoof_debug_${TIMESTAMP}.log"

if ! command -v adb &> /dev/null; then
  echo "Error: adb not found. Install Android SDK platform-tools."
  exit 1
fi

echo "Pulling logs from device..."
adb shell "run-as ${PACKAGE} cat ${REMOTE_PATH}" > "${OUTPUT_FILE}" 2>/dev/null

if [ $? -eq 0 ] && [ -s "${OUTPUT_FILE}" ]; then
  echo "Saved to ${OUTPUT_FILE} ($(wc -l < "${OUTPUT_FILE}") lines)"
else
  echo "No logs found or device not connected. Trying alternate method..."
  adb shell "cat ${REMOTE_PATH}" > "${OUTPUT_FILE}" 2>/dev/null
  if [ -s "${OUTPUT_FILE}" ]; then
    echo "Saved to ${OUTPUT_FILE} ($(wc -l < "${OUTPUT_FILE}") lines)"
  else
    echo "Could not retrieve logs. Check device connection and app status."
    rm -f "${OUTPUT_FILE}"
    exit 1
  fi
fi
