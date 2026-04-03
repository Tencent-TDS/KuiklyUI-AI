# Kuikly Core 模块 Public 类 API 文档

本文档汇总了 Core 模块中所有对外暴露的 public 类、枚举，并按功能分类拆分为独立子文档，便于按需快速查阅。

---

## 颜色与样式
- [Color 颜色](publicClasses/color-style.md#color) - 颜色类，支持 ARGB、十六进制、预设色等多种创建方式
- [Border 边框](publicClasses/color-style.md#border) - 边框样式，支持设置宽度、颜色、样式
- [BorderStyle 边框样式](publicClasses/color-style.md#borderstyle) - 边框样式枚举（solid、dashed、dotted 等）
- [BorderRectRadius 圆角](publicClasses/color-style.md#borderrectradius) - 四角独立圆角配置
- [BoxShadow 阴影](publicClasses/color-style.md#boxshadow) - 盒子阴影，支持颜色、偏移、模糊半径
- [Direction 渐变方向](publicClasses/color-style.md#direction) - 渐变方向枚举
- [ColorStop 渐变色值](publicClasses/color-style.md#colorstop) - 渐变中的颜色断点
- [InterfaceStyle 深浅模式](publicClasses/color-style.md#interfacestyle) - 深色/浅色模式枚举

## 变换类
- [Rotate 旋转](publicClasses/transform.md#rotate) - 2D/3D 旋转变换
- [Scale 缩放](publicClasses/transform.md#scale) - 缩放变换
- [Translate 平移](publicClasses/transform.md#translate) - 平移变换
- [Skew 倾斜](publicClasses/transform.md#skew) - 倾斜变换
- [Anchor 锚点](publicClasses/transform.md#anchor) - 变换锚点设置
- [组合 transform](publicClasses/transform.md#组合-transform) - 多变换组合使用

## 布局类
- [Percentage 百分比](publicClasses/layout.md#percentage) - 百分比布局值
- [EdgeInsets 内边距](publicClasses/layout.md#edgeinsets) - 四边内边距配置
- [FlexDirection 主轴方向](publicClasses/layout.md#flexdirection) - Flex 布局主轴方向枚举
- [FlexJustifyContent 主轴对齐](publicClasses/layout.md#flexjustifycontent) - 主轴对齐方式枚举
- [FlexAlign 交叉轴对齐](publicClasses/layout.md#flexalign) - 交叉轴对齐方式枚举
- [FlexPositionType 定位类型](publicClasses/layout.md#flexpositiontype) - relative / absolute 定位
- [FlexWrap 换行](publicClasses/layout.md#flexwrap) - Flex 换行模式枚举

## 动画类
- [Animation 动画](publicClasses/animation.md) - 普通动画、弹簧动画、键盘动画及链式配置

## 响应式数据
- [observable 响应式属性](publicClasses/reactive.md#observable) - 声明响应式状态属性，驱动 UI 自动更新
- [observableList 响应式列表](publicClasses/reactive.md#observablelist) - 响应式列表，支持 diffUpdate 高效更新
- [ObservableList API](publicClasses/reactive.md#observablelist-api) - ObservableList 的完整操作方法

## JSON 序列化
- [JSONObject](publicClasses/json.md#jsonobject) - JSON 对象，支持读取和构建
- [JSONArray](publicClasses/json.md#jsonarray) - JSON 数组，支持遍历和操作

## 页面与生命周期
- [Pager 页面](publicClasses/pager-lifecycle.md#pager) - 页面基类，包含完整生命周期回调
- [PageData 页面数据](publicClasses/pager-lifecycle.md#pagedata) - 页面参数与设备/平台属性

## 事件系统
- [Event 事件中心](publicClasses/event.md#event) - 全局事件订阅与发布
- [事件参数类](publicClasses/event.md#事件参数) - 各类事件的参数定义
- [可见性事件](publicClasses/event.md#可见性事件) - 组件进出屏幕的可见性回调

## 内置模块
- [Module 基类](publicClasses/modules.md#module) - 所有模块的基类
- [NetworkModule 网络](publicClasses/modules.md#networkmodule) - HTTP 网络请求
- [RouterModule 路由](publicClasses/modules.md#routermodule) - 页面跳转与路由
- [SharedPreferencesModule 持久化](publicClasses/modules.md#sharedpreferencesmodule) - 本地键值存储
- [NotifyModule 通知](publicClasses/modules.md#notifymodule) - 原生通知与消息
- [CalendarModule 日历](publicClasses/modules.md#calendarmodule) - 日历操作
- [CodecModule 编解码](publicClasses/modules.md#codecmodule) - 数据编解码
- [SnapshotModule 截图](publicClasses/modules.md#snapshotmodule) - 组件截图
- [MemoryCacheModule 缓存](publicClasses/modules.md#memorycachemodule) - 内存缓存管理
- [PerformanceModule 性能](publicClasses/modules.md#performancemodule) - 性能监控与上报

## 工具类
- [Timer 定时器](publicClasses/utils.md#timer) - 定时器，支持重复与单次
- [setTimeout / clearTimeout](publicClasses/utils.md#settimeout) - 延时执行与取消
- [协程 LifecycleScope / GlobalScope](publicClasses/utils.md#协程) - 协程作用域，异步任务管理
- [KLog 日志](publicClasses/utils.md#klog) - 日志输出工具
- [DateTime 日期时间](publicClasses/utils.md#datetime) - 日期时间工具类
- [AccessibilityRole 无障碍角色](publicClasses/utils.md#accessibilityrole) - 无障碍角色枚举
