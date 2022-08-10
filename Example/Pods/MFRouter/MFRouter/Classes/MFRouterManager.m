//
//  MFRouterManager.m
//  MFRouter
//
//  Created by achaoacwang on 2022/8/5.
//

#import "MFRouterManager.h"

static NSString * const kIWUrlSchemeJumpSel = @"openJumpUrl:extraParams:"; // 路由跳转需要实现的协议
static NSString * const kIWUrlSchemeAction = @"action"; // 跳转之后要执行的动作
static NSString * const kIWUrlSchemeActionParams = @"actionParams"; // 跳转之后要执行的动作传递的参数

@interface MFRouterConfig : NSObject

/// 路由前缀，默认是 ‘mf-route’
@property (nonatomic, copy) NSString *urlScheme;

/// 路由映射表
@property (nonatomic, strong) NSMutableDictionary *classDic;

@end

@implementation MFRouterConfig

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.urlScheme = @"mf-route";
        self.classDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)configRouter:(NSString * _Nullable)urlScheme classMaps:(NSDictionary *)classMaps {
    // 重新设置 urlScheme
    if (urlScheme.length > 0) {
        self.urlScheme = urlScheme;
    }
    // 存储路由映射表
    [self.classDic setValuesForKeysWithDictionary:classMaps];
}

- (NSString *)routerClassName:(NSString *)classKey {
    if (!self.classDic) {
        NSLog(@"please config router use selector '+ (void)configRouter:classMaps:' !!!");
        return nil;
    }
    // 根据路由名称获取对应类名
    NSString *className = [self.classDic objectForKey:classKey];
    return className ? className : nil;
}

@end

@implementation MFRouterManager

+ (void)configRouter:(NSString * _Nullable)urlScheme classMaps:(NSDictionary *)classMaps {
    [[MFRouterConfig sharedInstance] configRouter:urlScheme classMaps:classMaps];
}

+ (id)jump:(NSString *)urlStr {
    return [[self class] jump:urlStr params:nil];
}

+ (id)jump:(NSString *)urlStr params:(NSDictionary * _Nullable)params {
    return [[self class] jump:urlStr params:params extraParams:nil];
}

+ (id)jump:(NSString *)urlStr params:(NSDictionary * _Nullable)params extraParams:(NSDictionary * _Nullable)extraParams {
    if (urlStr.length == 0 || ![urlStr hasPrefix:[MFRouterConfig sharedInstance].urlScheme]) {
        NSLog(@"IWRouterManager unavailable url - %@, please make sure %@ has prefix '%@' !!!", urlStr, urlStr, [MFRouterConfig sharedInstance].urlScheme);
        return nil;
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    // 类名key
    NSString *classKey = [url host];
    NSString *className = [[MFRouterConfig sharedInstance] routerClassName:classKey];
    Class jumpClass = NSClassFromString(className);
    // 验证类是否合法
    if (!jumpClass) {
        NSLog(@"IWRouterManager can't jump to class %@ !!!", className);
        return nil;
    }
    if (![jumpClass conformsToProtocol:@protocol(MFRouterManagerDelegate)]) {
        NSLog(@"IWRouterManager can't jump to class - %@, please implement protocol <MFRouterManagerDelegate> !!!", className);
        return nil;
    }
    // 参数解析
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:params];
    [paramsDic addEntriesFromDictionary:[MFRouterManager urlToDictionary:urlStr]];
    
    // 执行跳转动作
    SEL jumpSel = NSSelectorFromString(kIWUrlSchemeJumpSel);
    if ([jumpClass respondsToSelector:jumpSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id jumpInstance = [jumpClass performSelector:jumpSel withObject:paramsDic withObject:extraParams];
#pragma clang diagnostic pop
        
        // 执行跳转之后的额外操作
        NSString *actionSelName = [paramsDic objectForKey:kIWUrlSchemeAction];
        if (jumpInstance && actionSelName) {
            SEL actionSel = NSSelectorFromString(actionSelName);
            id actionParams = [paramsDic objectForKey:kIWUrlSchemeActionParams];
            if ([jumpInstance respondsToSelector:actionSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                // 这里参数类型没有做强校验和匹配，使用时需要注意一下，后续可以通过method_getTypeEncoding来完善
                [jumpInstance performSelector:actionSel withObject:actionParams];
#pragma clang diagnostic pop
            } else {
                NSLog(@"Instance of %@ cant't responds to selector %@ !!!", className, actionSelName);
            }
        }
        return jumpInstance;
    } else {
        NSLog(@"%@ cant't responds to selector %@ !!!", className, kIWUrlSchemeJumpSel);
    }
    return nil;
}

+ (UINavigationController *)rootNavigationController {
    UINavigationController *navi = nil;
    UIWindow *keyWindow = [MFRouterManager keyWindow];
    if (!keyWindow) {
        NSLog(@"%s keyWindow 获取失败，导致无法获得 rootViewController !!!",__func__);
        return nil;
    }
    UIViewController *rootVC = keyWindow.rootViewController;
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        navi = (UINavigationController *)rootVC;
    }
    return navi;
}

+ (UIViewController *)topViewController {
    // 获取keyWindow
    UIWindow *keyWindow = [MFRouterManager keyWindow];
    // 递归查找顶部控制器
    UIViewController *topViewController = [keyWindow rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            // 模态化弹出
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] &&
                   [(UINavigationController*)topViewController topViewController]) {
            // UINavgationController
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            // UITabBarController
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            // 既不是navigationController又不是tabbarController也不是模态化则就是顶部控制器
            break;
        }
    }
    return topViewController;
}

+ (void)pushVC:(UIViewController *)viewController {
    UIViewController *vc = [MFRouterManager topViewController];
    if (vc.navigationController) {
        [vc.navigationController pushViewController:viewController animated:YES];
    }else {
        // 全屏
        viewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [vc presentViewController:viewController animated:YES completion:nil];
    }
}

+ (void)dismissVC:(UIViewController *)viewConroller {
    if (viewConroller.navigationController && viewConroller.navigationController.viewControllers.count > 1) {
        [viewConroller.navigationController popViewControllerAnimated:YES];
    }else {
        [viewConroller dismissViewControllerAnimated:YES completion:nil];
    }
}


/// 获得应用程序的keywindow
+ (UIWindow *)keyWindow {
    // 获取keyWindow
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
                if (keyWindow) {
                    break;
                }
            }
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        keyWindow = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
    }
    return keyWindow;
}

/// url的query参数转key-value
/// @param url 需要转化的url
+ (NSDictionary *)urlToDictionary:(NSString *)url {
    if (url.length <= 0) {
        return nil;
    }
    NSScanner *scanner = [NSScanner scannerWithString:url];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
    if ([url containsString:@"?"]) {
        [scanner scanUpToString:@"?" intoString:nil];
    }
    NSString *tmpValue;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    while ([scanner scanUpToString:@"&" intoString:&tmpValue]) {
        NSArray *components = [tmpValue componentsSeparatedByString:@"="];
        if (components.count >= 2) {
            NSString *key = [components[0] stringByRemovingPercentEncoding];
            NSString *value = [components[1] stringByRemovingPercentEncoding];
            if (key && value) {
                [dictionary setObject:value forKey:key];
            }
        }
    }
    return dictionary;
}

+ (NSString *)routerUrl:(NSString *)classKey {
    return [NSString stringWithFormat:@"%@://%@",[MFRouterConfig sharedInstance].urlScheme, classKey];
}

@end

