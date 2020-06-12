//
//  UINavigationController+XYBase.h
//  CodeToolsDemo
//
//  Created by htmj on 2019/7/19.
//  Copyright © 2019年 Wcaulpl. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface UIViewController (XYSideslip)

/*
 * 视图控制器可以自己控制导航栏的外观，
 * 而不是全局方式，检查“xy_prefersnavigationbarhidden”属性。
 * 默认为 YES
 */
@property (nonatomic, assign) BOOL xy_prefersSide_slipBackEnabled;

@end

@interface UINavigationController (XYBase)

/*
 *  一次性跳转多个 控制器
 */
- (void)xy_pushViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated;

/*
 *  替换 控制器
 */
- (void)xy_replaceViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)back;

@end

NS_ASSUME_NONNULL_END
