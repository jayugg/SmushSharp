#import <Cocoa/Cocoa.h>

static NSString *g_detectedURL = nil;

@interface UrlDelegate : NSObject <NSApplicationDelegate> @end
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
  // copy() gives us a +1 retain, so it lives past the @autoreleasepool
  [g_detectedURL release];
  g_detectedURL = [[[evt paramDescriptorForKeyword:keyDirectObject]
                    stringValue]
                   copy];
  [NSApp stop:nil];
}
@end

__attribute__((visibility("default")))
const char* DetectLaunchUrlNative(double timeoutSeconds)
{
  @autoreleasepool {
    // clear any old URL
    [g_detectedURL release];
    g_detectedURL = nil;

    NSApplication *app = [NSApplication sharedApplication];
    app.delegate = [[UrlDelegate alloc] init];

    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:timeoutSeconds];

    // pump the run loop until we get a URL or timeout
    while (g_detectedURL == nil
           && [deadline timeIntervalSinceNow] > 0)
    {
      // runs one pass in the *default* mode for up to 0.1s
      [[NSRunLoop currentRunLoop]
         runMode:NSDefaultRunLoopMode
        beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    if (!g_detectedURL) return NULL;

    // we’ve copied the NSString, so UTF8String is valid
    return [g_detectedURL UTF8String];
  }
}