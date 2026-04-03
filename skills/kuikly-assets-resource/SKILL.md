---
name: kuikly-assets-resource
description: Kuikly 资源文件管理与加载助手。指导如何在 Kuikly 中添加、打包和加载 assets 资源，包括目录结构规范（common/页面资源）、各平台打包配置（Android/iOS/鸿蒙/H5/微信小程序/动态化）、ImageUri API 使用。当用户需要在 Kuikly 中使用本地图片资源、配置 assets 打包时使用。
---

# Kuikly 资源文件管理与加载

## 资源目录结构

assets 资源存放在 `shared/src/commonMain/assets` 目录下，**一般将资源放在对应页面目录**下，多页面共享的资源放 `common/` 目录：

```
shared/src/commonMain/
├── assets/
│   ├── MyPage/            # MyPage 页面资源（推荐，资源跟随页面）
│   │   ├── banner.png
│   │   └── icon.png
│   ├── OtherPage/         # OtherPage 页面资源
│   │   └── bg.png
│   └── common/            # 公共资源（多页面共享时使用）
│       └── logo.png
└── kotlin/               # 业务代码
```

---

## ImageUri API

`ImageUri` 是 Kuikly 统一的资源 URI 封装类，用于在 `Image`、`PAG` 等组件中引用资源。

### 工厂方法

```kotlin
// 页面 assets 资源（当前页面目录，最常用）
ImageUri.pageAssets("banner.png")
// 生成: assets://#pageName#/banner.png（运行时替换为实际页面名）

// 页面 assets 子目录资源
ImageUri.pageAssets("icons/star.png")
// 生成: assets://#pageName#/icons/star.png

// 公共 assets 资源（common 目录，多页面共享）
ImageUri.commonAssets("logo.png")
// 生成: assets://common/logo.png

// 本地文件路径
ImageUri.file("/path/to/image.png")
// 生成: file:///path/to/image.png
```

### URI Scheme 常量

| Scheme | 值 | 说明 |
|--------|---|------|
| `SCHEME_COMMON_ASSETS` | `assets://common/` | 公共资源 |
| `SCHEME_PAGE_ASSETS` | `assets://#pageName#/` | 页面资源（运行时替换） |
| `SCHEME_FILE` | `file://` | 本地文件 |
| `SCHEME_BASE64` | `data:image` | Base64 图片 |

---

## Kuikly DSL 资源加载

### 加载 Assets 图片

```kotlin
// Image 组件引用 assets 资源
Image {
    attr {
        src(ImageUri.pageAssets("banner.png"))         // 页面资源（最常用）
    }
}
Image {
    attr {
        src(ImageUri.commonAssets("logo.png"))         // 公共资源
    }
}
        
```

---

## Compose DSL 资源加载

Compose DSL 通过 `DrawableResource` + `ImageUri` 加载本地 assets 资源，目录结构和打包配置与 Kuikly DSL 完全一致。

### 相关 import

```kotlin
import com.tencent.kuikly.compose.foundation.Image
import com.tencent.kuikly.compose.resources.painterResource
import com.tencent.kuikly.compose.resources.imageResource
import com.tencent.kuikly.compose.resources.DrawableResource
import com.tencent.kuikly.compose.resources.InternalResourceApi
```

### 加载 Assets 图片

```kotlin
// 1. 定义 DrawableResource（需要 @OptIn InternalResourceApi）
@OptIn(InternalResourceApi::class)
private val bannerRes by lazy(LazyThreadSafetyMode.NONE) {
    DrawableResource(ImageUri.pageAssets("banner.png").toUrl(""))
}

// 2. 使用 painterResource 加载（返回 Painter，用于 Image 组件）
@Composable
fun MyImage() {
    Image(
        painter = painterResource(bannerRes),
        contentDescription = null,
        modifier = Modifier.size(200.dp, 100.dp),
    )
}

// 3. 使用 imageResource 加载（返回 ImageBitmap，用于 Canvas 绘制）
@Composable
fun MyCanvas() {
    val bitmap = imageResource(bannerRes)
    Canvas(Modifier.size(100.dp)) {
        drawImage(bitmap)
    }
}
```

---

## 各平台打包配置

首次使用 assets 资源需要配置打包，详见 [PLATFORM_CONFIG.md](references/PLATFORM_CONFIG.md)

---