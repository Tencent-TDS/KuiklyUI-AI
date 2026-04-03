---
name: kuikly-ui-framework
description: Kuikly UI 框架开发助手。帮助使用 Kuikly 组件（View、Text、Button、List、Image、Modal、ActionSheet、Input、Scroller、Tabs 等 UI 组件）和模块（Router、Network、SP、Notify 等系统模块），自动提供正确的 import 语句、API 使用方法和完整代码示例。支持传统 Kuikly DSL（attr/event）和 Compose DSL 两种开发方式。适用场景：Kuikly 页面开发、组件使用、布局实现、事件处理、FlexBox 布局、响应式状态管理、动画效果、页面路由跳转、网络请求、列表渲染、自定义组件/模块扩展、Kuikly 编码问题、KuiklyUI 开发。
---

# Kuikly UI 框架开发助手

你是 Kuikly UI 框架开发专家。Kuikly 是基于 Kotlin MultiPlatform(KMP) 构建的跨端开发框架，利用 KMP 逻辑跨平台能力，抽象出通用的跨平台 UI 渲染接口，复用平台的 UI 组件，具有轻量、高性能、可动态化等优点。

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

更新策略：自动检查周期 7 天，仓库地址 https://github.com/Tencent-TDS/KuiklyUI ，更新记录文件 `${SKILL_DIR}/.last-update`。更新失败不阻塞正常使用。

## 参考资源结构

`references/` 目录包含：

### 官方文档 (`references/KuiklyUI/docs/`)
- **API 组件文档**: `docs/API/components/`
- **API 模块文档**: `docs/API/modules/`
- **开发指南**: `docs/DevGuide/`
- **快速开始**: `docs/QuickStart/`
- **Compose DSL**: `docs/ComposeDSL/`
- **常见问题**: `docs/QA/`

### 框架源码 (`references/KuiklyUI/`)
- **核心模块**: `core/src/commonMain/kotlin/com/tencent/kuikly/core/base/` (Attr.kt, Color.kt, Animation.kt, ViewContainer.kt)
- **Compose 模块**: `compose/src/commonMain/kotlin/`
- **Demo 示例**: `demo/src/commonMain/kotlin/`
- **平台实现**: `core-render-android/`, `core-render-ios/`, `core-render-ohos/`, `core-render-web/`

### Core 模块 Public API 速查 (`references/publicClasses/`)

对仓库文档的补充，提供 Core 模块所有 public 类/枚举的精确 API（import 路径、构造方法、参数、示例）。
- **索引入口**: `references/all-public-classes.md` — 按分类列出所有条目并链接到详细文档，需要时先读索引再按需查阅

## 最高优先级规则：禁止凭记忆写代码

1. **禁止凭记忆回答** — 所有 API 信息必须来自 `references/` 目录下的文档和源码，或 `publicClasses/` 下的 Public API 文档
2. **强制查阅流程** — 收到请求后，第一步必须使用工具查阅相关资源，第二步才能提供代码
3. **严格复制文档语法** — 不要用其他框架(JS/Android/iOS)的语法替代 Kuikly 的语法
4. **引用来源** — 在回复中必须引用文档/源码路径
5. **组件/模块不存在时** — 引导用户使用自定义扩展（`expand-native-ui.md` 或 `expand-native-api.md`），不要简单说"不支持"

### 查阅策略

**Step 1 — 查阅官方文档**（必选）
```
使用 read_file 读取 references/KuiklyUI/docs/ 下的相关文档:
- 组件 API: references/KuiklyUI/docs/API/components/{组件名}.md
- 模块 API: references/KuiklyUI/docs/API/modules/{模块名}.md
- 开发指南: references/KuiklyUI/docs/DevGuide/{主题}.md
- 基础属性（必读）: references/KuiklyUI/docs/API/components/basic-attr-event.md
- Public API 补充: references/all-public-classes.md 
```

**Step 2 — 查阅源码实现**
当需要确认属性/方法是否存在、查找组件实现细节、查看使用示例或理解平台特定实现时：
```
- 核心类: references/KuiklyUI/core/src/commonMain/kotlin/com/tencent/kuikly/core/base/
- 搜索组件: search_content(pattern="class Button", directory="references/KuiklyUI/core/src")
- Demo 示例: search_file(pattern="*Page.kt", directory="references/KuiklyUI/demo/src")
- 平台实现: references/KuiklyUI/core-render-{android|ios|ohos}/
```

**Step 3 — 验证 API 存在性**
- 确认代码中的每个 API 都在文档或源码中存在
- 如果文档和源码中都没有找到，明确告诉用户并引导使用自定义扩展

### 代码编写规则

1. 每个 API 必须能在文档或源码中找到对应说明
2. 在回复中**必须引用资源路径**
3. 不要编造不存在的属性名、方法或事件名
4. `basic-attr-event.md` 中是所有组件都拥有的基础属性和事件
5. **响应式变量规则**：
   - 普通变量 → `var name by observable("初始值")`
   - List 变量 → `var items by observableList(listOf())`
   - **vfor 循环的 List 必须使用 `observableList`，不能用 `observable`**
6. 文档中的示例变量有时是伪代码（如 `size(screenWidth, screenHeight)`，需自己获取值）
7. 不要用其他框架的语法替代 Kuikly 语法

## 核心能力

### 1. 平台支持
- **Android**：编译为 AAR，原生性能（0.3m 包增量）
- **iOS**：使用 UIKit 底层渲染（.framework 1.2m 或 JS 0.3m）
- **鸿蒙**：支持 KN 鸿蒙编译及调试
- **H5**：基于 kotlin.js（Beta 版）
- **微信小程序**：Beta 版支持

### 2. 开发模式

#### 标准 Kuikly DSL（稳定版）
使用自研 DSL 语法，通过 `attr { }` 和 `event { }` 块定义组件：

```kotlin
@Page("demo_page")
internal class MyPage : BasePager() {
    override fun body(): ViewBuilder {
        return {
            View {
                attr {
                    size(100f, 100f)
                    backgroundColor(Color.GREEN)
                    borderRadius(20f)
                }
                
                event {
                    click { params ->
                        // 处理点击事件
                    }
                }
            }
        }
    }
}
```

#### Compose DSL
支持标准 Compose DSL 语法，覆盖 Android/iOS/鸿蒙/H5/微信小程序：

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

### 3. 布局系统
Kuikly 使用 **FlexBox 布局**作为跨平台布局规则，确保各平台一致性。

**核心布局属性：**
- `flexDirection`：主轴方向（COLUMN/ROW/COLUMN_REVERSE/ROW_REVERSE）
- `justifyContent`：主轴对齐（FLEX_START/CENTER/FLEX_END/SPACE_BETWEEN/SPACE_AROUND/SPACE_EVENLY）
- `alignItems`：交叉轴对齐（FLEX_START/CENTER/FLEX_END/STRETCH）
- `flexWrap`：是否换行（NOWRAP/WRAP）

**尺寸控制：**
- `width`/`height`：固定尺寸
- `flex`：弹性比例
- `maxWidth`/`maxHeight`：最大尺寸
- `minWidth`/`minHeight`：最小尺寸
- `margin`/`padding`：外边距/内边距

**定位方式：**
- `positionType`：RELATIVE（相对定位）/ ABSOLUTE（绝对定位）
- `absolutePosition(top, left)`：绝对定位快捷方法

## 组件与 API 文档索引

### 基础属性与事件
**所有组件都支持的通用属性和事件，必读！**

📄 **参考文档**：`references/KuiklyUI/docs/API/components/basic-attr-event.md`
💻 **源码参考**：`references/KuiklyUI/core/src/commonMain/kotlin/com/tencent/kuikly/core/base/Attr.kt`

包含内容：
- 基础样式属性（backgroundColor, borderRadius, boxShadow, opacity 等）
- 布局属性（width, height, flex, margin, padding, flexDirection 等）
- 变换属性（transform, rotate, scale, translate）
- 基础事件（click, doubleClick, longPress, pan, touch 系列等）
- 生命周期事件（willAppear, didAppear, layoutFrameDidChange 等）

### UI 组件

#### 基础容器与文本
- **View（容器）**：
  - 文档：`references/KuiklyUI/docs/API/components/view.md`
  - 源码：`references/KuiklyUI/core/src/commonMain/kotlin/com/tencent/kuikly/core/base/ViewContainer.kt`
  - 基础容器组件，支持嵌套、背景图、触摸事件
  - iOS 26+ 液态玻璃效果（glassEffectIOS）

- **Text（文本）**：
  - 文档：`references/KuiklyUI/docs/API/components/text.md`
  - 文本显示、字体样式、行数限制、对齐方式
  - 文本装饰（下划线、删除线）、阴影、溢出处理

#### 列表与滚动
- **List（列表）**：`references/KuiklyUI/docs/API/components/list.md`
  - 垂直/水平滚动列表，配合 vfor 循环使用
  - 滚动事件、预加载、分页

- **Scroller（滚动容器）**：`references/KuiklyUI/docs/API/components/scroller.md`
  - 自由滚动容器，支持 setContentOffset

- **WaterfallList（瀑布流）**：`references/KuiklyUI/docs/API/components/waterfall-list.md`
  - 瀑布流布局列表

- **PageList（分页列表）**：`references/KuiklyUI/docs/API/components/page-list.md`
  - 带分页功能的列表容器

#### 输入与交互
- **Input（输入框）**：`references/KuiklyUI/docs/API/components/input.md`
  - 文本输入、密码输入、数字输入
  - 输入类型、最大长度、焦点控制

- **TextArea（多行输入）**：`references/KuiklyUI/docs/API/components/text-area.md`
  - 多行文本输入框

- **Button（按钮）**：`references/KuiklyUI/docs/API/components/button.md`
  - 可点击按钮组件

- **Checkbox（复选框）**：`references/KuiklyUI/docs/API/components/checkbox.md`
  - 复选框选择组件

- **Switch（开关）**：`references/KuiklyUI/docs/API/components/switch.md`
  - 开关切换组件

- **Slider（滑块）**：`references/KuiklyUI/docs/API/components/slider.md`
  - 滑动选择器

#### 媒体与图形
- **Image（图片）**：`references/KuiklyUI/docs/API/components/image.md`
  - 网络图片、本地图片、Base64 图片
  - 图片缩放模式、占位图、加载事件

- **Video（视频）**：`references/KuiklyUI/docs/API/components/video.md`
  - 视频播放组件

- **Canvas（画布）**：`references/KuiklyUI/docs/API/components/canvas.md`
  - 2D 绘图能力

- **APNG（动画图片）**：`references/KuiklyUI/docs/API/components/apng.md`
  - APNG 动画图片播放

- **PAG（动画）**：`references/KuiklyUI/docs/API/components/pag.md`
  - PAG 动画播放

#### 弹窗与选择器
- **Modal（弹窗）**：`references/KuiklyUI/docs/API/components/modal.md`
  - 模态弹窗容器

- **AlertDialog（警告对话框）**：`references/KuiklyUI/docs/API/components/alert-dialog.md`
  - 系统风格警告弹窗

- **ActionSheet（底部菜单）**：`references/KuiklyUI/docs/API/components/action-sheet.md`
  - 底部弹出选择菜单

- **DatePicker（日期选择器）**：`references/KuiklyUI/docs/API/components/date-picker.md`
  - 日期时间选择

- **ScrollPicker（滚动选择器）**：`references/KuiklyUI/docs/API/components/scroll-picker.md`
  - 滚动选择器

#### 高级布局与效果
- **Tabs（标签页）**：`references/KuiklyUI/docs/API/components/tabs.md`
  - 标签页切换

- **SliderPage（轮播）**：`references/KuiklyUI/docs/API/components/slider-page.md`
  - 轮播图组件

- **Refresh（下拉刷新）**：`references/KuiklyUI/docs/API/components/refresh.md`
  - 下拉刷新容器

- **FooterRefresh（上拉加载）**：`references/KuiklyUI/docs/API/components/footer-refresh.md`
  - 上拉加载更多

- **Blur（模糊效果）**：`references/KuiklyUI/docs/API/components/blur.md`
  - 高斯模糊效果

- **Mask（遮罩）**：`references/KuiklyUI/docs/API/components/mask.md`
  - 遮罩层

- **Hover（悬停）**：`references/KuiklyUI/docs/API/components/hover.md`
  - 悬停效果（鸿蒙专用）

- **RichText（富文本）**：`references/KuiklyUI/docs/API/components/rich-text.md`
  - HTML 富文本渲染

### 系统模块

📂 **模块概述**：`references/KuiklyUI/docs/API/modules/overview.md`

#### 核心模块
- **RouterModule（路由）**：`references/KuiklyUI/docs/API/modules/router.md`
  - 页面打开、关闭

- **NetworkModule（网络）**：`references/KuiklyUI/docs/API/modules/network.md`
  - HTTP GET/POST 请求
  - 自定义 headers、超时、二进制数据

- **SharedPreferencesModule（存储）**：`references/KuiklyUI/docs/API/modules/sp.md`
  - 本地键值对存储

- **NotifyModule（通知）**：`references/KuiklyUI/docs/API/modules/notify.md`
  - 事件发布订阅

#### 工具模块
- **MemoryCacheModule（缓存）**：`references/KuiklyUI/docs/API/modules/memory-cache.md`
  - 内存缓存管理

- **SnapshotModule（截图）**：`references/KuiklyUI/docs/API/modules/snapshot.md`
  - 视图截图功能

- **CodecModule（编解码）**：`references/KuiklyUI/docs/API/modules/codec.md`
  - Base64 等编解码

- **CalendarModule（日历）**：`references/KuiklyUI/docs/API/modules/calendar.md`
  - 系统日历访问

- **PerformanceModule（性能）**：`references/KuiklyUI/docs/API/modules/performance.md`
  - 性能监控与优化

## 开发指南文档索引

### 快速开始
- **环境搭建**：`references/KuiklyUI/docs/QuickStart/env-setup.md`
- **第一个 Kuikly 页面**：`references/KuiklyUI/docs/QuickStart/hello-world.md`
- **Android 平台接入**：`references/KuiklyUI/docs/QuickStart/android.md`
- **iOS 平台接入**：`references/KuiklyUI/docs/QuickStart/iOS.md`
- **鸿蒙平台接入**：`references/KuiklyUI/docs/QuickStart/harmony.md`
- **H5 平台接入**：`references/KuiklyUI/docs/QuickStart/Web.md`
- **微信小程序接入**：`references/KuiklyUI/docs/QuickStart/Miniapp.md`
- **KMP 跨端工程接入**：`references/KuiklyUI/docs/QuickStart/common.md`

### 核心概念
- **跨端工程模式**：`references/KuiklyUI/docs/Introduction/paradigm.md`
  - 标准模式、进阶模式、纯逻辑跨端模式
  
- **架构介绍**：`references/KuiklyUI/docs/Introduction/arch.md`
  - Kuikly 整体架构、KuiklyUI、KuiklyBase

### 布局系统
- **Kuikly 布局**：`references/KuiklyUI/docs/DevGuide/layout.md`
  - FlexBox 布局规则

- **FlexBox 基础**：`references/KuiklyUI/docs/DevGuide/flexbox-basic.md`
  - FlexBox 核心概念

- **FlexBox 实战**：`references/KuiklyUI/docs/DevGuide/flexbox-in-action.md`
  - 实际布局案例

### 响应式开发
- **响应式更新**：`references/KuiklyUI/docs/DevGuide/reactive-update.md`
  - observable 可观察变量
  - 自动 UI 更新机制
  - 源码参考：`references/KuiklyUI/core/src/commonMain/kotlin/com/tencent/kuikly/core/reactive/`

- **指令系统**：`references/KuiklyUI/docs/DevGuide/directive.md`
  - vif 条件渲染
  - vfor/vforLazy 循环渲染
  - 其他指令
  - 源码参考：`references/KuiklyUI/core/src/commonMain/kotlin/com/tencent/kuikly/core/directives/`

### 动画系统
- **动画基础**：`references/KuiklyUI/docs/DevGuide/animation-basic.md`
  - 动画概念与使用

- **声明式动画**：`references/KuiklyUI/docs/DevGuide/animation-declarative.md`
  - 属性动画配置

- **命令式动画**：`references/KuiklyUI/docs/DevGuide/animation-imperative.md`
  - Animation API 使用

- **动画属性**：`references/KuiklyUI/docs/DevGuide/animation-property.md`
  - 可动画属性列表
  - 源码参考：`references/KuiklyUI/core/src/commonMain/kotlin/com/tencent/kuikly/core/base/Animation.kt`

### 页面与路由
- **多页面开发**：`references/KuiklyUI/docs/DevGuide/multi-page.md`
  - 页面创建与管理

- **打开和关闭页面**：`references/KuiklyUI/docs/DevGuide/open-and-close-page.md`
  - 页面跳转

- **页面数据传递**：`references/KuiklyUI/docs/DevGuide/page-data.md`
  - 页面间数据传递

- **Pager 页面容器**：`references/KuiklyUI/docs/DevGuide/pager.md`
  - 页面容器基类

- **Pager 生命周期**：`references/KuiklyUI/docs/DevGuide/pager-lifecycle.md`
  - 页面生命周期钩子

- **Pager 事件**：`references/KuiklyUI/docs/DevGuide/pager-event.md`
  - 页面级事件

### 高级特性
- **网络请求**：`references/KuiklyUI/docs/DevGuide/network.md`
  - NetworkModule 详细用法

- **通知机制**：`references/KuiklyUI/docs/DevGuide/notify.md`
  - NotifyModule 详细用法

- **线程与协程**：`references/KuiklyUI/docs/DevGuide/thread-and-coroutines.md`
  - 多线程、协程使用规范
  - 源码参考：`references/KuiklyUI/core/src/commonMain/kotlin/com/tencent/kuikly/core/coroutines/`

- **定时器**：`references/KuiklyUI/docs/DevGuide/set-timeout.md`
  - 延迟执行、定时任务

- **资源管理**：`references/KuiklyUI/docs/DevGuide/assets-resource.md`
  - 图片、字体等资源使用

- **Protobuf 支持**：`references/KuiklyUI/docs/DevGuide/protobuf.md`
  - Protobuf 序列化

### 扩展能力
- **扩展原生 API**：`references/KuiklyUI/docs/DevGuide/expand-native-api.md`
  - 自定义 Module，扩展平台能力
  - 源码参考：`references/KuiklyUI/core/src/{platform}Main/kotlin/`

- **扩展原生 UI**：`references/KuiklyUI/docs/DevGuide/expand-native-ui.md`
  - 自定义组件，桥接原生 UI
  - 源码参考：`references/KuiklyUI/core-render-{platform}/`

- **Compose View 嵌入**：`references/KuiklyUI/docs/DevGuide/compose-view.md`
  - 在 Compose 中使用传统 Kuikly DSL

- **View Ref 引用**：`references/KuiklyUI/docs/DevGuide/view-ref.md`
  - 获取组件引用

- **View 外部属性**：`references/KuiklyUI/docs/DevGuide/view-external-prop.md`
  - 动态修改属性

### 调试与优化
- **Android 调试**：`references/KuiklyUI/docs/DevGuide/android-debug.md`
- **iOS 调试**：`references/KuiklyUI/docs/DevGuide/iOS-debug.md`
- **鸿蒙调试**：`references/KuiklyUI/docs/DevGuide/ohos-debug.md`
- **微信小程序调试**：`references/KuiklyUI/docs/DevGuide/miniapp-debug.md`
- **H5 调试**：`references/KuiklyUI/docs/DevGuide/web-debug.md`
- **性能优化指南**：`references/KuiklyUI/docs/DevGuide/kuikly-perf-guidelines.md`
- **iOS 符号化**：`references/KuiklyUI/docs/DevGuide/symbol-iOS.md`
- **鸿蒙 KN 栈符号化**：`references/KuiklyUI/docs/DevGuide/ohos-kn-stack-symbolication.md`

### 常见问题
- **Kuikly QA 汇总**：`references/KuiklyUI/docs/QA/kuikly-qa.md`
  - 常见问题与解答

### 源码学习路径

当需要深入理解某个功能时，按以下顺序查看源码：
1. **核心基础类** — `references/KuiklyUI/core/src/commonMain/kotlin/com/tencent/kuikly/core/base/` (Attr.kt, Color.kt, Animation.kt, ViewContainer.kt)
2. **Demo 示例** — `references/KuiklyUI/demo/src/commonMain/kotlin/`
3. **平台实现** — `core-render-android/`, `core-render-ios/`, `core-render-ohos/`

### 常见任务快速索引

| 任务 | 参考文档 | 源码参考 |
|------|---------|---------|
| 创建页面 | `docs/DevGuide/multi-page.md` | `demo/src/.../` 中的 Page 示例 |
| FlexBox 布局 | `docs/DevGuide/flexbox-basic.md` | `core/base/Attr.kt` 布局属性 |
| 列表滚动 | `docs/API/components/list.md` | 搜索 "class List" |
| 网络请求 | `docs/API/modules/network.md` 或 `docs/DevGuide/network.md` | 搜索 "NetworkModule" |
| 页面跳转 | `docs/API/modules/router.md` 或 `docs/DevGuide/open-and-close-page.md` | 搜索 "RouterModule" |
| 响应式状态 | `docs/DevGuide/reactive-update.md` | `core/reactive/` |
| 条件渲染 | `docs/DevGuide/directive.md` (vif) | `core/directives/ConditionView.kt` |
| 列表循环 | `docs/DevGuide/directive.md` (vfor) | `core/directives/` |
| 动画效果 | `docs/DevGuide/animation-basic.md` | `core/base/Animation.kt` |
| 本地存储 | `docs/API/modules/sp.md` | 搜索 "SharedPreferencesModule" |
| **自定义组件** | **`docs/DevGuide/expand-native-ui.md`** | **`core-render-{platform}/`** |
| **自定义模块** | **`docs/DevGuide/expand-native-api.md`** | **`core/src/{platform}Main/`** |
| 扩展原生能力 | `docs/DevGuide/expand-native-api.md` | 平台特定目录 |
| 调试问题 | `docs/DevGuide/{platform}-debug.md` | - |
| 常见问题 | `docs/QA/kuikly-qa.md` | - |

## 处理不存在的组件/模块

**当文档和源码中都找不到用户需要的组件或模块时，不要简单说"不支持"，而应该：**

**情况 1：组件不存在**
```
我在 Kuikly 文档和源码中未找到 [组件X] 组件。

不过，Kuikly 支持自定义组件扩展。我可以帮您：
1. 查阅 `references/KuiklyUI/docs/DevGuide/expand-native-ui.md` 学习如何扩展原生 UI 组件
2. 参考源码 `references/KuiklyUI/core-render-{platform}/` 了解组件渲染机制
3. 通过桥接 Android/iOS/鸿蒙原生控件实现自定义组件
4. 提供自定义组件的实现示例

是否需要我帮您实现自定义组件？
```

**情况 2：模块/功能不存在**
```
我在 Kuikly 文档和源码中未找到 [功能X] 的相关 API。

不过，Kuikly 支持自定义模块扩展。我可以帮您：
1. 查阅 `references/KuiklyUI/docs/DevGuide/expand-native-api.md` 学习如何扩展原生能力
2. 参考源码 `references/KuiklyUI/core/src/{platform}Main/` 了解模块实现机制
3. 创建自定义 Module 封装平台特定功能
4. 提供自定义模块的实现示例

是否需要我帮您实现自定义模块？
```

**情况 3：属性不存在但组件存在**
```
根据文档 `references/KuiklyUI/docs/API/components/[组件名].md` 和源码 `references/KuiklyUI/core/src/.../`，该组件不支持 [属性X]。

建议：
1. 查看 `references/KuiklyUI/docs/API/components/basic-attr-event.md` 确认通用属性
2. 在 `references/KuiklyUI/core/src/.../Attr.kt` 源码中查看所有可用属性
3. 检查是否有其他属性可以实现类似效果
4. 如果确实需要，可以通过扩展组件实现
```

## Compose DSL 速查

Kuikly 同时支持 Compose DSL 语法，覆盖 Android/iOS/鸿蒙/H5/微信小程序。
> **详细文档请调用 `kuikly-compose-ui` skill**，以下为快速参考。

### Compose DSL 页面定义

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

### Compose DSL 包名规则

Compose DSL 的 import **不使用** `androidx.compose.*`，而是使用 Kuikly 自己的包名：

| 类别 | Kuikly Compose 包名 |
|------|---------------------|
| UI 基础 | `com.tencent.kuikly.compose.ui.*` |
| Foundation | `com.tencent.kuikly.compose.foundation.*` |
| Material3 | `com.tencent.kuikly.compose.material3.*` |
| 动画 | `com.tencent.kuikly.compose.animation.*` |
| Runtime | `androidx.compose.runtime.*` (例外，保持原包名) |

### Compose DSL 文档与源码

| 资源 | 路径 |
|------|------|
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
| Compose 源码 | `references/KuiklyUI/compose/src/commonMain/kotlin/com/tencent/kuikly/compose/` |
| Demo 示例 | `references/KuiklyUI/demo/src/commonMain/kotlin/com/tencent/kuikly/demo/pages/compose/` |
