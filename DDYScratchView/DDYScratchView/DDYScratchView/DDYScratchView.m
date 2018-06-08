#import "DDYScratchView.h"
#import <objc/runtime.h>

@interface DDYScratchView ()

@property (nonatomic) CGContextRef imageContext;
/** 是否未刮开的初始状态 */
@property (nonatomic, assign) BOOL isFirst;
/** 等份分割 5*5 个区域 */
@property (nonatomic, strong) NSMutableArray *rectArray;
/** 已经刮开的区域 */
@property (nonatomic, strong) NSMutableArray *passArray;

@end

@implementation DDYScratchView

- (NSMutableArray *)rectArray {
    if (!_rectArray) {
        _rectArray = [NSMutableArray array];
        
        CGFloat rectW = self.bounds.size.width  / 20.;
        CGFloat rectH = self.bounds.size.height / 20.;
        for (int i = 1; i < 20; i++) {
            for (int j = 1; j < 20; j++) {
                [_rectArray addObject:[NSValue valueWithCGPoint:CGPointMake(j * rectW, i * rectH)]];
            }
        }
    }
    return _rectArray;
}

- (NSMutableArray *)passArray {
    if (!_passArray) {
        _passArray = [NSMutableArray array];
    }
    return _passArray;
}

+ (void)load {    
    Method originalMethod = class_getInstanceMethod([self class], @selector(setImage:));
    Method swizzleMethod = class_getInstanceMethod([self class], @selector(setMaskImage:));
    BOOL didAddMethod = class_addMethod([self class], @selector(setImage:), method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
    if (didAddMethod) {
        class_replaceMethod([self class], @selector(setMaskImage:), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.brashWidth = 20;
        self.isFirst = YES;
        self.minScale = 0.7;
    }
    return self;
}

- (void)setMaskImage:(UIImage *)image {
    [self setMaskImage:image];
    if (_isFirst) {
        self.imageContext = CGBitmapContextCreate(0,
                                                  self.bounds.size.width,
                                                  self.bounds.size.height,
                                                  8,
                                                  self.bounds.size.width * 4,
                                                  CGColorSpaceCreateDeviceRGB(),
                                                  kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(self.imageContext, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height), self.image.CGImage);
        CGContextSetBlendMode(self.imageContext, kCGBlendModeClear);
        CGContextSetFillColorWithColor(self.imageContext, [UIColor clearColor].CGColor);
        CGContextSetStrokeColorWithColor(self.imageContext, [UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor);
        _isFirst = NO;
    }
}

#pragma  mark - UIResponder
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setMaskImage:[self handleTouches:touches]];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setMaskImage:[self handleTouches:touches]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setMaskImage:[self handleTouches:touches]];
}

#pragma mark 自己是最佳接收事件的view 防止手指从该视图外滑进视图内不触发touch
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self;
}

#pragma mark -

- (UIImage *)handleTouches:(NSSet *)touches
{
    // 不要每次直接调用touches.anyObject，防止多次取到的数值不一样
    UITouch *touch = touches.anyObject;
    CGPoint touchPoint = [touch locationInView:self];NSLog(@"%@",NSStringFromCGPoint(touchPoint));
    touchPoint.y = self.bounds.size.height - touchPoint.y;
    CGRect touchRect = CGRectMake(touchPoint.x - self.brashWidth/2., touchPoint.y - self.brashWidth/2., self.brashWidth, self.brashWidth);
    
    for (NSValue *pointValue in self.rectArray) {
        if (CGRectContainsPoint(touchRect, [pointValue CGPointValue]) && ![self.passArray containsObject:pointValue]) {
            [self.passArray addObject:pointValue];
        }
    }
    
    if (UITouchPhaseBegan == touch.phase) {
        CGContextAddEllipseInRect(self.imageContext, touchRect);
        CGContextFillPath(self.imageContext);
        CGContextStrokePath(self.imageContext);
    } else if (UITouchPhaseMoved == touch.phase) {
        CGPoint prevPoint = [touch previousLocationInView:self];
        prevPoint.y = self.bounds.size.height - prevPoint.y;
        CGContextSetLineCap(self.imageContext, kCGLineCapRound);
        CGContextSetLineWidth(self.imageContext, self.brashWidth);
        CGContextMoveToPoint(self.imageContext, prevPoint.x, prevPoint.y);
        CGContextAddLineToPoint(self.imageContext, touchPoint.x, touchPoint.y);
        CGContextStrokePath(self.imageContext);
    } else  {
        [self showResult];
    }
    CGImageRef cgImage = CGBitmapContextCreateImage(self.imageContext);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return image;
}

- (void)showResult
{
    if (self.passArray.count >= (self.rectArray.count * self.minScale)) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(ddy_ScratchComplete:)]) {
            [self.delegate ddy_ScratchComplete:self];
        } else if (self.scratchCompleteBlock) {
            self.scratchCompleteBlock();
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:[NSString stringWithFormat:@"%ld",self.passArray.count]
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

@end


/**
 *
 *  如果要使用autolayout布局(推荐Masonry和SDAutoLayout)，然后重写-layoutSubviews,在这里初始化画布
 *
 *  如果想增加restart方法，可以把 -setMaskImage: 中条件逻辑的代码拷贝，并且添加属性变量保存原图
 */
