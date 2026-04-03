---
name: kuikly-multi-module-config
description: Kuikly 多模块工程配置助手。指导如何创建 Kuikly 子模块、配置多模块。当用户需要创建新 Kuikly 子模块、配置多模块参数、解决 KuiklyCoreEntry 入口类冲突时使用。
---

# Kuikly 多模块工程管理

## Contents

- When to use multi-module
- Interactive workflow
- Configuration overview
- Critical rules
- Detailed config references

## 何时需要多模块

子模块中有 Kuikly 页面（使用了 `@Page` 注解）才需要多模块设置。若子模块无页面则为普通 KMP 模块，无需特殊配置。

多模块解决的核心问题：多个独立 Kuikly 模块会导致 `KuiklyCoreEntry` 入口类冲突。

## 交互式工作流

当用户要求创建 Kuikly 子模块时，按以下步骤执行：

### Step 1: 收集信息（⚠️ 必须先完成，不可跳过）

> **🚨 强制规则：在执行任何配置操作之前，必须先向用户询问子模块名称。**
> 即使用户只说了"帮我建一个子模块"，也**必须先停下来询问子模块要叫什么名字**，拿到名称后才能继续。
> **绝对不要自行假设或编造子模块名称。**

向用户询问以下信息（如未提供）：

**🔴 必须询问（缺一不可，未获得答案前不得执行后续步骤）**：
1. **子模块名称** — 问用户："你的子模块要叫什么名字？"（英文，如 `kuikly_business`）
2. **主模块名称** — 可从 `settings.gradle.kts` 中确认，如果无法确定则询问用户（通常是 `demo` 或 `shared`）

确认名称后，展示以下 checklist：

```
Task Progress:
- [x] Step 1: 确认子模块名称 → ${用户提供的名称}
- [x] Step 2: 确认主模块名称 → ${确认的主模块名}
- [ ] Step 3: 创建子模块目录和 build.gradle.kts
- [ ] Step 4: 修改 settings.gradle.kts
- [ ] Step 5: 修改主模块 build.gradle.kts（依赖 + KSP 多模块参数）
- [ ] Step 6: 创建子模块 src 目录结构
- [ ] Step 7: 生成示例页面（@Page）
- [ ] Step 8: 检查是否有多套 Gradle 配置（如有则每套都需配置）
```

### Step 2: 执行配置

按顺序执行以下配置，每步完成后勾选 checklist：

#### 2.1 settings.gradle.kts

在根目录 `settings.gradle.kts` 中添加子模块 include：

```kotlin
include(":${子模块名}")
// 如果主模块有 buildFileName 配置，子模块也需要：
project(":${子模块名}").buildFileName = buildFileName
```

#### 2.2 主模块 build.gradle.kts

修改主模块，添加两处配置：

```kotlin
// 1. commonMain 依赖中添加子模块
kotlin {
    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation(project(":${子模块名}"))
            }
        }
    }
}

// 2. ksp 块中配置多模块参数
ksp {
    arg("moduleId", "${主模块名}")
    arg("isMainModule", "true")
    arg("subModules", "${子模块名}")      // 多个子模块用 & 分隔
    arg("enableMultiModule", "true")
}
```

> **已有 subModules 时**：在现有值后追加 `&${子模块名}`，如 `"sub1&sub2&${新子模块}"`

#### 2.3 子模块 build.gradle.kts

> **直接复制主模块的 `build.gradle.kts` 到子模块目录**，然后**仅修改以下差异点**，其余配置（plugins、targets、cocoapods 等）保持与主模块完全一致。

需要修改的差异点：

```kotlin
// 差异 1：ksp 块 — 修改多模块参数
ksp {
    // 其余参数保持不变...
    arg("moduleId", "${子模块名}")       // ← 改为子模块自己的名称
    arg("isMainModule", "false")         // ← 关键：改为 false
    arg("enableMultiModule", "true")
    // ★ 删除 subModules 参数（子模块不需要）
}

// 差异 2：android.namespace — 改为子模块包名
android {
    namespace = "com.tencent.kuikly.${子模块名}"
}

// 差异 3：commonMain dependencies — 移除对其他子模块的依赖（保留 core、compose 等基础依赖）
```

完整差异清单详见 [SUBMODULE_CONFIG.md](references/SUBMODULE_CONFIG.md)

#### 2.4 子模块目录结构

```
${子模块名}/
├── build.gradle.kts
├── src/
│   ├── commonMain/
│   │   ├── kotlin/com/tencent/kuikly/${子模块名}/
│   │   │   └── pages/          # 放 @Page 页面
│   │   └── assets/             # 资源文件（可选）
│   ├── androidMain/            # 以下 *Main 目录根据主模块架构按需创建
│   │   ├── AndroidManifest.xml
│   │   └── kotlin/
│   ├── iosMain/
│   │   └── kotlin/
│   └── jsMain/
│       └── kotlin/
```

#### 2.5 AndroidManifest.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest package="com.tencent.kuikly.${子模块名}"/>
```

#### 2.6 生成示例页面

在子模块的 `pages` 目录下创建一个示例页面文件，确保子模块至少有一个 `@Page` 页面可以验证配置是否正确。

示例页面模板详见 [SUBMODULE_CONFIG.md](references/SUBMODULE_CONFIG.md) 中的「示例页面模板」章节。

页面文件路径：`${子模块名}/src/commonMain/kotlin/com/tencent/kuikly/${子模块名}/pages/SamplePage.kt`

#### 2.7 检查多套 Gradle 配置（如有则每套都需配置）

有些项目会为不同平台维护多套 Gradle 配置文件（例如鸿蒙单独使用 `build.ohos.gradle.kts`、`settings.ohos.gradle.kts`），此时需要：

1. **检查项目根目录和主模块目录**，确认是否存在多个 `build.*.gradle.kts` 或 `settings.*.gradle.kts` 文件
2. **如果存在多套配置**，则上述 Step 3~5 的所有修改（子模块 `build.gradle.kts`、`settings.gradle.kts`、主模块 KSP 参数等）都需要在**每套配置中重复执行一遍**
3. 子模块也需要对应创建多份 `build.gradle.kts`（如 `build.ohos.gradle.kts`），内容同样基于对应的主模块配置文件复制后修改差异点

> 💡 **判断方法**：查看 `settings.gradle.kts` 中是否有 `buildFileName` 相关配置，或者主模块目录下是否有多个 `build.*.gradle.kts` 文件。

鸿蒙平台的具体适配细节详见 [MAIN_MODULE_CONFIG.md](references/MAIN_MODULE_CONFIG.md)

## 配置速查表

| 配置项 | 主模块 | 子模块 |
|--------|--------|--------|
| `moduleId` | 主模块名（如 `"shared"`） | 子模块名（如 `"feature_chat"`） |
| `isMainModule` | `"true"` | `"false"` |
| `subModules` | 所有子模块名，`&` 分隔 | **不需要** |
| `enableMultiModule` | `"true"` | `"true"` |
| commonMain 依赖 | `implementation(project(":子模块"))` | 不依赖主模块 |

## Critical rules

### ❌ 子模块不能单独编译

子模块依赖主模块的 `KuiklyCoreEntry` 生成，不能独立存在。必须通过主模块编译。

### ❌ moduleId 必须唯一

每个模块的 `moduleId` 必须不同，否则 KSP 生成的入口类会冲突。

### ❌ subModules 只在主模块配置

子模块的 ksp 块中**不要**配置 `subModules` 参数。

### ✅ iOS 端无需额外配置

子模块配置了 `cocoapods` 插件后，Gradle 会自动生成 podspec 文件，**无需手动创建**。同时，iOS Podfile 中**不需要**单独 pod 引入子模块，因为子模块会和主模块统一编译生成一个 framework（`shared.framework`）。

### ✅ 其余配置建议与主模块保持一致

子模块的 plugins、kotlin targets、cocoapods、android 块等其余配置**建议和主模块保持一致**，避免因配置差异导致编译或运行时问题。操作方式：直接复制主模块的 `build.gradle.kts`，然后仅修改差异清单中列出的项即可。

## Detailed guides

- **子模块完整配置模板**（build.gradle.kts + 目录结构）：[SUBMODULE_CONFIG.md](references/SUBMODULE_CONFIG.md)
- **主模块修改指南**（依赖、KSP适配）：[MAIN_MODULE_CONFIG.md](references/MAIN_MODULE_CONFIG.md)
