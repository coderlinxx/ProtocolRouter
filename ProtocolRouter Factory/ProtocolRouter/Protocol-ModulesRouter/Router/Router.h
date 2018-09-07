//
//  Router.h
//  ProtocolRouter
//
//  Created by GoGo: 林祥星 on 2018/8/6.
//  Copyright © 2018年 GoGoGold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModulePublicProtocolSI.h"
#import "ModulePublicProtocolSI+Second.h"

@interface Router : NSObject

+ (instancetype)router;

/** 请确保组件遵守组件对应的协议，并创建对应的接口类 */
- (id)interfaceForProtocol:(Protocol *)p;
- (id)interfaceForURL:(NSURL *)url;

// for unit test
- (void)assertForMoudleWithProtocol:(Protocol *)p;
- (void)assertForMoudleWithURL:(NSURL *)url;

// navi  for vc push/present
- (UIViewController *)findVcOfView:(UIView *)view;

@end
