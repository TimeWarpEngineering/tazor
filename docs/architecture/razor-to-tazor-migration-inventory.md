# .tazor to .tazor Migration Inventory

**Date**: 2025-11-03
**Purpose**: Complete inventory of all `.tazor` references in the codebase to guide the file extension migration from `.tazor` to `.tazor`.

**Total References Found**: ~1,900+ string literal references to `.tazor`

---

## CRITICAL CHANGES (Must Change First)

These are the core constant definitions and logic that control file processing. **Change these first before anything else.**

### 1. Core Extension Constants

| File | Line | Current Code | New Code | Priority |
|------|------|--------------|----------|----------|
| `src/Compiler/Microsoft.CodeAnalysis.Razor.Compiler/src/Language/FileKinds.cs` | 12 | `private const string ComponentFileExtension = ".tazor";` | `".tazor"` | 🔴 CRITICAL |
| `src/Shared/Microsoft.AspNetCore.Razor.Utilities.Shared/FileUtilities.cs` | 12 | `private const string RazorExtension = ".tazor";` | `".tazor"` | 🔴 CRITICAL |

### 2. Import File Name Constants

| File | Line | Current Code | New Code | Priority |
|------|------|--------------|----------|----------|
| `src/Compiler/Microsoft.CodeAnalysis.Razor.Compiler/src/Language/Components/ComponentHelpers.cs` | 10 | `public const string ImportsFileName = "_Imports.tazor";` | `"_Imports.tazor"` | 🔴 CRITICAL |
| `src/Shared/Microsoft.AspNetCore.Razor.Test.Common/Language/TestImportProjectFeature.cs` | 22 | `private const string DefaultImportsFileName = "_Imports.tazor";` | `"_Imports.tazor"` | 🔴 CRITICAL |

### 3. Source Generator File Filtering

**File**: `src/Compiler/Microsoft.CodeAnalysis.Razor.Compiler/src/SourceGenerators/RazorSourceGenerator.cs`

| Line | Current Code | New Code | Priority |
|------|--------------|----------|----------|
| 69 | `if (path.EndsWith(".tazor", StringComparison.OrdinalIgnoreCase))` | `".tazor"` | 🔴 CRITICAL |
| 72 | `string.Equals(fileName, "_Imports", ...)` | Keep as `"_Imports"` | 🔴 CRITICAL |

### 4. IDE File Detection

| File | Line | Current Code | New Code | Priority |
|------|------|--------------|----------|----------|
| `src/Razor/src/Microsoft.CodeAnalysis.Razor.Workspaces/DocumentPresentation/UriPresentationHelper.cs` | 23 | `EndsWith(".tazor", PathUtilities.OSSpecificPathComparison)` | `".tazor"` | 🔴 CRITICAL |
| `src/Razor/src/Microsoft.VisualStudio.LanguageServices.Razor/Discovery/ProjectStateChangeDetector.cs` | 252 | `filePath.EndsWith(".tazor", PathUtilities.OSSpecificPathComparison)` | `".tazor"` | 🔴 CRITICAL |

### 5. MSBuild Targets

**File**: `src/Razor/src/Microsoft.VisualStudioCode.RazorExtension/Targets/Microsoft.CSharpExtension.DesignTime.targets`

| Line | Current Code | New Code | Priority |
|------|--------------|----------|----------|
| 33 | `<_RazorOrCshtmlFiles Include="**\*.tazor;**\*.cshtml" />` | `**\*.tazor` | 🔴 CRITICAL |

### 6. Generated File Extension Construction

**File**: `src/Razor/src/Microsoft.CodeAnalysis.Razor.Workspaces/Utilities/RazorProjectInfoFactory.cs`

Look for: `const string generatedRazorExtension = $".tazor{suffix}";`

Change to: `const string generatedTazorExtension = $".tazor{suffix}";`

**Priority**: 🔴 CRITICAL

---

## SHOULD CHANGE (Test Infrastructure)

### Test Assertion Files for Generated Names

These test files assert specific generated file names ending in `_tazor.g.cs`. Update to `_tazor.g.cs`:

| File | Lines with Assertions | Priority |
|------|----------------------|----------|
| `src/Compiler/test/Microsoft.NET.Sdk.Razor.SourceGenerators.Tests/RazorSourceGeneratorTests.cs` | 240-241, 458, 845, 1019, 1181, 2736-2737, 2858-2859, 2887-2888, 2930-2931, 3582 | 🟡 HIGH |
| `src/Compiler/perf/Microsoft.AspNetCore.Razor.Microbenchmarks.Generator/RazorTests.cs` | 66, 78, 86, 114, 122, 134-135, 143-144, 156, 168 | 🟡 HIGH |
| `src/Razor/test/Microsoft.VisualStudioCode.RazorExtension.Test/Endpoints/Shared/ComputedTargetPathTest.cs` | 48, 73, 77, 105, 109 | 🟡 HIGH |

### Test Helper Methods

Files with `CompileToCSharp("_Imports.tazor", ...)` or similar test helper calls:

- `src/Compiler/Microsoft.AspNetCore.Razor.Language/test/IntegrationTests/ComponentImportsIntegrationTest.cs`
- `src/Compiler/Microsoft.AspNetCore.Razor.Language/test/IntegrationTests/ComponentCodeGenerationTestBase.cs`
- `src/Compiler/test/Microsoft.NET.Sdk.Razor.SourceGenerators.Tests/RazorSourceGeneratorComponentTests.cs`
- `src/Compiler/Microsoft.AspNetCore.Razor.Language/test/RazorCodeDocumentExtensionsTest.cs` (lines 235-334)

**Action**: Search and replace `"_Imports.tazor"` → `"_Imports.tazor"` in test files

**Priority**: 🟡 HIGH

### Test File Path Literals

Files with test path literals like `"Test.tazor"`, `"Counter.tazor"`, etc.:

- `src/Compiler/Microsoft.AspNetCore.Razor.Language/test/Components/ComponentDocumentClassifierPassTest.cs` (lines 22, 44, 67, 92, 118, 138)
- `src/Compiler/test/Microsoft.NET.Sdk.Razor.SourceGenerators.Tests/SourceGeneratorProjectItemTest.cs` (lines 57, 78, 100-101)
- `src/Compiler/perf/Microsoft.AspNetCore.Razor.Microbenchmarks.Generator/RazorBenchmarks.cs` (lines 13-28)
- Multiple benchmark and test files in `src/Razor/benchmarks/`

**Action**: Search and replace `.tazor"` → `.tazor"` in test/benchmark files

**Priority**: 🟡 HIGH

### Test Formatting Checks

**File**: `src/Razor/test/Microsoft.VisualStudio.Razor.IntegrationTests/Formatting/FormatDocumentTests.cs`

| Line | Current Code | Priority |
|------|--------------|----------|
| 43 | `if (testFileName.EndsWith(".tazor", StringComparison.OrdinalIgnoreCase))` | 🟡 HIGH |

---

## DOCUMENTATION CHANGES

### Code Comments Mentioning _Imports.tazor

| File | Context | Priority |
|------|---------|----------|
| `src/Compiler/Microsoft.CodeAnalysis.Razor.Compiler/src/Language/RazorFileKind.cs` | XML doc comment | 🟢 MEDIUM |
| `src/Razor/src/Microsoft.CodeAnalysis.Razor.Workspaces/CodeActions/Razor/SimplifyFullyQualifiedComponentCodeActionResolver.cs` | Code comment line 41 | 🟢 MEDIUM |
| `src/Razor/src/Microsoft.CodeAnalysis.Razor.Workspaces/ProjectSystem/ProjectState.cs` | Code comments lines 437-438 | 🟢 MEDIUM |
| `src/Razor/src/Microsoft.CodeAnalysis.Razor.Workspaces/Formatting/AddUsingsHelper.cs` | Code comment line 39 | 🟢 MEDIUM |

### MSBuild Target Comments

**File**: `src/Razor/src/Microsoft.VisualStudioCode.RazorExtension/Targets/Microsoft.CSharpExtension.DesignTime.targets`

| Line | Current Comment | Priority |
|------|----------------|----------|
| 22 | `If there are any .tazor or .cshtml files in this project` | 🟢 MEDIUM |
| 26 | `Add each .tazor and .cshtml file to the project` | 🟢 MEDIUM |

### Documentation Files

Update all `.tazor` references in documentation:

| File | Priority |
|------|----------|
| `CLAUDE.md` | 🟢 MEDIUM |
| `.github/copilot-instructions.md` | 🟢 MEDIUM |
| `docs/Onboarding Docs/01_Razor_Basics.md` | 🟢 MEDIUM |
| `docs/contributing/BuildingSamples.md` | 🟢 MEDIUM |
| `docs/InsertingRazorIntoVSCodeCSharp.md` | 🟢 MEDIUM |
| `docs/architecture/razor-compiler-outputs.md` | 🟢 MEDIUM |
| `docs/architecture/nuget-packages-analysis.md` | 🟢 MEDIUM |
| `docs/architecture/Overview.md` | 🟢 MEDIUM |
| `kanban/to-do/change-razor-extension-to-tazor.md` | 🟢 MEDIUM |
| `src/Razor/src/Microsoft.VisualStudio.LanguageServices.Razor/LanguageClient/README.md` | 🟢 MEDIUM |

---

## FILE RENAMES REQUIRED

### Sample Application Files

| Current Path | New Path | Priority |
|-------------|----------|----------|
| `sample/TestBlazorApp/Components/App.tazor` | `App.tazor` | 🔴 CRITICAL |
| `sample/TestBlazorApp/Components/Pages/Counter.tazor` | `Counter.tazor` | 🔴 CRITICAL |
| `sample/TestBlazorApp/Components/Pages/Error.tazor` | `Error.tazor` | 🔴 CRITICAL |
| `sample/TestBlazorApp/Components/Pages/Home.tazor` | `Home.tazor` | 🔴 CRITICAL |
| `sample/TestBlazorApp/Components/Pages/Weather.tazor` | `Weather.tazor` | 🔴 CRITICAL |
| `sample/TestBlazorApp/Components/Layout/MainLayout.tazor` | `MainLayout.tazor` | 🔴 CRITICAL |
| `sample/TestBlazorApp/Components/Layout/NavMenu.tazor` | `NavMenu.tazor` | 🔴 CRITICAL |
| `sample/TestBlazorApp/Components/Routes.tazor` | `Routes.tazor` | 🔴 CRITICAL |
| `sample/TestBlazorApp/Components/_Imports.tazor` | `_Imports.tazor` | 🔴 CRITICAL |

### Benchmark Data Files

| Current Path | New Path | Priority |
|-------------|----------|----------|
| `src/Compiler/perf/Microbenchmarks/BlazorServerTagHelpers.tazor` | `BlazorServerTagHelpers.tazor` | 🟡 HIGH |

---

## NO ACTION NEEDED (Auto-Regenerated)

These files are generated outputs and will be automatically regenerated with new names once the source files are renamed and compiler is updated:

### Generated Files in sample/TestBlazorApp/Generated/

- `Components_App_tazor.g.cs` → will become `Components_App_tazor.g.cs`
- `Components_Pages_Counter_tazor.g.cs` → will become `Components_Pages_Counter_tazor.g.cs`
- `Components_Pages_Error_tazor.g.cs` → will become `Components_Pages_Error_tazor.g.cs`
- And all other `*_tazor.g.cs` files

### Test Fixture Files

Test baseline files (`.codegen.cs`, `.mappings.txt`, `.ir.txt`, `.diagnostics.txt`) in:
- `src/Compiler/test/Microsoft.NET.Sdk.Razor.SourceGenerators.Tests/TestFiles/`
- `src/Compiler/Microsoft.AspNetCore.Razor.Language/test/TestFiles/`

These will need to be regenerated after the change. Follow the test baseline regeneration process.

---

## GITIGNORE UPDATE

**File**: `.gitignore`

Current line 157:
```
sample/TestBlazorApp/Generated/
```

This is correct - the generated folder is already ignored. No change needed unless there are specific `.tazor` file patterns in gitignore (there aren't any).

---

## RECOMMENDED IMPLEMENTATION ORDER

### Phase 1: Core Constants (Start Here)
1. ✅ Change `FileKinds.cs` line 12
2. ✅ Change `FileUtilities.cs` line 12
3. ✅ Change `ComponentHelpers.cs` line 10
4. ✅ Change `TestImportProjectFeature.cs` line 22

### Phase 2: File Detection Logic
5. ✅ Update `RazorSourceGenerator.cs` lines 69, 72
6. ✅ Update `UriPresentationHelper.cs` line 23
7. ✅ Update `ProjectStateChangeDetector.cs` line 252
8. ✅ Update `RazorProjectInfoFactory.cs` generated extension

### Phase 3: Build System
9. ✅ Update MSBuild targets file line 33

### Phase 4: Sample Application
10. ✅ Rename all 9 `.tazor` files in `sample/TestBlazorApp/`

### Phase 5: Test Infrastructure
11. ✅ Update test assertion files (generated name checks)
12. ✅ Update test helper methods
13. ✅ Update test file path literals
14. ✅ Regenerate test baseline files

### Phase 6: Documentation
15. ✅ Update code comments
16. ✅ Update documentation files
17. ✅ Update MSBuild target comments

### Phase 7: Verification
18. ✅ Run `./build-sample.ps1`
19. ✅ Verify generated files have `*_tazor.g.cs` names
20. ✅ Verify sample app builds successfully
21. ✅ Run full test suite: `./build.sh -test`

---

## SEARCH PATTERNS FOR VERIFICATION

After making changes, verify completeness with these searches:

```bash
# Should find ZERO results in source code (excluding legacy .cshtml)
grep -r '\.tazor"' --include="*.cs" --include="*.props" --include="*.targets" src/

# Should find appropriate references to .tazor
grep -r '\.tazor"' --include="*.cs" src/

# Verify import file references updated
grep -r '_Imports\.tazor' --include="*.cs" src/

# Should find updated import references
grep -r '_Imports\.tazor' --include="*.cs" src/
```

---

## ESTIMATED EFFORT

- **Core changes (Phases 1-3)**: 30 minutes
- **Sample app rename (Phase 4)**: 10 minutes
- **Test updates (Phase 5)**: 2-3 hours (many test files)
- **Documentation (Phase 6)**: 1 hour
- **Testing and verification (Phase 7)**: 1-2 hours

**Total**: ~5-7 hours for complete, tested migration

---

## NOTES

1. **Legacy .cshtml support**: We are NOT changing `.cshtml` references - those remain for legacy MVC/Razor Pages support
2. **Test baselines**: Many test baseline files will need regeneration after the change
3. **Atomic commit**: All changes should be in a single atomic commit to avoid partial state
4. **Generated files**: Do NOT manually edit `*_tazor.g.cs` files - they will be regenerated automatically

---

## REFERENCE

- Original task: `kanban/to-do/change-razor-extension-to-tazor.md`
- Architecture docs: `docs/architecture/`
- Build script: `build-sample.ps1`
