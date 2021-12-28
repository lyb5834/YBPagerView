//
//  ViewController.m
//  YBPagerView
//
//  Created by liyuanbo on 2021/12/27.
//

#import "ViewController.h"
#import "YBPagerView.h"
#import "ContainerViewController.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "JXCategoryView.h"

@interface ViewController ()
<
YBPagerViewDelegate,
JXCategoryViewDelegate
>
@property (nonatomic, strong) JXCategoryTitleView * categoryView;
@property (nonatomic, strong) YBPagerView * pagerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.pagerView];
    
    [self.pagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.categoryView.listContainer = (id<JXCategoryViewListContainer>)self.pagerView.listContainerView;
    [self.pagerView reloadData];
}

#pragma mark - lazyloads
- (JXCategoryTitleView *)categoryView
{
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] init];
        _categoryView.titleFont = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
        _categoryView.titleColor = [UIColor darkGrayColor];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        _categoryView.titleSelectedColor = [UIColor redColor];
        _categoryView.titleColorGradientEnabled = YES;
        _categoryView.backgroundColor = [UIColor clearColor];
        _categoryView.cellSpacing = 48;
        _categoryView.contentEdgeInsetLeft = 30;
        _categoryView.contentEdgeInsetRight = 30;
        _categoryView.titles = @[@"栏目一",@"栏目二",@"栏目三",@"栏目四",@"栏目五"];
        _categoryView.separatorLineShowEnabled = YES;
        _categoryView.separatorLineSize = CGSizeMake(1, 13);
        _categoryView.separatorLineColor = [UIColor lightGrayColor];
        _categoryView.delegate = self;
    }
    return _categoryView;
}

- (YBPagerView *)pagerView
{
    if (!_pagerView) {
        _pagerView = [[YBPagerView alloc] initWithDelegate:self listContainerType:YBPagerListContainerType_ScrollView];
        _pagerView.refreshPosition = YBPagerViewRefreshPositionInner;
        _pagerView.pinSectionHeaderVerticalOffset = 80;
        
        __weak typeof(self) weakSelf = self;
        _pagerView.mainScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            __strong typeof(weakSelf)self = weakSelf;
            [self.pagerView.mainScrollView.mj_header endRefreshing];
        }];
    }
    return _pagerView;
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didClickSelectedItemAtIndex:(NSInteger)index
{
    
}

#pragma mark - YBPagerViewDelegate
- (UIView *)headerViewInPagerView:(YBPagerView *)pagerView
{
    UIView * headerView = [UIView new];
    headerView.backgroundColor = [UIColor greenColor];
    return headerView;
}

- (NSUInteger)headerViewHeightInPagerView:(YBPagerView *)pagerView
{
    return 200;
}

- (UIView *)viewForPinSectionHeaderInPagerView:(YBPagerView *)pagerView
{
    return self.categoryView;
}

- (NSUInteger)heightForPinSectionHeaderInPagerView:(YBPagerView *)pagerView
{
    return 44;
}

- (NSInteger)numberOfListsInPagerView:(YBPagerView *)pagerView
{
    return self.categoryView.titles.count;
}

- (id<YBPagerViewListViewDelegate>)pagerView:(YBPagerView *)pagerView initListAtIndex:(NSInteger)index
{
    ContainerViewController * containerVC = [ContainerViewController new];
    return containerVC;
}

@end
