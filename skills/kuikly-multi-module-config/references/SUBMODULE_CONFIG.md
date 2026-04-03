# 子模块完整配置模板

## Contents

- build.gradle.kts 配置方法（基于主模块复制 + 修改差异）
- 需要修改的差异点清单
- iOS 说明（podspec 自动生成，Podfile 无需改动）
- AndroidManifest.xml
- 目录结构创建命令

## build.gradle.kts 配置方法

> **核心原则**：子模块的 `build.gradle.kts` 应该**直接复制主模块的 `build.gradle.kts`**，然后**仅修改以下差异点**。
> 这样可以确保子模块与主模块的 targets、plugins、cocoapods、依赖版本等架构配置完全一致。

### 操作步骤

1. **复制主模块的 `build.gradle.kts`** 到子模块目录下
2. **仅修改以下差异点**，其余配置保持不变

### 必须修改的差异点

#### 差异 1：ksp 块 — 修改多模块参数

找到 `ksp { ... }` 块，修改以下参数：

```kotlin
ksp {
    // 其余参数保持不变...
    arg("moduleId", "${MODULE_NAME}")     // ← 改为子模块自己的名称
    arg("isMainModule", "false")          // ← 关键：改为 false
    arg("enableMultiModule", "true")      // 保持不变
    // ★ 删除 subModules 参数（子模块不需要）
}
```

#### 差异 2：android.namespace — 修改包名

```kotlin
android {
    // 其余配置保持不变...
    namespace = "com.tencent.kuikly.${MODULE_NAME}"  // ← 改为子模块包名
}
```

#### 差异 3：commonMain dependencies — 移除子模块依赖

子模块的 `commonMain.dependencies` 中**不需要** `implementation(project(":其他子模块"))`，只保留 core、compose 等基础依赖。如果子模块有自己额外的依赖，在此添加。

```kotlin
val commonMain by sourceSets.getting {
    dependencies {
        // 保留基础依赖（与主模块一致）
        implementation(project(":core"))
        implementation(project(":compose"))
        implementation(project(":core-annotations"))
        // ★ 不要添加 implementation(project(":其他子模块"))
        // 可以添加子模块自身需要的额外依赖
    }
}
```

> ⚠️ **Kuikly 依赖版本必须与主模块一致**：子模块引用的 `core`、`compose`、`core-annotations`、`core-ksp` 等 Kuikly 相关依赖的版本号必须和主模块保持完全一致，否则可能导致编译错误或运行时异常。由于子模块是直接复制主模块的 `build.gradle.kts`，只要不手动修改版本号即可自动保持一致。

### 差异速查表

| 配置项 | 主模块 | 子模块（需要改的） |
|--------|--------|--------|
| `ksp.moduleId` | 主模块名（如 `"demo"`） | **改为**子模块名（如 `"feature_chat"`） |
| `ksp.isMainModule` | `"true"` | **改为** `"false"` |
| `ksp.subModules` | `"sub1&sub2"` | **删除此行** |
| `android.namespace` | 主模块包名 | **改为**子模块包名 |
| `commonMain.dependencies` | 包含 `implementation(project(":子模块"))` | **移除**对其他子模块的依赖 |
| 其余所有配置 | — | **建议保持一致**（与主模块一致） |

### 其余配置建议与主模块保持一致

以下配置直接从主模块复制，**建议和主模块保持一致**，避免因配置差异导致编译或运行时问题：

- `plugins { ... }` — 插件列表
- `kotlin { ... }` 中的 targets（androidTarget、iosX64、iosArm64 等）
- `cocoapods { ... }` — CocoaPods 配置（Gradle 会自动生成 podspec）
- `dependencies { ... }` 中的 ksp 平台配置
- 其余未在差异清单中列出的配置项

---

## iOS 说明

> **podspec 自动生成**：子模块的 `build.gradle.kts` 中配置了 `cocoapods` 插件后，Gradle 会自动生成对应的 `.podspec` 文件，**无需手动创建**。
>
> **Podfile 无需改动**：iOS 端的 Podfile **不需要**单独 pod 引入子模块。因为主模块通过 `implementation(project(":子模块"))` 依赖了子模块后，所有子模块的代码会和主模块一起统一编译生成一个 `shared.framework`，iOS 宿主工程只需引入主模块的 framework 即可。

---

## 目录结构创建

用以下命令快速创建子模块目录结构（将 `MODULE_NAME` 替换为实际名称）：

> ⚠️ **注意**：以下各种 `*Main` 目录（如 `androidMain`、`iosMain`、`jsMain`、`appleMain` 等）需要根据主模块实际的 `sourceSets` / `targets` 架构设置来决定创建哪些。先查看主模块 `src/` 下有哪些 `*Main` 目录，子模块就创建哪些。

```bash
MODULE_NAME=feature_chat

mkdir -p ${MODULE_NAME}/src/commonMain/kotlin/com/tencent/kuikly/${MODULE_NAME}/pages
mkdir -p ${MODULE_NAME}/src/commonMain/assets
# 以下 *Main 目录根据主模块的架构设置按需创建
mkdir -p ${MODULE_NAME}/src/androidMain/kotlin
mkdir -p ${MODULE_NAME}/src/iosMain/kotlin
mkdir -p ${MODULE_NAME}/src/jsMain/kotlin
mkdir -p ${MODULE_NAME}/src/appleMain/kotlin

# AndroidManifest.xml
cat > ${MODULE_NAME}/src/androidMain/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest package="com.tencent.kuikly.${MODULE_NAME}"/>
EOF
```

---

## 示例页面模板

在子模块的 `pages` 目录下创建一个示例页面，确保子模块至少有一个 `@Page` 页面可以验证配置是否正确。

文件路径：`${MODULE_NAME}/src/commonMain/kotlin/com/tencent/kuikly/${MODULE_NAME}/pages/SamplePage.kt`

将以下模板中的 `${MODULE_NAME}` 替换为实际子模块名，`${PAGE_NAME}` 替换为页面名称（默认使用 `${MODULE_NAME}_sample`）：

```kotlin
package com.tencent.kuikly.${MODULE_NAME}.pages

import com.tencent.kuikly.core.annotations.Page
import com.tencent.kuikly.core.base.Color
import com.tencent.kuikly.core.base.ComposeEvent
import com.tencent.kuikly.core.base.ViewBuilder
import com.tencent.kuikly.core.pager.Pager
import com.tencent.kuikly.core.views.Text

@Page("${PAGE_NAME}")
internal class SamplePage : Pager() {

    override fun body(): ViewBuilder {
        return {
            attr {
                backgroundColor(Color.WHITE)
                allCenter()
            }
            Text {
                attr {
                    fontSize(18f)
                    color(Color.BLACK)
                    text("Hello from ${MODULE_NAME}!")
                }
            }
        }
    }
}
```

> 💡 **说明**：示例页面直接继承 `Pager`，不依赖主模块的自定义基类，确保子模块独立性。可根据项目需要替换基类或扩展内容。
