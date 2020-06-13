//
//  UINavigationController+XYNavigationBar.m
//  Leton
//
//  Created by htmj on 2019/7/15.
//  Copyright © 2019年 htmj. All rights reserved.
//

#import "UINavigationController+XYNavigationBar.h"
#import <objc/runtime.h>

#define backImageIcon @"nav_back_black"
#define whiteImageIcon @"nav_back_white"

typedef void(^XYViewControllerWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (XYHandlerNavigationBarPrivate)

@property(nonatomic, copy) XYViewControllerWillAppearInjectBlock xy_willAppearInjectBlock;

@end

// MARK: - 替换UIViewController的viewWillAppear方法，在此方法中，执行设置导航栏隐藏和显示的代码块。
@implementation UIViewController (XYHandlerNavigationBarPrivate)

+ (void)load {
    Method orginalMethod = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(xy_viewWillAppear:));
    method_exchangeImplementations(orginalMethod, swizzledMethod);
    
//    Method orginalDisMethod = class_getInstanceMethod(self, @selector(viewWillDisappear:));
//    Method swizzledDisMethod = class_getInstanceMethod(self, @selector(xy_viewWillDisappear:));
//    method_exchangeImplementations(orginalDisMethod, swizzledDisMethod);
}

- (void)xy_viewWillAppear:(BOOL)animated {
    [self xy_viewWillAppear:animated];
    if (self.xy_willAppearInjectBlock) {
        self.xy_willAppearInjectBlock(self, animated);
    }
}

- (XYViewControllerWillAppearInjectBlock)xy_willAppearInjectBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setXy_willAppearInjectBlock:(XYViewControllerWillAppearInjectBlock)block {
    objc_setAssociatedObject(self, @selector(xy_willAppearInjectBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end


// MARK: - 给UIViewController添加xy_prefersNavigationBarHidden属性
@implementation UIViewController (XYHandlerNavigationBar)

- (BOOL)xy_prefersNavigationBarHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setXy_prefersNavigationBarHidden:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(xy_prefersNavigationBarHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)xy_prefersNavigationBarTransparent {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setXy_prefersNavigationBarTransparent:(BOOL)transparent {
    objc_setAssociatedObject(self, @selector(xy_prefersNavigationBarTransparent), @(transparent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

// MARK: - 替换UINavigationController的pushViewController:animated:方法，在此方法中去设置导航栏的隐藏和显示
@implementation UINavigationController (XYNavigationBar)

+ (void)load {
    
    Method originMethod = class_getInstanceMethod(self, @selector(pushViewController:animated:));
    Method swizzedMethod = class_getInstanceMethod(self, @selector(xy_pushViewController:animated:));
    method_exchangeImplementations(originMethod, swizzedMethod);
    
    Method originSetViewControllersMethod = class_getInstanceMethod(self, @selector(setViewControllers:animated:));
    Method swizzedSetViewControllersMethod = class_getInstanceMethod(self, @selector(xy_setViewControllers:animated:));
    method_exchangeImplementations(originSetViewControllersMethod, swizzedSetViewControllersMethod);
}

- (void)xy_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // Handle perferred navigation bar appearance.
    [self xy_setupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    // Forward to primary implementation.
    [self xy_pushViewController:viewController animated:animated];
}

- (void)xy_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    // Handle perferred navigation bar appearance.
    for (UIViewController *viewController in viewControllers) {
        [self xy_setupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    }
    // Forward to primary implementation.
    [self xy_setViewControllers:viewControllers animated:animated];
}

- (void)xy_setupViewControllerBasedNavigationBarAppearanceIfNeeded:(UIViewController *)appearingViewController {
    if (!self.xy_viewControllerBasedNavigationBarAppearanceEnabled) {
        return;
    }
    
    // 即将被调用的代码块
    __weak typeof(self) weakSelf = self;
    XYViewControllerWillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setNavigationBarHidden:viewController.xy_prefersNavigationBarHidden animated:animated];
            if (!viewController.xy_prefersNavigationBarHidden && [strongSelf isKindOfClass:[UINavigationController class]]) {
                strongSelf.navigationBar.translucent = viewController.xy_prefersNavigationBarTransparent;
                UIButton *leftBtn = (UIButton *)viewController.navigationItem.leftBarButtonItem.customView;
                if (leftBtn.tag == 1) {
                    [leftBtn setImage:[UIImage imageNamed:viewController.xy_prefersNavigationBarTransparent?whiteImageIcon:backImageIcon] forState:UIControlStateNormal];
                }
                [viewController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:viewController.xy_prefersNavigationBarTransparent?UIColor.whiteColor:UIColor.blackColor,NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 17]}];
            }
        }
    };
    
    // 给即将显示的控制器，注入代码块
    appearingViewController.xy_willAppearInjectBlock = block;
    
    // 因为不是所有的都是通过push的方式，把控制器压入stack中，也可能是"-setViewControllers:"的方式，所以需要对栈顶控制器做下判断并赋值。
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (disappearingViewController && !disappearingViewController.xy_willAppearInjectBlock) {
        disappearingViewController.xy_willAppearInjectBlock = block;
    }
}

- (BOOL)xy_viewControllerBasedNavigationBarAppearanceEnabled {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }
    self.xy_viewControllerBasedNavigationBarAppearanceEnabled = YES;
    return YES;
}

- (void)setXy_viewControllerBasedNavigationBarAppearanceEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self, @selector(xy_viewControllerBasedNavigationBarAppearanceEnabled), @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

