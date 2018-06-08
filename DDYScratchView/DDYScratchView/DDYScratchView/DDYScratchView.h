#import <UIKit/UIKit.h>

@class DDYScratchView;

@protocol DDYScratchViewDelegate <NSObject>

@required
- (void)ddy_ScratchComplete:(DDYScratchView *)scratchView;

@end

@interface DDYScratchView : UIImageView
/** 手指划痕刷子的宽度 默认20 */
@property (nonatomic, assign) CGFloat brashWidth;
/** 当滑过点所在分割块的数量大于设定值则自动消除整个遮罩 默认0.7 推荐0.6-0.8 范围0.1-1 */
@property (nonatomic, assign) CGFloat minScale;
/** 刮涂完成delegate 优先delegate */
@property (nonatomic, weak) id <DDYScratchViewDelegate> delegate;
/** 刮涂完成block 优先delegate */
@property (nonatomic, copy) void (^scratchCompleteBlock)(void);

@end
