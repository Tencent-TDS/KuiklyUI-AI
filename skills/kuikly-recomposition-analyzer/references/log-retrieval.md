# 日志获取命令

Profiler 日志默认保存在 App 的 cache 目录。

## Android

```bash
# 方式 1：adb（需 run-as 权限，debug 包）
adb shell run-as <包名> cat cache/KuiklyProfiler/profiler_report.json > profiler_report.json
adb shell run-as <包名> cat cache/KuiklyProfiler/profiler_frames.jsonl > profiler_frames.jsonl

# 方式 2：adb pull（需 root 或 backup 权限）
adb pull /data/data/<包名>/cache/KuiklyProfiler/profiler_report.json
adb pull /data/data/<包名>/cache/KuiklyProfiler/profiler_frames.jsonl

# 查看连接的设备
adb devices
```

## iOS 模拟器

```bash
# 获取 App 容器路径
xcrun simctl get_app_container booted <BundleID> data

# 复制文件（替换 <容器路径> 为上一步输出的路径）
cp "<容器路径>/Library/Caches/KuiklyProfiler/profiler_report.json" ./
cp "<容器路径>/Library/Caches/KuiklyProfiler/profiler_frames.jsonl" ./

# 或直接用 Bash 合并两步
CONTAINER=$(xcrun simctl get_app_container booted <BundleID> data)
cp "$CONTAINER/Library/Caches/KuiklyProfiler/profiler_report.json" ./
cp "$CONTAINER/Library/Caches/KuiklyProfiler/profiler_frames.jsonl" ./
```

## iOS 真机

```bash
# 需要 Xcode 开发者工具（devicectl，Xcode 15+）
xcrun devicectl device copy from --device <设备UDID> \
  --source "KuiklyProfiler/profiler_report.json" \
  --destination ./profiler_report.json

# 或通过 Xcode Devices 窗口手动下载 App Container
```

## HarmonyOS

```bash
# HDC（HarmonyOS Device Connector）
hdc file recv /data/storage/el2/base/haps/entry/cache/KuiklyProfiler/profiler_report.json ./
hdc file recv /data/storage/el2/base/haps/entry/cache/KuiklyProfiler/profiler_frames.jsonl ./

# 查看连接的设备
hdc list targets
```

## 无法自动获取时

告知用户：

> 未检测到可用设备或无法自动拉取文件。请手动从设备获取以下两个文件后告诉我路径：
> - `profiler_report.json`
> - `profiler_frames.jsonl`
> 
> 文件位于 App cache 目录的 `KuiklyProfiler/` 子目录下。
