#!/bin/bash

# Reproducer for Quarkus Issue #44435
# Tests java.home detection in AWT extension during native build

set -e

echo "=================================================="
echo "Quarkus Issue #44435 Reproducer"
echo "Testing GraalVM java.home detection in AWT"
echo "=================================================="
echo ""

# Check SDKMAN
if [ ! -d "$HOME/.sdkman" ]; then
    echo "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Function to check GraalVM
check_graalvm() {
    if command -v gu &> /dev/null; then
        echo "✓ GraalVM detected: $(java -version 2>&1 | head -1)"
        return 0
    else
        echo "✗ GraalVM not found"
        return 1
    fi
}

# Install GraalVM via SDKMAN if needed
install_graalvm() {
    echo "Installing GraalVM via SDKMAN..."
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk install java 21.0.2-graal || true
    sdk use java 21.0.2-graal
    gu install native-image
}

# Menu
echo "Choose an option:"
echo "1) Run in JVM mode (quick test)"
echo "2) Build native image (check for warnings)"
echo "3) Full test (JVM + Native)"
echo ""
read -p "Option: " option

case $option in
    1)
        echo "Starting in dev mode..."
        ./mvnw quarkus:dev
        ;;
    2)
        if ! check_graalvm; then
            install_graalvm
        fi

        echo ""
        echo "Building native image..."
        echo "This may take a few minutes..."
        echo ""

        # Build and capture output
        ./mvnw package -Pnative 2>&1 | tee native-build.log

        echo ""
        echo "=================================================="
        echo "Checking for java.home warnings..."
        echo "=================================================="

        if grep -i "System.getProperty.*java.home" native-build.log; then
            echo ""
            echo "✓ SUCCESS: Found java.home warnings!"
            echo "This reproduces the issue described in #44435"
        else
            echo ""
            echo "ℹ No java.home warnings found"
            echo "This could mean:"
            echo "  - Using older GraalVM (need PR #10030)"
            echo "  - Quarkus substitution is working"
            echo "  - Check native-build.log for details"
        fi
        ;;
    3)
        echo "Running full test suite..."

        # JVM test
        echo ""
        echo "=== JVM Mode Test ==="
        ./mvnw test

        # Native build
        if ! check_graalvm; then
            install_graalvm
        fi

        echo ""
        echo "=== Native Build ==="
        ./mvnw package -Pnative -DskipTests 2>&1 | tee native-build.log

        # Check warnings
        echo ""
        echo "=== Results ==="
        grep -i "java.home" native-build.log || echo "No warnings found"
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac
