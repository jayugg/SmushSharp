#nullable enable
using System.Runtime.InteropServices;

namespace SmushSharp;

public static partial class UrlEventDetector
{
    [LibraryImport("libsmush.dylib")]
    static partial void DetectLaunchUrl(UrlCallback callback, double timeoutSeconds);
    private delegate void UrlCallback([MarshalAs(UnmanagedType.LPStr)] string url);

    // Public API
    public static string? DetectLaunchUrl(double timeoutSeconds)
    {
        string? result = null;
        DetectLaunchUrl(u => result = u, timeoutSeconds);
        return result;
    }
}