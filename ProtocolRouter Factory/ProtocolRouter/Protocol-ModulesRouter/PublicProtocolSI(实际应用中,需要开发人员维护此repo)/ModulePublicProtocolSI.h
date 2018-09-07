//
//  ModuleProtocolSI.h
//  ProtocolRouter
//
//  Created by 林祥星 on 2018/8/7.
//  Copyright © 2018年 GoGoGold. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIViewController+ProtocolSI.h" //ModuleBaseProtocolSI+Second.h也要用这个,所以要在.h内引用
#import "ModulePublicProtocol.h"
#import "ModulePublicProtocol+Second.h" //都是给分类用的

/** MoudleBaseProtocol的协议服务类,用协议的特性接收协议的@required 和 @optional 属性 */
@interface ModulePublicProtocolSI : NSObject <MoudleBaseProtocol>
@end

@interface AProtocolSI : ModulePublicProtocolSI <AProtocol>
@end

@interface BProtocolSI : ModulePublicProtocolSI <BProtocol>
@end


