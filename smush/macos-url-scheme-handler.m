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
const char *DetectLaunchUrlNative(double timeoutSeconds)
{
  @autoreleasepool {
    [g_detectedURL release];
    g_detectedURL = nil;

    NSApplication *app = [NSApplication sharedApplication];
    app.delegate = [[UrlDelegate alloc] init];

    dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutSeconds * NSEC_PER_SEC)),
      dispatch_get_main_queue(),
      ^{ [NSApp stop:nil]; }
    );

    [app run]; // blocks until stop()
  }

  if (!g_detectedURL) return NULL;
  // UTF8String is owned by the NSString we just copied, so it’s safe
  return [g_detectedURL UTF8String];
}
