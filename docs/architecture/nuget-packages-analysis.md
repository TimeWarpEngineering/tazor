# NuGet Packages Built by Tazor Repository

**Purpose**: Comprehensive analysis of all NuGet packages built by this repository (artifacts/packages/), documenting their purposes, consumers, and roles in the Razor/Tazor ecosystem.

**Related**: See [razor-compiler-outputs.md](razor-compiler-outputs.md) for details on the C# code generation outputs.

---

## Package Categories

This repository builds **21 packages** in two categories:
- **15 Shipping Packages** - Distributed to customers via NuGet.org, VS Marketplace, etc.
- **6 Non-Shipping Packages** - Internal transport/test packages

---

## SHIPPING PACKAGES (artifacts/packages/Debug/Shipping/)

### 1. Microsoft.AspNetCore.Razor.Test.Common

**Location**: `src/Shared/Microsoft.AspNetCore.Razor.Test.Common/`

**Purpose**: Shared test infrastructure and utilities for Razor tooling test projects

**Target Frameworks**: net8.0, net9.0, net472

**Contents**:
- xUnit test utilities (ConditionalFact, TheoryDataExtensions)
- Diagnostic assertion helpers
- Test compilation setup utilities
- Baseline/snapshot testing support
- Symbol and reference management helpers

**Consumers**: All test projects across the Razor compiler, language server, and IDE extensions (23+ test assemblies via InternalsVisibleTo)

**Distribution**: NuGet.org

**Use Case**: Standardized testing infrastructure for all Razor components

---

### 2. Microsoft.CodeAnalysis.Razor.Compiler ⭐ CORE

**Location**: `src/Compiler/Microsoft.CodeAnalysis.Razor.Compiler/src/`

**Purpose**: The foundational Razor compilation engine - parses, analyzes, and generates C# code from .tazor/.cshtml files

**Target Frameworks**: net8.0, net9.0, netstandard2.0

**Contents** (590+ source files):
- Complete Razor language compiler
- 10-phase compilation pipeline
- Syntax parsing and analysis
- Intermediate representation (IR) with 70+ node types
- C# code generation
- Source generators
- MVC/Razor Pages extensions

**Key Components**:
- `DefaultRazorCSharpLoweringPhase` - Final C# code generation
- `RazorSourceGenerator` - Incremental source generator
- `RazorProjectEngine` - Compilation orchestration
- Various node writers (Runtime, DesignTime, Component)

**Consumers**: Every other package in the ecosystem
- Microsoft.Net.Compilers.Razor.Toolset
- Microsoft.AspNetCore.Razor.LanguageServer
- Microsoft.CodeAnalysis.Razor.Workspaces
- All IDE integration packages
- Test projects

**Distribution**: NuGet.org

**Use Case**: Foundation for all Razor compilation - every .tazor file processed goes through this compiler

**Critical Note**: This is the package that will be forked into Tazor compiler with `.tazor` extension support

---

### 3. Microsoft.Net.Compilers.Razor.Toolset

**Location**: `src/Compiler/Microsoft.Net.Compilers.Razor.Toolset/`

**Purpose**: Build-time development dependency providing Razor compiler and source generator for MSBuild projects

**Target Framework**: netstandard2.0

**Package Type**: DevelopmentDependency (no lib/ folder, only build assets)

**Contents**:
- MSBuild targets and props
- Source generator binaries in `source-generators/` folder:
  - Microsoft.CodeAnalysis.Razor.Compiler.dll
  - Microsoft.Extensions.ObjectPool.dll
  - Microsoft.CodeAnalysis.Razor.Tooling.Internal.dll

**Description** (from package):
> ".NET Compilers Razor Toolset Package. Referencing this package will cause the project to be built using the Razor compilers and source generator contained in the package, as opposed to the version installed with the SDK. This package is primarily intended as a method for rapidly shipping hotfixes to customers."

**Consumers**: .NET projects needing custom Razor compiler version (like our sample app)

**Distribution**: NuGet.org

**Use Case**:
- Hotfixes for Razor compilation bugs
- Testing new compiler features before SDK integration
- Our sample app uses this to test local builds: `<PackageReference Include="Microsoft.Net.Compilers.Razor.Toolset" Version="10.0.0-dev" />`

**SDK Integration**: Automatically discovered by MSBuild when referenced

**Critical Note**: This is how the sample app consumes our locally-built compiler. When transitioning to Tazor, we'll need to create `Microsoft.Net.Compilers.Tazor.Toolset` or similar.

---

### 4. Microsoft.VisualStudio.DevKit.Razor

**Location**: `src/Razor/src/Microsoft.VisualStudio.DevKit.Razor/`

**Purpose**: Language server assets for C# DevKit VS Code extension

**Target Framework**: net9.0

**Contents**:
- Microsoft.VisualStudio.DevKit.Razor.dll
- Telemetry infrastructure (TelemetryReporter, AggregatingTelemetryLog)
- Microsoft.VisualStudio.Telemetry.dll

**Dependencies**:
- Microsoft.CodeAnalysis.Razor.Workspaces
- Microsoft.VisualStudio.Telemetry

**Consumers**: VS Code C# DevKit extension (Microsoft's official VS Code extension)

**Distribution**: NuGet.org (consumed by C# DevKit build process)

**Use Case**: Provides Razor language support in VS Code via C# DevKit, enabling modern Razor development with feature parity to Visual Studio

---

### 5. Microsoft.VisualStudio.RazorExtension

**Location**: `src/Razor/src/Microsoft.VisualStudio.RazorExtension/`

**Purpose**: Complete Razor IDE support for Visual Studio 2022+

**Target Framework**: net472 (Framework for VS integration)

**Package Format**: VSIX (Visual Studio Extension)

**Contents**:
- Complete IDE integration assembly
- Syntax tree visualizer UI
- Language configuration files (JSON)
- TextMate grammars for syntax highlighting
- Context menu integration (VSCT files)
- MSBuild design-time targets
- Package definition files (pkgdef)

**Major Components**:
- Core extension assembly
- Microsoft.CodeAnalysis.Razor.Compiler.dll
- Language Server implementation
- Workspaces and IDE APIs
- Legacy editor support for .cshtml files
- Roslyn integration layer

**Dependencies** (all net472 targets):
- Microsoft.AspNetCore.Razor.LanguageServer
- Microsoft.CodeAnalysis.Razor.Workspaces
- Microsoft.VisualStudio.LanguageServices.Razor
- Microsoft.VisualStudio.LegacyEditor.Razor
- Microsoft.VisualStudio.LanguageServer.ContainedLanguage

**Consumers**: Visual Studio 2022 and later

**Distribution**:
- VS Extension Gallery (marketplace)
- VSIX insertion into VS preview/release builds
- Standalone VSIX download

**Use Case**: Complete Razor development experience in Visual Studio including IntelliSense, debugging, syntax tree visualization, and all IDE features

**Integration**: VSPackage-based with MEF composition, LSP, ServiceHub, and RPC contracts

---

### 6. Microsoft.VisualStudioCode.RazorExtension

**Location**: `src/Razor/src/Microsoft.VisualStudioCode.RazorExtension/`

**Purpose**: NuGet transport package for VS Code Razor extension binaries

**Target Framework**: net9.0

**Contents** (published to content/):
- Microsoft.VisualStudioCode.RazorExtension.dll
- Runtime dependencies:
  - Microsoft.AspNetCore.Razor.Utilities.Shared.dll
  - Microsoft.CodeAnalysis.Razor.Compiler.dll
  - Microsoft.CodeAnalysis.Razor.Workspaces.dll
  - Microsoft.CodeAnalysis.Remote.Razor.dll
  - Microsoft.Extensions.ObjectPool.dll
- Localization resources (14 languages)
- Build targets for TypeScript integration

**Dependencies**:
- Microsoft.CodeAnalysis.Razor.Compiler
- Microsoft.CodeAnalysis.Razor.Workspaces
- Microsoft.CodeAnalysis.Remote.Razor

**Consumers**: VS Code Razor extension (during build)

**Distribution**: NuGet.org (not directly consumed by end users)

**Use Case**: The NuGet package is consumed during the TypeScript/JavaScript build of the VS Code extension to obtain compiled .NET binaries for the language server

**Integration Pattern**: Extracted during VS Code extension build and packaged into the extension VSIX

---

### 7. rzls.* (Platform-Specific Language Server Executables)

**Location**: `src/Razor/src/rzls/`

**Purpose**: Standalone Razor Language Server executables for LSP-based editors

**Target Framework**: net9.0 (requires .NET 9 runtime)

**Package Format**: Platform-specific executables

**Platforms** (9 packages):
1. **rzls.win-x64** - Windows 64-bit
2. **rzls.win-arm64** - Windows ARM64
3. **rzls.linux-x64** - Linux 64-bit
4. **rzls.linux-arm64** - Linux ARM64
5. **rzls.linux-musl-x64** - Alpine/musl 64-bit
6. **rzls.linux-musl-arm64** - Alpine/musl ARM64
7. **rzls.osx-x64** - macOS Intel
8. **rzls.osx-arm64** - macOS Apple Silicon
9. **rzls.neutral** - Platform-neutral (no executable)

**Contents per package**:
```
LanguageServer/{RID}/
├── rzls (or rzls.exe on Windows)
├── Microsoft.AspNetCore.Razor.LanguageServer.dll
├── Supporting DLLs
└── Localization resources
```

**Build Configuration**:
- SelfContained: false (requires .NET runtime)
- PublishReadyToRun: true (for performance)
- RollForward: LatestMajor

**Dependencies**:
- Microsoft.AspNetCore.Razor.LanguageServer

**Consumers**: LSP-based editors and plugins
- Neovim (via mason.nvim or manual install)
- Sublime Text (via LSP plugin)
- Emacs (via lsp-mode)
- Other editors supporting Language Server Protocol

**Distribution**: NuGet.org

**Use Case**: Universal Razor language support for any editor
```bash
rzls --stdio  # Communicates via JSON-RPC on STDIN/STDOUT
```

**Critical Note**: For Tazor, these will become `tzls.*` (Tazor Language Server) supporting `.tazor` files and TUI rendering

---

## NON-SHIPPING PACKAGES (artifacts/packages/Debug/NonShipping/)

### 1. Microsoft.AspNetCore.Mvc.Razor.Extensions.Tooling.Internal

**Location**: `src/Compiler/tools/Microsoft.AspNetCore.Mvc.Razor.Extensions.Tooling.Internal/`

**Purpose**: Internal transport for MVC/Razor Pages compilation extensions

**Target Framework**: netstandard2.0

**Package Type**: DevelopmentDependency (transport only)

**Contents**:
```
lib/netstandard2.0/
└── Microsoft.CodeAnalysis.Razor.Compiler.dll
```

**Description**: "Transport package for Razor extension binaries. For internal use only."

**Consumers**: Internal build processes, Microsoft.Net.Compilers.Razor.Toolset packaging

**Use Case**: Transports compiled binaries between build phases for MVC/Razor Pages support

---

### 2. Microsoft.CodeAnalysis.Razor.Tooling.Internal

**Location**: `src/Compiler/tools/Microsoft.CodeAnalysis.Razor.Tooling.Internal/`

**Purpose**: Internal utilities and object pooling for Razor compiler

**Target Framework**: netstandard2.0

**Contents**:
```
lib/netstandard2.0/
├── Microsoft.CodeAnalysis.Razor.Compiler.dll
├── Microsoft.AspNetCore.Razor.Utilities.Shared.dll
└── Microsoft.Extensions.ObjectPool.dll
```

**Key Component**: Object pooling infrastructure for performance-critical operations
- PooledArrayBuilder<T>
- Temporary object pooling
- Memory allocation reduction

**Description**: "Transport package for Razor compiler binaries. For internal use only."

**Consumers**:
- Microsoft.Net.Compilers.Razor.Toolset
- Source generator implementations

**Use Case**: Transport of binary dependencies for Razor source generation

---

### 3. Microsoft.AspNetCore.Razor.LanguageServer

**Location**: `src/Razor/src/Microsoft.AspNetCore.Razor.LanguageServer/`

**Purpose**: Core LSP server implementation (NOT packaged as NuGet, embedded in other packages)

**Target Frameworks**: net8.0, net9.0, net472

**IsPackable**: false (library only, not distributed as NuGet)

**Contents**:
- Complete Language Server Protocol implementation
- Request/response handlers for:
  - Completion
  - Hover
  - Signature help
  - Go to definition
  - Find references
  - Rename
  - Formatting
  - Diagnostics
  - CodeLens
  - Inlay hints
- Document management
- Semantic analysis integration

**Framework Used**: CLaSP (Common Language Server Protocol Framework)
- From Microsoft.CommonLanguageServerProtocol.Framework
- Source-only package for LSP scaffolding

**Dependencies**:
- Microsoft.CodeAnalysis.Razor.Compiler
- Microsoft.CodeAnalysis.Razor.Workspaces
- Microsoft.CommonLanguageServerProtocol.Framework (source package)

**Consumers** (embedded, not referenced):
- Microsoft.VisualStudioCode.RazorExtension (binary embedded)
- Microsoft.VisualStudio.RazorExtension (net472 binary embedded)
- rzls (compiled into executable)

**Shipping Model**: Distributed as compiled binary within other packages, not as standalone NuGet

**Use Case**: Core language services provider for all editor integrations, ensuring consistent Razor support across IDEs

---

### 4. Microsoft.AspNetCore.Razor.Utilities.Shared.Test

**Location**: `src/Shared/Microsoft.AspNetCore.Razor.Utilities.Shared.Test/`

**Purpose**: Test utilities for shared utility libraries

**Target Frameworks**: net8.0, net9.0, net472

**IsPackable**: false (test project)

**Contents**:
- Test infrastructure for utility library validation
- Combinatorial test helpers

**Dependencies**:
- Microsoft.AspNetCore.Razor.Test.Common
- Microsoft.AspNetCore.Razor.Utilities.Shared
- Xunit.Combinatorial

**Use Case**: Internal testing of shared utilities

---

### 5. Microsoft.NET.Sdk.Razor.SourceGenerators.Transport

**Location**: `src/Compiler/Microsoft.NET.Sdk.Razor.SourceGenerators.Transport/`

**Purpose**: Transport package for source generator binaries to SDK build tasks

**Target Framework**: netstandard2.0

**SDK**: Microsoft.Build.NoTargets (no compilation, pure transport)

**Contents**:
```
source-generators/
├── Microsoft.CodeAnalysis.Razor.Compiler.dll
├── Microsoft.Extensions.ObjectPool.dll
└── Other compiler binaries
```

**Description**: "Transport package for Microsoft.NET.SDK.Razor.SourceGenerator assemblies. For internal use only."

**Build Process**:
- PackLayout target gathers pre-built binaries
- Excludes .pdb files

**Consumers**: .NET SDK Razor source generator host

**Use Case**: Bridges between Razor compiler build output and SDK's source generator infrastructure

---

### 6. Razor.Diagnostics.Analyzers.Test

**Location**: `src/Analyzers/Razor.Diagnostics.Analyzers.Test/`

**Purpose**: Tests for Razor diagnostic analyzers

**Target Frameworks**: net8.0, net9.0, net472

**IsPackable**: false (test project)

**Contents**:
- Tests for analyzer behavior validation

**Dependencies**:
- Razor.Diagnostics.Analyzers (analyzer being tested)
- Microsoft.CodeAnalysis.CSharp.Analyzer.Testing

**Use Case**: Ensures analyzer implementations produce correct diagnostics

---

## PACKAGE DEPENDENCY GRAPH

```
Foundation Layer:
Microsoft.CodeAnalysis.Razor.Compiler (CORE) ⭐
├─ Microsoft.AspNetCore.Razor.Utilities.Shared
└─ [All other packages depend on this]

Tooling Layer:
Microsoft.CodeAnalysis.Razor.Workspaces
├─ Microsoft.CodeAnalysis.Razor.Compiler
└─ [Used by IDE integrations]

Language Server Layer:
Microsoft.AspNetCore.Razor.LanguageServer (not packaged)
├─ Microsoft.CodeAnalysis.Razor.Compiler
├─ Microsoft.CodeAnalysis.Razor.Workspaces
└─ CLaSP Framework

Build Tool Layer:
Microsoft.Net.Compilers.Razor.Toolset
├─ Microsoft.CodeAnalysis.Razor.Compiler
└─ Microsoft.CodeAnalysis.Razor.Tooling.Internal

IDE Integration Layer:
Microsoft.VisualStudio.RazorExtension (VSIX)
├─ Microsoft.CodeAnalysis.Razor.Compiler
├─ Microsoft.AspNetCore.Razor.LanguageServer (net472)
├─ Microsoft.CodeAnalysis.Razor.Workspaces
├─ Microsoft.VisualStudio.LanguageServices.Razor
└─ Microsoft.VisualStudio.LegacyEditor.Razor

Microsoft.VisualStudioCode.RazorExtension
├─ Microsoft.CodeAnalysis.Razor.Compiler
├─ Microsoft.CodeAnalysis.Razor.Workspaces
└─ Microsoft.CodeAnalysis.Remote.Razor

Microsoft.VisualStudio.DevKit.Razor
└─ Microsoft.CodeAnalysis.Razor.Workspaces

rzls.* (all platforms)
└─ Microsoft.AspNetCore.Razor.LanguageServer
    ├─ Microsoft.CodeAnalysis.Razor.Compiler
    └─ Microsoft.CodeAnalysis.Razor.Workspaces

Test Infrastructure:
Microsoft.AspNetCore.Razor.Test.Common
└─ Microsoft.CodeAnalysis.Razor.Compiler
```

---

## DISTRIBUTION CHANNELS

| Package | Channel | Audience | Typical Usage |
|---------|---------|----------|---------------|
| **Shipping Packages** |
| Microsoft.AspNetCore.Razor.Test.Common | NuGet.org | Test developers | Test project PackageReference |
| Microsoft.CodeAnalysis.Razor.Compiler | NuGet.org | SDK/tooling devs | Transitive dependency |
| Microsoft.Net.Compilers.Razor.Toolset | NuGet.org | Projects needing custom compiler | Development dependency |
| Microsoft.VisualStudio.RazorExtension | VS Marketplace | VS users | VS Extension Manager |
| Microsoft.VisualStudioCode.RazorExtension | NuGet.org (internal) | VS Code build | Extension build artifact |
| Microsoft.VisualStudio.DevKit.Razor | NuGet.org | C# DevKit users | Transitive via DevKit |
| rzls.* | NuGet.org | Editor plugin devs | Direct download/plugin install |
| **Non-Shipping Packages** |
| *.Tooling.Internal | NuGet (private?) | Build system | Internal build phases |
| *.LanguageServer | N/A (embedded) | N/A | Compiled into packages |
| *.Test | NuGet.org | Test projects | Internal test references |

---

## TAZOR TRANSITION IMPLICATIONS

### Packages That Need Forking/Renaming:

1. **Microsoft.CodeAnalysis.Razor.Compiler** → **Microsoft.CodeAnalysis.Tazor.Compiler**
   - Core compiler supporting `.tazor` extension
   - TUI rendering instead of Blazor ComponentBase
   - Remove net472/netstandard2.0, keep only net10.0+

2. **Microsoft.Net.Compilers.Razor.Toolset** → **Microsoft.Net.Compilers.Tazor.Toolset**
   - Build-time package for `.tazor` files
   - MSBuild targets updated for new extension
   - Source generator for `.tazor` files

3. **rzls.*** → **tzls.*** (Tazor Language Server)
   - Platform-specific executables
   - Support `.tazor` files
   - TUI-specific language features

4. **Microsoft.VisualStudioCode.RazorExtension** → **Microsoft.VisualStudioCode.TazorExtension**
   - VS Code extension for `.tazor` files
   - TUI component support

5. **Microsoft.VisualStudio.DevKit.Razor** → **Microsoft.VisualStudio.DevKit.Tazor**
   - C# DevKit integration for `.tazor`

### Packages That Can Be Dropped:

1. **Microsoft.VisualStudio.RazorExtension** - Visual Studio VSIX (net472)
   - Focus on VS Code only for Tazor
   - Drop net472 support entirely

2. **Microsoft.AspNetCore.Mvc.Razor.Extensions.Tooling.Internal**
   - Legacy MVC/Razor Pages support
   - Not needed for TUI applications

3. Test packages can be updated but keep similar structure

### Key Changes Needed:

1. **File Extension**: `.tazor` → `.tazor` throughout all packages
2. **Generated File Naming**: `*_tazor.g.cs` → `*_tazor.g.cs`
3. **Import Files**: `_Imports.tazor` → `_Imports.tazor`
4. **Target Frameworks**: Remove net472, netstandard2.0, net8.0, net9.0; keep only net10.0+
5. **Base Classes**: ComponentBase → TUI base class
6. **Rendering**: BuildRenderTree(RenderTreeBuilder) → TUI rendering model
7. **SDK Independence**: Remove dependency on Microsoft.NET.Sdk.Razor

---

## SUMMARY

This repository builds a complete Razor tooling ecosystem:

**Core**: Compiler + Workspaces + Language Server
**Build Integration**: Toolset package for MSBuild
**IDE Integration**: VS extension, VS Code extension, C# DevKit
**Universal Support**: Platform-specific language server executables (rzls)
**Testing**: Shared test utilities

**Critical Package**: `Microsoft.CodeAnalysis.Razor.Compiler` is the foundation - all other packages depend on it. This is where the `.tazor` → `.tazor` transition begins.

**Sample App Usage**: Our `sample/TestBlazorApp` uses `Microsoft.Net.Compilers.Razor.Toolset@10.0.0-dev` to consume locally-built packages, which is why `build-sample.ps1` works.
