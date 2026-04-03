# 自定义 Module 各平台 Native 实现

以 `KRMyLogModule` 为例，展示各平台如何实现 Kuikly 侧定义的三个方法：`log`（异步无返回值）、`logWithCallback`（异步带回调）、`syncLog`（同步有返回值）。

## Contents
- [Android 侧](#android-侧)
- [iOS 侧](#ios-侧)
- [鸿蒙侧 (ArkTS)](#鸿蒙侧-arkts)
- [鸿蒙侧 (C)](#鸿蒙侧-c)
- [H5 侧](#h5-侧)
- [小程序侧](#小程序侧)

---

## Android 侧

### 1. 创建 Module 类

继承 `KuiklyRenderBaseModule`，重写 `call` 方法。根据参数类型选择重写：
- `call(method, params: String?, callback)` — 接收 JSON 字符串参数
- `call(method, params: Any?, callback)` — 接收基本类型/数组参数

```kotlin
import com.tencent.kuikly.core.render.android.export.KuiklyRenderBaseModule
import com.tencent.kuikly.core.render.android.export.KuiklyRenderCallback
import android.util.Log

class KRMyLogModule : KuiklyRenderBaseModule() {

    override fun call(method: String, params: String?, callback: KuiklyRenderCallback?): Any? {
        return when (method) {
            "log" -> log(params ?: "")
            "logWithCallback" -> logWithCallback(params ?: "", callback)
            "syncLog" -> syncLog(params ?: "")
            else -> super.call(method, params, callback)
        }
    }

    private fun log(content: String) {
        Log.d("MyLog", content)
    }

    private fun logWithCallback(content: String, callback: KuiklyRenderCallback?) {
        Log.d("MyLog", content)
        callback?.invoke(mapOf("result" to 1))
    }

    private fun syncLog(content: String): String {
        Log.d("MyLog", content)
        return "success"
    }
}
```

### 2. 注册 Module

在实现了 `KuiklyRenderViewDelegatorDelegate` 接口的类中注册：

```kotlin
override fun registerExternalModule(kuiklyRenderExport: IKuiklyRenderExport) {
    super.registerExternalModule(kuiklyRenderExport)
    with(kuiklyRenderExport) {
        moduleExport("KRMyLogModule") {
            KRMyLogModule()
        }
    }
}
```

> ⚠️ 注册名字必须与 Kuikly 侧 `moduleName()` 返回值一致。

### 线程说明

| 调用方式 | 执行线程 | 注意事项 |
|---------|---------|---------|
| `syncToNativeMethod` | Kuikly 线程 | 避免耗时操作，会阻塞渲染 |
| `asyncToNativeMethod` | 主线程(UI线程) | 避免耗时操作，会阻塞 UI |

---

## iOS 侧

### 1. 创建 Module 类

继承 `KRBaseModule`，**类名必须与 Kuikly 侧 `moduleName()` 返回值一致**（iOS 通过类名动态创建 Module）。

```objc
// KRMyLogModule.h
#import <Foundation/Foundation.h>
#import "KRBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface KRMyLogModule : KRBaseModule

@end

NS_ASSUME_NONNULL_END
```

### 2. 实现方法

方法名与 Kuikly 侧 `toNative` 的 `methodName` 一致，参数固定为 `NSDictionary`。

```objc
// KRMyLogModule.m
#import "KRMyLogModule.h"

@implementation KRMyLogModule

// 异步无返回值
- (void)log:(NSDictionary *)args {
    NSString *content = args[KR_PARAM_KEY];
    NSLog(@"log: %@", content);
}

// 异步带回调
- (void)logWithCallback:(NSDictionary *)args {
    NSString *content = args[KR_PARAM_KEY];
    NSLog(@"log: %@", content);

    KuiklyRenderCallback callback = args[KR_CALLBACK_KEY];
    callback(@{ @"result": @1 });
}

// 同步有返回值
- (id)syncLog:(NSDictionary *)args {
    NSString *content = args[KR_PARAM_KEY];
    NSLog(@"log: %@", content);
    return @"success";
}

@end
```

**关键常量：**
- `KR_PARAM_KEY` — 获取 Kuikly 侧传递的参数
- `KR_CALLBACK_KEY` — 获取 Kuikly 侧传递的回调闭包

> ⚠️ iOS 侧无需额外注册步骤，框架通过类名自动发现。
> ⚠️ 如果使用 Swift 实现，需要 `@objc` 或 `@objcMembers` 注解修饰类。

---

## 鸿蒙侧 (ArkTS)

### 1. 创建 Module 类

继承 `KuiklyRenderBaseModule`，实现 `syncMode()` 和 `call` 方法。

```ts
import { KRAny, KuiklyRenderBaseModule, KuiklyRenderCallback } from '@kuikly/render';

export class KRMyLogModule extends KuiklyRenderBaseModule {
    static readonly MODULE_NAME = "KRMyLogModule";

    // 同步模式：运行在 Kuikly 线程，支持同步和异步调用
    // 异步模式：运行在 UI 线程，只支持异步调用
    syncMode(): boolean {
        return true;
    }

    call(method: string, params: KRAny, callback: KuiklyRenderCallback | null): KRAny {
        switch (method) {
            case 'log':
                this.log(params as string);
                return null;
            case 'logWithCallback':
                this.logWithCallback(params as string, callback);
                return null;
            case 'syncLog':
                return this.syncLog(params as string);
        }
        return null;
    }

    private log(content: string) {
        console.log(`log: ${content}`);
    }

    private logWithCallback(content: string, callback: KuiklyRenderCallback | null) {
        console.log(`log: ${content}`);
        callback?.({ "result": 1 });
    }

    private syncLog(content: string): string {
        console.log(`log: ${content}`);
        return "success";
    }
}
```

### 2. 注册 Module

在实现了 `IKuiklyViewDelegate` 接口的类中注册：

```ts
export class KuiklyViewDelegate extends IKuiklyViewDelegate {
    getCustomRenderModuleCreatorRegisterMap(): Map<string, KRRenderModuleExportCreator> {
        const map: Map<string, KRRenderModuleExportCreator> = new Map();
        map.set(KRMyLogModule.MODULE_NAME, () => new KRMyLogModule());
        return map;
    }
}
```

### syncMode 说明

| syncMode() | 执行线程 | 支持的调用方式 |
|------------|---------|-------------|
| `true` | Kuikly 线程 | 同步调用 + 异步调用 |
| `false` | UI 线程 | 仅异步调用 |

---

## 鸿蒙侧 (C)

适用于需要在 C 层实现高性能 Module 的场景。

### 1. 实现 Module

```c
static void* MyModuleOnConstruct(const char *moduleName) {
    return nullptr;
}

static void MyModuleOnDestruct(const void* moduleInstance) {
    // 清理资源
}

static KRAnyData MyModuleOnCallMethod(
    const void* moduleInstance,
    const char* moduleName,
    int sync,
    const char *method,
    KRAnyData param,
    KRRenderModuleCallbackContext context) {

    if (context) {
        // 异步回调示例
        char* result = "{\"key\":\"value\"}";
        KRRenderModuleDoCallback(context, result);
    }

    std::string resultString(method ? method : "");
    resultString.append(" handled.");
    return KRAnyDataCreateString(resultString.c_str());
}
```

### 2. 注册 Module

推荐在 `InitKuikly` 过程中注册：

```c
KRRenderModuleRegisterV2("KRMyLogModule",
    &MyModuleOnConstruct,
    &MyModuleOnDestruct,
    &MyModuleOnCallMethod,
    nullptr);
```

> ⚠️ 返回值 `KRAnyData` 由框架释放，不需要额外调用 `KRAnyDataDestroy`。
> ⚠️ ArkTS Module 和 C Module 同时存在时，优先调用 C Module。

---

## H5 侧

### 1. 创建 Module 类

继承 `KuiklyRenderBaseModule`，实现方式与 Android 侧一致：

```kotlin
import com.tencent.kuikly.core.render.web.export.KuiklyRenderBaseModule
import com.tencent.kuikly.core.render.web.ktx.KuiklyRenderCallback

class KRMyLogModule : KuiklyRenderBaseModule() {

    override fun call(method: String, params: String?, callback: KuiklyRenderCallback?): Any? {
        return when (method) {
            "log" -> log(params ?: "")
            "logWithCallback" -> logWithCallback(params ?: "", callback)
            "syncLog" -> syncLog(params ?: "")
            else -> null
        }
    }

    private fun log(content: String) {
        console.log("log: $content")
    }

    private fun logWithCallback(content: String, callback: KuiklyRenderCallback?) {
        console.log("log: $content")
        callback?.invoke(mapOf(
            "result" to "1",
            "locationHref" to window.location.href  // 可使用 H5 宿主 API
        ))
    }

    private fun syncLog(content: String): String {
        console.log("log: $content")
        return "success"
    }

    companion object {
        const val MODULE_NAME = "KRMyLogModule"
    }
}
```

### 2. 注册 Module

```kotlin
override fun registerExternalModule(kuiklyRenderExport: IKuiklyRenderExport) {
    super.registerExternalModule(kuiklyRenderExport)
    with(kuiklyRenderExport) {
        moduleExport("KRMyLogModule") {
            KRMyLogModule()
        }
    }
}
```

---

## 小程序侧

### 1. 创建 Module 类

与 H5 侧类似，但可通过 `NativeApi.plat` 访问微信 `wx` 对象：

```kotlin
import com.tencent.kuikly.core.render.web.export.KuiklyRenderBaseModule
import com.tencent.kuikly.core.render.web.ktx.KuiklyRenderCallback

class KRMyLogModule : KuiklyRenderBaseModule() {

    override fun call(method: String, params: String?, callback: KuiklyRenderCallback?): Any? {
        return when (method) {
            "log" -> log(params ?: "")
            "logWithCallback" -> logWithCallback(params ?: "", callback)
            "syncLog" -> syncLog(params ?: "")
            else -> null
        }
    }

    private fun log(content: String) {
        console.log("log: $content")
    }

    private fun logWithCallback(content: String, callback: KuiklyRenderCallback?) {
        console.log("log: $content")
        callback?.invoke(mapOf(
            "result" to "1",
            "platform" to NativeApi.plat.getSystemInfoSync().platform  // 访问 wx 对象
        ))
    }

    private fun syncLog(content: String): String {
        console.log("log: $content")
        return "success"
    }

    companion object {
        const val MODULE_NAME = "KRMyLogModule"
    }
}
```

### 2. 注册方式

同 H5 侧，在 `registerExternalModule` 中注册。

### 小程序特有 API

- `NativeApi.plat` — 全局 `wx` 对象（如 `NativeApi.plat.showToast`）
- `NativeApi.globalThis` — 微信小程序全局 `global` 对象
