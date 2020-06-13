//
//  ViewController.m
//  XYNavigationControllerDemo
//
//  Created by Wcaulpl on 2020/6/12.
//  Copyright © 2020 Wcaulpl. All rights reserved.
//

#import "ViewController.h"
#import "XY1ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:XY1ViewController.new] animated:YES completion:nil];
}

@end
