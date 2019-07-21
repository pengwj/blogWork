//
//  MainViewController.m
//  ReacttiveObjC-MVVM-tableview
//
//  Created by darkwing90s on 2019/7/20.
//  Copyright © 2019 darkwing90s. All rights reserved.
//

#import "ConvertViewController.h"
#import "ConvertCell.h"

@interface ConvertViewController ()<UITableViewDelegate,UITableViewDataSource,ConvertCellDelegate>

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation ConvertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self makeUI];
}


- (void)makeUI
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ConvertCell" bundle:nil] forCellReuseIdentifier:@"ConvertCell"];
}

#pragma mark - View Method

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
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConvertCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ConvertCell"];
    cell.delegate = self;
    cell.tag = indexPath.row;
    return cell;
}

- (void)convertCellDelegateBtnDown:(UIButton *)button
{
    ConvertCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    
    NSLog(@"convertCellBtn-VC:%@",NSStringFromCGRect(button.frame));

    // 计算viewB上的viewC相对于viewA的frame。
    // 计算cell上的控件button的frame相对于self.view的frame
    CGRect rect = [cell convertRect:button.frame toView:self.view];
    
    NSLog(@"convertToView-VC:%@",NSStringFromCGRect(rect));

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
