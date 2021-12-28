//
//  YBPagerView.h
//  YBPagerView
//
//  Created by liyuanbo on 2021/12/27.
//

#import <UIKit/UIKit.h>
#import "YBPagerListContainerView.h"
#import "YBPagerViewMainScrollView.h"

@class YBPagerView;
@protocol YBPagerViewDelegate <NSObject>

@required
/**
 返回tableHeaderView的高度，因为内部需要比对判断，只能是整型数
 */
- (NSUInteger)headerViewHeightInPagerView:(YBPagerView *)pagerView;

/**
 返回headerView
 */
- (UIView *)headerViewInPagerView:(YBPagerView *)pagerView;

/**
 返回悬浮HeaderView的高度，因为内部需要比对判断，只能是整型数
 */
- (NSUInteger)heightForPinSectionHeaderInPagerView:(YBPagerView *)pagerView;

/**
 返回悬浮HeaderView。我用的是自己封装的JXCategoryView（Github:https://github.com/pujiaxin33/JXCategoryView），你也可以选择其他的三方库或者自己写
 */
- (UIView *)viewForPinSectionHeaderInPagerView:(YBPagerView *)pagerView;

/**
 返回列表的数量
 */
- (NSInteger)numberOfListsInPagerView:(YBPagerView *)pagerView;

/**
 根据index初始化一个对应列表实例，需要是遵从`YBPagerViewListViewDelegate`协议的对象。
 如果列表是用自定义UIView封装的，就让自定义UIView遵从`YBPagerViewListViewDelegate`协议，该方法返回自定义UIView即可。
 如果列表是用自定义UIViewController封装的，就让自定义UIViewController遵从`YBPagerViewListViewDelegate`协议，该方法返回自定义UIViewController即可。
 注意：一定要是新生成的实例！！！

 @param pagerView pagerView description
 @param index index description
 @return 新生成的列表实例
 */
- (id<YBPagerViewListViewDelegate>)pagerView:(YBPagerView *)pagerView initListAtIndex:(NSInteger)index;

@optional
- (void)pagerView:(YBPagerView *)pagerView mainScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)pagerView:(YBPagerView *)pagerView mainScrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)pagerView:(YBPagerView *)pagerView mainScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)pagerView:(YBPagerView *)pagerView mainScrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)pagerView:(YBPagerView *)pagerView mainScrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

/**
 返回自定义UIScrollView或UICollectionView的Class
 某些特殊情况需要自己处理列表容器内UIScrollView内部逻辑。比如项目用了FDFullscreenPopGesture，需要处理手势相关代理。

 @param pagerView YBPagerView
 @return 自定义UIScrollView实例
 */
- (Class)scrollViewClassInlistContainerViewInPagerView:(YBPagerView *)pagerView;
@end

typedef NS_ENUM(NSInteger,YBPagerViewRefreshPosition) {
    /**
     刷新位置在外面 default
     */
    YBPagerViewRefreshPositionOuter = 0,
    /**
     刷新位置在列表里
     */
    YBPagerViewRefreshPositionInner
};

@interface YBPagerView : UIView

/**
 需要和self.categoryView.defaultSelectedIndex保持一致
 */
@property (nonatomic, assign) NSInteger defaultSelectedIndex;
@property (nonatomic, strong, readonly) YBPagerViewMainScrollView *mainScrollView;
@property (nonatomic, strong, readonly) YBPagerListContainerView *listContainerView;
/**
 当前已经加载过可用的列表字典，key就是index值，value是对应的列表。
 */
@property (nonatomic, strong, readonly) NSDictionary <NSNumber *, id<YBPagerViewListViewDelegate>> *validListDict;
/**
 顶部固定sectionHeader的垂直偏移量。数值越大越往下沉。
 */
@property (nonatomic, assign) NSInteger pinSectionHeaderVerticalOffset;
/**
 刷新头位置 default is YBPagerViewRefreshPositionOuter
 */
@property (nonatomic, assign) YBPagerViewRefreshPosition refreshPosition;

- (instancetype)initWithDelegate:(id<YBPagerViewDelegate>)delegate listContainerType:(YBPagerListContainerType)type NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (void)reloadData;
- (void)resizeHeaderViewHeightWithAnimatable:(BOOL)animatable duration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve;

@end

/**
暴露给子类使用，请勿直接使用相关属性和方法！
*/
@interface YBPagerView (UISubclassingGet)
@property (nonatomic, strong, readonly) UIScrollView *currentScrollingListView;
@property (nonatomic, strong, readonly) id<YBPagerViewListViewDelegate> currentList;
@property (nonatomic, assign, readonly) CGFloat mainScrollViewMaxContentOffsetY;
@end

@interface YBPagerView (UISubclassingHooks)
- (void)preferredProcessListViewDidScroll:(UIScrollView *)scrollView;
- (void)preferredProcessMainScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)setMainScrollViewToMaxContentOffsetY;
- (void)setListScrollViewToMinContentOffsetY:(UIScrollView *)scrollView;
- (CGFloat)minContentOffsetYInListScrollView:(UIScrollView *)scrollView;
@end

