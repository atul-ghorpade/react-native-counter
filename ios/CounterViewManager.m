#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>

@interface RCT_EXTERN_MODULE(CounterViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(count, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(onCountChange, RCTBubblingEventBlock)

RCT_EXTERN_METHOD(increment:(nonnull NSNumber *)reactTag)
RCT_EXTERN_METHOD(decrement:(nonnull NSNumber *)reactTag)

@end

