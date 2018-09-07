//
//  BController.m
//  ProtocolRouter
//
//  Created by 林祥星 on 2018/8/7.
//  Copyright © 2018年 GoGoGold. All rights reserved.
//

#import "BController.h"
#import "Router.h"

@interface BController ()

@end

@implementation BController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGRect frame = self.view.bounds;
    frame.size.height =  frame.size.height/2;
    UIButton *back = [[UIButton alloc] initWithFrame:frame];
    NSString *title = [NSString stringWithFormat:@"back %@ %@", self.protocolSI.param, self.class];
    [back setTitle:title forState:UIControlStateNormal];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    frame.origin.y = frame.size.height;
    UIButton *next = [[UIButton alloc] initWithFrame:frame];
    NSString *title2 = [NSString stringWithFormat:@"next %@ %@", self.protocolSI.param, self.class];
    [next setTitle:title2 forState:UIControlStateNormal];
    [next addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:back];
    [self.view addSubview:next];
}

- (void)back{
    NSString *s = [NSString stringWithFormat:@"%@ %@ dismiss", self.protocolSI.param,self.class];
    !self.protocolSI.callback ?: self.protocolSI.callback(s);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)next{
    id <CProtocol> protocolObj = [[Router router] interfaceForProtocol:@protocol(CProtocol)];
    //    id <CProtocol> protocolObj = [[Router router] interfaceForURL:[NSURL URLWithString:@"CProtocol://?param=xiaobaitu"]];
    protocolObj.param = @"C大爷";
    protocolObj._id = @"wjchwkbcwbck";
    protocolObj.callback = ^(id params) {
        [self dosomething:params];
    };
    [self presentViewController:protocolObj.serverController animated:YES completion:nil];
}


- (void)dosomething:(id)params{
    NSLog(@"%@", params);
}
- (void)dealloc {
    NSLog(@"%@ dealloc",self);
}

@end
