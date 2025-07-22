#nullable enable
using System.Runtime.InteropServices;

namespace Mush;

public static partial class UrlDetector
{
    [LibraryImport("Lib/libUrlHandler.dylib")]
    static partial void detect_launch_url(UrlCallback callback, double timeoutSeconds);
    private delegate void UrlCallback([MarshalAs(UnmanagedType.LPStr)] string url);

    // Public API
    public static string? DetectLaunchUrl(double timeoutSeconds)
    {
        string? result = null;
        detect_launch_url(u => result = u, timeoutSeconds);
        return result;
    }
}