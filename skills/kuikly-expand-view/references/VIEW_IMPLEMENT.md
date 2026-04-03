# 自定义 View 各平台 Native 实现

以 `HRImageView` 为例，展示各平台如何实现 Kuikly 侧定义的自定义图片组件。

## Contents
- [Android 侧](#android-侧)
- [iOS 侧](#ios-侧)
- [鸿蒙侧 (ArkTS)](#鸿蒙侧-arkts)
- [H5 侧](#h5-侧)
- [小程序侧](#小程序侧)

---

## Android 侧

### 1. 创建 View 类

继承原生 View 并实现 `IKuiklyRenderViewExport` 接口：

```kotlin
import android.content.Context
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.widget.ImageView
import com.squareup.picasso.Picasso
import com.squareup.picasso.Target
import com.tencent.kuikly.core.render.android.export.IKuiklyRenderViewExport
import com.tencent.kuikly.core.render.android.export.KuiklyRenderCallback

open class HRImageView(context: Context) : ImageView(context), IKuiklyRenderViewExport {

    private var src = ""
    private var loadSuccessCallback: KuiklyRenderCallback? = null

    override fun setProp(propKey: String, propValue: Any): Boolean {
        return when (propKey) {
            "src" -> {
                setSrc(propValue as String)
                true
            }
            "loadSuccess" -> {
                loadSuccessCallback = propValue as KuiklyRenderCallback
                true
            }
            else -> super.setProp(propKey, propValue)
        }
    }
    
    override fun call(method: String, params: String?, callback: KuiklyRenderCallback?): Any? {
        return when(method) {
            "reload" -> {
                reload()
                null
            }
            "getImageInfo" -> {
                callback?.invoke(mapOf(
                    "width" to drawable?.intrinsicWidth,
                    "height" to drawable?.intrinsicHeight
                ))
                null
            }
            else -> super.call(method, params, callback)
        }
    }

    private fun setSrc(url: String) {
        if (src == url) return
        src = url
        setImageDrawable(null)
        
        val target = object : Target {
            override fun onBitmapLoaded(bitmap: Bitmap, from: Picasso.LoadedFrom) {
                setImageDrawable(BitmapDrawable(resources, bitmap))
                fireLoadSuccess(bitmap.width, bitmap.height)
            }
            override fun onBitmapFailed(e: Exception?, errorDrawable: Drawable?) {
                setImageDrawable(null)
            }
            override fun onPrepareLoad(placeHolderDrawable: Drawable?) {}
        }
        Picasso.get().load(src).into(target)
    }
    
    private fun fireLoadSuccess(width: Int, height: Int) {
        loadSuccessCallback?.invoke(mapOf(
            "src" to src,
            "width" to width,
            "height" to height
        ))
    }
    
    private fun reload() {
        val currentSrc = src
        src = ""
        setSrc(currentSrc)
    }
}
```

### 2. 注册 View

在实现了 `KuiklyRenderViewDelegatorDelegate` 接口的类中注册：

```kotlin
override fun registerExternalRenderView(kuiklyRenderExport: IKuiklyRenderExport) {
    super.registerExternalRenderView(kuiklyRenderExport)
    with(kuiklyRenderExport) {
        renderViewExport("HRImageView", { context ->
            HRImageView(context)
        })
    }
}
```

> ⚠️ **Android 注册注意事项：**
> - 注册名字必须与 Kuikly 侧 `viewName()` 返回值一致
> - `renderViewExport` 有可选的第三个参数 `shadowExportCreator`，**不要使用尾随 lambda 语法**，必须将 creator 作为参数传入：`renderViewExport(name, { context -> View(context) })`

---

## iOS 侧

### 1. 创建 View 类

继承原生 View 并实现 `KuiklyRenderViewExportProtocol` 协议。**类名必须与 Kuikly 侧 viewName 一致**。

```objc
// HRImageView.h
#import <UIKit/UIKit.h>
#import "KuiklyRenderViewExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface HRImageView : UIImageView<KuiklyRenderViewExportProtocol>

@end

NS_ASSUME_NONNULL_END
```

### 2. 实现属性和事件

```objc
// HRImageView.m
#import "HRImageView.h"
#import "KRComponentDefine.h"

@interface HRImageView()

@property (nonatomic, copy) NSString *css_src;
@property (nonatomic, strong, nullable) KuiklyRenderCallback css_loadSuccess;

@end

@implementation HRImageView

@synthesize hr_rootView;

#pragma mark - KuiklyRenderViewExportProtocol

- (void)hrv_setPropWithKey:(NSString *)propKey propValue:(id)propValue {
    // 宏会自动调用 setCss_xxx 方法
    KUIKLY_SET_CSS_COMMON_PROP;
}

// 属性方法命名规则：setCss_属性名
- (void)setCss_src:(NSString *)src {
    if ([_css_src isEqualToString:src]) return;
    _css_src = src;
    
    // 加载图片
    [self loadImageFromURL:src];
}

// 事件属性
- (void)setCss_loadSuccess:(KuiklyRenderCallback)callback {
    _css_loadSuccess = callback;
}

- (void)loadImageFromURL:(NSString *)url {
    // 使用 SDWebImage 等库加载图片
    __weak typeof(self) weakSelf = self;
    [self sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image && weakSelf.css_loadSuccess) {
            weakSelf.css_loadSuccess(@{
                @"src": url ?: @"",
                @"width": @(image.size.width),
                @"height": @(image.size.height)
            });
        }
    }];
}

@end
```

### 3. 实现方法调用

```objc
// HRImageView.m (续)

- (NSString * _Nullable)hrv_callWithMethod:(NSString *)method params:(NSString *)params callback:(KuiklyRenderCallback)callback {
    // 宏会自动调用 css_xxx 方法
    KUIKLY_CALL_CSS_METHOD;
    return nil;
}

// 方法命名规则：css_方法名
- (void)css_reload {
    NSString *currentSrc = self.css_src;
    self.css_src = nil;
    [self setCss_src:currentSrc];
}

- (void)css_getImageInfo:(KuiklyRenderCallback)callback {
    if (callback && self.image) {
        callback(@{
            @"width": @(self.image.size.width),
            @"height": @(self.image.size.height)
        });
    }
}

@end
```

> ⚠️ **iOS 注意事项：**
> - **类名必须与 `viewName()` 一致**，iOS 通过类名运行时动态创建组件
> - 使用 Swift 实现时需要 `@objc` 或 `@objcMembers` 修饰类
> - 属性方法命名：`setCss_属性名`
> - 方法命名：`css_方法名`
> - iOS 侧无需额外注册步骤，框架通过类名自动发现

---

## 鸿蒙侧 (ArkTS)

### 1. 创建 View 类

继承 `KuiklyRenderBaseView` 类：

```ts
// KRMyDemoCustomView.ets
import { KRAny, KuiklyRenderBaseView, KuiklyRenderCallback } from '@kuikly/render';
import { ComponentContent, NodeContent } from '@kit.ArkUI';

const kMessage = 'message';

@Observed
export class KRMyDemoCustomView extends KuiklyRenderBaseView {
    static readonly VIEW_NAME = 'KRMyDemoCustomView';
    
    // 属性
    cssMessage: string | null = null;
    
    // 事件回调
    onMyViewTapped: KuiklyRenderCallback | null = null;
    
    // 子内容槽（可选，支持嵌套子组件时需要）
    slot: NodeContent | null = new NodeContent();

    // 创建 ArkUI 视图（必须实现）
    createArkUIView(): ComponentContent<KuiklyRenderBaseView> {
        const uiContext = this.getUIContext() as UIContext;
        return new ComponentContent<KuiklyRenderBaseView>(
            uiContext, 
            wrapBuilder<[KuiklyRenderBaseView]>(createMyView), 
            this
        );
    }
    
    // 获取子内容槽（支持嵌套时需要）
    getContentSlot(): NodeContent | null {
        return this.slot;
    }

    // 设置属性和事件
    setProp(propKey: string, propValue: KRAny | KuiklyRenderCallback): boolean {
        switch (propKey) {
            case kMessage:
                this.cssMessage = propValue as string;
                return true;
            case "onMyViewTapped":
                this.onMyViewTapped = propValue as KuiklyRenderCallback;
                return true;
            default:
                return super.setProp(propKey, propValue);
        }
    }

    // 方法调用
    call(method: string, params: KRAny, callback: KuiklyRenderCallback | null): void {
        switch (method) {
            case 'reload':
                this.reload();
                break;
            case 'getInfo':
                callback?.({ "message": this.cssMessage });
                break;
        }
    }
    
    private reload(): void {
        // 重新加载逻辑
    }
}
```

### 2. 创建 ArkUI 组件

```ts
// KRMyDemoCustomView.ets (续)

@Component
export struct KRMyDemoCustomViewComponent {
    @ObjectLink renderView: KRMyDemoCustomView;

    build() {
        Stack() {
            Column() {
                Text(this.renderView.cssMessage)
                    .fontSize(48)
                    .width('100%')
                    .height('50%')
                    .textAlign(TextAlign.Center)

                Button("Tap Me")
                    .onClick(() => {
                        // 触发事件回调
                        this.renderView.onMyViewTapped?.("{}");
                    })
                    .width('100%')
                    .height('50%')
            }
            .justifyContent(FlexAlign.Center)

            // 子内容槽（支持嵌套子组件）
            ContentSlot(this.renderView.slot)
        }
        .alignContent(Alignment.TopStart)
        .backgroundColor(this.renderView.cssBackgroundColor)
        .size({ width: '100%', height: '100%' })
    }
}

@Builder
function createMyView(view: KuiklyRenderBaseView) {
    KRMyDemoCustomViewComponent({ renderView: view as KRMyDemoCustomView });
}
```

### 3. 注册 View

在 `IKuiklyViewDelegate` 实现类中注册：

```ts
// KuiklyViewDelegate.ets
import { IKuiklyViewDelegate, KRRenderViewExportCreator } from '@kuikly/render';
import { KRMyDemoCustomView } from './components/KRMyDemoCustomView';

export class KuiklyViewDelegate extends IKuiklyViewDelegate {
    // 方式一：getCustomRenderViewCreatorRegisterMap (C层渲染)
    getCustomRenderViewCreatorRegisterMap(): Map<string, KRRenderViewExportCreator> {
        const map: Map<string, KRRenderViewExportCreator> = new Map();
        // map.set(KRMyView.VIEW_NAME, () => new KRMyView());
        return map;
    }

    // 方式二：getCustomRenderViewCreatorRegisterMapV2 (ArkTS层渲染)
    getCustomRenderViewCreatorRegisterMapV2(): Map<string, KRRenderViewExportCreator> {
        const map: Map<string, KRRenderViewExportCreator> = new Map();
        map.set(KRMyDemoCustomView.VIEW_NAME, () => new KRMyDemoCustomView());
        return map;
    }
}
```

> ⚠️ **鸿蒙侧注意事项：**
> - `VIEW_NAME` 必须与 Kuikly 侧 `viewName()` 返回值一致
> - 必须实现 `createArkUIView()` 方法返回 `ComponentContent`
> - 使用 `@Observed` 装饰器支持响应式更新
> - 支持嵌套子组件时需要实现 `getContentSlot()` 并在 UI 中使用 `ContentSlot`

---

## H5 侧

### 1. 创建 View 类

实现 `IKuiklyRenderViewExport` 接口：

```kotlin
import com.tencent.kuikly.core.render.web.export.IKuiklyRenderViewExport
import com.tencent.kuikly.core.render.web.ktx.KuiklyRenderCallback
import kotlinx.browser.document
import org.w3c.dom.Element
import org.w3c.dom.HTMLImageElement

class HRImageView : IKuiklyRenderViewExport {
    private val img = document.createElement("img")
    private var loadSuccessCallback: KuiklyRenderCallback? = null
    private var hasAddLoadListener = false

    override val ele: HTMLImageElement
        get() = img.unsafeCast<HTMLImageElement>()

    override fun setProp(propKey: String, propValue: Any): Boolean {
        return when (propKey) {
            "src" -> {
                ele.src = propValue as String
                true
            }
            "loadSuccess" -> {
                loadSuccessCallback = propValue as KuiklyRenderCallback
                if (!hasAddLoadListener) {
                    hasAddLoadListener = true
                    ele.addEventListener("load", {
                        loadSuccessCallback?.invoke(
                            mapOf(
                                "src" to ele.src,
                                "width" to ele.naturalWidth,
                                "height" to ele.naturalHeight
                            )
                        )
                    })
                }
                true
            }
            else -> super.setProp(propKey, propValue)
        }
    }

    override fun call(method: String, params: String?, callback: KuiklyRenderCallback?): Any? {
        return when (method) {
            "reload" -> {
                val currentSrc = ele.src
                ele.src = ""
                ele.src = currentSrc
                null
            }
            "getImageInfo" -> {
                callback?.invoke(mapOf(
                    "width" to ele.naturalWidth,
                    "height" to ele.naturalHeight
                ))
                null
            }
            else -> super.call(method, params, callback)
        }
    }
}
```

### 2. 注册 View

```kotlin
override fun registerExternalRenderView(kuiklyRenderExport: IKuiklyRenderExport) {
    super.registerExternalRenderView(kuiklyRenderExport)
    with(kuiklyRenderExport) {
        renderViewExport("HRImageView", {
            HRImageView()
        })
    }
}
```

> ⚠️ **H5 侧注意事项：**
> - `ele` 属性返回实际参与 DOM 布局的元素
> - 要扩展其他组件，只需把 `document.createElement("img")` 换成其他 HTML 标签

---

## 小程序侧

### 1. 创建 View 类

与 H5 类似，但使用 `MiniXxxElement`：

```kotlin
class KRWebView : IKuiklyRenderViewExport {
    private val webElement = MiniWebViewElement()
    
    override val ele: Element
        get() = webElement.unsafeCast<Element>()
        
    override fun setProp(propKey: String, propValue: Any): Boolean {
        return when (propKey) {
            "src" -> {
                webElement.src = propValue as String
                true
            }
            else -> super.setProp(propKey, propValue)
        }
    }

    companion object {
        const val VIEW_NAME = "KRWebView"
    }
}
```

### 2. 实现 MiniElement（新组件才需要）

如果使用的小程序组件不是内置的，需要创建对应的 `MiniXxxElement`：

```kotlin
class MiniWebViewElement(
    nodeName: String = NODE_NAME,
    nodeType: Int = MiniElementUtil.ELEMENT_NODE
) : MiniElement(nodeName, nodeType) {
    var src: String = ""
        set(value) {
            setAttribute("src", value)
        }

    companion object {
        const val NODE_NAME = "web-view"
        // 模板配置：_num 对应模板名 tmpl_0_74，src 对应属性 p0
        val componentsAlias = js("{_num: '74', src: 'p0'}")
    }
}
```

### 3. 注册 View

```kotlin
override fun registerExternalRenderView(kuiklyRenderExport: IKuiklyRenderExport) {
    super.registerExternalRenderView(kuiklyRenderExport)

    // 添加组件模板信息（新组件才需要）
    Transform.addComponentsAlias(
        MiniWebViewElement.NODE_NAME,
        MiniWebViewElement.componentsAlias
    )

    // 注册 View
    kuiklyRenderExport.renderViewExport(KRWebView.VIEW_NAME, {
        KRWebView()
    })
}
```

### 4. 补充小程序模板（新组件才需要）

在小程序壳工程的 `base.wxml` 中添加模板：

```xml
<template name="tmpl_0_74">
  <web-view src="{{i.p0}}" bindmessage="eh" bindload="eh" binderror="eh" bindtap="eh" id="{{i.uid||i.sid}}">
  </web-view>
</template>
```

> ⚠️ **小程序侧注意事项：**
> - `_num` 配置值（如 74）对应模板名 `tmpl_0_74`
> - 属性别名（如 `src: 'p0'`）对应模板中的 `{{i.p0}}`
> - 可通过 `NativeApi.plat` 访问微信 `wx` 对象
