#nullable enable
using System.Runtime.InteropServices;

namespace SmushSharp;

public static partial class UrlEventDetector
{
    [LibraryImport("libsmush.dylib", StringMarshalling = StringMarshalling.Utf8)]
    static partial void DetectLaunchUrl(UrlCallback callback, double timeoutSeconds);
    private delegate void UrlCallback(string url);

    // Public API
    public static string? DetectLaunchUrl(double timeoutSeconds)
    {
        string? result = null;
        DetectLaunchUrl(u => result = u, timeoutSeconds);
        return result;
    }
}