//
//  MFViewController.m
//  MFRouter
//
//  Created by achaoac on 08/05/2022.
//  Copyright (c) 2022 achaoac. All rights reserved.
//

#import "MFViewController.h"
#import "MFRouterManager.h"

@interface MFViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation MFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
	
    self.title = @"MFRouter";
    
    self.dataArr = @[@"普通跳转",@"普通跳转传参数",@"跳转并执行某个方法"];
    
    UITableView *tView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tView.dataSource = self;
    tView.delegate = self;
    tView.estimatedRowHeight = 40;
    [self.view addSubview:tView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *ident = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            [MFRouterManager jump:@"test-router://detailVC"];
            // 或者快捷使用
//             [MFRouterManager jump:[MFRouterManager routerUrl:@"detailVC"]];
        }
            break;
        case 1:{
            [MFRouterManager jump:@"test-router://detailVC?key1=123" params:@{@"key2" : @"456"} extraParams:@{@"key3": @"789"}];
        }
            break;
        case 2:{
            // 同名的query参数会覆盖params参数，比如此处的key2，最终值是test
            [MFRouterManager jump:@"test-router://settingVC?key1=123&key2=test" params:@{@"key2" : @"456",
                                                                               @"action" : @"actionTest:",
                                                                               @"actionParams" : @"this is test action params",
                                                                             } extraParams:@{@"key3": @"789"}];
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
