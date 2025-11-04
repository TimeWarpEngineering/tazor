# Change File Extension from .razor to .tazor

**Status**: Ready for Review
**Priority**: High
**Type**: Breaking Change
**Effort**: Medium

## Objective

Replace the `.razor` file extension with `.tazor` throughout the compiler, tooling, and build system. This is the first step toward creating an independent Tazor compiler fork that will eventually:
- Move out of Microsoft.NET.Sdk.Razor dependency
- Support TUI (Terminal UI) instead of Blazor components
- Target .NET 10+ only

## Scope

This task focuses ONLY on the file extension change. Other transitions (SDK independence, TUI rendering) will be handled in separate tasks.

## Latest Update (2025-11-04)

- Core compiler, tooling, and tests now consume `.tazor` files exclusively (commit `f739e9c2d0`).
- `./build.sh` succeeds on Linux; Windows/VSIX validation still pending.
- VS host assets now vend in-repo rule files (`RazorConfiguration.xaml`, etc.) rather than pulling from `Microsoft.NET.Sdk.Razor`.
- `./build-sample.ps1` now re-activates the repo environment automatically and succeeds on Linux PowerShell and bash; Windows run still queued.
- Documentation and diagnostic string sweep remain open follow-ups.

## Acceptance Criteria

- [x] Compiler recognizes `*.tazor` files instead of `*.razor` files
- [x] Source generator processes `*.tazor` files
- [x] Generated files use `_tazor.g.cs` suffix instead of `_razor.g.cs`
- [x] Import files use `_Imports.tazor` instead of `_Imports.razor`
- [x] MSBuild targets include `*.tazor` in compilation
- [x] Sample application uses `.tazor` extension and builds successfully
- [ ] All diagnostics reference `.tazor` in error messages (strings audit outstanding)
- [ ] Documentation updated to reflect new extension
- [ ] Build script (`build-sample.ps1`) works with new extension (pending Windows run)
- [ ] No breaking changes to generated C# code structure (spot-check still needed)

## Affected Areas

### 1. Source Generator
**Location**: `src/Compiler/Microsoft.CodeAnalysis.Razor.Compiler/src/SourceGenerators/`

**Files to Modify**:
- `RazorSourceGenerator.cs` - Change file filter from `*.razor` to `*.tazor`
- `SourceGeneratorProjectEngine.cs` - Update file discovery logic

**Changes**:
```csharp
// Before
if (additionalFile.Path.EndsWith(".razor", StringComparison.OrdinalIgnoreCase))

// After
if (additionalFile.Path.EndsWith(".tazor", StringComparison.OrdinalIgnoreCase))
```

### 2. File Naming Convention
**Location**: Multiple locations in code generation pipeline

**Changes**:
- Output file pattern: `{ComponentPath}_razor.g.cs` → `{ComponentPath}_tazor.g.cs`
- Example: `Components_Pages_Counter_razor.g.cs` → `Components_Pages_Counter_tazor.g.cs`

**Files to Check**:
- Code generation utilities
- Source mapping logic
- Diagnostic message formatting

### 3. Import Files Discovery
**Location**: Import resolution logic

**Changes**:
- `_Imports.razor` → `_Imports.tazor`
- `_ViewImports.cshtml` remains unchanged (legacy MVC/Razor Pages)

**Logic**:
- Update import file detection patterns
- Ensure cascading import behavior works with new extension

### 4. MSBuild Integration
**Location**: `eng/targets/` or MSBuild configuration files

**Changes**:
- Add `*.tazor` to `AdditionalFiles` or compilation items
- Update file globs and filters
- Consider backward compatibility (support both during transition?)

**Targets to Review**:
- Source generator configuration
- Clean targets (to remove old `*_tazor.g.cs` files)
- Content file handling

### 5. Sample Application
**Location**: `sample/TestBlazorApp/`

**Changes**:
- Rename all `.razor` files to `.tazor`:
  - `Components/App.razor` → `Components/App.tazor`
  - `Components/Pages/Counter.razor` → `Components/Pages/Counter.tazor`
  - `Components/_Imports.razor` → `Components/_Imports.tazor`
  - etc.
- Update any explicit file references in code or config
- Verify generated output folder updates accordingly

### 6. Diagnostics and Error Messages
**Location**: Throughout compiler

**Changes**:
- Update error messages to reference `.tazor` files
- Source location reporting
- Diagnostic formatting

### 7. Documentation
**Location**: `docs/`, `CLAUDE.md`

**Changes**:
- Update all references from `.razor` to `.tazor`
- Update `BuildingSamples.md` to reflect new extension
- Update `docs/architecture/razor-compiler-outputs.md`

### 8. .gitignore
**Location**: `.gitignore`

**Changes**:
- May need to add patterns for `*.tazor` files if specific ignore rules exist
- Update generated file patterns if they reference the extension

## Sub-Tasks

### Phase 1: Research and Planning (This Task)
- [x] Document all current outputs and pipeline (see `docs/architecture/razor-compiler-outputs.md`)
- [x] Create this kanban task
- [x] Identify all hardcoded `.tazor` string references in codebase (see `docs/architecture/razor-to-tazor-migration-inventory.md`)
- [x] Determine if gradual migration or all-at-once is better (Decision: **All-at-once** - confirmed feasible)

### Phase 2: Core Compiler Changes
- [x] Update source generator file filter
- [x] Update generated file naming convention
- [x] Update import file discovery (`_Imports.razor` → `_Imports.tazor`)
- [x] Update all hardcoded file extension checks

### Phase 3: Build System Changes
- [x] Update MSBuild targets/props to include `*.tazor`
- [ ] Update NuGet.config if needed (not currently required)
- [x] Update build scripts (PowerShell variant validated on Linux and WSL PowerShell; Windows still to run)

### Phase 4: Sample Application Migration
- [x] Rename all `.razor` files to `.tazor` in sample app
- [x] Update any explicit file references
- [x] Test with `build-sample.ps1` (PowerShell run succeeded on Linux; Windows run pending)
- [x] Verify generated files have correct naming

### Phase 5: Testing and Validation
- [x] Build sample app successfully (via `./build.sh` Linux run)
- [x] Verify generated file names (`*_tazor.g.cs`)
- [ ] Check generated code content (should be identical except file references)
- [ ] Test IntelliSense/IDE integration if possible
- [ ] Verify error messages reference correct file extension

### Phase 6: Documentation
- [ ] Update `docs/contributing/BuildingSamples.md`
- [ ] Update `docs/architecture/razor-compiler-outputs.md`
- [ ] Update `CLAUDE.md` if it references `.tazor`
- [ ] Add migration notes explaining the change

## Implementation Strategy

### Current Reality Check (Nov 2025)
- `.tazor` is now the primary component extension across compiler, workspace, and language server layers; automated tests run green on Linux.
- Remaining work involves Windows/Visual Studio validation plus documentation and diagnostic text updates.

### Step 1 – Centralize Extension Constants
1. Audit canonical extension sources (`FileKinds`, `ComponentFileKindClassifier`, `ProjectEngineFactory`, path helpers).
2. Introduce shared helpers listing `.tazor` (primary) plus optional `.razor` compatibility until tests green.
3. Update unit tests that assert supported extensions.

### Step 2 – Restore Component FileKind Inference
1. Ensure `DefaultRazorProjectItem` / `DefaultRazorProjectFileSystem` return `FileKinds.Component` for `.tazor` (fixes `DefaultRazorProjectEngineIntegrationTest` and `DefaultRazorProjectItemTest`).
2. Update `ComponentFileKindClassifier` and related detection points to prefer `.tazor`.
3. Re-run `Microsoft.AspNetCore.Razor.Language.Test` to confirm expected inference.

### Step 3 – Project System & Workspace Wiring
1. Update `RemoteProjectSnapshot`, `ProjectSnapshotManager`, `RazorDocumentServiceBase`, cohosting interceptors, and any document factories so `.tazor` resolves to Razor contexts (address VSCode “Document is not a Razor document” failures).
2. Verify tag helper, generated document, and source document factories include `.tazor` paths.
3. Re-run `Microsoft.CodeAnalysis.Razor.Workspaces.Test` and `Microsoft.VisualStudioCode.RazorExtension.Test` suites.

### Step 4 – Language Server Features
1. Propagate `.tazor` awareness through completion, folding, semantic tokens, and diagnostics pipelines.
2. Refresh semantic token baselines if token classifications shift.
3. Re-run `Microsoft.AspNetCore.Razor.LanguageServer.Test` to validate completions, folds, and tokens.

### Step 5 – Targeted Cleanup
1. After tests pass, sweep remaining `.razor` literals (commands, docs, tooling messages) and replace with `.tazor` where intended.
2. Document any deliberate `.razor` compatibility paths maintained for migration.

### Step 6 – End-to-End Verification
1. Execute `./build.sh -test` (or equivalent) and archive updated HTML reports.
2. Record pass/fail status per suite in this kanban card with log links.
3. Decide when to drop temporary `.tazor` fallbacks once confidence is high.

### Search Patterns (cleanup phase)
```bash
# Find .tazor string literals (post-classification fixes)
grep -r '\.tazor' --include="*.cs" --include="*.csproj" --include="*.props" --include="*.targets"

# Find _razor naming references
grep -r '_razor' --include="*.cs" --include="*.csproj"

# Find generated file suffix references
grep -r 'razor\.g\.cs' --include="*.cs"
```

## Testing Plan

1. **Build Test**: Run `./build.sh --pack` successfully
2. **Sample Build**: Run `./build-sample.ps1` successfully
3. **Generated Files**: Verify output in `sample/TestBlazorApp/Generated/` uses new naming
4. **Code Inspection**: Check generated C# code for correctness
5. **Error Handling**: Introduce syntax error in `.tazor` file and verify error message references correct file

## Risks and Mitigation

**Risk**: Breaking IDE integration
**Mitigation**: Document that IDE support for `.tazor` may be limited initially; focus on command-line build

**Risk**: Missing some hardcoded references
**Mitigation**: Comprehensive search with multiple patterns; thorough testing

**Risk**: MSBuild not picking up `*.tazor` files
**Mitigation**: Verify MSBuild configuration explicitly includes new extension

## Related Tasks

**Next Steps** (future kanban tasks):
- Remove Microsoft.NET.Sdk.Razor dependency
- Replace ComponentBase with TUI base class
- Change `BuildRenderTree` to TUI rendering model
- Remove net472/netstandard2.0/net8.0/net9.0 support, keep only net10.0+

## Notes

- This change is intentionally breaking - we're forking from Microsoft's Razor
- The `.tazor` extension signals this is a different compiler with different goals
- Keep generated C# code structure identical for now (only change file extension references)
- Consider this the "public API" change that announces Tazor as distinct from Razor

## References

- **Migration inventory**: `docs/architecture/razor-to-tazor-migration-inventory.md` ⭐ **START HERE**
- Baseline documentation: `docs/architecture/razor-compiler-outputs.md`
- Package analysis: `docs/architecture/nuget-packages-analysis.md`
- Current sample app: `sample/TestBlazorApp/`
- Build script: `build-sample.ps1`
- Documentation: `docs/contributing/BuildingSamples.md`

## Research Findings Summary

**Total Scope** (from migration inventory):
- ~1,900+ string references to `.tazor` in codebase
- **9 critical files** to change (4 constants + 5 file detection points)
- **9 sample files** to rename
- **50+ test files** to update
- **10+ documentation files** to update
- **Estimated effort**: 5-7 hours for complete, tested migration

**Key Finding**: The change is very **contained** and **systematic**:
- Only **4 core constants** define the extension (in FileKinds.cs, FileUtilities.cs, ComponentHelpers.cs, TestImportProjectFeature.cs)
- Only **5 file detection logic points** check the extension
- Everything else cascades from those core changes
- Generated files auto-regenerate with new names

**Decision**: All-at-once approach is **confirmed feasible** and recommended.
