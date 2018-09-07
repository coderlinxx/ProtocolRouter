//
//  ModuleBaseProtocolSI+Second.m
//  ProtocolRouter
//
//  Created by 林祥星 on 2018/8/10.
//  Copyright © 2018年 GoGoGold. All rights reserved.
//

#import "ModulePublicProtocolSI+Second.h"

@implementation ModulePublicProtocolSI (Second)
@end

#import "CController.h"
@implementation CProtocolSI
@synthesize serverController;
- (UIViewController *)serverController{
    if (serverController)
        return serverController;
    else {
        CController *vc = [CController new];
        vc.protocolSI = self;
        serverController = vc;
        return serverController;
    }
}
@synthesize _id;

@end
