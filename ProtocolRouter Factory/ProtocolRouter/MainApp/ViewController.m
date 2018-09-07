//
//  ViewController.m
//  ProtocolRouter
//
//  Created by GoGo: 林祥星 on 2018/8/6.
//  Copyright © 2018年 GoGoGold. All rights reserved.
//

#import "ViewController.h"
#import "Router.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];

    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.bounds];
    [btn setTitle:@"调用组件A" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)action{
    
    //方式1:
//    NSString *url = [self encodeToPercentEscapeString:@"AProtocol://?name=URL传递name参数"];
//    id <AProtocol> protocolObj = [[Router router] interfaceForURL:[NSURL URLWithString:url]];
    
    //方式2:
//    id <AProtocol> protocolObj = [[Router router] interfaceForProtocol:@protocol(AProtocol)];
    
    //方式3:
    AProtocolSI *protocolObj = [[Router router] interfaceForProtocol:@protocol(AProtocol)];

    //独立参数
    protocolObj.name = @"AProtocol的独立参数";
    //公共参数
    protocolObj.param = @"A大爷";
    protocolObj.callback = ^(id params) {
        //NSLog(@"%@", params);
    };
    [self presentViewController:protocolObj.serverController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** URL地址过滤,中文转义 */
- (NSString *)encodeToPercentEscapeString: (NSString *)input{
    if (@available(iOS 9.0, *)) {
        input = [input stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:input]];
    }else{
        input = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)input, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL,kCFStringEncodingUTF8));
    }
    return input;
}

@end
