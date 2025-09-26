///|
/// 时间格式化扩展功能
/// 提供多种时间格式的转换和人性化显示

// 导入必要的函数

///|
/// 将时间点转换为 ISO 8601 格式字符串
/// 格式：YYYY-MM-DDTHH:mm:ss.sssZ
pub fn to_iso8601(pt : PTime) -> String {
  to_rfc3339(pt) // RFC3339 是 ISO 8601 的子集
}

///|
/// 将时间点转换为 Unix 时间戳（秒）
pub fn to_unix_timestamp(pt : PTime) -> Int64 {
  pt.seconds
}

///|
/// 将时间点转换为毫秒时间戳
pub fn to_milliseconds_timestamp(pt : PTime) -> Int64 {
  pt.seconds * 1000 + pt.picoseconds / 1_000_000_000
}

///|
/// 将时间点转换为微秒时间戳
pub fn to_microseconds_timestamp(pt : PTime) -> Int64 {
  pt.seconds * 1_000_000 + pt.picoseconds / 1_000_000
}

///|
/// 将时间点转换为纳秒时间戳
pub fn to_nanoseconds_timestamp(pt : PTime) -> Int64 {
  pt.seconds * 1_000_000_000 + pt.picoseconds / 1000
}

///|
/// 将时间点转换为人类可读格式
/// 格式：YYYY-MM-DD HH:mm:ss
pub fn to_human_readable(pt : PTime) -> String {
  let rfc3339_str = to_rfc3339(pt)
  // 将 RFC3339 格式中的 'T' 替换为空格，去掉 'Z'
  let mut result = rfc3339_str.replace(old="T", new=" ")
  if result.has_suffix("Z") {
    result = result.unsafe_substring(start=0, end=result.length() - 1)
  }
  result
}

///|
/// 将时间点转换为详细的人类可读格式
/// 格式：2023年9月15日 08:30:00
pub fn to_detailed_human_readable(pt : PTime) -> String {
  let date_components = calculate_date_from_days(pt.seconds / 86400)
  let day_seconds = pt.seconds % 86400
  let hours = (day_seconds / 3600).to_int()
  let minutes = (day_seconds % 3600 / 60).to_int()
  let seconds = (day_seconds % 60).to_int()
  let month_names = [
    "", "1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月",
    "11月", "12月",
  ]
  let year = date_components.year
  let month = month_names[date_components.month]
  let day = date_components.day
  format_with_padding(hours, 2) +
  ":" +
  format_with_padding(minutes, 2) +
  ":" +
  format_with_padding(seconds, 2) +
  " " +
  year.to_string() +
  "年" +
  month +
  day.to_string() +
  "日"
}

///|
/// 将时间点转换为相对时间描述
/// 例如："2小时前", "3天后", "刚刚"
pub fn to_relative_time(pt : PTime, now : PTime) -> String {
  let diff_span = diff(now, pt)
  let total_seconds = diff_span.seconds.to_int()
  if total_seconds == 0 {
    return "刚刚"
  }
  let abs_seconds = if total_seconds < 0 {
    -total_seconds
  } else {
    total_seconds
  }
  let is_future = total_seconds < 0
  if abs_seconds < 60 {
    let suffix = if is_future { "后" } else { "前" }
    return abs_seconds.to_string() + "秒" + suffix
  } else if abs_seconds < 3600 {
    let minutes = abs_seconds / 60
    let suffix = if is_future { "后" } else { "前" }
    return minutes.to_string() + "分钟" + suffix
  } else if abs_seconds < 86400 {
    let hours = abs_seconds / 3600
    let suffix = if is_future { "后" } else { "前" }
    return hours.to_string() + "小时" + suffix
  } else if abs_seconds < 2592000 { // 30天
    let days = abs_seconds / 86400
    let suffix = if is_future { "后" } else { "前" }
    return days.to_string() + "天" + suffix
  } else if abs_seconds < 31536000 { // 365天
    let months = abs_seconds / 2592000
    let suffix = if is_future { "后" } else { "前" }
    return months.to_string() + "个月" + suffix
  } else {
    let years = abs_seconds / 31536000
    let suffix = if is_future { "后" } else { "前" }
    return years.to_string() + "年" + suffix
  }
}

///|
/// 将时间点转换为简短格式
/// 格式：09/15/23 08:30
pub fn to_short_format(pt : PTime) -> String {
  let date_components = calculate_date_from_days(pt.seconds / 86400)
  let day_seconds = pt.seconds % 86400
  let hours = (day_seconds / 3600).to_int()
  let minutes = (day_seconds % 3600 / 60).to_int()
  let year_short = date_components.year % 100
  let month = date_components.month
  let day = date_components.day
  format_with_padding(month, 2) +
  "/" +
  format_with_padding(day, 2) +
  "/" +
  format_with_padding(year_short, 2) +
  " " +
  format_with_padding(hours, 2) +
  ":" +
  format_with_padding(minutes, 2)
}

///|
/// 将时间点转换为日志格式
/// 格式：2023-09-15 08:30:00.123
pub fn to_log_format(pt : PTime) -> String {
  let human_readable = to_human_readable(pt)
  let fractional = format_fractional_seconds(pt.picoseconds)
  if fractional != "" {
    // 只保留前3位小数（毫秒）
    let millis = if fractional.length() >= 3 {
      fractional.unsafe_substring(start=0, end=3)
    } else {
      fractional
    }
    human_readable + "." + millis
  } else {
    human_readable + ".000"
  }
}

///|
/// 将时间点转换为文件名安全格式
/// 格式：20230915_083000
pub fn to_filename_safe(pt : PTime) -> String {
  let date_components = calculate_date_from_days(pt.seconds / 86400)
  let day_seconds = pt.seconds % 86400
  let hours = (day_seconds / 3600).to_int()
  let minutes = (day_seconds % 3600 / 60).to_int()
  let seconds = (day_seconds % 60).to_int()
  let year = date_components.year
  let month = date_components.month
  let day = date_components.day
  format_with_padding(year, 4) +
  format_with_padding(month, 2) +
  format_with_padding(day, 2) +
  "_" +
  format_with_padding(hours, 2) +
  format_with_padding(minutes, 2) +
  format_with_padding(seconds, 2)
}

///|
/// 将时间点转换为12小时制格式
/// 格式：2023-09-15 08:30:00 AM
pub fn to_12_hour_format(pt : PTime) -> String {
  let date_components = calculate_date_from_days(pt.seconds / 86400)
  let day_seconds = pt.seconds % 86400
  let mut hours = (day_seconds / 3600).to_int()
  let minutes = (day_seconds % 3600 / 60).to_int()
  let seconds = (day_seconds % 60).to_int()
  let period = if hours >= 12 { "PM" } else { "AM" }
  if hours > 12 {
    hours -= 12
  } else if hours == 0 {
    hours = 12
  }
  let year = date_components.year
  let month = date_components.month
  let day = date_components.day
  format_with_padding(year, 4) +
  "-" +
  format_with_padding(month, 2) +
  "-" +
  format_with_padding(day, 2) +
  " " +
  format_with_padding(hours, 2) +
  ":" +
  format_with_padding(minutes, 2) +
  ":" +
  format_with_padding(seconds, 2) +
  " " +
  period
}

///|
/// 将时间点转换为HTTP日期格式
/// 格式：Fri, 15 Sep 2023 08:30:00 GMT
pub fn to_http_date(pt : PTime) -> String {
  let date_components = calculate_date_from_days(pt.seconds / 86400)
  let day_seconds = pt.seconds % 86400
  let hours = (day_seconds / 3600).to_int()
  let minutes = (day_seconds % 3600 / 60).to_int()
  let seconds = (day_seconds % 60).to_int()
  let year = date_components.year
  let month = date_components.month
  let day = date_components.day
  let month_names = [
    "", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov",
    "Dec",
  ]
  let day_names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

  // 计算星期几（简化实现）
  let weekday = calculate_weekday(year, month, day)
  let month_name = month_names[month]
  let day_name = day_names[weekday]
  day_name +
  ", " +
  format_with_padding(day, 2) +
  " " +
  month_name +
  " " +
  year.to_string() +
  " " +
  format_with_padding(hours, 2) +
  ":" +
  format_with_padding(minutes, 2) +
  ":" +
  format_with_padding(seconds, 2) +
  " GMT"
}

///|
/// 计算星期几（0=Sunday, 1=Monday, ..., 6=Saturday）
/// 使用Zeller公式的简化版本
fn calculate_weekday(year : Int, month : Int, day : Int) -> Int {
  let mut y = year
  let mut m = month
  if m < 3 {
    m += 12
    y -= 1
  }
  let c = y / 100
  let yy = y % 100
  let w = (day + 13 * (m + 1) / 5 + yy + yy / 4 + c / 4 - 2 * c) % 7
  if w < 0 {
    w + 7
  } else {
    w
  }
}

///|
/// 将时间点转换为SQL日期时间格式
/// 格式：2023-09-15 08:30:00
pub fn to_sql_datetime(pt : PTime) -> String {
  to_human_readable(pt)
}

///|
/// 将时间点转换为JSON时间格式
/// 格式：2023-09-15T08:30:00.000Z
pub fn to_json_time(pt : PTime) -> String {
  let rfc3339_str = to_rfc3339(pt)
  // 确保有毫秒部分
  if !rfc3339_str.contains(".") {
    rfc3339_str.replace(old="Z", new=".000Z")
  } else {
    rfc3339_str
  }
}

///|
/// 将时间点转换为自定义格式
/// 支持格式占位符：%Y=年, %m=月, %d=日, %H=时, %M=分, %S=秒
pub fn to_custom_format(pt : PTime, format : String) -> String {
  let date_components = calculate_date_from_days(pt.seconds / 86400)
  let day_seconds = pt.seconds % 86400
  let hours = (day_seconds / 3600).to_int()
  let minutes = (day_seconds % 3600 / 60).to_int()
  let seconds = (day_seconds % 60).to_int()
  let year = date_components.year
  let month = date_components.month
  let day = date_components.day
  let mut result = format
  result = result.replace(old="%Y", new=year.to_string())
  result = result.replace(old="%m", new=format_with_padding(month, 2))
  result = result.replace(old="%d", new=format_with_padding(day, 2))
  result = result.replace(old="%H", new=format_with_padding(hours, 2))
  result = result.replace(old="%M", new=format_with_padding(minutes, 2))
  result = result.replace(old="%S", new=format_with_padding(seconds, 2))
  result
}

///|
/// 格式化时间跨度为人性化描述
/// 例如："2小时30分钟", "3天5小时"
pub fn humanize_span(span : Span) -> String {
  let total_seconds = span.seconds.to_int()
  let abs_seconds = if total_seconds < 0 {
    -total_seconds
  } else {
    total_seconds
  }
  if abs_seconds == 0 {
    return "0秒"
  }
  let years = abs_seconds / 31536000
  let months = abs_seconds % 31536000 / 2592000
  let days = abs_seconds % 2592000 / 86400
  let hours = abs_seconds % 86400 / 3600
  let minutes = abs_seconds % 3600 / 60
  let secs = abs_seconds % 60
  let parts : Array[String] = []
  if years > 0 {
    parts.push(years.to_string() + "年")
  }
  if months > 0 {
    parts.push(months.to_string() + "个月")
  }
  if days > 0 {
    parts.push(days.to_string() + "天")
  }
  if hours > 0 {
    parts.push(hours.to_string() + "小时")
  }
  if minutes > 0 {
    parts.push(minutes.to_string() + "分钟")
  }
  if secs > 0 {
    parts.push(secs.to_string() + "秒")
  }
  if parts.length() == 0 {
    return "0秒"
  }

  // 最多显示3个部分
  let display_parts = if parts.length() > 3 {
    let result : Array[String] = []
    for i in 0..<3 {
      result.push(parts[i])
    }
    result
  } else {
    parts
  }
  let mut result = ""
  for i in 0..<display_parts.length() {
    if i > 0 {
      result += ""
    }
    result += display_parts[i]
  }
  if total_seconds < 0 {
    "-" + result
  } else {
    result
  }
}

///|
/// 格式化时间跨度为近似描述
/// 例如："约3小时", "大约2天"
pub fn approximate_span(span : Span) -> String {
  let total_seconds = span.seconds.to_int()
  let abs_seconds = if total_seconds < 0 {
    -total_seconds
  } else {
    total_seconds
  }
  if abs_seconds < 60 {
    return "不到1分钟"
  } else if abs_seconds < 3600 {
    let minutes = (abs_seconds + 30) / 60
    return "约" + minutes.to_string() + "分钟"
  } else if abs_seconds < 86400 {
    let hours = (abs_seconds + 1800) / 3600
    return "约" + hours.to_string() + "小时"
  } else if abs_seconds < 2592000 {
    let days = (abs_seconds + 43200) / 86400
    return "约" + days.to_string() + "天"
  } else if abs_seconds < 31536000 {
    let months = (abs_seconds + 1296000) / 2592000
    return "约" + months.to_string() + "个月"
  } else {
    let years = (abs_seconds + 15768000) / 31536000
    return "约" + years.to_string() + "年"
  }
}

///|
/// 格式化时间跨度为精确描述
/// 例如："2h 30m 45s 123ms"
pub fn precise_span(span : Span) -> String {
  let total_seconds = span.seconds.to_int()
  let abs_seconds = if total_seconds < 0 {
    -total_seconds
  } else {
    total_seconds
  }
  let hours = abs_seconds / 3600
  let minutes = abs_seconds % 3600 / 60
  let secs = abs_seconds % 60
  let milliseconds = (span.picoseconds / 1_000_000_000).to_int()
  let parts : Array[String] = []
  if hours > 0 {
    parts.push(hours.to_string() + "h")
  }
  if minutes > 0 {
    parts.push(minutes.to_string() + "m")
  }
  if secs > 0 {
    parts.push(secs.to_string() + "s")
  }
  if milliseconds > 0 {
    parts.push(milliseconds.to_string() + "ms")
  }

  // 如果没有任何部分，检查是否有皮秒
  if parts.length() == 0 {
    if span.picoseconds > 0 {
      // 有皮秒但没有毫秒，显示微秒或纳秒
      let microseconds = (span.picoseconds / 1_000_000).to_int()
      if microseconds > 0 {
        return microseconds.to_string() + "μs"
      } else {
        let nanoseconds = (span.picoseconds / 1000).to_int()
        if nanoseconds > 0 {
          return nanoseconds.to_string() + "ns"
        } else {
          return "0s"
        }
      }
    } else {
      return "0s"
    }
  }
  let mut result = ""
  for i in 0..<parts.length() {
    if i > 0 {
      result += " "
    }
    result += parts[i]
  }
  if total_seconds < 0 {
    "-" + result
  } else {
    result
  }
}
