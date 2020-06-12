//
//  UINavigationController+XYBase.m
//  CodeToolsDemo
//
//  Created by htmj on 2019/7/19.
//  Copyright © 2019年 Wcaulpl. All rights reserved.
//

#import "UINavigationController+XYBase.h"
#import <objc/runtime.h>

@implementation UIViewController (XYSideslip)

- (BOOL)xy_prefersSide_slipBackEnabled
{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }
    self.xy_prefersSide_slipBackEnabled = YES;
    return YES;
}

- (void)setXy_prefersSide_slipBackEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self, @selector(xy_prefersSide_slipBackEnabled), @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface UINavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@end

@implementation UINavigationController (XYBase)

#pragma 禁止app屏幕旋转
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

+ (void)load {
    
    Method originMethod = class_getInstanceMethod(self, @selector(pushViewController:animated:));
    Method swizzedMethod = class_getInstanceMethod(self, @selector(xy_base_pushViewController:animated:));
    method_exchangeImplementations(originMethod, swizzedMethod);
    
}

- (void)xy_base_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.interactivePopGestureRecognizer.delegate = self;
    if (self.childViewControllers.count) {
        [self configureViewController:viewController];
    }
    
    [self xy_base_pushViewController:viewController animated:animated];
}

- (void)xy_pushViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    
    for (UIViewController *viewController in viewControllers) {
        if (![self.viewControllers containsObject:viewController] && self.childViewControllers.count) {
            [self configureViewController:viewController];
        }
    }
    [self setViewControllers:[self.viewControllers arrayByAddingObjectsFromArray:viewControllers] animated:animated];
}

- (void)xy_replaceViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count) {
        [self configureViewController:viewController];
    }
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    
    [viewControllers replaceObjectAtIndex:viewControllers.count-1 withObject:viewController];
    
    [self setViewControllers:viewControllers animated:animated];

}

- (void)configureViewController:(UIViewController *)viewController {
    viewController.hidesBottomBarWhenPushed = YES;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 1;
    button.frame = CGRectMake(0, 0, 40, 40);
    // 如果push进来的不是第一个控制器
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    // 修改导航栏左边的item
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)back {
    [self popViewControllerAnimated:YES];
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if(self.childViewControllers.count > 0){
        return self.visibleViewController.xy_prefersSide_slipBackEnabled;
    } else {
        return NO;
    }
}


@end
