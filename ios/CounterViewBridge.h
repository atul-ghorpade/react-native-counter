#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CounterViewBridge : NSObject

+ (UIView *)createCounterView;
+ (void)setCount:(NSNumber *)count forView:(UIView *)view;
+ (void)incrementView:(UIView *)view;
+ (void)decrementView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END

