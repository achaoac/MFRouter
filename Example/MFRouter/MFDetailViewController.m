//
//  MFDetailViewController.m
//  MFRouter_Example
//
//  Created by achaoacwang on 2022/8/10.
//  Copyright © 2022 achaoac. All rights reserved.
//

#import "MFDetailViewController.h"
#import "MFRouterManager.h"

@interface MFDetailViewController () <MFRouterManagerDelegate>

@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) NSDictionary *extraParams;

@end

@implementation MFDetailViewController

#pragma mark - MFRouterManagerDelegate
+ (id)openJumpUrl:(NSDictionary *)params extraParams:(NSDictionary *)extraParams {
    MFDetailViewController *vc = [[MFDetailViewController alloc] init];
    vc.params = params;
    vc.extraParams = extraParams;
    NSLog(@"params:%@",params);
    NSLog(@"extraParams:%@",extraParams);
    [MFRouterManager pushVC:vc];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详情页";
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
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
