//
//  LFGlassView.m
//
//  Updated to correctly handle nested container views and use UIKit snapshotting.
//

#import "LFGlassView.h"
#import "LFDisplayBridge.h"

@interface LFGlassView () <LFDisplayBridgeTriggering>

@property (nonatomic, assign, readonly) CGSize cachedBufferSize;
@property (nonatomic, assign, readonly) CGSize scaledSize;

@property (nonatomic, assign, readonly) CGContextRef effectInContext;
@property (nonatomic, assign, readonly) CGContextRef effectOutContext;

@property (nonatomic, assign, readonly) vImage_Buffer effectInBuffer;
@property (nonatomic, assign, readonly) vImage_Buffer effectOutBuffer;

@property (nonatomic, assign, readonly) uint32_t precalculatedBlurKernel;

@property (nonatomic, assign, readonly) BOOL shouldLiveBlur;
@property (nonatomic, assign, readonly) NSUInteger currentFrameInterval;


@property (nonatomic, strong, readonly) CALayer *backgroundColorLayer;
@property (nonatomic, assign) CGFloat rawBlurRadius;

@end

#if !__has_feature(objc_arc)
#error This implementation file must be compiled with Objective-C ARC.
#endif

@implementation LFGlassView
@dynamic scaledSize;
@dynamic liveBlurring;

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.clipsToBounds = YES;
    self.blurRadius = 4.0f;
    _backgroundColorLayer = [CALayer layer];
    _backgroundColorLayer.actions = @{@"backgroundColor": [NSNull null], @"bounds": [NSNull null], @"position": [NSNull null]};
    self.backgroundColor = [UIColor clearColor];
    self.scaleFactor = 0.25f;
    self.opaque = NO;
    self.userInteractionEnabled = NO;
    self.layer.actions = @{@"contents": [NSNull null]};
    self.layer.drawsAsynchronously = YES;
    _shouldLiveBlur = YES;
    _frameInterval = 1;
    _currentFrameInterval = 0;
}

- (void)dealloc {
    if (_effectInContext) CGContextRelease(_effectInContext);
    if (_effectOutContext) CGContextRelease(_effectOutContext);
    [self stopLiveBlurring];
}

#pragma mark - Public properties

- (void)setBlurRadius:(CGFloat)blurRadius {
    _rawBlurRadius = blurRadius;
    [self updatePrecalculatedBlurKernel];
}

- (void)updatePrecalculatedBlurKernel {
    CGFloat effectiveRadius = _rawBlurRadius * _scaleFactor;
    uint32_t radius = (uint32_t)floor(effectiveRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
    radius += (radius + 1) % 2;
    _precalculatedBlurKernel = radius;
}

- (void)setScaleFactor:(CGFloat)scaleFactor {
    _scaleFactor = scaleFactor;
    CGSize scaledSize = self.scaledSize;
    [self updatePrecalculatedBlurKernel];
    if (!CGSizeEqualToSize(_cachedBufferSize, scaledSize)) {
        _cachedBufferSize = scaledSize;
        [self recreateImageBuffers];
    }
}

- (CGSize)scaledSize {
    return CGSizeMake(_scaleFactor * CGRectGetWidth(self.bounds),
                      _scaleFactor * CGRectGetHeight(self.bounds));
}

#pragma mark - Frame & bounds adjustments

- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    [super setFrame:frame];
    [self adjustImageBuffersAndLayerFromFrame:oldFrame];
}

- (void)setBounds:(CGRect)bounds {
    CGRect oldFrame = self.frame;
    [super setBounds:bounds];
    [self adjustImageBuffersAndLayerFromFrame:oldFrame];
}

- (void)setCenter:(CGPoint)center {
    CGRect oldFrame = self.frame;
    [super setCenter:center];
    [self adjustImageBuffersAndLayerFromFrame:oldFrame];
}

- (void)setBackgroundColor:(UIColor *)color {
    [super setBackgroundColor:color];
    CGColorRef cgColor = color.CGColor;
    if (CGColorGetAlpha(cgColor)) {
        _backgroundColorLayer.backgroundColor = cgColor;
        [self.layer insertSublayer:_backgroundColorLayer atIndex:0];
    } else {
        [_backgroundColorLayer removeFromSuperlayer];
    }
}

#pragma mark - Nested container support

- (CGRect)frameInSnapshotTargetView {
    UIView *targetView = self.snapshotTargetView ?: self.superview;
    if (!targetView) return self.frame;
    return [self convertRect:self.bounds toView:targetView];
}

- (void)adjustImageBuffersAndLayerFromFrame:(CGRect)oldFrame {
    if (CGRectEqualToRect(oldFrame, self.frame)) return;
    
    _backgroundColorLayer.frame = self.bounds;
    
    if (!CGRectIsEmpty(self.bounds)) {
        CGRect visibleRect = [self frameInSnapshotTargetView];
        [self recreateImageBuffersForVisibleRect:visibleRect];
    } else {
        [self stopLiveBlurring];
        return;
    }
    
    [self startLiveBlurringIfReady];
}

#pragma mark - Lifecycle

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self startLiveBlurringIfReady];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        [self startLiveBlurringIfReady];
    } else {
        [self stopLiveBlurring];
    }
}

#pragma mark - Live blur control

- (BOOL)isLiveBlurring { return _shouldLiveBlur; }

- (void)setLiveBlurring:(BOOL)liveBlurring {
    if (liveBlurring == _shouldLiveBlur) return;
    _shouldLiveBlur = liveBlurring;
    if (liveBlurring) [self startLiveBlurringIfReady];
    else [self stopLiveBlurring];
}

- (void)startLiveBlurringIfReady {
    if ([self isReadyToLiveBlur]) {
        [self forceRefresh];
        [[LFDisplayBridge sharedInstance] addSubscribedViewsObject:self];
    }
}

- (void)stopLiveBlurring {
    [[LFDisplayBridge sharedInstance] removeSubscribedViewsObject:self];
}

- (BOOL)isReadyToLiveBlur {
    return (!CGRectIsEmpty(self.bounds) && self.superview && self.window && _shouldLiveBlur);
}

- (BOOL)blurOnceIfPossible {
    if (!CGRectIsEmpty(self.bounds) && self.layer.presentationLayer) {
        [self forceRefresh];
        return YES;
    }
    return NO;
}

#pragma mark - Frame interval

- (void)setFrameInterval:(NSUInteger)frameInterval {
    if (frameInterval == _frameInterval) return;
    if (frameInterval == 0) {
        NSLog(@"warning: attempted to set frameInterval to 0; must be 1 or greater");
        return;
    }
    _frameInterval = frameInterval;
}

#pragma mark - Image buffers

- (void)recreateImageBuffers {
    CGRect visibleRect = [self frameInSnapshotTargetView];
    [self recreateImageBuffersForVisibleRect:visibleRect];
}

- (void)recreateImageBuffersForVisibleRect:(CGRect)visibleRect {
    CGSize bufferSize = self.scaledSize;
    if (bufferSize.width == 0 || bufferSize.height == 0) return;
    
    size_t bufferWidth = (size_t)rint(bufferSize.width);
    size_t bufferHeight = (size_t)rint(bufferSize.height);
    if (bufferWidth == 0) bufferWidth = 1;
    if (bufferHeight == 0) bufferHeight = 1;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef effectInContext = CGBitmapContextCreate(NULL, bufferWidth, bufferHeight, 8, bufferWidth * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextRef effectOutContext = CGBitmapContextCreate(NULL, bufferWidth, bufferHeight, 8, bufferWidth * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);
    
    if (_effectInContext) CGContextRelease(_effectInContext);
    if (_effectOutContext) CGContextRelease(_effectOutContext);
    
    _effectInContext = effectInContext;
    _effectOutContext = effectOutContext;
    
    _effectInBuffer = (vImage_Buffer){.data = CGBitmapContextGetData(effectInContext),
                                      .width = CGBitmapContextGetWidth(effectInContext),
                                      .height = CGBitmapContextGetHeight(effectInContext),
                                      .rowBytes = CGBitmapContextGetBytesPerRow(effectInContext)};
    _effectOutBuffer = (vImage_Buffer){.data = CGBitmapContextGetData(effectOutContext),
                                       .width = CGBitmapContextGetWidth(effectOutContext),
                                       .height = CGBitmapContextGetHeight(effectOutContext),
                                       .rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext)};
}

#pragma mark - Refresh

- (void)forceRefresh {
    _currentFrameInterval = _frameInterval - 1;
    [self refresh];
}

UIImage* _UICreateScreenUIImage(void);

- (CGRect)absoluteFrameInScreen {
    UIView *view = self;
    CGRect frame = self.bounds;
    
    while (view) {
        frame.origin.x += view.frame.origin.x;
        frame.origin.y += view.frame.origin.y;
        view = view.superview;
    }
    
    UIWindow *window = self.window ?: [UIApplication sharedApplication].keyWindow;
    frame.origin.x += window.frame.origin.x;
    frame.origin.y += window.frame.origin.y;
    
    return frame;
}

- (void)refresh {
    if (++_currentFrameInterval < _frameInterval) return;
    _currentFrameInterval = 0;

    if (!self.window || CGRectIsEmpty(self.bounds)) return;

    self.hidden = YES;

    // 1. Capture the full screen using private API
    UIImage *screenImage = _UICreateScreenUIImage();
    if (!screenImage) {
        self.hidden = NO;
        return;
    }

    // 2. Compute the absolute frame in screen coordinates
    CGRect screenFrame = [self absoluteFrameInScreen];

    // 3. Scale for buffer
    CGSize scaledSize = self.scaledSize;
    CGRect scaledRect = CGRectMake(screenFrame.origin.x * _scaleFactor,
                                   screenFrame.origin.y * _scaleFactor,
                                   screenFrame.size.width * _scaleFactor,
                                   screenFrame.size.height * _scaleFactor);

    // 4. Clear previous contents
    CGContextClearRect(_effectInContext, CGRectMake(0, 0, scaledSize.width, scaledSize.height));

    // 5. Draw the cropped portion into the context
    CGImageRef croppedImage = CGImageCreateWithImageInRect(screenImage.CGImage, scaledRect);

    CGContextSaveGState(_effectInContext);
    // Flip vertically for Core Graphics coordinates
    CGContextTranslateCTM(_effectInContext, 0, scaledSize.height);
    CGContextScaleCTM(_effectInContext, 1.0, -1.0);

    CGContextDrawImage(_effectInContext, CGRectMake(0, 0, scaledRect.size.width, scaledRect.size.height), croppedImage);

    CGContextRestoreGState(_effectInContext);
    CGImageRelease(croppedImage);

    self.hidden = NO;

    // 6. Apply box blur
    uint32_t blurKernel = _precalculatedBlurKernel;
    vImageBoxConvolve_ARGB8888(&_effectInBuffer, &_effectOutBuffer, NULL, 0, 0, blurKernel, blurKernel, 0, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&_effectOutBuffer, &_effectInBuffer, NULL, 0, 0, blurKernel, blurKernel, 0, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&_effectInBuffer, &_effectOutBuffer, NULL, 0, 0, blurKernel, blurKernel, 0, kvImageEdgeExtend);

    // 7. Commit to layer
    CGImageRef outImage = CGBitmapContextCreateImage(_effectOutContext);
    self.layer.contents = (__bridge id)(outImage);
    CGImageRelease(outImage);
}




@end
