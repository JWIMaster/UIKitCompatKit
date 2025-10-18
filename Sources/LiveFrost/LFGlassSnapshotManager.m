#import "LFGlassSnapshotManager.h"

@interface LFGlassSnapshotManager ()

@property (nonatomic, assign) CGImageRef sharedSnapshot;
@property (nonatomic, assign) NSTimeInterval lastUpdateTime;

@end

@implementation LFGlassSnapshotManager

+ (instancetype)sharedManager {
    static LFGlassSnapshotManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [LFGlassSnapshotManager new];
    });
    return manager;
}

- (CGImageRef)snapshotForTargetView:(UIView *)view {
    NSTimeInterval now = CACurrentMediaTime();

    // Only update once per frame (~60fps)
    if (!_sharedSnapshot || now - _lastUpdateTime > (1.0 / 60.0)) {
        CGSize size = view.bounds.size;
        if (size.width <= 0 || size.height <= 0) return nil;

        // Create bitmap context
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     size.width,
                                                     size.height,
                                                     8,
                                                     size.width * 4,
                                                     colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);

        // Render the layer
        [view.layer renderInContext:context];

        // Create CGImage
        CGImageRef image = CGBitmapContextCreateImage(context);
        CGContextRelease(context);

        if (_sharedSnapshot) CGImageRelease(_sharedSnapshot);
        _sharedSnapshot = CGImageRetain(image);
        CGImageRelease(image);

        _lastUpdateTime = now;
    }

    return _sharedSnapshot;
}

@end
