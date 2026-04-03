#!/bin/bash

# Simple validation script for Issue #44435 reproducer

set -e

echo "=================================================="
echo "Quarkus Issue #44435 - java.home Detection"
echo "=================================================="
echo ""

# Check if SDKMAN is available
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"

    # Use GraalVM from .sdkmanrc
    if [ -f ".sdkmanrc" ]; then
        echo "✓ Found .sdkmanrc, SDKMAN will auto-switch Java version"
        echo "  Java version: $(grep 'java=' .sdkmanrc | cut -d= -f2)"
    fi
else
    echo "⚠ SDKMAN not found. Please install: https://sdkman.io/"
    exit 1
fi

echo ""
echo "Checking GraalVM installation..."
if java -version 2>&1 | grep -q "GraalVM"; then
    echo "✓ GraalVM detected: $(java -version 2>&1 | head -1)"
else
    echo "✗ GraalVM not in use. Current Java: $(java -version 2>&1 | head -1)"
    echo "  Run: sdk use java 24.0.2-graal"
    exit 1
fi

echo ""
echo "=================================================="
echo "Building Native Image..."
echo "=================================================="
echo ""

# Build native image
./mvnw package -Dnative 2>&1 | tee build.log

echo ""
echo "=================================================="
echo "Checking for java.home Detection..."
echo "=================================================="
echo ""

if grep -q "HOME:.*java.home" build.log; then
    echo "✓ SUCCESS: GraalVM detected java.home access!"
    echo ""
    grep "HOME:" build.log
    echo ""
    echo "This reproduces the issue from #44435"
    echo "The Quarkus AWT extension workarounds may need adjustment."
else
    echo "ℹ No java.home warning found"
    echo "This could mean Quarkus substitution is preventing detection"
fi

echo ""
echo "=================================================="
echo "Build log saved to: build.log"
echo "=================================================="
