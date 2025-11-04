# Building Sample Applications

This guide explains how to build and test your changes using the sample application in this repository.

## Overview

The sample application at [sample/TestBlazorApp/](../../sample/TestBlazorApp/) is a Blazor app configured to use the locally built Razor compiler packages. It's useful for testing changes to the Razor tooling in a real-world scenario.

## Quick Start

### Using the Build Script

The easiest way to build and test the sample is to use the automated script:

```powershell
./build-sample.ps1
```

The script will automatically activate the environment if needed, then perform all necessary steps in the correct order with clear feedback at each stage.

### Prerequisites (Optional)

The build script will automatically source [activate.ps1](../../activate.ps1) if the environment isn't already activated. However, you can manually activate it first if preferred:

```powershell
. ./activate.ps1
```

This sets up the correct `DOTNET_ROOT` and ensures the local .NET SDK is used.

## What the Script Does

The [build-sample.ps1](../../build-sample.ps1) script executes the following workflow:

### 1. Environment Validation

Checks that `activate.ps1` has been sourced by verifying the `DOTNET_ROOT` environment variable is set.

### 2. Clear NuGet Cache

```powershell
dotnet nuget locals all --clear
```

**Why this is required:** The sample app references packages built by this repository (like `Microsoft.Net.Compilers.Razor.Toolset@10.0.0-dev`). NuGet caches packages globally, so without clearing the cache, the sample would continue using old versions even after you rebuild.

This step ensures the sample app picks up your freshly built packages.

### 3. Build and Pack

```powershell
./build.sh --pack
```

Builds all projects in the repository and creates NuGet packages in `artifacts/packages/Debug/`.

**Key packages built:**
- `Microsoft.Net.Compilers.Razor.Toolset` - The main Razor compiler toolset (used by the sample)
- `Microsoft.CodeAnalysis.Razor.Compiler` - Core Razor compiler
- `Microsoft.AspNetCore.Razor.LanguageServer` - Language server for IDE support
- `rzls.*` - Razor Language Server executables for various platforms
- Many other packages (see `artifacts/packages/Debug/Shipping/` and `NonShipping/`)

### 4. Build Sample Application

```powershell
dotnet build ./sample/TestBlazorApp/TestBlazorApp.csproj
```

Builds the sample Blazor app, which triggers the Razor source generators and compiler to process `.tazor` files.

The sample project has `EmitCompilerGeneratedFiles` enabled, so you can inspect the generated C# code in [sample/TestBlazorApp/Generated/](../../sample/TestBlazorApp/Generated/).

## Manual Workflow

If you prefer to run commands individually or need more control:

```powershell
# 1. Activate environment (if not already done)
. ./activate.ps1

# 2. Clear NuGet cache
dotnet nuget locals all --clear

# 3. Build and pack
./build.sh --pack

# 4. Build sample
dotnet build ./sample/TestBlazorApp/TestBlazorApp.csproj
```

## Sample Application Details

The test Blazor app at [sample/TestBlazorApp/](../../sample/TestBlazorApp/) is configured to:

- Target .NET 9.0
- Use `Microsoft.Net.Compilers.Razor.Toolset@10.0.0-dev` from local packages
- Emit compiler-generated files to the `Generated/` directory for inspection
- Disable centrally managed package versions to use the local dev version

### What to Check After Building

1. **Build success** - The sample should build without errors
2. **Generated files** - Check [sample/TestBlazorApp/Generated/](../../sample/TestBlazorApp/Generated/) for the C# files generated from `.tazor` components
3. **Compiler output** - Look for any warnings or messages from the Razor compiler

## Troubleshooting

### "Package not found" errors

If you see errors about missing packages:
- Ensure you ran `./build.sh --pack` successfully
- Check that packages exist in `artifacts/packages/Debug/Shipping/`
- Verify the NuGet cache was cleared

### "dotnet not found" or wrong version

You likely haven't sourced `activate.ps1`. Run:
```powershell
. ./activate.ps1
```

### Changes not reflected in sample build

The NuGet cache may not have been cleared. Run:
```powershell
dotnet nuget locals all --clear
```

Then rebuild with `./build-sample.ps1`.

## Related Documentation

- [BuildFromSource.md](BuildFromSource.md) - Complete build instructions for the repository
- [ProjectsAndLayering.md](../ProjectsAndLayering.md) - Architecture and project structure
- [Razor Basics](../Onboarding%20Docs/01_Razor_Basics.md) - Introduction to Razor concepts
