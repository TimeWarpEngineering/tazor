# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **ASP.NET Core Razor Tooling** - the open-source implementation of the Razor compiler and IDE tooling. It provides the complete Razor language experience for Visual Studio, VS Code, and other editors.

**Key Characteristics**:
- Fork: TimeWarpEngineering/tazor (upstream: dotnet/razor)
- Language: C# (preview features enabled)
- Target Frameworks: net472, net8.0, net9.0, netstandard2.0 (multi-targeting)
- 53 projects organized in 4 major components
- Build System: .NET Arcade SDK (NOT standard dotnet CLI)

## Critical Build Rules

**NEVER use `dotnet build` or `dotnet test` directly!**

The repository uses Arcade SDK with custom build infrastructure:

```bash
# Restore dependencies (MUST run after pulling changes)
./restore.sh    # or restore.cmd on Windows

# Full build
./build.sh      # or build.cmd on Windows

# Build and run all tests
./build.sh -test

# Clean
./clean.sh
```

**Visual Studio Development**:
```bash
# MUST use this to open VS with correct environment
./startvs.cmd
```

**Using dotnet CLI directly**:
```bash
# If you need to use dotnet commands, first activate the environment
source ./activate.sh    # Linux/macOS
# Then you can use dotnet commands
```

## Razor Language Concepts

### File Types
- `.razor` - Blazor components (client/server-side)
- `.cshtml` - Razor views/pages (MVC/Pages) - also called "Legacy" in codebase

### Language Kinds
Razor documents contain multiple embedded languages:
- Razor syntax (`@` expressions, directives)
- C# code (server-side logic)
- HTML markup
- JavaScript/CSS

## Architecture

### Major Components (src/)

1. **Compiler** ([src/Compiler/](src/Compiler/))
   - Core Razor compilation engine and source generators
   - Targets: net8.0, netstandard2.0
   - Projects: Microsoft.CodeAnalysis.Razor.Compiler, Microsoft.AspNetCore.Razor.Language

2. **Razor** ([src/Razor/](src/Razor/))
   - Language server and IDE integrations (15 projects)
   - Key projects:
     - `Microsoft.AspNetCore.Razor.LanguageServer` - LSP implementation
     - `Microsoft.CodeAnalysis.Razor.Workspaces` - Core tooling APIs
     - `Microsoft.CodeAnalysis.Remote.Razor` - Roslyn OOP integration for VS
     - `Microsoft.VisualStudio.RazorExtension` - Visual Studio integration (net472)
     - `Microsoft.VisualStudioCode.RazorExtension` - VS Code integration (net9.0)
     - `rzls` - Razor Language Server executable (net9.0)

3. **Shared** ([src/Shared/](src/Shared/))
   - Common utilities across all layers
   - Targets: net8.0, netstandard2.0, net472

4. **Analyzers** ([src/Analyzers/](src/Analyzers/))
   - Diagnostic analyzers for Razor code

### Layering (see [docs/ProjectsAndLayering.md](docs/ProjectsAndLayering.md))
1. Shared (netstandard2.0, net472, net8.0)
2. Compiler (net8.0, netstandard2.0)
3. Tooling Core (net8.0, netstandard2.0, net472)
4. Razor Language Server (net8.0, net472, net9.0)
5. Roslyn OOP for VS (netstandard2.0)
6. Visual Studio integration (net472)
7. VS Code integration (net9.0)

### Solution Files
- `Razor.sln` - Full solution (630 lines, all projects)
- `Razor.Slim.slnf` - Solution filter (41 core projects for faster builds)

## Performance-Critical Patterns

**Context**: Razor compilation happens on every keystroke - performance is critical.

### Collection Best Practices (see [docs/CollectionBestPractices.md](docs/CollectionBestPractices.md))

**Exposing Collections**:
- Use `ImmutableArray<T>` instead of `IReadOnlyList<T>` (avoids allocation on foreach)
- NEVER expose `IReadOnlyList<T>` or `IReadOnlyDictionary<TKey, TValue>` directly
- Use frozen collections for static data

**Building Collections**:
- Set capacity upfront to avoid growth allocations
- Use `PooledArrayBuilder<T>` for small arrays (stores first 4 items inline)
- Use `ImmutableArray<T>.Builder` for immutable arrays
- Use `ArrayPool<T>` for temporary arrays
- Use `ObjectPool<T>` for temporary collections
- Never let pooled objects escape their scope

**LINQ Usage**:
- Avoid LINQ in hot paths (it allocates)
- Use static lambdas to avoid closures: `items.Where(static x => x.IsActive)`
- Collection expressions are generally good but verify on SharpLab

**Key Utilities**:
- `GetRequiredAbsoluteIndex` - Always use for position conversions
- `PooledArrayBuilder<T>` - Small array construction
- ArrayPool/ObjectPool - Temporary object reuse

## Testing

**Framework**: xUnit 2.9.2

**Test Patterns**:
- Always add `[WorkItem]` attributes for tracking
- Prefer `TestCode` over plain strings for test scenarios
- Prefer raw string literals over verbatim strings
- Test end-user scenarios, not implementation details
- Consider cross-platform compatibility (path handling, case sensitivity)

**New Architecture**:
- "Cohosting" is the new architecture - create tests in [src/Razor/test/Microsoft.VisualStudioCode.RazorExtension.Test](src/Razor/test/Microsoft.VisualStudioCode.RazorExtension.Test)

**Running Tests**:
```bash
# MUST run this before submitting PRs (no filters!)
./build.sh -test
```

## Code Standards

### From .editorconfig
- Indent: 4 spaces
- Nullable reference types: enabled
- LangVersion: preview
- UTF-8 BOM required for C# files
- `var` required everywhere
- File header template required (MIT license)
- Using directives: System.* first, sorted
- Braces always on new lines

### Critical Patterns
- Use `using` statements for disposables
- Proper async/await (NEVER use `Task.Wait()`)
- No temporal comments ("currently", "now") - use version-specific references
- Static lambdas in LINQ to avoid closures
- Cross-platform compatibility required

## Development Prerequisites

### Required
- .NET 9.0 SDK (version 9.0.111 exactly - see [global.json](global.json))
- .NET runtimes: 2.1.30, 3.1.30, 8.0.7
- Visual Studio 2022 17.2+ with VSSDK component (Windows)
  OR VS Code with C# extension (cross-platform)
- PowerShell (for Windows build scripts)
- Git with long paths enabled: `git config --global core.longpaths true`

### Platform Support
- Windows 10 version 1803+
- macOS Sierra+
- Linux (with .NET prerequisites)
- Code MUST work cross-platform

## Key Documentation

Essential reading for contributors:
- [docs/contributing/BuildFromSource.md](docs/contributing/BuildFromSource.md) - Build instructions
- [docs/ProjectsAndLayering.md](docs/ProjectsAndLayering.md) - Architecture overview
- [docs/CollectionBestPractices.md](docs/CollectionBestPractices.md) - Performance guidelines (extensive!)
- [docs/Onboarding Docs/01_Razor_Basics.md](docs/Onboarding%20Docs/01_Razor_Basics.md) - Razor fundamentals
- [.github/copilot-instructions.md](.github/copilot-instructions.md) - Team coding guidelines

## Common Development Workflow

### First Time Setup
```bash
git clone <repo>
git config --global core.longpaths true  # Windows only
./restore.sh
# Open with VS: ./startvs.cmd (Windows)
# OR open with VS Code
```

### Daily Development
```bash
source ./activate.sh  # If using dotnet commands directly
./build.sh -test      # Build and test
# Make changes
./build.sh -test      # Verify before commit
```

### Running Single Test
After activating environment with `source ./activate.sh`:
```bash
dotnet test path/to/TestProject.csproj --filter "FullyQualifiedName~TestMethodName"
```

## CI/CD

**Pipelines** (in [eng/](eng/)):
- `azure-pipelines.yml` - Main CI
- `azure-pipelines-official.yml` - Official builds
- `azure-pipelines-integration-dartlab.yml` - Integration tests
- `azure-pipelines-compliance.yml` - Compliance checks

## Contributing

- File issues at: https://github.com/dotnet/razor/issues
- CLA signing required
- PRs undergo rigorous ASP.NET team review
- Use "Report a Razor Issue" command in VS Code for bugs

## Special Notes

- This is a **fork**: TimeWarpEngineering/tazor from dotnet/razor
- Working in **worktrees**: Cannot checkout master or delete branches locally
- Always use `--head` flag with `gh pr create`
- NEVER squash or rebase (per team workflow)
- Heavy use of Roslyn source generators throughout
- Object pooling extensively used for performance
