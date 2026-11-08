# FLEX Swift 字段查看模块

为现有 FakeTools 内的 FLEX 补充官方 Reflex Swift 字段解析器。GitHub Actions 在 macOS 上交叉编译 iPhone arm64 动态库，最低构建目标 iOS 13。

## 与现有工具的对应关系

已分析的 `faketool_P_base64.dylib` 内含 FLEX 的 Reflex 接口，但没有定义 `FLEXSwiftMirror` 类。Swift 字段缺少 Objective-C 类型编码时，普通 FLEX 读取路径会显示 `? / nil`。

本项目编译官方 Reflex 和 Echo，动态链接已有 FLEX，实现 Swift 字段元数据及值读取。启动组件在类加载后调用 `setReflexAvailable:YES`。它不修改被检查应用的配置值。

原工具样本 SHA256：

```
8cd72f8d8563bec045dee6c188aadcdbc90fedfa689e24cb7245d3b758bed519
```

## 下载与加载

1. 打开仓库 Actions，选择最新成功的 `Build Swift inspection module`。
2. 下载 `NBFLEXReflex-arm64-iOS` artifact，解压得到 `libNBFLEXReflex.dylib`。
3. 复制你自己的原始 `faketool_P_base64.dylib`，将副本命名为 `FakeTools.dylib`。本仓库不提供原工具二进制。
4. 两个文件必须处于同一目录：

```
FakeTools.dylib
libNBFLEXReflex.dylib
```

5. 按设备原有方式签名并加载这两个文件。已有工具若使用其他文件名注入，应调整为这一个副本，避免重复加载两份相同 FLEX。
6. 完全重启目标 App，打开 FLEX；关闭重开对象详情页，再检查 Swift 字段。

依赖使用 `@loader_path/FakeTools.dylib`，不需要额外安装第二套 FLEX。原工具已有的 CydiaSubstrate 等依赖仍由设备现有环境提供。

## 验证范围

Actions 检查编译、arm64 架构、链接依赖、Swift mirror 导出、避免重复定义基础 FLEX 类，以及临时签名。构建成功不等于已通过 iPhone 运行验证。

官方 Reflex 自称 WIP。不同 Swift 编译器、类型和 iOS 版本可能仍存在兼容问题。`String`、`Bool`、`Int` 和集合字段应在手机上使用已知值进行校验；原来显示的 `nil` 不能直接当作实际值。

## 来源和许可

- [FLEXTool/FLEX](https://github.com/FLEXTool/FLEX)，头文件 commit `dac6130e0c7aca0bbf7ff8c0b57ba284776bfdff`。
- [FLEXTool/Reflex](https://github.com/FLEXTool/Reflex)，commit `2b992b7eddbf0420a8dcc66630b3d3abfe1a9a48`。
- [NSExceptional/Echo](https://github.com/NSExceptional/Echo)，commit `e912ad88d3524725127f5163a2c5015573078b08`，对应 Reflex Xcode 工程使用的 patch-1 分支。

保留相应项目许可证；链接桩根据指定原工具的导出符号生成，不含原工具实现。
