#import "UIViewHelper.h"

@implementation UIView (RootView)

- (UIView *)rootView {
    if (self.superview) {
        return [self.superview rootView];
    }
    return self;
}

@end
