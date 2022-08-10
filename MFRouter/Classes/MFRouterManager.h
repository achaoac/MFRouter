//
//  MFRouterManager.h
//  MFRouter
//
//  Created by achaoacwang on 2022/8/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 路由跳转的类需要遵循 <MFRouterManagerDelegate> 协议
@protocol MFRouterManagerDelegate <NSObject>

@required
/// 跳转实现类需要实现的协议
/// @param params 通用参数，由params和query参数合并而来
/// @param extraParams extraParams 额外传递的参数，例如上报参数
/// 返回一个实例对象，如果params里的action对应的方法名，会在跳转之后执行该方法，该方法接受actionParams参数
+ (id)openJumpUrl:(NSDictionary *)params extraParams:(NSDictionary *)extraParams;

@end

/// 路由管理类
@interface MFRouterManager : NSObject

/// 配置路由：建议在应用启动后就开始配置
/// @param urlScheme 路由前缀，传nil使用默认配置 ‘mf-route’ 作为路由前缀
/// @param classMaps 路由映射： key:路由名称；value: UIViewController 类名
+ (void)configRouter:(NSString * _Nullable)urlScheme classMaps:(NSDictionary *)classMaps;

/// 通用跳转
/// @param urlStr 跳转url
+ (id)jump:(NSString *)urlStr;

/// 通用跳转
/// @param urlStr 跳转url
/// @param params 跳转参数，会与query参数合并，同名的query参数会覆盖params参数
+ (id)jump:(NSString *)urlStr params:(NSDictionary * _Nullable)params;

/// 通用跳转
/// @param urlStr 跳转url
/// @param params 跳转参数，会与query参数合并，同名的query参数会覆盖params参数
/// @param extraParams 跳转额外携带参数，额外存储，不会与query参数合并，例如上报参数
+ (id)jump:(NSString *)urlStr params:(NSDictionary * _Nullable)params extraParams:(NSDictionary * _Nullable)extraParams;

/// 获取顶层viewController
+ (UIViewController *)topViewController;

/// 返回主视图的 navi vc
+ (UINavigationController *)rootNavigationController;

/// 跳转，如果topViewController的navigationVC不存在，则由topViewController来present出来
/// @param viewController 需要跳转的 UIViewController
+ (void)pushVC:(UIViewController *)viewController;

/// 销毁栈顶的VC
/// @param viewConroller 需要销毁的 UIViewController
+ (void)dismissVC:(UIViewController *)viewConroller;

/// 根据calssKey生成路由完整路径
/// @param classKey 映射表里 UIViewController 对应的 key
+ (NSString *)routerUrl:(NSString *)classKey;

@end

NS_ASSUME_NONNULL_END
