# 各平台打包配置

首次使用 assets 资源时，需要按平台修改编译配置。

## Android

修改 `shared/build.gradle.kts`，添加 assets 资源路径：

```kotlin
android {
    // ...
    sourceSets {
        named("main") {
            // ...
            assets.srcDirs("src/commonMain/assets")
        }
    }
}
```

## iOS

修改 `shared/build.gradle.kts`，添加 CocoaPods 资源路径：

```kotlin
kotlin {
    cocoapods {
        // ...
        extraSpecAttributes["resources"] = "['src/commonMain/assets/**']"
    }
}
```

> ⚠️ **Kotlin 2.x + Compose 注意**：使用了 compose plugin 的模块，插件会默认修改 `spec.resources`，导致 `build.gradle.kts` 中的设置不生效。需要在 `gradle.properties` 中添加：
> ```properties
> compose.ios.resources.sync=false
> ```

> ⚠️ **多模块配置注意**：iOS 端在多模块项目中，子模块的 assets 资源**不会自动合并**到最终产物中。需要手动将子模块的 assets 资源拷贝到主模块下，由主模块统一打包。例如将子模块 `submodule/src/commonMain/assets/` 下的资源拷贝到主模块 `shared/src/commonMain/assets/` 对应目录中。

## 鸿蒙

鸿蒙将业务代码编译为 so 文件，**不支持 assets 资源内置打包**。需要手动将资源拷贝到鸿蒙工程的 `resfile` 目录：

```
shared/src/commonMain/assets/common/* → entry/src/main/resources/resfile/common/*
```

## H5

H5 不需要打包配置。构建后的静态资源产物位于：

```
build/dist/js/productionExecutable/assets
```

将该目录的资源发布到 Web Server 或 CDN 即可。

## 微信小程序

在微信小程序工程目录下执行：

```shell
./gradlew :miniApp:copyAssets
```

> ⚠️ 微信小程序包限制为 2M，一般**不建议**资源内置打包到微信小程序中。
