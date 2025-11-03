# Change File Extension from .razor to .tazor

**Status**: In Progress
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

## Acceptance Criteria

- [x] Compiler recognizes `*.tazor` files instead of `*.razor` files
- [x] Source generator processes `*.tazor` files
- [x] Generated files use `_tazor.g.cs` suffix instead of `_razor.g.cs`
- [x] Import files use `_Imports.tazor` instead of `_Imports.razor`
- [x] MSBuild targets include `*.tazor` in compilation
- [x] Sample application uses `.tazor` extension and builds successfully
- [ ] All diagnostics reference `.tazor` in error messages
- [ ] Documentation updated to reflect new extension
- [x] Build script (`build-sample.ps1`) works with new extension
- [ ] No breaking changes to generated C# code structure (only file naming)

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
- Clean targets (to remove old `*_razor.g.cs` files)
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
- [x] Identify all hardcoded `.razor` string references in codebase (see `docs/architecture/razor-to-tazor-migration-inventory.md`)
- [x] Determine if gradual migration or all-at-once is better (Decision: **All-at-once** - confirmed feasible)

### Phase 2: Core Compiler Changes
- [x] Update source generator file filter
- [x] Update generated file naming convention
- [x] Update import file discovery (`_Imports.razor` → `_Imports.tazor`)
- [ ] Update all hardcoded file extension checks

### Phase 3: Build System Changes
- [x] Update MSBuild targets/props to include `*.tazor`
- [ ] Update NuGet.config if needed
- [ ] Update build scripts

### Phase 4: Sample Application Migration
- [x] Rename all `.razor` files to `.tazor` in sample app
- [x] Update any explicit file references
- [x] Test with `build-sample.ps1`
- [x] Verify generated files have correct naming

### Phase 5: Testing and Validation
- [x] Build sample app successfully
- [x] Verify generated file names (`*_tazor.g.cs`)
- [ ] Check generated code content (should be identical except file references)
- [ ] Test IntelliSense/IDE integration if possible
- [ ] Verify error messages reference correct file extension

### Phase 6: Documentation
- [ ] Update `docs/contributing/BuildingSamples.md`
- [ ] Update `docs/architecture/razor-compiler-outputs.md`
- [ ] Update `CLAUDE.md` if it references `.razor`
- [ ] Add migration notes explaining the change

## Implementation Strategy

### Recommended Approach: All-at-Once
Since this is a fork and not shipping to customers yet, do the change atomically in a single commit to avoid maintaining dual code paths.

**Advantages**:
- Clean, simple changeset
- No dual-extension support code
- Easier to reason about
- Single commit to revert if needed

**Process**:
1. Use search/replace for all `.razor` string references
2. Manually verify each change is appropriate
3. Update sample app files
4. Test thoroughly
5. Commit as single atomic change

### Search Patterns
Use these patterns to find all references:

```bash
# Find .razor string literals
grep -r '\.razor' --include="*.cs" --include="*.csproj" --include="*.props" --include="*.targets"

# Find _razor in variable names/file names
grep -r '_razor' --include="*.cs" --include="*.csproj"

# Find "razor" in file paths
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
- ~1,900+ string references to `.razor` in codebase
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
