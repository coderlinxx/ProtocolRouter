//
//  ModuleProtocol.h
//  ProtocolRouter
//
//  Created by GoGo: 林祥星 on 2018/8/6.
//  Copyright © 2018年 GoGoGold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** 协议的接口类所约定的关键字,替换成其他 KEY 的话,创建协议接口类时要拼接成相应的 KEY */
#ifndef MoudleProtocol_ServerInterface
#define MoudleProtocol_ServerInterface @"SI"
#endif

@protocol MoudleBaseProtocol <NSObject>

@required
/** server body */
@property(nonatomic, weak) __kindof UIViewController *serverController;

@optional
/** 可选参数: callback */
@property (nonatomic, copy) void (^callback) (id params);

/** 可选参数: 作为组件的入参 可以自定义任意属性 */
@property(nonatomic, weak) id param;

@end


@protocol AProtocol <MoudleBaseProtocol>
@required
// input 作为组件A的入参 可以自定义任意属性
@property(nonatomic, copy) NSString *name;
@end

@protocol BProtocol <MoudleBaseProtocol>

@end



