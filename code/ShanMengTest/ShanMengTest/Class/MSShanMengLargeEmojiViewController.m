//
//  MSShanMengLargeEmojiViewController.m
//  ShanMengTest
//
//  Created by Admin on 2019/8/6.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "MSShanMengLargeEmojiViewController.h"
#import <SDWebImage/SDWebImage.h>

@interface MSShanMengLargeEmojiViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *largeEmojiImageView;

@end

@implementation MSShanMengLargeEmojiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)refreshLargeGitWithUrl:(NSString *)url
{
    [self.largeEmojiImageView sd_setImageWithURL:[NSURL URLWithString:url]];
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
