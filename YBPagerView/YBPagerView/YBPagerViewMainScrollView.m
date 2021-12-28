//
//  YBPagerViewMainScrollView.m
//  YBPagerView
//
//  Created by liyuanbo on 2021/12/27.
//

#import "YBPagerViewMainScrollView.h"

@interface YBPagerViewMainScrollView ()
<
UIGestureRecognizerDelegate
>

@end

@implementation YBPagerViewMainScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(mainScrollViewGestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [self.gestureDelegate mainScrollViewGestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }else {
        return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
    }
}

@end
