# ptime

[English](https://github.com/SupremeHuaji/ptime/blob/main/README.md) | [简体中文](https://github.com/SupremeHuaji/ptime/blob/main/README_zh_CN.md)

ptime 是一个为 MoonBit 设计的轻量级时间库，提供皮秒级精度的时间处理功能。它支持多种时间格式转换、时间计算和人性化时间显示，是处理时间相关任务的理想选择。

## ✨ 主要特性
• ⏱️ **皮秒级精度** - 支持纳秒、微秒、毫秒、秒的精确时间计算  
• 🌍 **RFC 3339 支持** - 完整的 ISO 8601 / RFC 3339 时间格式解析和生成  
• 📅 **多种时间格式** - 支持人类可读、日志、HTTP 日期等多种格式  
• ⚡ **高性能** - 纯 MoonBit 实现，无外部依赖  
• 🎯 **易于使用** - 简洁的 API 设计，支持链式操作  
• 🛡️ **类型安全** - 完整的错误处理和类型检查  
• 🔄 **时间跨度运算** - 支持时间加减、比较、格式化等操作  

## 📥 安装
```bash
moon add SupremeHuaji/ptime
```

## 🚀 使用指南

### 🕐 创建时间点
你可以使用`epoch()`、`of_float()`或直接构造来创建时间点。

```moonbit
// 创建 Unix 纪元时间 (1970-01-01 00:00:00 UTC)
let epoch_time = epoch()

// 从浮点数创建时间点
let time_from_float = of_float(1694764200.5)

// 直接构造时间点
let custom_time = PTime::{ seconds: 1694764200, picoseconds: 500000000000 }
```

### ⏰ 时间比较和计算
使用`compare()`和`diff()`方法进行时间比较和计算。

```moonbit
let now = PTime::{ seconds: 1694764200, picoseconds: 0 }
let past = PTime::{ seconds: 1694760000, picoseconds: 0 }

// 比较时间点
let comparison = compare(now, past) // 1 (now > past)

// 计算时间差
let time_diff = diff(now, past)
println("时间差: \{time_diff.seconds} 秒")
```

### 🌍 RFC 3339 格式支持
使用`to_rfc3339()`和`of_rfc3339()`方法处理标准时间格式。

```moonbit
// 解析 RFC 3339 时间字符串
match of_rfc3339("2023-09-15T08:30:00Z") {
  Ok(time) => {
    // 转换为 RFC 3339 格式
    let rfc3339_str = to_rfc3339(time)
    println("RFC 3339: \{rfc3339_str}")
  }
  Err(error) => println("解析错误: \{error}")
}

// 支持带时区偏移的格式
let time_with_offset = of_rfc3339("2023-09-15T08:30:00+08:00")
```

### 📅 多种时间格式
ptime 支持多种时间格式输出，满足不同场景需求。

```moonbit
let time = PTime::{ seconds: 1694764200, picoseconds: 0 }

// 标准格式
println("ISO 8601: \{to_iso8601(time)}")
println("RFC 3339: \{to_rfc3339(time)}")

// 人类可读格式
println("人类可读: \{to_human_readable(time)}")
println("详细格式: \{to_detailed_human_readable(time)}")
println("短格式: \{to_short_format(time)}")

// 专业格式
println("日志格式: \{to_log_format(time)}")
println("HTTP 日期: \{to_http_date(time)}")
println("JSON 时间: \{to_json_time(time)}")
println("SQL 日期时间: \{to_sql_datetime(time)}")

// 特殊格式
println("文件名安全: \{to_filename_safe(time)}")
println("12小时制: \{to_12_hour_format(time)}")
```

### ⏱️ 时间跨度操作
使用`Span`类型进行时间跨度计算和操作。

```moonbit
// 创建时间跨度
let now = PTime::{ seconds: 1694764200, picoseconds: 0 }
let span = Span::{ seconds: 3600, picoseconds: 500000000000 } // 1小时500毫秒

// 时间跨度运算
let doubled = mul_span(span, 2.0)
let half = div_span(span, 2)
let sum = add_spans(span, span)
let diff = sub_spans(span, span)

// 时间跨度格式化
println("人性化: \{humanize_span(span)}")
println("近似: \{approximate_span(span)}")
println("精确: \{precise_span(span)}")

// 时间点运算
let future_time = add_span(now, span)
let past_time = add_span(now, negate_span(span))
```

### 🔄 相对时间显示
使用`to_relative_time()`方法显示相对时间。

```moonbit
let now = PTime::{ seconds: 1694764200, picoseconds: 0 }
let past = PTime::{ seconds: 1694760000, picoseconds: 0 }

// 相对时间描述
let relative = to_relative_time(past, now)
println("相对时间: \{relative}") // "1小时前"
```

### 📊 时间戳转换
支持多种时间戳格式的转换。

```moonbit
let time = PTime::{ seconds: 1694764200, picoseconds: 500000000000 }

// 各种时间戳格式
println("Unix 时间戳: \{to_unix_timestamp(time)}")
println("毫秒时间戳: \{to_milliseconds_timestamp(time)}")
println("微秒时间戳: \{to_microseconds_timestamp(time)}")
println("纳秒时间戳: \{to_nanoseconds_timestamp(time)}")
```

### 🎨 自定义格式
使用`to_custom_format()`方法创建自定义时间格式。

```moonbit
let time = PTime::{ seconds: 1694764200, picoseconds: 0 }

// 自定义格式
let custom = to_custom_format(time, "%Y-%m-%d %H:%M:%S")
println("自定义格式: \{custom}") // "2023-09-15 08:30:00"
```

### 🔍 时间查询和验证
使用各种方法查询和验证时间信息。

```moonbit
let time = PTime::{ seconds: 1694764200, picoseconds: 0 }

// 转换为浮点数
let float_time = to_float(time)
println("浮点数时间: \{float_time}")

// 检查时间跨度是否为零
let zero_span = Span::{ seconds: 0, picoseconds: 0 }
let is_zero = is_zero(zero_span)
println("是否为零跨度: \{is_zero}") // true
```

### 🧠 泛型支持
ptime 支持任何实现了相应特性的类型，具有良好的类型安全性。

```moonbit
// 时间点可以与其他数值类型进行转换
let time = PTime::{ seconds: 1694764200, picoseconds: 0 }
let float_val = to_float(time)
let back_to_time = of_float(float_val)

// 时间跨度支持各种运算
let span1 = Span::{ seconds: 100, picoseconds: 0 }
let span2 = Span::{ seconds: 200, picoseconds: 0 }
let combined = add_spans(span1, span2)
```

## 📋 示例应用

### 简单的计时器
```moonbit
fn benchmark() {
  let start = now() // 获取当前时间
  
  // 执行一些操作
  // ...
  
  let end = now()
  let duration = diff(end, start)
  println("操作耗时: \{humanize_span(duration)}")
}
```

### 时间格式化工具
```moonbit
fn format_timestamp(timestamp: Double) -> String {
  let time = of_float(timestamp)
  to_custom_format(time, "%Y年%m月%d日 %H时%M分%S秒")
}
```

## 📚 API 参考

### 主要类型
- `PTime` - 表示一个时间点，包含秒和皮秒
- `Span` - 表示时间跨度，用于时间间隔计算

### 常用函数
- `now()` - 获取当前系统时间
- `epoch()` - 获取 Unix 纪元时间
- `of_float()` - 从浮点数创建时间点
- `to_float()` - 将时间点转换为浮点数
- `compare()` - 比较两个时间点
- `diff()` - 计算两个时间点的差值
- `add_span()` - 为时间点添加时间跨度

## 📜 许可证
本项目采用 Apache-2.0 许可证。详情请参见 LICENSE 文件。

## 🤝 贡献
欢迎提交 Issue 和 Pull Request！请确保代码符合项目的编码规范。

## 📢 联系与支持
• Moonbit 社区：moonbit-community  

⭐ 如果您喜欢这个项目，请给它一个星标！祝编码愉快！🎉