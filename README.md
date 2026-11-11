# FclEx.Wmi [![LICENSE](https://img.shields.io/github/license/huoshan12345/FclEx.Wmi.svg?style=flat)](LICENSE.TXT) [![Build](https://github.com/huoshan12345/FclEx.Wmi/actions/workflows/build.yml/badge.svg)](https://github.com/huoshan12345/FclEx.Wmi/actions/workflows/build.yml)

FclEx means **fundamental class libraries extensions**.

FclEx.Wmi provides focused extensions for `System.Management` and generated C# models for Windows Management Instrumentation (WMI). It follows the conventions of [FclEx](https://github.com/huoshan12345/FclEx), with helpers for querying Windows hardware, operating system information, and performance data.

The library maps WMI query results to ordinary C# objects, so application code can work with named properties instead of repeatedly accessing values by string keys.

## Packages

|Package|Target Frameworks|NuGet|
|----|----|----|
|[FclEx.Wmi](src/FclEx.Wmi)|![net8.0-windows](https://img.shields.io/badge/net--windows-8.0-30a14e.svg) ![net9.0-windows](https://img.shields.io/badge/net--windows-9.0-30a14e.svg) ![net10.0-windows](https://img.shields.io/badge/net--windows-10.0-30a14e.svg) ![net11.0-windows](https://img.shields.io/badge/net--windows-11.0-30a14e.svg) |[![](https://img.shields.io/nuget/v/FclEx.Wmi?logo=nuget&label=nuget)](https://www.nuget.org/packages/FclEx.Wmi)|


## Features

- Generated models in the `CIMV2` namespace for `Win32_*` WMI classes, including disk drives, processors, operating systems, and performance counters.
- `ReadAs<T>()` to map a `ManagementBaseObject` to a model with matching public, readable and writable properties.
- `Get<T>()` to read a property with a fallback value when its WMI value is `null`.
- `Enumerate()` to expose a searcher's results as `IEnumerable<ManagementObject>` for use with LINQ.
- Model XML documentation derived from WMI class and property descriptions.

## Installation

```shell
dotnet add package FclEx.Wmi
```

Use a Windows target framework such as `net10.0-windows` in the consuming project. WMI access through `System.Management` requires Windows.

## Usage

### Query typed WMI models

```csharp
using System;
using System.Management;
using CIMV2;
using FclEx.Wmi;

using var searcher = new ManagementObjectSearcher(
    @"root\CIMV2",
    "SELECT * FROM Win32_DiskDrive");
using var results = searcher.Get();

foreach (ManagementObject item in results)
{
    using (item)
    {
        var disk = item.ReadAs<Win32_DiskDrive>();
        Console.WriteLine($"{disk.Model}: {disk.Size} bytes ({disk.PNPDeviceID})");
    }
}
```

The model namespace is `CIMV2`; the extension methods are in `FclEx.Wmi`. Models are data containers populated from query results.

### Read individual properties

Use `Get<T>()` when only a few values are needed:

```csharp
using System;
using System.Management;
using FclEx.Wmi;

using var searcher = new ManagementObjectSearcher(
    "SELECT Model FROM Win32_DiskDrive");
using var results = searcher.Get();

foreach (ManagementObject item in results)
{
    using (item)
    {
        var model = item.Get<string>("Model", "Unknown");
        Console.WriteLine(model);
    }
}
```

## Repository Layout

- `src/FclEx.Wmi/` contains the runtime extensions and compiles the generated models into the library.
- `src/FclEx.Wmi.SourceGenerator/` contains the model generator and cached WMI model sources. It is a build tool and is not published as a separate NuGet package.
- `test/` contains Windows WMI integration tests.
- `build/` contains package metadata and release helper scripts.

## Building And Testing

Build on Windows with the .NET 11 SDK. Running the tests across all target frameworks also requires the .NET 8, 9, 10, and 11 runtimes.

```shell
dotnet build FclEx.Wmi.slnx -c Release
dotnet test --solution FclEx.Wmi.slnx -c Release --no-build
```

The library build invokes the generator and includes its output from `src/FclEx.Wmi/obj/Generated/`. The generator uses cached sources from its `Resources/` directory and can refresh them from local `root\CIMV2` metadata on Windows. Available models can therefore depend on the WMI metadata used during generation; runtime query results depend on the machine and its installed providers.

## Notes

- Use `SELECT *` with `ReadAs<T>()` when mapping a complete generated model: it reads every matching public, readable and writable model property by name. For projected queries, use `Get<T>()` or a custom model containing only the selected properties.
- `Get<T>()` casts the WMI value directly to `T`; it does not convert types. Its fallback handles `null` values, while missing properties and incompatible types can still throw.
- Generated models include properties, but omit WMI reference properties and do not wrap WMI methods.
- WMI queries may require additional permissions depending on the class, provider, and target machine.

## License

FclEx.Wmi is licensed under the [MIT License](LICENSE.TXT).
