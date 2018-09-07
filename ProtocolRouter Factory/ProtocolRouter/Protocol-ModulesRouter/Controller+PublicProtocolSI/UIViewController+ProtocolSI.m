//
//  UIViewController+ProtocolSI.m
//  ProtocolRouter
//
//  Created by 林祥星 on 2018/8/8.
//  Copyright © 2018年 GoGoGold. All rights reserved.
//

#import "UIViewController+ProtocolSI.h"
#import <objc/runtime.h>

@implementation UIViewController (ProtocolSI)
@dynamic protocolSI;

#pragma mark ————— properties —————

- (UIColor *)shadowColor {
    return objc_getAssociatedObject(self, @selector(shadowColor));
}

- (void)setShadowColor:(UIColor *)shadowColor {
    if (self.shadowColor != shadowColor) {
        objc_setAssociatedObject(self, @selector(shadowColor), shadowColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (ModulePublicProtocolSI *)protocolSI{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setProtocolSI:(ModulePublicProtocolSI *)protocolSI{
    if (self.protocolSI != protocolSI) {
        objc_setAssociatedObject(self, @selector(protocolSI), protocolSI, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
