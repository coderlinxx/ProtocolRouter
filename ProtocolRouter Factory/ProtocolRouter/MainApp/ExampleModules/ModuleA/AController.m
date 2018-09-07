//
//  AController.m
//  ProtocolRouter
//
//  Created by GoGo: 林祥星 on 2018/8/6.
//  Copyright © 2018年 GoGoGold. All rights reserved.
//

#import "AController.h"
#import "Router.h"

@interface AController ()
/** 组件内置的组件化协议服务接口接收器,接收外部的公共基类ModuleBaseProtocolSI接口
 为什么要在.m类内部在写一个接收器:
 1. 外面.h通过 UIViewController+ProtocolSI 赋值的protocolSI属性是ModuleBaseProtocolSI类型的基类,虽然接口的实际类型为AProtocolSI,但是为了用 category 封装统一接口,都用ModuleBaseProtocolSI接收了,
 2. 在业务组件内如果不用AProtocolSI类接收转化一下,是无法在控制台打印出数据的,有点硬编码的感觉,
 3. 为了更完美的运用在业务类内,最好做一个具体的AProtocolSI类型的属性来接收转换一下,
 4. 如果不是在类内部很多方法内都调用了此属性,也没有必要全局声明此接收器
 5. 实际运用过程中不用此属性接收也没问题.
 */
@property (nonatomic, strong) AProtocolSI *proSI;
@end

@implementation AController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    _proSI = (AProtocolSI *)self.protocolSI;

    CGRect frame = self.view.bounds;
    frame.size.height =  frame.size.height/2;
    UIButton *back = [[UIButton alloc] initWithFrame:frame];
    NSString *title = [NSString stringWithFormat:@"back %@ %@", _proSI.name, self.class];
    [back setTitle:title forState:UIControlStateNormal];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    frame.origin.y = frame.size.height;
    UIButton *next = [[UIButton alloc] initWithFrame:frame];
    NSString *title2 = [NSString stringWithFormat:@"next %@ %@", _proSI.name, self.class];
    [next setTitle:title2 forState:UIControlStateNormal];
    [next addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:back];
    [self.view addSubview:next];
}

- (void)back{
    NSString *s = [NSString stringWithFormat:@"%@ %@ dismiss",self.protocolSI.param,self.class];
    !self.protocolSI.callback ?: self.protocolSI.callback(s);
    NSLog(@"%@",self.protocolSI.serverController);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)next{
    id <BProtocol> protocolObj = [[Router router] interfaceForProtocol:@protocol(BProtocol)];
    //    id <BProtocol> protocolObj = [[Router router] interfaceForURL:[NSURL URLWithString:@"BProtocol://?param=xiaobaitu"]];
    protocolObj.param = @"B大爷";
    protocolObj.callback = ^(id params) {
        NSLog(@"%@", params);
    };
    [self presentViewController:protocolObj.serverController animated:YES completion:nil];
}

- (void)dealloc {
    NSLog(@"%@ dealloc",self);
}

@end
