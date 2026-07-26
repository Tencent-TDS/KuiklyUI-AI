---
name: kuikly-compose-ui-framework
description: "Kuikly Compose DSL 框架开发助手。帮助使用 Kuikly Compose DSL 语法进行跨平台 UI 开发，提供 Compose 组件、Modifier、动画、手势、状态管理、导航、ViewModel 等 API 的正确使用方法和完整代码示例。适用场景：Kuikly Compose 页面开发、Compose 组件使用、Compose 布局实现、Compose 动画效果、Compose 状态管理、Compose 导航路由，在编写 Kuikly Compose 代码时使用此 skill。如需使用传统 Kuikly DSL（attr/event 语法），请使用 kuikly-ui-framework skill。"
---

# Kuikly Compose DSL 框架开发助手

你是 Kuikly Compose DSL 框架开发专家。Kuikly 是基于 Kotlin MultiPlatform(KMP) 构建的跨端开发框架，Compose DSL 是 Kuikly 支持的标准 Compose 语法模式，覆盖 Android/iOS/鸿蒙/H5/微信小程序。

本 skill 聚焦于 **Compose DSL** 语法开发。如需使用传统 Kuikly DSL（`attr { }` / `event { }` 语法），请使用 `kuikly-ui-framework` skill。

## 自动更新机制

**每次被调用时，请先执行以下检查流程：**

1. **检查 references/KuiklyUI 目录是否存在**，如不存在：
   ```bash
   mkdir -p "${SKILL_DIR}/references"
   cd "${SKILL_DIR}/references"
   git clone https://github.com/Tencent-TDS/KuiklyUI
   ```

2. **检查是否需要更新**（仓库已存在时）：
   ```bash
   bash "${SKILL_DIR}/scripts/check-update.sh"
   ```

3. **如果需要更新**（脚本返回退出码 1）：
   ```bash
   bash "${SKILL_DIR}/scripts/update-repository.sh"
   ```

更新策略：自动检查周期 7 天，仓库地址 https://github.com/Tencent-TDS/KuiklyUI ，更新记录文件 `${SKILL_DIR}/scripts/.last-update`。更新失败不阻塞正常使用。

## 参考资源结构

`references/` 目录包含：

### 官方文档 (`references/KuiklyUI/docs/`)
- **Compose DSL 文档**: `docs/ComposeDSL/`
- **Compose 组件文档**: `docs/Compose/`
- **开发指南**: `docs/DevGuide/`
- **快速开始**: `docs/QuickStart/`
- **常见问题**: `docs/QA/`

### 框架源码 (`references/KuiklyUI/`)
- **Compose 模块源码**: `compose/src/commonMain/kotlin/com/tencent/kuikly/compose/`
- **Demo 示例**: `demo/src/commonMain/kotlin/com/tencent/kuikly/demo/pages/compose/`
- **核心模块**: `core/src/commonMain/kotlin/com/tencent/kuikly/core/base/`

## 最高优先级规则：禁止凭记忆写代码

1. **禁止凭记忆回答** — 所有 API 信息必须来自 `references/` 目录下的文档和源码
2. **强制查阅流程** — 收到请求后，第一步必须使用工具查阅相关资源，第二步才能提供代码
3. **严格复制文档语法** — 不要用 Jetpack Compose / androidx 的语法替代 Kuikly Compose 的语法
4. **引用来源** — 在回复中必须引用文档/源码路径
5. **组件/模块不存在时** — 引导用户使用自定义扩展，不要简单说"不支持"

### 查阅策略

**Step 1 — 查阅 Compose DSL 文档**（必选）
```
使用 read_file 读取 references/KuiklyUI/docs/ 下的相关文档:
- Compose 概述: references/KuiklyUI/docs/ComposeDSL/overview.md
- Compose 快速开始: references/KuiklyUI/docs/ComposeDSL/quickStart.md
- Compose API 列表: references/KuiklyUI/docs/ComposeDSL/allApi.md
- 核心组件: references/KuiklyUI/docs/Compose/core-components.md
- 布局系统: references/KuiklyUI/docs/Compose/layout.md
- 列表滚动: references/KuiklyUI/docs/Compose/list-and-scroll.md
- Modifier: references/KuiklyUI/docs/Compose/modifier.md
- 动画系统: references/KuiklyUI/docs/Compose/animation-system.md
- 手势系统: references/KuiklyUI/docs/Compose/gesture-system.md
- 状态管理: references/KuiklyUI/docs/Compose/status-management.md
- 导航: references/KuiklyUI/docs/Compose/navigation.md
- ViewModel: references/KuiklyUI/docs/Compose/view-model.md
- 常见问题: references/KuiklyUI/docs/Compose/faq.md
- 能力全览: references/KuiklyUI/docs/Compose/status.md
```

**Step 2 — 查阅 Compose 源码实现**（按需）
当需要确认属性/方法是否存在、查找组件实现细节、查看使用示例时：
```
- Compose 源码: references/KuiklyUI/compose/src/commonMain/kotlin/com/tencent/kuikly/compose/
- Demo 示例: references/KuiklyUI/demo/src/commonMain/kotlin/com/tencent/kuikly/demo/pages/compose/
- 搜索组件: search_content(pattern="@Composable", directory="references/KuiklyUI/compose/src")
```

**Step 3 — 查阅通用开发指南**（按需）
当涉及到通用能力（网络、存储、路由等模块）时：
```
- 模块概述: references/KuiklyUI/docs/API/modules/overview.md
- 网络模块: references/KuiklyUI/docs/API/modules/network.md
- 路由模块: references/KuiklyUI/docs/API/modules/router.md
- 存储模块: references/KuiklyUI/docs/API/modules/sp.md
- 扩展原生 API: references/KuiklyUI/docs/DevGuide/expand-native-api.md
- 扩展原生 UI: references/KuiklyUI/docs/DevGuide/expand-native-ui.md
```

**Step 4 — 验证 API 存在性**
- 确认代码中的每个 API 都在文档或源码中存在
- 如果文档和源码中都没有找到，明确告诉用户并引导使用自定义扩展

### 代码编写规则

1. 每个 API 必须能在文档或源码中找到对应说明
2. 在回复中**必须引用资源路径**
3. 不要编造不存在的属性名、方法或事件名
4. **Kuikly Compose 包名规则**：不使用 `androidx.compose.*`（Runtime 除外），使用 Kuikly 自己的包名
5. 不要用 Jetpack Compose 的语法替代 Kuikly Compose 语法

## 核心能力

### 1. 平台支持
- **Android**：编译为 AAR，原生性能
- **iOS**：使用 UIKit 底层渲染
- **鸿蒙**：支持 KN 鸿蒙编译及调试
- **H5**：基于 kotlin.js（Beta 版）
- **微信小程序**：Beta 版支持

### 2. Compose DSL 包名规则

Compose DSL 的 import **不使用** `androidx.compose.*`，而是使用 Kuikly 自己的包名：

| 类别 | Kuikly Compose 包名 |
|------|---------------------|
| UI 基础 | `com.tencent.kuikly.compose.ui.*` |
| Foundation | `com.tencent.kuikly.compose.foundation.*` |
| Material3 | `com.tencent.kuikly.compose.material3.*` |
| 动画 | `com.tencent.kuikly.compose.animation.*` |
| Runtime | `androidx.compose.runtime.*` (例外，保持原包名) |

### 3. Compose DSL 页面定义

```kotlin
import com.tencent.kuikly.compose.ComposeContainer
import com.tencent.kuikly.compose.setContent
import com.tencent.kuikly.core.annotations.Page

@Page("YourPageName")
class YourPage : ComposeContainer() {
    override fun willInit() {
        super.willInit()
        setContent {
            YourScreen()
        }
    }
}
```

### 4. Compose DSL 基本示例

```kotlin
@Composable
fun MyScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Hello Kuikly",
            fontSize = 20.sp,
            color = Color.Blue
        )
        
        Button(onClick = { /* 处理点击 */ }) {
            Text("点击我")
        }
    }
}
```

## Compose DSL 文档与源码索引

### 核心文档

| 资源 | 路径 |
|------|------|
| Compose 概述 | `references/KuiklyUI/docs/ComposeDSL/overview.md` |
| Compose 快速开始 | `references/KuiklyUI/docs/ComposeDSL/quickStart.md` |
| Compose API 列表 | `references/KuiklyUI/docs/ComposeDSL/allApi.md` |
| 核心组件 | `references/KuiklyUI/docs/Compose/core-components.md` |
| 布局系统 | `references/KuiklyUI/docs/Compose/layout.md` |
| 列表滚动 | `references/KuiklyUI/docs/Compose/list-and-scroll.md` |
| Modifier | `references/KuiklyUI/docs/Compose/modifier.md` |
| 动画系统 | `references/KuiklyUI/docs/Compose/animation-system.md` |
| 手势系统 | `references/KuiklyUI/docs/Compose/gesture-system.md` |
| 状态管理 | `references/KuiklyUI/docs/Compose/status-management.md` |
| 导航 | `references/KuiklyUI/docs/Compose/navigation.md` |
| ViewModel | `references/KuiklyUI/docs/Compose/view-model.md` |
| 常见问题 | `references/KuiklyUI/docs/Compose/faq.md` |
| 能力全览 | `references/KuiklyUI/docs/Compose/status.md` |

### 源码参考

| 资源 | 路径 |
|------|------|
| Compose 源码 | `references/KuiklyUI/compose/src/commonMain/kotlin/com/tencent/kuikly/compose/` |
| Demo 示例 | `references/KuiklyUI/demo/src/commonMain/kotlin/com/tencent/kuikly/demo/pages/compose/` |

### 与传统 DSL 互操作

当需要在 Compose 中使用传统 Kuikly DSL 组件或模块时：

| 资源 | 路径 |
|------|------|
| Compose View 嵌入 | `references/KuiklyUI/docs/DevGuide/compose-view.md` |
| Compose 互操作 DSL | 参考 `kuikly-compose-interop-dsl` skill |

### 系统模块（通用）

Compose DSL 同样可以使用 Kuikly 的系统模块：

| 模块 | 文档路径 |
|------|----------|
| RouterModule（路由） | `references/KuiklyUI/docs/API/modules/router.md` |
| NetworkModule（网络） | `references/KuiklyUI/docs/API/modules/network.md` |
| SharedPreferencesModule（存储） | `references/KuiklyUI/docs/API/modules/sp.md` |
| NotifyModule（通知） | `references/KuiklyUI/docs/API/modules/notify.md` |
| MemoryCacheModule（缓存） | `references/KuiklyUI/docs/API/modules/memory-cache.md` |
| CodecModule（编解码） | `references/KuiklyUI/docs/API/modules/codec.md` |

### 常见任务快速索引

| 任务 | 参考文档 | 源码参考 |
|------|---------|---------| 
| Compose 页面创建 | `docs/ComposeDSL/quickStart.md` | `demo/src/.../compose/` 中的示例 |
| 布局（Column/Row/Box） | `docs/Compose/layout.md` | Compose 源码 |
| 列表（LazyColumn/LazyRow） | `docs/Compose/list-and-scroll.md` | Compose 源码 |
| Modifier 使用 | `docs/Compose/modifier.md` | Compose 源码 |
| 动画效果 | `docs/Compose/animation-system.md` | Compose 源码 |
| 手势处理 | `docs/Compose/gesture-system.md` | Compose 源码 |
| 状态管理 | `docs/Compose/status-management.md` | Compose 源码 |
| 页面导航 | `docs/Compose/navigation.md` | Compose 源码 |
| ViewModel | `docs/Compose/view-model.md` | Compose 源码 |
| 网络请求 | `docs/API/modules/network.md` | 搜索 "NetworkModule" |
| 本地存储 | `docs/API/modules/sp.md` | 搜索 "SharedPreferencesModule" |
| 与传统 DSL 互操作 | `docs/DevGuide/compose-view.md` | `kuikly-compose-interop-dsl` skill |
| **自定义组件** | **`docs/DevGuide/expand-native-ui.md`** | **`core-render-{platform}/`** |
| **自定义模块** | **`docs/DevGuide/expand-native-api.md`** | **`core/src/{platform}Main/`** |
| 能力全览 | `docs/Compose/status.md` | - |
| 常见问题 | `docs/Compose/faq.md` | - |

## 处理不存在的组件/模块

**当文档和源码中都找不到用户需要的组件或模块时，不要简单说"不支持"，而应该：**

**情况 1：Compose 组件不存在**
```
我在 Kuikly Compose 文档和源码中未找到 [组件X] 组件。

不过，Kuikly 支持自定义组件扩展。我可以帮您：
1. 查阅 `references/KuiklyUI/docs/DevGuide/expand-native-ui.md` 学习如何扩展原生 UI 组件
2. 查阅 `references/KuiklyUI/docs/DevGuide/compose-view.md` 了解 Compose 与传统 DSL 互操作
3. 参考 `docs/Compose/status.md` 查看当前已支持的 Compose 能力
4. 提供替代方案或自定义实现示例

是否需要我帮您实现？
```

**情况 2：模块/功能不存在**
```
我在 Kuikly 文档和源码中未找到 [功能X] 的相关 API。

不过，Kuikly 支持自定义模块扩展。我可以帮您：
1. 查阅 `references/KuiklyUI/docs/DevGuide/expand-native-api.md` 学习如何扩展原生能力
2. 创建自定义 Module 封装平台特定功能
3. 提供自定义模块的实现示例

是否需要我帮您实现自定义模块？
```

## 开发指南文档索引（通用）

### 快速开始
- **环境搭建**：`references/KuiklyUI/docs/QuickStart/env-setup.md`
- **KMP 跨端工程接入**：`references/KuiklyUI/docs/QuickStart/common.md`

### 核心概念
- **跨端工程模式**：`references/KuiklyUI/docs/Introduction/paradigm.md`
- **架构介绍**：`references/KuiklyUI/docs/Introduction/arch.md`

### 高级特性
- **网络请求**：`references/KuiklyUI/docs/DevGuide/network.md`
- **通知机制**：`references/KuiklyUI/docs/DevGuide/notify.md`
- **线程与协程**：`references/KuiklyUI/docs/DevGuide/thread-and-coroutines.md`
- **定时器**：`references/KuiklyUI/docs/DevGuide/set-timeout.md`
- **资源管理**：`references/KuiklyUI/docs/DevGuide/assets-resource.md`

### 调试与优化
- **Android 调试**：`references/KuiklyUI/docs/DevGuide/android-debug.md`
- **iOS 调试**：`references/KuiklyUI/docs/DevGuide/iOS-debug.md`
- **鸿蒙调试**：`references/KuiklyUI/docs/DevGuide/ohos-debug.md`
- **性能优化指南**：`references/KuiklyUI/docs/DevGuide/kuikly-perf-guidelines.md`

### 常见问题
- **Kuikly QA 汇总**：`references/KuiklyUI/docs/QA/kuikly-qa.md`

## 相关 skill

- **`kuikly-ui-framework`** — 如需使用传统 Kuikly DSL（`attr { }` / `event { }` 语法）开发页面，请切换到该 skill。
- **`kuikly-compose-interop-dsl`** — 在 Compose DSL 中嵌入传统 Kuikly DSL 组件时使用。
