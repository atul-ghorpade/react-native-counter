#ifdef RCT_NEW_ARCH_ENABLED
#import "CounterViewComponentView.h"
#import "CounterViewBridge.h"
#import "CounterViewFabric.h"

#import <react/renderer/components/RNCounterSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNCounterSpec/EventEmitters.h>
#import <react/renderer/components/RNCounterSpec/Props.h>
#import <react/renderer/components/RNCounterSpec/RCTComponentViewHelpers.h>

#import <React/RCTFabricComponentsPlugins.h>

using namespace facebook::react;

@interface CounterViewComponentView () <RCTCounterViewViewProtocol>
@end

@implementation CounterViewComponentView {
    UIView *_view;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<CounterViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const CounterViewProps>();
        _props = defaultProps;

        _view = [CounterViewBridge createCounterView];
        
        self.contentView = _view;
    }

    return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<CounterViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<CounterViewProps const>(props);

    if (oldViewProps.count != newViewProps.count) {
        [CounterViewBridge setCount:@(newViewProps.count) forView:_view];
    }

    [super updateProps:props oldProps:oldProps];
}

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
    RCTCounterViewHandleCommand(self, commandName, args);
}

- (void)increment
{
    [CounterViewBridge incrementView:_view];
}

- (void)decrement
{
    [CounterViewBridge decrementView:_view];
}

Class<RCTComponentViewProtocol> CounterViewCls(void)
{
    return CounterViewComponentView.class;
}

@end

#endif /* RCT_NEW_ARCH_ENABLED */

