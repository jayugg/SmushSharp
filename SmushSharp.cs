using System;
using System.Runtime.InteropServices;

#nullable enable

namespace SmushSharp;

static partial class NativeMethods
{
    // returns a UTF8‐encoded char* (or NULL), caller must free()
    [LibraryImport("libsmush.dylib")]
    public static partial IntPtr DetectLaunchUrlNative(double timeoutSeconds);
}

public static class SmushSharp
{
    public static string? DetectLaunchUrl(double timeoutSeconds)
    {
        IntPtr ptr = NativeMethods.DetectLaunchUrlNative(timeoutSeconds);
        if (ptr == IntPtr.Zero) return null;
        try
        {
            return Marshal.PtrToStringUTF8(ptr);
        }
        finally
        {
            unsafe { NativeMemory.Free((void*)ptr); }
        }
    }
}
