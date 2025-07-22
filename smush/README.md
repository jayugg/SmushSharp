# Smush – Simple macOS URL Scheme Handler

A simple Obj-C shim to handle custom URL schemes in macOS applications.  
This library allows you to handle incoming URLs in your application using native Cocoa APIs.

---

## Compilation

To compile the library, you need to be on macOS and have Xcode command line tools installed. You can install them by running:

```bash
xcode-select --install
```

Then, compile the library using the following command:

```bash
clang -dynamiclib -arch x86_64 -framework Cocoa \
      -o libsmush.dylib macos-url-scheme-handler.m
```

---

## Usage with C#

Smush can be used in C# applications by loading the compiled dynamic library and using P/Invoke to call the necessary functions.

### Example with `LibraryImport`

```csharp
[LibraryImport("libsmush.dylib")]
static partial void DetectLaunchUrl(UrlCallback callback, double timeoutSeconds);
private delegate void UrlCallback(string url);
```

### Example with `DllImport`

```csharp
[DllImport("libsmush.dylib")]
private static extern void DetectLaunchUrl(UrlCallback callback, double timeoutSeconds);
private delegate void UrlCallback(string url);
```

---

## Info.plist

Your application will need to receive the URL event—this requires you to register the URL scheme in your `Info.plist` file:

```xml
<!-- In Info.plist -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>your-custom-scheme</string>
        </array>
    </dict>
</array>
```

For more information on handling url schemes in macOS from other apps, see also: https://blakewilliams.me/posts/handling-macos-url-schemes-with-go

