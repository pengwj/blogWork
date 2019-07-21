//
//  MainViewController.m
//  ReacttiveObjC-MVVM-tableview
//
//  Created by darkwing90s on 2019/7/20.
//  Copyright © 2019 darkwing90s. All rights reserved.
//

#import "MainViewController.h"
#import "MainCell.h"
#import "MainModel.h"
#import "MainViewModel.h"
#import <MJRefresh/MJRefresh.h>

static NSString * const cellIdentifier = @"MainCellIdentifier";

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) MainViewModel *viewModel;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initViewModel];
    [self bindViewModel];
    [self makeUI];
}


- (void)makeUI
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];

    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)initViewModel {
    
    _viewModel = [MainViewModel new];
    @weakify(self)
    [_viewModel.fetchProductCommand.executing subscribeNext:^(NSNumber *executing) {
        NSLog(@"command executing:%@", executing);
        if (!executing.boolValue) {
            @strongify(self)
            [self.tableView.mj_header endRefreshing];
        }
    }];
    
    [_viewModel.fetchMoreProductCommand.executing subscribeNext:^(NSNumber *executing) {
        if (!executing.boolValue) {
            @strongify(self);
            [self.tableView.mj_footer endRefreshing];
        }
    }];
    
    [_viewModel.errors subscribeNext:^(NSError *error) {
        NSLog(@"something error:%@", error.userInfo);
        //TODO: 这里可以选择一种合适的方式将错误信息展示出来
    }];
    
}

- (void)bindViewModel {
    @weakify(self);
    
    [RACObserve(self.viewModel, dataArray) subscribeNext:^(id x) {
        @strongify(self);
        
        
        NSLog(@"bindViewModel-dataArray");
        [self.tableView reloadData];
    }];
    
}

#pragma mark - View Method
- (void)loadData {
    
    [self.viewModel.fetchProductCommand execute:nil];
}

- (void)loadMoreData {
    [self.viewModel.fetchMoreProductCommand execute:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    MainModel *model = self.viewModel.dataArray[indexPath.row];
    cell.model = model;
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
