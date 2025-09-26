# ptime

[English](https://github.com/SupremeHuaji/ptime/blob/main/README.md) | [简体中文](https://github.com/SupremeHuaji/ptime/blob/main/README_zh_CN.md)

ptime is a lightweight time library designed for MoonBit, providing picosecond-level precision time processing capabilities. It supports multiple time format conversions, time calculations, and human-readable time displays, making it an ideal choice for handling time-related tasks.

## ✨ Key Features
• ⏱️ **Picosecond Precision** - Supports precise time calculations for nanoseconds, microseconds, milliseconds, and seconds  
• 🌍 **RFC 3339 Support** - Complete ISO 8601 / RFC 3339 time format parsing and generation  
• 📅 **Multiple Time Formats** - Supports human-readable, log, HTTP date, and various other formats  
• ⚡ **High Performance** - Pure MoonBit implementation with no external dependencies  
• 🎯 **Easy to Use** - Clean API design with support for chainable operations  
• 🛡️ **Type Safety** - Comprehensive error handling and type checking  
• 🔄 **Time Span Operations** - Supports time addition, subtraction, comparison, formatting, and more  

## 📥 Installation
```bash
moon add SupremeHuaji/ptime
```

## 🚀 Usage Guide

### 🕐 Creating Time Points
You can create time points using `epoch()`, `of_float()`, or direct construction.

```moonbit
// Create Unix epoch time (1970-01-01 00:00:00 UTC)
let epoch_time = epoch()

// Create time point from float
let time_from_float = of_float(1694764200.5)

// Directly construct time point
let custom_time = PTime::{ seconds: 1694764200, picoseconds: 500000000000 }
```

### ⏰ Time Comparison and Calculation
Use `compare()` and `diff()` methods for time comparison and calculation.

```moonbit
let now = PTime::{ seconds: 1694764200, picoseconds: 0 }
let past = PTime::{ seconds: 1694760000, picoseconds: 0 }

// Compare time points
let comparison = compare(now, past) // 1 (now > past)

// Calculate time difference
let time_diff = diff(now, past)
println("Time difference: \{time_diff.seconds} seconds")
```

### 🌍 RFC 3339 Format Support
Use `to_rfc3339()` and `of_rfc3339()` methods to handle standard time formats.

```moonbit
// Parse RFC 3339 time string
match of_rfc3339("2023-09-15T08:30:00Z") {
  Ok(time) => {
    // Convert to RFC 3339 format
    let rfc3339_str = to_rfc3339(time)
    println("RFC 3339: \{rfc3339_str}")
  }
  Err(error) => println("Parse error: \{error}")
}

// Support formats with timezone offsets
let time_with_offset = of_rfc3339("2023-09-15T08:30:00+08:00")
```

### 📅 Multiple Time Formats
ptime supports multiple time format outputs for different scenarios.

```moonbit
let time = PTime::{ seconds: 1694764200, picoseconds: 0 }

// Standard formats
println("ISO 8601: \{to_iso8601(time)}")
println("RFC 3339: \{to_rfc3339(time)}")

// Human-readable formats
println("Human readable: \{to_human_readable(time)}")
println("Detailed format: \{to_detailed_human_readable(time)}")
println("Short format: \{to_short_format(time)}")

// Professional formats
println("Log format: \{to_log_format(time)}")
println("HTTP date: \{to_http_date(time)}")
println("JSON time: \{to_json_time(time)}")
println("SQL datetime: \{to_sql_datetime(time)}")

// Special formats
println("Filename safe: \{to_filename_safe(time)}")
println("12-hour format: \{to_12_hour_format(time)}")
```

### ⏱️ Time Span Operations
Use the `Span` type for time span calculations and operations.

```moonbit
// Create time span
let now = PTime::{ seconds: 1694764200, picoseconds: 0 }
let span = Span::{ seconds: 3600, picoseconds: 500000000000 } // 1 hour 500 milliseconds

// Time span operations
let doubled = mul_span(span, 2.0)
let half = div_span(span, 2)
let sum = add_spans(span, span)
let diff = sub_spans(span, span)

// Time span formatting
println("Humanized: \{humanize_span(span)}")
println("Approximate: \{approximate_span(span)}")
println("Precise: \{precise_span(span)}")

// Time point operations
let future_time = add_span(now, span)
let past_time = add_span(now, negate_span(span))
```

### 🔄 Relative Time Display
Use the `to_relative_time()` method to display relative time.

```moonbit
let now = PTime::{ seconds: 1694764200, picoseconds: 0 }
let past = PTime::{ seconds: 1694760000, picoseconds: 0 }

// Relative time description
let relative = to_relative_time(past, now)
println("Relative time: \{relative}") // "1 hour ago"
```

### 📊 Timestamp Conversion
Supports conversion between various timestamp formats.

```moonbit
let time = PTime::{ seconds: 1694764200, picoseconds: 500000000000 }

// Various timestamp formats
println("Unix timestamp: \{to_unix_timestamp(time)}")
println("Milliseconds timestamp: \{to_milliseconds_timestamp(time)}")
println("Microseconds timestamp: \{to_microseconds_timestamp(time)}")
println("Nanoseconds timestamp: \{to_nanoseconds_timestamp(time)}")
```

### 🎨 Custom Formatting
Use the `to_custom_format()` method to create custom time formats.

```moonbit
let time = PTime::{ seconds: 1694764200, picoseconds: 0 }

// Custom format
let custom = to_custom_format(time, "%Y-%m-%d %H:%M:%S")
println("Custom format: \{custom}") // "2023-09-15 08:30:00"
```

### 🔍 Time Query and Validation
Use various methods to query and validate time information.

```moonbit
let time = PTime::{ seconds: 1694764200, picoseconds: 0 }

// Convert to float
let float_time = to_float(time)
println("Float time: \{float_time}")

// Check if time span is zero
let zero_span = Span::{ seconds: 0, picoseconds: 0 }
let is_zero = is_zero(zero_span)
println("Is zero span: \{is_zero}") // true
```

### 🧠 Generic Support
ptime supports any type that implements the corresponding traits, providing good type safety.

```moonbit
// Time points can be converted to other numeric types
let time = PTime::{ seconds: 1694764200, picoseconds: 0 }
let float_val = to_float(time)
let back_to_time = of_float(float_val)

// Time spans support various operations
let span1 = Span::{ seconds: 100, picoseconds: 0 }
let span2 = Span::{ seconds: 200, picoseconds: 0 }
let combined = add_spans(span1, span2)
```

## 📋 Example Applications

### Simple Timer
```moonbit
fn benchmark() {
  let start = now() // Get current time
  
  // Perform some operations
  // ...
  
  let end = now()
  let duration = diff(end, start)
  println("Operation took: \{humanize_span(duration)}")
}
```

### Time Formatting Tool
```moonbit
fn format_timestamp(timestamp: Double) -> String {
  let time = of_float(timestamp)
  to_custom_format(time, "%Y-%m-%d %H:%M:%S")
}
```

## 📚 API Reference

### Main Types
- `PTime` - Represents a point in time, containing seconds and picoseconds
- `Span` - Represents a time span, used for time interval calculations

### Common Functions
- `now()` - Get current system time
- `epoch()` - Get Unix epoch time
- `of_float()` - Create time point from float
- `to_float()` - Convert time point to float
- `compare()` - Compare two time points
- `diff()` - Calculate difference between two time points
- `add_span()` - Add time span to time point

## 📜 License
This project is licensed under the Apache-2.0 License. See the LICENSE file for details.

## 🤝 Contributing
Issues and Pull Requests are welcome! Please ensure your code follows the project's coding standards.

## 📢 Contact & Support
• Moonbit Community: moonbit-community  


⭐ If you like this project, please give it a star! Happy coding! 🎉