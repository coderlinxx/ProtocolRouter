//
//  ModuleProtocol+Second.h
//  ProtocolRouter
//
//  Created by 林祥星 on 2018/8/7.
//  Copyright © 2018年 GoGoGold. All rights reserved.
//

#import "ModulePublicProtocol.h"

@protocol CProtocol <MoudleBaseProtocol>
@required
// input 作为组件A的入参 可以自定义任意属性
@property(nonatomic, copy) NSString *_id;
@end

