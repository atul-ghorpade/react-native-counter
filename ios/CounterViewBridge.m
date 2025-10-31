#import "CounterViewBridge.h"
#import <objc/runtime.h>
#import <React/RCTViewManager.h>

@implementation CounterViewBridge

+ (UIView *)createCounterView
{
    // Dynamically load the Swift class
    Class counterViewClass = NSClassFromString(@"CounterView");
    if (counterViewClass) {
        return [[counterViewClass alloc] init];
    }
    return [[UIView alloc] init]; // Fallback
}

+ (void)setCount:(NSNumber *)count forView:(UIView *)view
{
    // Use KVC to set the count property
    @try {
        [view setValue:count forKey:@"count"];
    } @catch (NSException *exception) {
        NSLog(@"Failed to set count: %@", exception);
    }
}

+ (void)incrementView:(UIView *)view
{
    // Call the increment method using performSelector
    SEL incrementSelector = NSSelectorFromString(@"increment");
    if ([view respondsToSelector:incrementSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [view performSelector:incrementSelector];
#pragma clang diagnostic pop
    }
}

+ (void)decrementView:(UIView *)view
{
    // Call the decrement method using performSelector
    SEL decrementSelector = NSSelectorFromString(@"decrement");
    if ([view respondsToSelector:decrementSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [view performSelector:decrementSelector];
#pragma clang diagnostic pop
    }
}

+ (void)setCountChangeCallback:(CountChangeCallback)callback forView:(UIView *)view
{
    // Store the callback as an associated object
    objc_setAssociatedObject(view, @"countChangeCallback", callback, OBJC_ASSOCIATION_COPY);
    
    // Create a wrapper block that bridges to RCTBubblingEventBlock
    RCTBubblingEventBlock eventBlock = ^(NSDictionary *event) {
        NSNumber *count = event[@"count"];
        if (count && callback) {
            callback([count integerValue]);
        }
    };
    
    // Set the onCountChange property
    @try {
        [view setValue:eventBlock forKey:@"onCountChange"];
    } @catch (NSException *exception) {
        NSLog(@"Failed to set onCountChange: %@", exception);
    }
}

@end

