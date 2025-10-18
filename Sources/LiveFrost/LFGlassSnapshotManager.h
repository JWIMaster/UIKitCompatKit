#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFGlassSnapshotManager : NSObject

+ (instancetype)sharedManager;

/// Returns a shared snapshot of the target view hierarchy
- (CGImageRef)snapshotForTargetView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
