# Quarkus Issue #44435 - Reproducer

Standalone reproducer for [Issue #44435](https://github.com/quarkusio/quarkus/issues/44435)

## Evidence

When building with GraalVM 25.0.2, the following warning appears:

```
Recommendations:
 HOME: To avoid errors, provide java.home to the app with '-Djava.home=<path>'.
```

This confirms that GraalVM's PR #10030 is detecting `java.home` access during native image build.

## Quick Start

```bash
# 1. Enter directory (SDKMAN auto-switches to GraalVM 25.0.2)
cd reproducer-44435

# 2. Build native image
./mvnw clean package -Dnative -DskipTests

# 3. View evidence
./evidence.sh
```

## Problem Statement

GraalVM PR [#10030](https://github.com/oracle/graal/pull/10030) (merged Nov 2024) added detection of `System.getProperty("java.home")` calls during native image build.

**The Issue**: Quarkus AWT extension has a workaround that:
- Creates fake `java.home` in `/tmp/quarkus-awt-tmp-fonts`
- Substitutes `sun.awt.FontConfiguration.setOsNameAndVersion()`
- Works at runtime, but GraalVM still detects the access during build time analysis

## What Gets Tested

1. **GraalVM Detection**: Native build shows `HOME:` recommendation
2. **Quarkus Workaround**: Runtime shows fake `java.home` being used
3. **Conflict**: Warning persists despite workaround

## Questions Raised

- Should we **suppress** this GraalVM warning?
- Should we **adjust** the Quarkus workaround?
- Should we use a **different approach** (substitute `findFontConfigFile` instead)?

## Files

- **`.sdkmanrc`** - Uses GraalVM 25.0.2 (latest with PR #10030)
- **`FontResource.java`** - Tests AWT fonts
- **`evidence.sh`** - Extracts and shows the warning
- **`ANALYSIS.md`** - Detailed analysis of the problem

## Versions

- Quarkus: 3.34.2
- GraalVM: 25.0.2 (Oracle)
- Java: 25.0.2

## See Also

- Issue: https://github.com/quarkusio/quarkus/issues/44435
- GraalVM PR: https://github.com/oracle/graal/pull/10030
- Quarkus Workaround: `extensions/awt/runtime/src/main/java/io/quarkus/awt/runtime/JDKSubstitutions.java`
