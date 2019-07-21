//
//  MainCell.m
//  ReacttiveObjC-MVVM-tableview
//
//  Created by darkwing90s on 2019/7/20.
//  Copyright © 2019 darkwing90s. All rights reserved.
//

#import "MainCell.h"
#import "MainModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface MainCell ()

@property (nonatomic, strong) UILabel *rtLabel;
@property (nonatomic, strong) UIButton *rtButton;

@end

@implementation MainCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self makeUI];
        [self bindData];
        
    }
    return self;
}

- (void)makeUI
{
    self.rtLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 200, 20)];
    [self.contentView addSubview:self.rtLabel];
    
    self.rtButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.rtButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-100, 5, 80, 40);
    [self.rtButton setTitle:@"change" forState:UIControlStateNormal];
    [self.contentView addSubview:self.rtButton];
}

- (void)bindData
{
    @weakify(self)
    [RACObserve(self, model.rtTitle) subscribeNext:^(id x) {
        
        @strongify(self)
        self.rtLabel.text = self.model.rtTitle;
        
    }];
    
    [RACObserve(self, model.rtSelect) subscribeNext:^(id x) {
        
        if ([self.model.rtSelect isEqualToString:@"0"]) {
            self.rtLabel.textColor = [UIColor yellowColor];
        } else {
            self.rtLabel.textColor = [UIColor redColor];
        }
    }];
    
    self.rtButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input){
        NSLog(@"按钮被点击");
        
        if ([self.model.rtSelect isEqualToString:@"0"]) {
            self.model.rtSelect = @"1";
        } else {
            self.model.rtSelect = @"0";
        }
        
        return [RACSignal empty];
    }];
}

@end
