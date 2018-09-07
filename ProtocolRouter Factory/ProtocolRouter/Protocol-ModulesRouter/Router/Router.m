//
//  Router.m
//  ProtocolRouter
//
//  Created by GoGo: 林祥星 on 2018/8/6.
//  Copyright © 2018年 GoGoGold. All rights reserved.
//

#import "Router.h"
#import <objc/runtime.h>

@implementation Router

+ (instancetype)router {
    static dispatch_once_t onceToken;
    static Router *__router;
    dispatch_once(&onceToken, ^{
        __router = [[self alloc] init];
    });
    return __router;
}

- (id)interfaceForProtocol:(Protocol *)p {
    Class cls = [self _clsForProtocol:p];
    return [[cls alloc] init];
}

- (id)interfaceForURL:(NSURL *)url {
    id __block ret = [self interfaceForProtocol: objc_getProtocol(url.scheme.UTF8String)];
    NSURLComponents *cp = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    [cp.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ret setValue: obj.value forKey: obj.name];
    }];
    return ret;
}

- (void)assertForMoudleWithProtocol:(Protocol *)p {
    if (![self _clsForProtocol:p]) {
        NSString *protocolName = NSStringFromProtocol(p);
        NSString *clsName = [protocolName stringByAppendingString: MoudleProtocol_ServerInterface];
        NSString *reason = [NSString stringWithFormat: @"找不到协议 %@ 对应的接口类 %@ 的实现", protocolName, clsName];
        [self _throwException: reason];
    }
}

- (void)assertForMoudleWithURL:(NSURL *)url {
    NSString *protocolName = url.scheme;
    if (![self _clsForProtocol: objc_getProtocol(protocolName.UTF8String)]) {
        NSString *clsName = [protocolName stringByAppendingString: MoudleProtocol_ServerInterface];
        NSString *reason = [NSString stringWithFormat: @"找不到协议 %@ 对应的接口类 %@ 的实现", protocolName, clsName];
        [self _throwException: reason];
    }
}

#pragma -mark NAVI
- (UIViewController *)findVcOfView:(UIView *)view {
    UIResponder *rp = view;
    while ((rp = [rp nextResponder])) {
        if ([rp isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)rp;
        }
    }
    return nil;
}


#pragma -mark private

- (Class)_clsForProtocol:(Protocol *) p {
    NSString *clsString = [NSStringFromProtocol(p) stringByAppendingString: MoudleProtocol_ServerInterface];
    return NSClassFromString(clsString);
}

- (void)_throwException:(NSString *) reason {
    @throw [NSException exceptionWithName: NSGenericException reason: reason userInfo: nil];
}

@end
