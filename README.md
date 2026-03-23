# ProtocolRouter

一个基于协议的轻量级 iOS 应用模块化解耦方案。通过 Protocol 实现模块间的完全解耦和动态服务发现。

## 核心特性

- **基于协议的解耦** - 完全依赖 Protocol 定义模块接口，模块间无直接依赖
- **零依赖框架** - 纯 Objective-C 实现，无需外部库依赖
- **动态服务发现** - 通过 Runtime 在运行时动态解析协议实现类
- **生命周期管理** - 内置模块生命周期管理，支持自定义初始化和回收逻辑
- **参数传递灵活** - 支持协议属性、回调函数、URL Scheme 等多种参数传递方式
- **Type-Safe** - 完整的编译时类型检查，避免字符串映射的问题

## 项目特点

ProtocolRouter 采用 **命名约定** + **Runtime 反射** 的方式实现自动化的模块发现和初始化：

```
协议定义 → 服务接口实现 → Router 动态解析 → 服务调用
```

通过这种设计，避免了配置文件和手动映射表的维护需求。

## 核心概念

### 1. 协议 (Protocol)

模块的公开接口契约，定义模块提供的功能。所有协议必须继承自 `MoudleBaseProtocol`：

```objc
@protocol MoudleBaseProtocol <NSObject>

@required
@property(nonatomic, weak) __kindof UIViewController *serverController;  // 组件的 UI 载体

@optional
@property (nonatomic, copy) void (^callback) (id params);                // 回调函数
@property(nonatomic, weak) id param;                                      // 自定义入参

@end
```

例如 ModuleA 的协议定义：

```objc
@protocol AProtocol <MoudleBaseProtocol>
@required
@property(nonatomic, copy) NSString *name;  // 模块特有的参数
@end
```

### 2. 服务接口实现 (Server Interface)

具体实现协议的类，命名规则为 `协议名 + SI` (ServerInterface 缩写)。

```objc
@interface AProtocolSI : ModulePublicProtocolSI <AProtocol>
@end

@implementation AProtocolSI
@synthesize name;
@synthesize serverController;

- (UIViewController *)serverController {
    // 第一次调用时创建并缓存 Controller
    return serverController ?: ({
        UIViewController *vc = [AController new];
        vc.protocolSI = self;
        serverController = vc;
        serverController;
    });
}
@end
```

### 3. Router 路由器

单例模式的核心路由引擎，负责协议到实现类的运行时解析。

```objc
Router *router = [Router router];

// 方式1: 通过协议获取服务
id<AProtocol> service = [router interfaceForProtocol:@protocol(AProtocol)];

// 方式2: 通过 URL Scheme 获取服务（Query 参数自动绑定到属性）
id<AProtocol> service = [router interfaceForURL:[NSURL URLWithString:@"AProtocol://?name=test"]];
```

**Router 的工作原理：**

1. 获取协议名称：`NSStringFromProtocol(@protocol(AProtocol))` → `"AProtocol"`
2. 拼接服务实现类名：`"AProtocol" + "SI"` → `"AProtocolSI"`
3. 通过 Runtime 获取类：`NSClassFromString("AProtocolSI")` → `AProtocolSI class`
4. 创建实例：`[[AProtocolSI alloc] init]`

## 快速开始

### 项目结构

```
ProtocolRouter Factory/
├── ProtocolRouter/
│   ├── MainApp/                              # 主应用
│   │   └── ExampleModules/                   # 模块示例
│   │       ├── ModuleA/
│   │       ├── ModuleB/
│   │       └── ModuleC/
│   │
│   └── Protocol-ModulesRouter/               # 核心框架
│       ├── Router/                           # 路由引擎
│       │   └── Router.h/m
│       ├── PublicProtocol/                   # 协议定义（开发者维护）
│       │   ├── ModulePublicProtocol.h
│       │   └── ModulePublicProtocol+Second.h
│       ├── PublicProtocolSI/                 # 服务接口实现（开发者维护）
│       │   ├── ModulePublicProtocolSI.h/m
│       │   └── ModulePublicProtocolSI+Second.h/m
│       └── Controller+PublicProtocolSI/      # UIViewController 扩展
│           └── UIViewController+ProtocolSI.h/m
```

### 编译构建

```bash
# 打开项目
open "ProtocolRouter Factory/ProtocolRouter.xcodeproj"

# 命令行构建
xcodebuild -project "ProtocolRouter Factory/ProtocolRouter.xcodeproj" \
           -scheme ProtocolRouter \
           -configuration Debug
```

## 使用示例

### 基础使用 - 调用模块服务

主页面调用 ModuleA：

```objc
// ViewController.m
#import "Router.h"

- (void)callModuleA {
    // 1. 获取服务
    id<AProtocol> service = [[Router router] interfaceForProtocol:@protocol(AProtocol)];

    // 2. 配置参数
    service.name = @"来自主页面的参数";           // 协议特有参数
    service.param = @"主页面";                   // 基础参数
    service.callback = ^(id params) {
        NSLog(@"回调数据: %@", params);
    };

    // 3. 调用服务（获取 UI）
    [self presentViewController:service.serverController
                      animated:YES
                    completion:nil];
}
```

### URL Scheme 方式

通过 URL 调用服务，Query 参数自动绑定到协议属性：

```objc
// 自动解析 URL 并设置属性
id<AProtocol> service = [[Router router]
    interfaceForURL:[NSURL URLWithString:@"AProtocol://?name=url_param&param=data"]];

// 等价于：
// service.name = @"url_param"
// service.param = @"data"

[self presentViewController:service.serverController animated:YES completion:nil];
```

### 模块间级联调用

ModuleA 调用 ModuleB（展示链式调用）：

```objc
// AController.m
- (void)callModuleB {
    // 1. 通过 Router 获取 ModuleB 服务
    id<BProtocol> bService = [[Router router] interfaceForProtocol:@protocol(BProtocol)];

    // 2. 配置参数
    bService.param = @"来自 ModuleA";
    bService.callback = ^(id params) {
        NSLog(@"ModuleB 返回: %@", params);
    };

    // 3. 跳转到 ModuleB
    [self presentViewController:bService.serverController animated:YES completion:nil];
}

// AController.m - 返回回调
- (void)backAction {
    NSString *result = [NSString stringWithFormat:@"%@ 执行完成", self.class];

    // 调用上级模块的回调
    if (self.protocolSI.callback) {
        self.protocolSI.callback(result);
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}
```

ModuleB 调用 ModuleC（三级嵌套）：

```objc
// BController.m
- (void)callModuleC {
    id<CProtocol> cService = [[Router router] interfaceForProtocol:@protocol(CProtocol)];

    // CProtocol 有扩展参数 _id
    cService._id = @"12345";
    cService.param = @"来自 ModuleB";
    cService.callback = ^(id params) {
        NSLog(@"ModuleC 返回: %@", params);
    };

    [self presentViewController:cService.serverController animated:YES completion:nil];
}
```

### 协议定义示例

**基础协议** (ModulePublicProtocol.h)：

```objc
// 关键字定义，可自定义
#define MoudleProtocol_ServerInterface @"SI"

// 基础协议
@protocol MoudleBaseProtocol <NSObject>
@required
@property(nonatomic, weak) __kindof UIViewController *serverController;
@optional
@property (nonatomic, copy) void (^callback) (id params);
@property(nonatomic, weak) id param;
@end

// ModuleA 协议
@protocol AProtocol <MoudleBaseProtocol>
@required
@property(nonatomic, copy) NSString *name;
@end

// ModuleB 协议
@protocol BProtocol <MoudleBaseProtocol>
@end

// ModuleC 协议（通过分类扩展）
@protocol CProtocol <MoudleBaseProtocol>
@required
@property(nonatomic, copy) NSString *_id;
@end
```

**分类扩展** (ModulePublicProtocol+Second.h)：

```objc
@protocol CProtocol <MoudleBaseProtocol>
@required
@property(nonatomic, copy) NSString *_id;
@end
```

### 服务接口实现示例

**基础实现** (ModulePublicProtocolSI.h/m)：

```objc
// ModulePublicProtocolSI.h
#import "ModulePublicProtocol.h"

@interface ModulePublicProtocolSI : NSObject <MoudleBaseProtocol>
@end

@interface AProtocolSI : ModulePublicProtocolSI <AProtocol>
@end

@interface BProtocolSI : ModulePublicProtocolSI <BProtocol>
@end
```

```objc
// ModulePublicProtocolSI.m
@implementation ModulePublicProtocolSI
@dynamic serverController;      // 由子类实现
@synthesize callback;
@synthesize param;

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"%@ 初始化", self);
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%@ 释放", self);
}

// 通用工具方法：字符串创建 Controller
- (UIViewController *)controllerFromString:(NSString *)string {
    UIViewController *vc = [NSClassFromString(string) new];
    if (vc) {
        return vc;
    } else {
        NSLog(@"找不到类: %@", string);
        return nil;
    }
}
@end

// AProtocolSI 实现
@implementation AProtocolSI
@synthesize name;
@synthesize serverController;

- (UIViewController *)serverController {
    // 懒加载：第一次调用时创建，后续复用
    return serverController ?: ({
        UIViewController *vc = [AController new];
        vc.protocolSI = self;
        serverController = vc;
        serverController;
    });
}
@end

// BProtocolSI 实现（使用字符串创建）
@implementation BProtocolSI
@synthesize serverController;

- (UIViewController *)serverController {
    return serverController ?: ({
        UIViewController *vc = [self controllerFromString:@"BController"];
        vc.protocolSI = self;
        serverController = vc;
        serverController;
    });
}
@end
```

**分类扩展** (ModulePublicProtocolSI+Second.m)：

```objc
// ModulePublicProtocolSI+Second.m
@implementation CProtocolSI
@synthesize serverController;
@synthesize _id;

- (UIViewController *)serverController {
    if (serverController) {
        return serverController;
    } else {
        CController *vc = [CController new];
        vc.protocolSI = self;
        serverController = vc;
        return serverController;
    }
}
@end
```

### 模块内部实现

**接收协议服务** (AController.m)：

```objc
@interface AController ()
@property (nonatomic, strong) AProtocolSI *proSI;
@end

@implementation AController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];

    // 从基类属性中获取并类型转换
    _proSI = (AProtocolSI *)self.protocolSI;

    // 使用协议参数
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 200, 50)];
    label.text = [NSString stringWithFormat:@"模块参数: %@", _proSI.name];
    [self.view addSubview:label];
}

- (void)backAction {
    // 拼装返回数据
    NSString *result = [NSString stringWithFormat:@"%@ 完成", self.class];

    // 调用回调函数
    if (self.protocolSI.callback) {
        self.protocolSI.callback(result);
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextAction {
    // 调用下一个模块
    id<BProtocol> bService = [[Router router] interfaceForProtocol:@protocol(BProtocol)];
    bService.param = @"来自 A";
    bService.callback = ^(id params) {
        NSLog(@"B 返回: %@", params);
    };
    [self presentViewController:bService.serverController animated:YES completion:nil];
}
@end
```

## 添加新模块

按照以下步骤可以轻松添加新模块，无需修改现有代码：

### 第1步：定义协议

在 `PublicProtocol/ModulePublicProtocol.h` 中添加新协议：

```objc
@protocol DProtocol <MoudleBaseProtocol>
@required
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) NSArray *dataArray;
@end
```

### 第2步：创建 UI 组件

创建 `DController.h/m`：

```objc
// DController.h
#import <UIKit/UIKit.h>
@interface DController : UIViewController
@end

// DController.m
#import "DController.h"
#import "Router.h"

@implementation DController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];

    // 获取协议属性
    DProtocolSI *si = (DProtocolSI *)self.protocolSI;
    NSLog(@"标题: %@, 数据: %@", si.title, si.dataArray);
}

- (void)dismissAction {
    if (self.protocolSI.callback) {
        self.protocolSI.callback(@"D 模块返回数据");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
```

### 第3步：实现服务接口

在 `PublicProtocolSI/ModulePublicProtocolSI.h` 中添加：

```objc
@interface DProtocolSI : ModulePublicProtocolSI <DProtocol>
@end
```

在 `PublicProtocolSI/ModulePublicProtocolSI.m` 中实现：

```objc
#import "DController.h"

@implementation DProtocolSI
@synthesize title;
@synthesize dataArray;
@synthesize serverController;

- (UIViewController *)serverController {
    return serverController ?: ({
        UIViewController *vc = [DController new];
        vc.protocolSI = self;
        serverController = vc;
        serverController;
    });
}
@end
```

### 第4步：使用新模块

就这样！现在可以在任何地方调用新模块了：

```objc
id<DProtocol> service = [[Router router] interfaceForProtocol:@protocol(DProtocol)];
service.title = @"新模块";
service.dataArray = @[@"1", @"2", @"3"];
service.callback = ^(id params) {
    NSLog(@"返回: %@", params);
};
[self presentViewController:service.serverController animated:YES completion:nil];
```

## 高级特性

### 1. URL Scheme 路由

支持使用 URL 调用模块，Query 参数自动映射到协议属性：

```objc
// URL 方式调用
NSString *urlString = @"AProtocol://?name=test&param=data";
NSURL *url = [NSURL URLWithString:urlString];
id<AProtocol> service = [[Router router] interfaceForURL:url];

// 自动设置了 service.name = @"test", service.param = @"data"
[self presentViewController:service.serverController animated:YES completion:nil];
```

### 2. 模块可用性检测

在单元测试中验证模块是否正确注册：

```objc
// 检验模块是否存在
[[Router router] assertForMoudleWithProtocol:@protocol(AProtocol)];  // 若不存在则抛异常

// 检验 URL 对应的模块
[[Router router] assertForMoudleWithURL:[NSURL URLWithString:@"AProtocol://"]];
```

### 3. 动态 ViewController 查找

获取当前视图对应的 ViewController：

```objc
UIViewController *vc = [[Router router] findVcOfView:self.view];
```

### 4. 模块生命周期管理

在服务接口的 `init` 和 `dealloc` 方法中可以处理模块的初始化和回收：

```objc
@implementation AProtocolSI

- (instancetype)init {
    if (self = [super init]) {
        // 模块初始化，可以在这里加载数据、注册监听等
        NSLog(@"AProtocolSI 初始化");
        [self setupData];
    }
    return self;
}

- (void)dealloc {
    // 模块回收，清理资源、取消监听等
    NSLog(@"AProtocolSI 释放");
    [self cleanup];
}
@end
```

## 设计特点一览

| 特点 | ProtocolRouter |
|------|-------|
| 映射表 | 无需手动维护 |
| 中间件 | 极少 |
| 编译检查 | 完整的类型检查 |
| 学习成本 | 低 |
| 代码侵入 | 低 |
| 配置文件 | 无需 |

## 常见问题

### Q: 为什么必须使用 "SI" 后缀？

A: 这是框架的命名约定，Router 通过这个约定在运行时动态查找实现类。可以通过修改 `MoudleProtocol_ServerInterface` 宏来自定义后缀。

```objc
#define MoudleProtocol_ServerInterface @"Impl"  // 改为使用 Impl 后缀
```

### Q: 模块怎么相互调用？

A: 通过 Router 获取服务，模块之间完全解耦。即使模块 A 调用模块 B，也是通过 Router 获取 B 的服务，而不是直接依赖。

### Q: 能否传复杂对象参数？

A: 可以。使用 `param` 属性传递任意对象。如果需要多个参数，可以在协议中自定义属性。

```objc
@protocol CustomProtocol <MoudleBaseProtocol>
@required
@property(nonatomic, strong) NSDictionary *data;
@property(nonatomic, strong) NSArray *list;
@end
```

### Q: 如何处理模块初始化失败？

A: 如果 Router 找不到对应的服务实现类，会抛出异常。可以在测试中使用 `assertForMoudleWithProtocol:` 提前验证。

### Q: 支持协议继承吗？

A: 支持。所有协议都继承自 `MoudleBaseProtocol`，也可以创建中间协议进行多层继承。

## 技术实现细节

### Runtime 反射机制

Router 的核心实现利用 Objective-C Runtime：

```objc
- (id)interfaceForProtocol:(Protocol *)p {
    // 1. 获取协议名
    NSString *protocolName = NSStringFromProtocol(p);

    // 2. 拼接实现类名
    NSString *className = [protocolName stringByAppendingString:MoudleProtocol_ServerInterface];

    // 3. 从运行时获取类
    Class cls = NSClassFromString(className);

    // 4. 创建实例
    return [[cls alloc] init];
}
```

### 属性绑定机制

URL Query 参数的自动绑定：

```objc
- (id)interfaceForURL:(NSURL *)url {
    id instance = [self interfaceForProtocol:objc_getProtocol(url.scheme.UTF8String)];

    // 解析 Query 参数
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];

    // 通过 KVC 自动赋值
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *item, NSUInteger idx, BOOL *stop) {
        [instance setValue:item.value forKey:item.name];
    }];

    return instance;
}
```

## License

MIT License 
