//
//  MFSettingViewController.m
//  MFRouter_Example
//
//  Created by achaoacwang on 2022/8/10.
//  Copyright © 2022 achaoac. All rights reserved.
//

#import "MFSettingViewController.h"
#import "MFRouterManager.h"

@interface MFSettingViewController () <MFRouterManagerDelegate>

@end

@implementation MFSettingViewController

#pragma mark - MFRouterManagerDelegate
+ (id)openJumpUrl:(NSDictionary *)params extraParams:(NSDictionary *)extraParams {
    MFSettingViewController *vc = [[MFSettingViewController alloc] init];
    NSLog(@"params:%@",params);
    NSLog(@"extraParams:%@",extraParams);
    [MFRouterManager pushVC:vc];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置页";
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (void)actionTest:(NSString *)str {
    NSLog(@"执行了-actionTest:方法\n参数是 - %@",str);
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
