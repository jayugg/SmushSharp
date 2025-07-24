# SmushSharp - Simple macOS URL Scheme Handler

A minimal C# wrapper for **Smush**—a tiny Objective-C shim that lets a .NET 8 app detect custom URL-scheme launches on macOS (x64).

---

## Prerequisites

- **macOS** with the Xcode command-line tools installed:
  ```bash
  xcode-select --install
  ```
- **.NET 8 SDK** (for `dotnet build` / `pack` / `run`).

---

## Compilation

**Build the native shim & C# library**
From the `src/SmushSharp` folder:
```bash
dotnet build -c Release
```
You can find the output in `bin/Release/net8.0`

---

## Installing the NuGet package

Once you’ve **packed**, you can install the nuget package like this:

```bash
# from your own .NET app folder
dotnet add package SmushSharp --version 1.x.x --source .
```

Alternatively, you can get it from NuGet.org:
```bash
dotnet add package SmushSharp --version 1.x.x
```
---

## Usage

**Register your URL scheme** in your **Info.plist** (inside your `.app` bundle):

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>com.yourcompany.yourapp</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>your-custom-scheme</string>
    </array>
  </dict>
</array>
```

**Call** `DetectLaunchUrl` early in your `Main`:

```csharp
using SmushSharp;

class Program
{
    static void Main(string[] args)
    {
        // Wait up to 1 seconds for a URL
        string? launchUrl = UrlDetector.DetectLaunchUrl(2.0);
        // Your code to handle the URL ...
    }
}
```

**Run** your app:
 - Launch your app normally so that macOS can register the URL scheme. If necessary, you can manually register the URL scheme by running:
     ```bash
     /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f <yourAppPath>.app
     ```
 - If you now launch via `open your-custom-scheme://foo`, the URL will be relayed into your C# callback.

---