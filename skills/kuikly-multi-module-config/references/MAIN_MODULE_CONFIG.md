# 主模块修改指南

## Contents

- settings.gradle.kts 修改
- 主模块 build.gradle.kts 修改
- 已有多个子模块时的配置
- 鸿蒙适配

## settings.gradle.kts

在根目录 `settings.gradle.kts` 中添加子模块：

```kotlin
// 已有内容
include(":demo")

// 新增子模块
include(":${子模块名}")
// 如果项目使用了 buildFileName，也需要配置：
project(":${子模块名}").buildFileName = buildFileName
```

## 主模块 build.gradle.kts

需要修改两处：

### 1. commonMain 添加子模块依赖

```kotlin
kotlin {
    sourceSets {
        val commonMain by getting {
            dependencies {
                // 已有依赖...
                implementation(project(":${子模块名}"))  // ← 新增
            }
        }
    }
}
```

### 2. ksp 块添加多模块参数

**首次启用多模块**（之前没有 enableMultiModule）：

```kotlin
ksp {
    // 已有配置...
    arg("moduleId", "main")                  // 主模块 ID
    arg("isMainModule", "true")
    arg("subModules", "${子模块名}")           // 新增
    arg("enableMultiModule", "true")          // 新增
}
```

**已有多模块配置，追加子模块**：

```kotlin
ksp {
    // 修改 subModules，用 & 分隔追加新模块
    arg("subModules", "existing_sub&${新子模块名}")
}
```

---

## 已有多个子模块示例

假设主模块 `demo` 已有子模块 `demo_sub`，现在要新增 `feature_chat`：

```kotlin
// settings.gradle.kts
include(":demo")
include(":demo_sub")
include(":feature_chat")    // ← 新增

// demo/build.gradle.kts
kotlin {
    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation(project(":demo_sub"))
                implementation(project(":feature_chat"))  // ← 新增
            }
        }
    }
}

ksp {
    arg("moduleId", "main")
    arg("isMainModule", "true")
    arg("subModules", "demo_sub&feature_chat")  // ← 追加
    arg("enableMultiModule", "true")
}
```

---

## 鸿蒙适配（多套 Gradle 配置场景）

如果项目为鸿蒙平台维护了单独的 Gradle 配置文件（如 `build.ohos.gradle.kts`、`settings.ohos.gradle.kts`），则子模块也需要对应创建一份鸿蒙版本的配置。

> 💡 **核心原则**：有几套 Gradle 配置，子模块就需要几份对应的 `build.gradle.kts`，每份都基于对应的主模块配置文件复制后修改差异点。

除了上述通用差异点外，鸿蒙配置还需要注意以下额外事项：

### 1. 使用鸿蒙 Kotlin 版本

确保使用 鸿蒙 版本的 Kotlin 编译器。

### 2. 添加 ohosArm64 target

在子模块 `build.gradle.kts`（或 `build.ohos.gradle.kts`）中：

```kotlin
kotlin {
    ohosArm64 {
        binaries {
            sharedLib()
        }
    }
}
```

### 3. ksp 添加鸿蒙平台

```kotlin
dependencies {
    compileOnly(project(":core-ksp")) {
        // 已有的平台...
        add("kspOhosArm64", this)  // ← 新增鸿蒙
    }
}
```

### 4. 使用鸿蒙版本的 Kuikly 依赖

```kotlin
kotlin {
    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation("com.tencent.kuikly:core:KUIKLY_VERSION-2.0.21-ohos")
                implementation("com.tencent.kuikly:core-annotations:KUIKLY_VERSION-2.0.21-ohos")
            }
        }
    }
}
```