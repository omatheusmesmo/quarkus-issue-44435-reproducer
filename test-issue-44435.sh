#!/bin/bash

# Test script for Quarkus Issue #44435
# Run this script to generate test logs and summary

set -e

echo "=================================================="
echo "Quarkus Issue #44435 - Test Script"
echo "=================================================="
echo ""
echo "This script will:"
echo "1. Build native image"
echo "2. Test /fonts endpoint (AWT)"
echo "3. Test /javahome endpoint (explicit)"
echo "4. Generate logs/"
echo ""

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="logs/test-${TIMESTAMP}.log"
SUMMARY_FILE="logs/summary-${TIMESTAMP}.txt"

mkdir -p logs

echo "Building native image..."
./mvnw clean package -Dnative -DskipTests 2>&1 | tee "$LOG_FILE"

echo ""
echo "Starting application..."
RUNNER=$(find target -name "*-runner" -type f -executable | head -1)
$RUNNER > /tmp/runner.log 2>&1 &
RUNNER_PID=$!

sleep 10

echo "Testing endpoints..."
curl -s http://localhost:8080/fonts > /tmp/fonts.txt
curl -s http://localhost:8080/javahome > /tmp/javahome.txt

kill $RUNNER_PID 2>/dev/null || true

echo ""
echo "Logs generated:"
echo "  - $LOG_FILE"
echo "  - $SUMMARY_FILE (will be created by analyzing logs)"
echo ""
echo "Done!"
