//
//  YBPagerViewMainScrollView.h
//  YBPagerView
//
//  Created by liyuanbo on 2021/12/27.
//

#import <UIKit/UIKit.h>

@protocol YBPagerViewMainScrollViewDelegate <NSObject>

@optional
- (BOOL)mainScrollViewGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

@end

@interface YBPagerViewMainScrollView : UIScrollView

@property (nonatomic, weak) id<YBPagerViewMainScrollViewDelegate> gestureDelegate;

@end
