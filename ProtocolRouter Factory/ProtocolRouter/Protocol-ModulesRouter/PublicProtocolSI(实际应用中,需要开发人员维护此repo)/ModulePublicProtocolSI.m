//
//  ModuleProtocolSI.m
//  ProtocolRouter
//
//  Created by 林祥星 on 2018/8/7.
//  Copyright © 2018年 GoGoGold. All rights reserved.
//

#import "ModulePublicProtocolSI.h"
@implementation ModulePublicProtocolSI
@dynamic serverController; //告诉编译器这个属性是动态的
@synthesize callback;
@synthesize param;
- (instancetype)init{
    if (self == [super init]) {
        NSLog(@"%@ init success", self);
    }
    return self;
}
- (void)dealloc {
    NSLog(@"%@ dealloc",self);
}



@end


#import "AController.h"
@implementation AProtocolSI
@synthesize name;
@synthesize serverController;

- (instancetype)init{
    if (self == [super init]) {
        //可以在每个子协议里面对相应模块进行特殊处理
    }
    return self;
}
- (void)dealloc {
    //可以在每个子协议里面对相应模块进行特殊处理
}
- (UIViewController *)serverController{
    return serverController ?: ({UIViewController *vc = [AController new];
        vc.protocolSI = self; serverController = vc;
        serverController;});
}

@end

#import "BController.h"
@implementation BProtocolSI
@synthesize serverController;
- (UIViewController *)serverController{
    if (serverController)
        return serverController;
    else {
        BController *vc = [BController new];
        vc.protocolSI = self;
        serverController = vc;
        return serverController;
    }
}
@end

