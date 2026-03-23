# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ProtocolRouter** is an iOS modularization solution using Protocol-based decoupling. It provides a lightweight alternative to traditional app modularization approaches like CTMediator and BeeHive, focusing on protocol-driven architecture with minimal boilerplate.

The core principle: modules expose their services through protocols, which are resolved at runtime to concrete implementations (interface classes) via the Router.

## Technology Stack

- **Language**: Objective-C (iOS traditional codebase)
- **Deployment Target**: iOS 9.0+
- **Build Tool**: Xcode (project at `ProtocolRouter Factory/ProtocolRouter.xcodeproj`)
- **Dependencies**: None (framework-free implementation)

## Project Structure

```
ProtocolRouter Factory/
├── ProtocolRouter/
│   ├── MainApp/                                          # Main application entry point
│   │   ├── AppDelegate.h/m
│   │   ├── ViewController.h/m
│   │   └── ExampleModules/                              # Example modules demonstrating the pattern
│   │       ├── ModuleA/ (AController)
│   │       ├── ModuleB/ (BController)
│   │       └── ModuleC/ (CController)
│   │
│   ├── Protocol-ModulesRouter/
│   │   ├── Router/                                      # Core routing engine
│   │   │   ├── Router.h/m                               # Main Router singleton
│   │   │
│   │   ├── PublicProtocol(实际应用中,需要开发人员维护此repo)/
│   │   │   ├── ModulePublicProtocol.h                   # Base protocol definitions (MoudleBaseProtocol, AProtocol, BProtocol, etc.)
│   │   │   └── ModulePublicProtocol+Second.h            # Additional protocol categories
│   │   │
│   │   ├── PublicProtocolSI(实际应用中,需要开发人员维护此repo)/
│   │   │   ├── ModulePublicProtocolSI.h/m               # Service interface implementations for protocols
│   │   │   └── ModulePublicProtocolSI+Second.h/m        # Additional service interface implementations
│   │   │
│   │   └── Controller+PublicProtocolSI/
│   │       └── UIViewController+ProtocolSI.h/m          # UIViewController category to attach protocol service interfaces
│   │
│   └── SupportFiles/
│       ├── Info.plist
│       ├── Main.storyboard
│       ├── LaunchScreen.storyboard
│       └── Assets.xcassets/
│
└── ProtocolRouter.xcodeproj/
```

## Architecture & Key Concepts

### Protocol-Based Routing Pattern

**Core Components:**

1. **Protocol Definition** (e.g., `AProtocol`)
   - Conforms to `MoudleBaseProtocol`
   - Declares module interface methods/properties
   - Named with PascalCase suffix (e.g., `AProtocol`)

2. **Service Interface Implementation** (e.g., `AProtocolSI`)
   - Implements the protocol
   - Suffix convention: `MoudleProtocol_ServerInterface` macro (default: `"SI"`)
   - Located in module-specific implementation class
   - Example: `AProtocol` → `AProtocolSI` class

3. **Router Singleton** (`Router.m`)
   - Runtime protocol-to-class resolution via ObjC runtime
   - Uses naming convention: `Protocol_Name + "SI"` to find implementation
   - Key methods:
     - `interfaceForProtocol:` — Returns instance for protocol
     - `interfaceForURL:` — Returns instance from URL with query param binding
     - `assertForMoudleWithProtocol:` / `assertForMoudleWithURL:` — Validates module exists (for testing)

4. **UIViewController Extension** (`UIViewController+ProtocolSI.h/m`)
   - Adds `protocolSI` property to UIViewController
   - Allows controllers to expose module services

### Design Pattern: Server Interface (SI)

Each module defines a service interface that conforms to its protocol:
- Module's protocol declares what it exposes (`serverController`, `callback`, custom properties)
- Module's SI class implements the protocol and handles logic
- Router dynamically instantiates SI on demand via `interfaceForProtocol:`

### Module Lifecycle & Decoupling

- Modules are completely decoupled; each module only knows about its own protocol
- No direct imports between modules (only through Router)
- Service discovery is dynamic: protocols resolved to implementations at runtime
- Naming convention ensures compile-free module integration

## Building & Running

### Build with Xcode
```bash
# Build the project
xcodebuild -project "ProtocolRouter Factory/ProtocolRouter.xcodeproj" -scheme ProtocolRouter -configuration Debug

# Build for Release
xcodebuild -project "ProtocolRouter Factory/ProtocolRouter.xcodeproj" -scheme ProtocolRouter -configuration Release

# Open in Xcode
open "ProtocolRouter Factory/ProtocolRouter.xcodeproj"
```

### Running on Simulator
```bash
# Run on default simulator
xcodebuild -project "ProtocolRouter Factory/ProtocolRouter.xcodeproj" -scheme ProtocolRouter -configuration Debug -derivedDataPath build/ -destination 'generic/platform=iOS Simulator' test
```

## Code Patterns & Conventions

### Adding a New Module

1. **Create Protocol** in `PublicProtocol/ModulePublicProtocol.h`:
   ```objc
   @protocol DProtocol <MoudleBaseProtocol>
   @required
   @property(nonatomic, copy) NSString *moduleName;
   - (void)performAction;
   @end
   ```

2. **Create Service Interface** in `PublicProtocolSI/ModulePublicProtocolSI.h/m`:
   ```objc
   @interface DProtocolSI : NSObject <DProtocol>
   @end

   @implementation DProtocolSI
   - (void)performAction { /* ... */ }
   @end
   ```

3. **Use via Router**:
   ```objc
   id<DProtocol> service = [[Router router] interfaceForProtocol:@protocol(DProtocol)];
   service.moduleName = @"Module D";
   [service performAction];
   ```

### Base Protocol Requirements (MoudleBaseProtocol)

All module protocols must conform to `MoudleBaseProtocol`:
- `@required`: `serverController` — weak UIViewController reference
- `@optional`: `callback` — completion block with params
- `@optional`: `param` — custom input parameter

## Runtime Behavior & Error Handling

- **Service Resolution**: Router uses ObjC runtime (`objc_getProtocol`, `NSClassFromString`) to find `ProtocolNameSI` classes
- **Missing Module Error**: If SI class not found, throws NSException with message indicating missing protocol implementation
- **URL-based Routing**: Can use URL scheme = protocol name with query params auto-bound to SI instance properties

## Testing Notes

- `assertForMoudleWithProtocol:` / `assertForMoudleWithURL:` methods exist for unit testing module availability
- Modules can be tested in isolation; router validation ensures compile-time mapping issues caught early

## Important Notes for Development

- **Naming Convention is Critical**: The `SI` suffix (or custom `MoudleProtocol_ServerInterface` value) is hardcoded in Router logic; deviation will cause runtime failures
- **Protocol Categories**: Use `ModulePublicProtocol+Second.h` and `ModulePublicProtocolSI+Second.h/m` for protocol extensions without modifying base files
- **No External Dependencies**: This is a zero-dependency framework; do not add CocoaPods or other package managers
- **Language**: User communicates in Chinese (中文); source code comments/documentation may be bilingual
