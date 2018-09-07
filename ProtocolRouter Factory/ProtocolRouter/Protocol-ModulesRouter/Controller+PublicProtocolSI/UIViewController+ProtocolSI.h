//
//  UIViewController+ProtocolSI.h
//  ProtocolRouter
//
//  Created by 林祥星 on 2018/8/8.
//  Copyright © 2018年 GoGoGold. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ModulePublicProtocolSI;
@interface UIViewController (ProtocolSI)
/** 所有模块通用的publicProtocolServerInterface */
@property(nonatomic, strong) ModulePublicProtocolSI *protocolSI;
@end

NS_ASSUME_NONNULL_END
