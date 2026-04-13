# ProtocolRouter

一个基于协议的轻量级 iOS 应用模块化解耦方案。通过 Protocol + Runtime + 反射机制 实现模块间的完全解耦和动态服务发现。

## 核心特性

- **基于协议的解耦** - 协议是模块间通信的唯一契约，模块间零直接依赖
- **零配置路由** - 命名约定驱动，无需手动注册路由表，Router 在运行时自动发现服务类
- **动态服务发现** - 通过 Runtime 反射，根据协议名自动定位并实例化对应的实现类
- **类型安全** - 完整的编译期类型检查，避免纯字符串路由的运行时错误风险
- **灵活的参数传递** - 支持协议属性、回调函数、URL Scheme + KVC 自动注入等多种方式
- **轻量无外依赖** - 纯 Objective-C 实现，无需任何第三方库

## 核心设计

ProtocolRouter 采用 **命名约定 + Runtime 反射** 实现自动化的服务发现：

```
协议名（AProtocol）
    ↓ NSStringFromProtocol + 拼接 "SI"
实现类名（AProtocolSI）
    ↓ NSClassFromString（Runtime 反射）
实现类（AProtocolSI.class）
    ↓ alloc init
服务实例（id<AProtocol>）
```

只需遵循 `协议名 + "SI"` 的命名约定，无需任何配置文件或手动注册，Router 即可在运行时自动发现并实例化服务类。

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

### 2. 服务接口实现 (Service Interface)

具体实现协议的类，命名规则为 `协议名 + SI`（ServerInterface 缩写）。这个命名约定是 Router 动态发现的唯一依据。

```objc
@interface AProtocolSI : ModulePublicProtocolSI <AProtocol>
@end

@implementation AProtocolSI
@synthesize name;
@synthesize serverController;

- (UIViewController *)serverController {
    // 懒加载：首次访问时创建并缓存 Controller
    return serverController ?: ({
        UIViewController *vc = [AController new];
        vc.protocolSI = self;   // 将 SI 注入 VC，实现参数传递和回调绑定
        serverController = vc;
        serverController;
    });
}
@end
```

### 3. Router 路由器

单例模式的核心路由引擎，通过 Runtime 反射实现协议到实现类的动态映射。

```objc
Router *router = [Router router];

// 方式1: 通过协议获取服务（类型安全，编译期检查）
id<AProtocol> service = [router interfaceForProtocol:@protocol(AProtocol)];

// 方式2: 通过 URL Scheme 获取服务（Query 参数通过 KVC 自动注入属性）
id<AProtocol> service = [router interfaceForURL:[NSURL URLWithString:@"AProtocol://?name=test"]];
```

**Router 的工作原理：**

1. 获取协议名称：`NSStringFromProtocol(@protocol(AProtocol))` → `"AProtocol"`
2. 拼接服务实现类名：`"AProtocol"` + `"SI"` → `"AProtocolSI"`
3. Runtime 反射获取类：`NSClassFromString("AProtocolSI")` → `AProtocolSI.class`
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

通过 URL 调用服务，Query 参数通过 KVC 自动注入到对应协议属性：

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

ModuleA 调用 ModuleB（无需 import BController 或任何 B 模块实现）：

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

// AController.m - 返回并触发回调
- (void)backAction {
    NSString *result = [NSString stringWithFormat:@"%@ 执行完成", self.class];

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

## 添加新模块

按照以下步骤可以轻松添加新模块，**无需修改任何现有代码，Router 通过命名约定自动发现**：

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

就这样！Router 通过 `"DProtocol"` + `"SI"` = `"DProtocolSI"` 自动发现实现类：

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

支持使用 URL 调用模块，Query 参数通过 KVC 自动映射到协议属性，适用于跨应用、动态路由等场景：

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
// 检验模块是否存在（找不到则抛异常，适合用于测试阶段）
[[Router router] assertForMoudleWithProtocol:@protocol(AProtocol)];

// 检验 URL 对应的模块
[[Router router] assertForMoudleWithURL:[NSURL URLWithString:@"AProtocol://"]];
```

### 3. 动态 ViewController 查找

通过 UIResponder 链查找当前视图所在的 ViewController：

```objc
UIViewController *vc = [[Router router] findVcOfView:self.view];
```

### 4. 模块生命周期管理

在服务接口的 `init` 和 `dealloc` 中处理模块的初始化和资源回收：

```objc
@implementation AProtocolSI

- (instancetype)init {
    if (self = [super init]) {
        // 模块初始化：加载数据、注册监听等
        [self setupData];
    }
    return self;
}

- (void)dealloc {
    // 模块回收：清理资源、取消监听等
    [self cleanup];
}
@end
```

## 设计对比

| 特点 | ProtocolRouter | 路由表方案 | 手动 import 方案 |
|------|:-:|:-:|:-:|
| 路由注册 | 无需 | 需手动注册 | 无需 |
| 模块间依赖 | 零依赖 | 依赖路由 | 强依赖 |
| 编译期类型检查 | ✅ | ❌ | ✅ |
| 配置文件 | 无需 | 需要 | 无需 |
| 学习成本 | 低 | 中 | 低 |
| 代码侵入 | 低 | 中 | 高 |

## 常见问题

### Q: 为什么必须使用 "SI" 后缀？

A: 这是框架的命名约定，Router 通过 `协议名 + "SI"` 在运行时自动查找实现类。可以通过修改 `MoudleProtocol_ServerInterface` 宏来自定义后缀。

```objc
#define MoudleProtocol_ServerInterface @"Impl"  // 改为使用 Impl 后缀
```

### Q: 模块间怎么相互调用？

A: 通过 Router 获取服务，模块之间完全解耦。即使模块 A 调用模块 B，也是通过 Router 获取 B 的服务接口，A 只需要 import B 的协议头文件，不依赖 B 的任何具体实现。

### Q: 能否传复杂对象参数？

A: 可以。使用基础协议的 `param` 属性可传递任意对象；或在协议中自定义强类型属性：

```objc
@protocol CustomProtocol <MoudleBaseProtocol>
@required
@property(nonatomic, strong) NSDictionary *data;
@property(nonatomic, strong) NSArray *list;
@end
```

### Q: 如何处理找不到实现类的情况？

A: Router 找不到对应实现类时会返回 `nil`，可在测试阶段用 `assertForMoudleWithProtocol:` 提前断言验证。

### Q: 支持协议继承吗？

A: 支持。所有协议都继承自 `MoudleBaseProtocol`，也可以在模块间创建中间协议进行多层继承。

## 技术实现细节

### Runtime 反射机制

Router 核心只需 3 行代码，完全通过 Runtime 实现动态服务发现：

```objc
- (id)interfaceForProtocol:(Protocol *)p {
    NSString *clsString = [NSStringFromProtocol(p) stringByAppendingString:MoudleProtocol_ServerInterface];
    return [[NSClassFromString(clsString) alloc] init];
}
```

- `NSStringFromProtocol()`：协议对象 → 字符串
- `NSClassFromString()`：字符串 → 类对象（Runtime 反射核心）
- 整个过程不需要 `#import` 任何具体的实现类

### URL 参数 KVC 自动注入

```objc
- (id)interfaceForURL:(NSURL *)url {
    id instance = [self interfaceForProtocol:objc_getProtocol(url.scheme.UTF8String)];

    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *item, NSUInteger idx, BOOL *stop) {
        [instance setValue:item.value forKey:item.name];  // KVC 自动映射到同名属性
    }];

    return instance;
}
```

- `objc_getProtocol()`：字符串 → 协议对象（`NSStringFromProtocol` 的逆操作）
- `NSURLComponents`：解析 URL 各组成部分
- KVC `setValue:forKey:`：动态注入参数，无需关心具体属性类型

### UIViewController 属性扩展

通过 Category + AssociatedObject 为所有 UIViewController 注入 `protocolSI` 属性：

```objc
- (void)setProtocolSI:(ModulePublicProtocolSI *)protocolSI {
    objc_setAssociatedObject(self, @selector(protocolSI), protocolSI,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ModulePublicProtocolSI *)protocolSI {
    return objc_getAssociatedObject(self, _cmd);
}
```

## License

MIT License
