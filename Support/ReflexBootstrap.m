// Enable the existing FLEX integration after both images have loaded.
// This only selects the Swift metadata reader; it does not alter app fields.
#import <Foundation/Foundation.h>
#import <objc/message.h>

__attribute__((constructor))
static void NBEnableReflex(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        Class mirror = NSClassFromString(@"FLEXSwiftMirror");
        Class explorer = NSClassFromString(@"FLEXObjectExplorer");
        SEL selector = NSSelectorFromString(@"setReflexAvailable:");
        if (mirror && explorer && [explorer respondsToSelector:selector]) {
            ((void (*)(id, SEL, BOOL))objc_msgSend)(explorer, selector, YES);
            NSLog(@"[NBReflex] Swift mirror available. Close and reopen FLEX's object explorer.");
        } else {
            NSLog(@"[NBReflex] Integration unavailable: mirror=%@ explorer=%@", mirror, explorer);
        }
    });
}
