//
//  YBPagerView.m
//  YBPagerView
//
//  Created by liyuanbo on 2021/12/27.
//

#import "YBPagerView.h"
#import "Masonry.h"

@class YBPagerListContainerScrollView;

@interface YBPagerView ()
<
UIScrollViewDelegate,
YBPagerListContainerViewDelegate
>

@property (nonatomic, weak) id<YBPagerViewDelegate> delegate;
@property (nonatomic, strong) YBPagerViewMainScrollView *mainScrollView;
@property (nonatomic, strong) YBPagerListContainerView *listContainerView;
@property (nonatomic, strong) UIScrollView *currentScrollingListView;
@property (nonatomic, strong) id<YBPagerViewListViewDelegate> currentList;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, id<YBPagerViewListViewDelegate>> *validListDict;
@property (nonatomic, strong) UIView *headerContainerView;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, strong) UIView *categoryView;
@property (nonatomic, assign) CGFloat categoryViewHeight;
@property (nonatomic, assign) CGFloat lastScrollingListViewContentOffsetY;

@end

@implementation YBPagerView

#pragma mark - init
- (instancetype)initWithDelegate:(id<YBPagerViewDelegate>)delegate listContainerType:(YBPagerListContainerType)type
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _delegate = delegate;
        _validListDict = [NSMutableDictionary dictionary];
        _refreshPosition = YBPagerViewRefreshPositionOuter;
        
        _listContainerView = [[YBPagerListContainerView alloc] initWithType:type delegate:self];
        
        [self setupUI];
    }
    return self;
}

- (void)resizeHeaderViewHeightWithAnimatable:(BOOL)animatable duration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve
{
    self.headerViewHeight = [self.delegate headerViewHeightInPagerView:self];
    [self.headerContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(self.headerViewHeight);
    }];
    [self.listContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.mas_height).offset(-self.categoryViewHeight - self.pinSectionHeaderVerticalOffset);
    }];
    if (animatable) {
        UIViewAnimationOptions options = UIViewAnimationOptionCurveLinear;
        switch (curve) {
            case UIViewAnimationCurveEaseIn: options = UIViewAnimationOptionCurveEaseIn; break;
            case UIViewAnimationCurveEaseOut: options = UIViewAnimationOptionCurveEaseOut; break;
            case UIViewAnimationCurveEaseInOut: options = UIViewAnimationOptionCurveEaseInOut; break;
            default: break;
        }
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            [self.mainScrollView layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }else {
        [self.mainScrollView layoutIfNeeded];
    }
}

- (void)setupUI
{
    [self addSubview:self.mainScrollView];
    [self.mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.headerContainerView = [self.delegate headerViewInPagerView:self];
    self.headerViewHeight = [self.delegate headerViewHeightInPagerView:self];
    [self.mainScrollView addSubview:self.headerContainerView];
    [self.headerContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.mainScrollView);
        make.width.equalTo(self.mainScrollView.mas_width);
        make.height.offset(self.headerViewHeight);
    }];
    
    self.categoryView = [self.delegate viewForPinSectionHeaderInPagerView:self];
    self.categoryViewHeight = [self.delegate heightForPinSectionHeaderInPagerView:self];
    [self.mainScrollView addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.mainScrollView);
        make.width.equalTo(self.mainScrollView.mas_width);
        make.top.equalTo(self.headerContainerView.mas_bottom);
        make.height.offset(self.categoryViewHeight);
    }];
    
    [self.mainScrollView addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.mainScrollView);
        make.width.equalTo(self.mainScrollView.mas_width);
        make.top.equalTo(self.categoryView.mas_bottom);
        make.height.equalTo(self.mas_height).offset(-self.categoryViewHeight - self.pinSectionHeaderVerticalOffset);
    }];
}

- (void)reloadData
{
    self.currentList = nil;
    self.currentScrollingListView = nil;
    [_validListDict removeAllObjects];
    if (self.pinSectionHeaderVerticalOffset != 0) {
        self.mainScrollView.contentOffset = CGPointZero;
    }
    
    self.headerViewHeight = [self.delegate headerViewHeightInPagerView:self];
    [self.headerContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(self.headerViewHeight);
    }];
    self.categoryViewHeight = [self.delegate heightForPinSectionHeaderInPagerView:self];
    [self.categoryView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(self.categoryViewHeight);
    }];
    [self.listContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.mas_height).offset(-self.categoryViewHeight-self.pinSectionHeaderVerticalOffset);
    }];
    [self.mainScrollView layoutIfNeeded];
    [self.listContainerView reloadData];
}

#pragma mark - setter
- (void)setHeaderContainerView:(UIView *)headerContainerView
{
    if (headerContainerView) {
        _headerContainerView = headerContainerView;
    }else {
        _headerContainerView = [UIView new];
    }
}

- (void)setCategoryView:(UIView *)categoryView
{
    if (categoryView) {
        _categoryView = categoryView;
    }else {
        _categoryView = [UIView new];
    }
}

- (void)setDefaultSelectedIndex:(NSInteger)defaultSelectedIndex {
    _defaultSelectedIndex = defaultSelectedIndex;

    self.listContainerView.defaultSelectedIndex = defaultSelectedIndex;
}

- (void)setRefreshPosition:(YBPagerViewRefreshPosition)refreshPosition
{
    _refreshPosition = refreshPosition;
    self.mainScrollView.bounces = refreshPosition == YBPagerViewRefreshPositionOuter;
}

- (void)setPinSectionHeaderVerticalOffset:(NSInteger)pinSectionHeaderVerticalOffset
{
    _pinSectionHeaderVerticalOffset = pinSectionHeaderVerticalOffset;
    
    CGFloat categoryHeight = self.categoryViewHeight + pinSectionHeaderVerticalOffset;
    [self.listContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.mas_height).offset(-categoryHeight);
    }];
}

#pragma mark - lazyloads
- (YBPagerViewMainScrollView *)mainScrollView
{
    if (!_mainScrollView) {
        _mainScrollView = [[YBPagerViewMainScrollView alloc] initWithFrame:CGRectZero];
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.scrollsToTop = NO;
        _mainScrollView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _mainScrollView;
}

#pragma mark - privite
- (void)adjustMainScrollViewToTargetContentInsetIfNeeded:(UIEdgeInsets)insets {
    if (UIEdgeInsetsEqualToEdgeInsets(insets, self.mainScrollView.contentInset) == NO) {
        self.mainScrollView.delegate = nil;
        self.mainScrollView.contentInset = insets;
        self.mainScrollView.delegate = self;
    }
}

- (void)listViewDidScroll:(UIScrollView *)scrollView
{
    self.currentScrollingListView = scrollView;
    [self preferredProcessListViewDidScroll:scrollView];
}

//????????????????????????pinSectionHeaderVerticalOffset???????????????MJRefresh???????????????????????????????????????JXPagingView???MJRefresh????????????contentInset?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????pinSectionHeaderVerticalOffset????????????????????????contentInset.top????????????
//?????????????????????https://github.com/pujiaxin33/JXPagingView/issues/203
- (BOOL)isSetMainScrollViewContentInsetToZeroEnabled:(UIScrollView *)scrollView {
    //scrollView.contentInset.top??????0??????scrollView.contentInset.top?????????pinSectionHeaderVerticalOffset???????????????????????????????????????????????????????????????pinSectionHeaderVerticalOffset???MJRefresh???mj_insetT??????????????????
    BOOL isRefreshing = scrollView.contentInset.top != 0 && scrollView.contentInset.top != self.pinSectionHeaderVerticalOffset;
    return !isRefreshing;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.pinSectionHeaderVerticalOffset != 0) {
        if (!(self.currentScrollingListView != nil && self.currentScrollingListView.contentOffset.y > [self minContentOffsetYInListScrollView:self.currentScrollingListView])) {
            //???????????????????????????listView?????????
            if (scrollView.contentOffset.y >= self.pinSectionHeaderVerticalOffset) {
                //?????????????????????contentInset.top
                [self adjustMainScrollViewToTargetContentInsetIfNeeded:UIEdgeInsetsMake(self.pinSectionHeaderVerticalOffset, 0, 0, 0)];
            }else {
                if ([self isSetMainScrollViewContentInsetToZeroEnabled:scrollView]) {
                    [self adjustMainScrollViewToTargetContentInsetIfNeeded:UIEdgeInsetsZero];
                }
            }
        }
    }
    [self preferredProcessMainScrollViewDidScroll:scrollView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pagerView:mainScrollViewDidScroll:)]) {
        [self.delegate pagerView:self mainScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.listContainerView.scrollView.scrollEnabled = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pagerView:mainScrollViewWillBeginDragging:)]) {
        [self.delegate pagerView:self mainScrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.listContainerView.scrollView.scrollEnabled = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(pagerView:mainScrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate pagerView:self mainScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.listContainerView.scrollView.scrollEnabled = YES;
    if ([self isSetMainScrollViewContentInsetToZeroEnabled:scrollView]) {
        if (self.mainScrollView.contentInset.top != 0 && self.pinSectionHeaderVerticalOffset != 0) {
            [self adjustMainScrollViewToTargetContentInsetIfNeeded:UIEdgeInsetsZero];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(pagerView:mainScrollViewDidEndDecelerating:)]) {
        [self.delegate pagerView:self mainScrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.listContainerView.scrollView.scrollEnabled = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pagerView:mainScrollViewDidEndScrollingAnimation:)]) {
        [self.delegate pagerView:self mainScrollViewDidEndScrollingAnimation:scrollView];
    }
}

#pragma mark - YBPagerListContainerViewDelegate
- (NSInteger)numberOfListsInlistContainerView:(YBPagerListContainerView *)listContainerView
{
    return [self.delegate numberOfListsInPagerView:self];
}

- (id<YBPagerViewListViewDelegate>)listContainerView:(YBPagerListContainerView *)listContainerView initListForIndex:(NSInteger)index
{
    id<YBPagerViewListViewDelegate> list = self.validListDict[@(index)];
    if (list == nil) {
        list = [self.delegate pagerView:self initListAtIndex:index];
        __weak typeof(self)weakSelf = self;
        __weak typeof(id<YBPagerViewListViewDelegate>) weakList = list;
        [list listViewDidScrollCallback:^(UIScrollView *scrollView) {
            weakSelf.currentList = weakList;
            [weakSelf listViewDidScroll:scrollView];
        }];
        _validListDict[@(index)] = list;
    }
    return list;
}

- (void)listContainerViewWillBeginDragging:(YBPagerListContainerView *)listContainerView {
    self.mainScrollView.scrollEnabled = NO;
}

- (void)listContainerViewWDidEndScroll:(YBPagerListContainerView *)listContainerView {
    self.mainScrollView.scrollEnabled = YES;
}

- (void)listContainerView:(YBPagerListContainerView *)listContainerView listDidAppearAtIndex:(NSInteger)index {
    self.currentScrollingListView = [self.validListDict[@(index)] listScrollView];
    for (id<YBPagerViewListViewDelegate> listItem in self.validListDict.allValues) {
        if (listItem == self.validListDict[@(index)]) {
            [listItem listScrollView].scrollsToTop = YES;
        }else {
            [listItem listScrollView].scrollsToTop = NO;
        }
    }
}

- (Class)scrollViewClassInlistContainerView:(YBPagerListContainerView *)listContainerView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewClassInlistContainerViewInPagerView:)]) {
        return [self.delegate scrollViewClassInlistContainerViewInPagerView:self];
    }
    return nil;
}

@end

@implementation YBPagerView (UISubclassingGet)

- (CGFloat)mainScrollViewMaxContentOffsetY {
    return [self.delegate headerViewHeightInPagerView:self] - self.pinSectionHeaderVerticalOffset;
}

@end

@implementation YBPagerView (UISubclassingHooks)

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction
{
    //?????????????????????????????????????????????????????????????????????
    if (direction == UIAccessibilityScrollDirectionDown) {
        if (self.mainScrollView.contentOffset.y < self.mainScrollViewMaxContentOffsetY) {
            [self.mainScrollView setContentOffset:CGPointMake(0, self.mainScrollViewMaxContentOffsetY) animated:YES];
            return YES;
        }
    }
    return NO;
}

- (void)preferredProcessListViewDidScroll:(UIScrollView *)scrollView {
    switch (self.refreshPosition) {
        case YBPagerViewRefreshPositionOuter:
        {
            if (self.mainScrollView.contentOffset.y < self.mainScrollViewMaxContentOffsetY) {
                //mainTableView???header?????????????????????listScrollView?????????0
                if (self.currentList && [self.currentList respondsToSelector:@selector(listScrollViewWillResetContentOffset)]) {
                    [self.currentList listScrollViewWillResetContentOffset];
                }
                [self setListScrollViewToMinContentOffsetY:scrollView];
                scrollView.showsVerticalScrollIndicator = NO;
            }else {
                //mainTableView???header?????????????????????mainTableView??????????????????listScrollView????????????
                self.mainScrollView.contentOffset = CGPointMake(0, self.mainScrollViewMaxContentOffsetY);
                scrollView.showsVerticalScrollIndicator = YES;
            }
        }
            break;
            
        case YBPagerViewRefreshPositionInner:
        {
            BOOL shouldProcess = YES;
            if (self.currentScrollingListView.contentOffset.y > self.lastScrollingListViewContentOffsetY) {
                //????????????
            }else {
                //????????????
                if (self.mainScrollView.contentOffset.y == 0) {
                    shouldProcess = NO;
                }else {
                    if (self.mainScrollView.contentOffset.y < self.mainScrollViewMaxContentOffsetY) {
                        //mainScrollView???header?????????????????????listScrollView?????????0
                        if (self.currentList && [self.currentList respondsToSelector:@selector(listScrollViewWillResetContentOffset)]) {
                            [self.currentList listScrollViewWillResetContentOffset];
                        }
                        [self setListScrollViewToMinContentOffsetY:self.currentScrollingListView];
                        self.currentScrollingListView.showsVerticalScrollIndicator = NO;
                    }
                }
            }
            if (shouldProcess) {
                if (self.mainScrollView.contentOffset.y < self.mainScrollViewMaxContentOffsetY) {
                    //??????????????????????????????scrollView.contentOffset.y????????????????????????0
                    if (self.currentScrollingListView.contentOffset.y > [self minContentOffsetYInListScrollView:self.currentScrollingListView]) {
                        //mainScrollView???header?????????????????????listScrollView?????????0
                        if (self.currentList && [self.currentList respondsToSelector:@selector(listScrollViewWillResetContentOffset)]) {
                            [self.currentList listScrollViewWillResetContentOffset];
                        }
                        [self setListScrollViewToMinContentOffsetY:self.currentScrollingListView];
                        self.currentScrollingListView.showsVerticalScrollIndicator = NO;
                    }
                } else {
                    //mainScrollView???header?????????????????????mainScrollView??????????????????listScrollView????????????
                    self.mainScrollView.contentOffset = CGPointMake(0, self.mainScrollViewMaxContentOffsetY);
                    self.currentScrollingListView.showsVerticalScrollIndicator = YES;
                }
            }
            self.lastScrollingListViewContentOffsetY = self.currentScrollingListView.contentOffset.y;
        }
            break;
    }
    
}

- (void)preferredProcessMainScrollViewDidScroll:(UIScrollView *)scrollView {
    switch (self.refreshPosition) {
        case YBPagerViewRefreshPositionOuter:
        {
            if (self.currentScrollingListView != nil && self.currentScrollingListView.contentOffset.y > [self minContentOffsetYInListScrollView:self.currentScrollingListView]) {
                //mainTableView???header??????????????????????????????????????????listView???????????????mainTableView???contentOffset???????????????
                [self setMainScrollViewToMaxContentOffsetY];
            }

            if (scrollView.contentOffset.y < self.mainScrollViewMaxContentOffsetY) {
                //mainTableView???????????????header???listView???contentOffset????????????
                for (id<YBPagerViewListViewDelegate> list in self.validListDict.allValues) {
                    if ([list respondsToSelector:@selector(listScrollViewWillResetContentOffset)]) {
                        [list listScrollViewWillResetContentOffset];
                    }
                    [self setListScrollViewToMinContentOffsetY:[list listScrollView]];
                }
            }

            if (scrollView.contentOffset.y > self.mainScrollViewMaxContentOffsetY && self.currentScrollingListView.contentOffset.y == [self minContentOffsetYInListScrollView:self.currentScrollingListView]) {
                //???????????????mainTableView???headerView??????????????????????????????listView?????????????????????
                [self setMainScrollViewToMaxContentOffsetY];
            }
        }
            break;
            
        case YBPagerViewRefreshPositionInner:
        {
            if (self.pinSectionHeaderVerticalOffset != 0) {
                if (!(self.currentScrollingListView != nil && self.currentScrollingListView.contentOffset.y > [self minContentOffsetYInListScrollView:self.currentScrollingListView])) {
                    //???????????????????????????listView?????????
                    if (scrollView.contentOffset.y <= 0) {
                        self.mainScrollView.bounces = NO;
                        self.mainScrollView.contentOffset = CGPointZero;
                        return;
                    }else {
                        self.mainScrollView.bounces = YES;
                    }
                }
            }
            if (self.currentScrollingListView != nil && self.currentScrollingListView.contentOffset.y > [self minContentOffsetYInListScrollView:self.currentScrollingListView]) {
                //mainScrollView???header??????????????????????????????????????????listView???????????????mainScrollView???contentOffset???????????????
                [self setMainScrollViewToMaxContentOffsetY];
            }

            if (scrollView.contentOffset.y < self.mainScrollViewMaxContentOffsetY) {
                //mainScrollView???????????????header???listView???contentOffset????????????
                for (id<YBPagerViewListViewDelegate> list in self.validListDict.allValues) {
                    //???????????????????????????????????????
                    UIScrollView *listScrollView = [list listScrollView];
                    if (listScrollView.contentOffset.y > 0) {
                        if ([list respondsToSelector:@selector(listScrollViewWillResetContentOffset)]) {
                            [list listScrollViewWillResetContentOffset];
                        }
                        [self setListScrollViewToMinContentOffsetY:listScrollView];
                    }
                }
            }

            if (scrollView.contentOffset.y > self.mainScrollViewMaxContentOffsetY && self.currentScrollingListView.contentOffset.y == [self minContentOffsetYInListScrollView:self.currentScrollingListView]) {
                //???????????????mainScrollView???headerView??????????????????????????????listView?????????????????????
                [self setMainScrollViewToMaxContentOffsetY];
            }
        }
            break;
    }
    
}

- (void)setMainScrollViewToMaxContentOffsetY {
    self.mainScrollView.contentOffset = CGPointMake(0, self.mainScrollViewMaxContentOffsetY);
}

- (void)setListScrollViewToMinContentOffsetY:(UIScrollView *)scrollView {
    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, [self minContentOffsetYInListScrollView:scrollView]);
}

- (CGFloat)minContentOffsetYInListScrollView:(UIScrollView *)scrollView {
    if (@available(iOS 11.0, *)) {
        return -scrollView.adjustedContentInset.top;
    }
    return -scrollView.contentInset.top;
}

@end
