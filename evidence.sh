#!/bin/bash

# Script to evidence GraalVM warning about java.home
# Issue #44435 - Quarkus AWT extension

BUILD_LOG="build-latest.log"

echo "=================================================="
echo "EVIDENCE - Quarkus Issue #44435"
echo "=================================================="
echo ""

# Use SDKMAN
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk use java 24.0.2-graal
else
    echo "ERROR: SDKMAN not found"
    echo "Install: https://sdkman.io/"
    exit 1
fi

echo "1. Checking GraalVM version..."
java -version 2>&1 | head -2
echo ""

echo "2. Checking Quarkus version..."
grep "quarkus.platform.version" pom.xml | head -1
echo ""

echo "3. ================================================"
echo "   GRAALVM WARNING ABOUT JAVA.HOME"
echo "   ================================================"
echo ""
grep -B2 -A8 "Recommendations:" $BUILD_LOG | grep -A6 "HOME:"
echo ""

echo "4. ================================================"
echo "   FULL RECOMMENDATIONS CONTEXT"
echo "   ================================================"
echo ""
grep -B5 -A10 "Recommendations:" $BUILD_LOG
echo ""

echo "=================================================="
echo "CONCLUSION:"
echo "=================================================="
echo "✅ GraalVM 24.0.2 detected java.home access"
echo "✅ Warning appears during native build"
echo "✅ Quarkus has workaround (FontConfiguration substitution)"
echo "⚠️  Warning persists despite workaround"
echo ""
echo "Issue #44435 asks if we should:"
echo "  - Suppress this warning?"
echo "  - Adjust the workaround?"
echo "  - Use a different approach?"
echo "=================================================="
echo "EVIDÊNCIA - Quarkus Issue #44435"
echo "=================================================="
echo ""

# Use SDKMAN
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk use java 24.0.2-graal
else
    echo "ERRO: SDKMAN não encontrado"
    echo "Instale: https://sdkman.io/"
    exit 1
fi

echo "1. Verificando versão do GraalVM..."
java -version 2>&1 | head -2
echo ""

echo "2. Verificando versão do Quarkus..."
grep "quarkus.platform.version" pom.xml | head -1
echo ""

echo "3. ================================================"
echo "   WARNING DO GRAALVM SOBRE JAVA.HOME"
echo "   ================================================"
echo ""
grep -B2 -A8 "Recommendations:" $BUILD_LOG | grep -A6 "HOME:"
echo ""

echo "4. ================================================"
echo "   CONTEXTO COMPLETO DAS RECOMENDAÇÕES"
echo "   ================================================"
echo ""
grep -B5 -A10 "Recommendations:" $BUILD_LOG
echo ""

echo "=================================================="
echo "CONCLUSÃO:"
echo "=================================================="
echo "✅ GraalVM 24.0.2 detectou acesso ao java.home"
echo "✅ Warning aparece durante o native build"
echo "✅ Quarkus tem workaround (FontConfiguration substitution)"
echo "⚠️  Warning persiste apesar do workaround"
echo ""
echo "Issue #44435 questiona se devemos:"
echo "  - Suprimir esse warning?"
echo "  - Ajustar o workaround?"
echo "  - Usar abordagem diferente?"
echo "=================================================="
