#import <Cocoa/Cocoa.h>
#import <stdlib.h> // for strdup

static NSString *g_detectedURL = nil;

@interface URLHandler : NSObject
@end

@implementation URLHandler
// This method is just here so we can use the selector; actual installation is done manually.
- (void)handleGetURLEvent:(NSAppleEventDescriptor *)evt withReplyEvent:(NSAppleEventDescriptor *)reply {
    NSString *urlString = [[evt paramDescriptorForKeyword:keyDirectObject] stringValue];
    if (urlString) {
        g_detectedURL = [urlString copy]; // keep a copy
    }
}
@end

__attribute__((visibility("default")))
const char *DetectLaunchUrlNative(double timeoutSeconds)
{
    @autoreleasepool {
        g_detectedURL = nil;

        // Install the AppleEvent handler *immediately*
        URLHandler *handler = [URLHandler new];
        [[NSAppleEventManager sharedAppleEventManager]
            setEventHandler:handler
                andSelector:@selector(handleGetURLEvent:withReplyEvent:)
              forEventClass:kInternetEventClass
                 andEventID:kAEGetURL];

        // To ensure the process is treated as an AppKit app for event delivery:
        (void)[NSApplication sharedApplication];

        NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:timeoutSeconds];
        // Pump the run loop manually; kCFRunLoopDefaultMode is equivalent to NSDefaultRunLoopMode.
        while (!g_detectedURL && [deadline timeIntervalSinceNow] > 0) {
            [[NSRunLoop currentRunLoop]
                runMode:NSDefaultRunLoopMode
               beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }

        if (!g_detectedURL) {
            return NULL;
        }
        
		// Duplicate the bytes with malloc (strdup) since pointer might have a lifetime shorter than NSString
		// https://developer.apple.com/documentation/foundation/nsstring#//apple_ref/occ/instp/NSString/UTF8String
		const char *utf8 = strdup([g_detectedURL UTF8String]);
		// Drop our retain so the NSString can disappear, this is because it won't be needed again
		g_detectedURL = nil;
		
		// Return the caller‑owned buffer, C# side frees with free()
		return utf8;
		// For more info on returning strings: https://stackoverflow.com/questions/27914934/how-to-replace-a-char-in-an-an-char-array-xcode?utm_source=chatgpt.com
	}
}