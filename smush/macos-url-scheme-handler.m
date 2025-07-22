#import <Cocoa/Cocoa.h>

typedef void (*UrlCallback)(const char *url);
static UrlCallback s_callback;

// Delegate to catch the URL event
@interface UrlDelegate : NSObject <NSApplicationDelegate>
@end

@implementation UrlDelegate
- (void)applicationWillFinishLaunching:(NSNotification*)n {
    [[NSAppleEventManager sharedAppleEventManager]
            setEventHandler:self
                andSelector:@selector(handleGetURLEvent:withReplyEvent:)
              forEventClass:kInternetEventClass
                 andEventID:kAEGetURL];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor*)evt
           withReplyEvent:(NSAppleEventDescriptor*)reply
{
    NSString *u = [[evt paramDescriptorForKeyword:keyDirectObject] stringValue];
    if (s_callback) s_callback(u.UTF8String);
    [NSApp stop:nil];  // quits the run loop immediately
}
@end

__attribute__((visibility("default")))
void DetectLaunchUrl(UrlCallback callback, double timeoutSeconds)
{
    s_callback = callback;

    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        app.delegate = [[UrlDelegate alloc] init];

        // Schedule a GCD‐based timeout that fires even inside -[app run]
        dispatch_after(
                dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutSeconds * NSEC_PER_SEC)),
                dispatch_get_main_queue(),
                ^{
                    [NSApp stop:nil];
                }
        );

        // This will block until either:
        // – you get a kAEGetURL event (and handleGetURLEvent: calls stop)
        // – OR the above dispatch_after calls stop after timeoutSeconds
        [app run];
    }
}