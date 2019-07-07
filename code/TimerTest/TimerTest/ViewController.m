//
//  ViewController.m
//  TimerTest
//
//  Created by Admin on 2019/7/5.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"

@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)buttonDown:(id)sender {
    SecondViewController *second = [[SecondViewController alloc] init];
    [self presentViewController:second animated:YES completion:nil];
}


@end
