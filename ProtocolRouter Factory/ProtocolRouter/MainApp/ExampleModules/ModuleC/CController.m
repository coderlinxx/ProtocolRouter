//
//  CController.m
//  ProtocolRouter
//
//  Created by 林祥星 on 2018/8/7.
//  Copyright © 2018年 GoGoGold. All rights reserved.
//

#import "CController.h"
#import "Router.h"

@interface CController ()

@end

@implementation CController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    
    CGRect frame = self.view.bounds;
    frame.size.height =  frame.size.height/2;
    UIButton *back = [[UIButton alloc] initWithFrame:frame];
    NSString *title = [NSString stringWithFormat:@"back %@ %@",((CProtocolSI *)self.protocolSI)._id, self.class];
    [back setTitle:title forState:UIControlStateNormal];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    frame.origin.y = frame.size.height;
    UIButton *next = [[UIButton alloc] initWithFrame:frame];
    NSString *title2 = [NSString stringWithFormat:@"next %@ %@", ((CProtocolSI *)self.protocolSI).param, self.class];
    [next setTitle:title2 forState:UIControlStateNormal];
    [next addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:back];
    [self.view addSubview:next];
}

- (void)back{
    NSString *s = [NSString stringWithFormat:@"%@ %@ dismiss",self.protocolSI.param,self.class];
    !self.protocolSI.callback ?: self.protocolSI.callback(s);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)next{
    NSLog(@"CController 的下一步");
}

- (void)dealloc {
    NSLog(@"%@ dealloc",self);
}

@end
