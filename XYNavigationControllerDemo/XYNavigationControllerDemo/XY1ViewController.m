//
//  XY1ViewController.m
//  XYNavigationControllerDemo
//
//  Created by Wcaulpl on 2020/6/12.
//  Copyright © 2020 Wcaulpl. All rights reserved.
//

#import "XY1ViewController.h"
#import "XY2ViewController.h"

@interface XY1ViewController ()

@end

@implementation XY1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.xy_prefersNavigationBarHidden = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController pushViewController:XY2ViewController.new animated:YES];
}

@end
