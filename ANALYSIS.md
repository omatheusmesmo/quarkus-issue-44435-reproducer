# Issue #44435 - Analysis and Evidence

## Problem Statement

GraalVM PR [#10030](https://github.com/oracle/graal/pull/10030) (merged Nov 2024) adds detection of `System.getProperty("java.home")` calls during native image build.

**The Issue**: Quarkus AWT extension has a workaround that may conflict with this new GraalVM feature.

## Current Quarkus Workaround

File: `extensions/awt/runtime/src/main/java/io/quarkus/awt/runtime/JDKSubstitutions.java`

```java
@TargetClass(className = "sun.awt.FontConfiguration", onlyWith = IsLinux.class)
final class Target_sun_awt_FontConfiguration_Linux {
    @Substitute
    protected void setOsNameAndVersion() {
        // Creates fake java.home in tmp dir
        final Path javaHome = Path.of(System.getProperty("java.io.tmpdir"),
                                       "quarkus-awt-tmp-fonts");
        System.setProperty("java.home", javaHome.toString());
        // ... creates directory structure
    }
}
```

## Evidence from Reproducer

### 1. GraalVM Detection (Build Time)

When building with GraalVM 24.0.2+:

```
Recommendations:
 HOME: To avoid errors, provide java.home to the app with '-Djava.home=<path>'.
```

This shows GraalVM detected `java.home` access during analysis.

### 2. Quarkus Workaround (Runtime)

When running the native executable, access the `/fonts` endpoint:

```bash
./target/reproducer-44435-*-runner &
curl http://localhost:8080/fonts
```

Output shows:
```
java.home: /tmp/quarkus-awt-tmp-fonts
✓ Quarkus AWT workaround ACTIVE
  (Fake java.home created by JDKSubstitutions)
```

## The Conflict

### Before PR #10030 (Old Behavior)
- GraalVM didn't warn about `java.home` access
- Quarkus workaround worked silently
- No issues

### After PR #10030 (New Behavior)
- GraalVM **warns** about `java.home` access
- Recommends: "provide java.home to the app"
- Quarkus workaround still works, but GraalVM shows warning

## Questions Raised by Issue #44435

1. **Should we suppress the GraalVM warning?**
   - The workaround is intentional
   - Warning might confuse users

2. **Should we adjust the workaround?**
   - GraalVM now provides recommendations
   - Maybe use GraalVM's approach instead?

3. **Should we substitute differently?**
   - Issue suggests substituting `FontConfiguration.findFontConfigFile()`
   - Instead of `setOsNameAndVersion()`

## Testing Scenarios

### Scenario 1: JVM Mode
```bash
./mvnw quarkus:dev
curl http://localhost:8080/fonts
```
Works fine. Uses real java.home.

### Scenario 2: Native Mode (with workaround)
```bash
./mvnw package -Dnative
./target/reproducer-44435-*-runner
curl http://localhost:8080/fonts
```
Works. Uses fake java.home from Quarkus substitution.

### Scenario 3: Native Mode (without workaround)
If we remove the Quarkus substitution, AWT font initialization might fail because:
- Native image doesn't have full JDK directory structure
- FontConfiguration expects `java.home/lib/fonts` etc.

## How to Reproduce

1. **Enter the reproducer directory** (SDKMAN auto-switches to GraalVM 24.0.2):
   ```bash
   cd reproducer-44435
   ```

2. **Build native image**:
   ```bash
   ./mvnw package -Dnative
   ```

3. **Check build output** for GraalVM warning:
   ```
   grep "HOME:" build-output.log
   ```

4. **Run and test**:
   ```bash
   ./target/reproducer-44435-*-runner &
   curl http://localhost:8080/fonts
   ```

5. **Verify Quarkus workaround**:
   Output should show: `/tmp/quarkus-awt-tmp-fonts`

## Conclusion

The reproducer demonstrates:
- ✅ GraalVM 24.0.2 detects `java.home` access (PR #10030 working)
- ✅ Quarkus AWT workaround still functions correctly
- ⚠️ GraalVM shows warning/recommendation about `java.home`
- ❓ The issue asks: should we adjust the workaround?

## Next Steps

Per issue discussion:
1. Test with GraalVM PR #10030 merged ✅ (done)
2. Evaluate if warning should be suppressed
3. Consider alternative approach (substitute `findFontConfigFile` instead)
4. Wait for feedback from Quarkus maintainers
