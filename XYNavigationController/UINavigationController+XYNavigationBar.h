//
//  UINavigationController+XYNavigationBar.h
//  Leton
//
//  Created by htmj on 2019/7/15.
//  Copyright © 2019年 htmj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (XYNavigationBar)

///视图控制器可以自己控制导航栏的外观，
///而不是全局方式，检查“xy_prefersnavigationbarhidden”属性。
///默认为 YES
@property (nonatomic, assign) BOOL xy_viewControllerBasedNavigationBarAppearanceEnabled;

@end


@interface UIViewController (XYHandlerNavigationBar)

///指示此视图控制器是否希望隐藏其导航栏，
///启用基于视图控制器的导航栏外观时选中。
///默认为 NO
@property (nonatomic, assign) BOOL xy_prefersNavigationBarHidden;

///指示此视图控制器是否希望使其导航栏 透明，
///启用基于视图控制器的导航栏外观时选中。
///默认为 NO
/// 设置 透明 必须 NavigationBar.shadowImage = UIImage.new; [NavigationBar setBackgroundImage:UIImage.new forBarMetrics:UIBarMetricsDefault];
@property (nonatomic, assign) BOOL xy_prefersNavigationBarTransparent;

@end

NS_ASSUME_NONNULL_END
