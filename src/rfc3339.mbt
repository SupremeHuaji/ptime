///|

///|
/// 将时间点格式化为 RFC 3339 字符串
pub fn to_rfc3339(pt : PTime) -> String {
  // 处理负时间戳的情况（1970年之前）
  if pt.seconds < 0 || (pt.seconds == 0 && pt.picoseconds < 0) {
    return format_pre_epoch_time(pt)
  }

  // 获取总天数和一天内的秒数
  let total_seconds = pt.seconds
  let day_seconds = total_seconds % 86400
  let days_since_epoch = total_seconds / 86400

  // 计算时分秒
  let hours = (day_seconds / 3600).to_int()
  let minutes = (day_seconds % 3600 / 60).to_int()
  let seconds = (day_seconds % 60).to_int()

  // 日期计算
  let date_components = calculate_date_from_days(days_since_epoch)
  let year = date_components.year
  let month = date_components.month
  let day = date_components.day

  // 格式化小数部分
  let fractional = format_fractional_seconds(pt.picoseconds)

  // 组合结果
  let date_part = format_with_padding(year, 4) +
    "-" +
    format_with_padding(month, 2) +
    "-" +
    format_with_padding(day, 2)
  let time_part = format_with_padding(hours, 2) +
    ":" +
    format_with_padding(minutes, 2) +
    ":" +
    format_with_padding(seconds, 2)
  let mut result = date_part + "T" + time_part
  if fractional != "" {
    result += "." + fractional
  }

  // 添加 UTC 标志
  result + "Z"
}

///|
/// 从 RFC 3339 字符串解析时间点
pub fn of_rfc3339(s : String) -> Result[PTime, PTimeError] {
  // 验证格式
  if !is_valid_rfc3339_format(s) {
    return Err(PTimeError::InvalidFormat("Invalid RFC 3339 format"))
  }

  // 解析年月日
  let year = parse_int(s.substring(start=0, end=4))
  let month = parse_int(s.substring(start=5, end=7))
  let day = parse_int(s.substring(start=8, end=10))

  // 验证日期
  if !is_valid_date(year, month, day) {
    return Err(PTimeError::InvalidDate("Invalid date values"))
  }

  // 解析时分秒
  let hour = parse_int(s.substring(start=11, end=13))
  let minute = parse_int(s.substring(start=14, end=16))
  let second = parse_int(s.substring(start=17, end=19))

  // 验证时间
  if hour >= 24 || minute >= 60 || second >= 60 {
    return Err(PTimeError::InvalidTime("Invalid time values"))
  }

  // 解析小数秒（如果有）
  let mut picoseconds : Int64 = 0
  let mut pos = 19
  if pos < s.length() && s[pos] == '.' {
    pos += 1
    let frac_start = pos

    // 找到小数部分的结束位置
    while pos < s.length() && is_digit(s[pos]) {
      pos += 1
    }
    let frac_str = s.substring(start=frac_start, end=pos)
    picoseconds = parse_fractional_seconds(frac_str)
  }

  // 处理时区
  let mut tz_offset_seconds = 0
  if pos < s.length() {
    if s[pos] == 'Z' || s[pos] == 'z' {
      // UTC 时区，偏移为 0
      tz_offset_seconds = 0
    } else if s[pos] == '+' || s[pos] == '-' {
      // 解析 ±HH:MM 格式的时区偏移
      let sign = if s[pos] == '+' { 1 } else { -1 }
      let tz_hour = parse_int(s.substring(start=pos + 1, end=pos + 3))
      let tz_minute = parse_int(s.substring(start=pos + 4, end=pos + 6))
      tz_offset_seconds = sign * (tz_hour * 3600 + tz_minute * 60)
    }
  }

  // 计算从 1970-01-01 开始的秒数
  let seconds = calculate_seconds_from_date(
    year, month, day, hour, minute, second,
  )

  // 应用时区偏移
  let adjusted_seconds = seconds - tz_offset_seconds.to_int64()
  Ok(PTime::{ seconds: adjusted_seconds, picoseconds })
}

///|
/// 计算日期对应的天数（从 1970-01-01 开始）
fn calculate_days_from_date(year : Int, month : Int, day : Int) -> Int64 {
  // 计算从 1970-01-01 到指定日期的天数

  // 先计算年份贡献的天数
  let mut days : Int64 = 0

  // 计算整年的贡献
  if year >= 1970 {
    // 1970年之后
    for y in 1970..<year {
      days += if is_leap_year(y) { 366 } else { 365 }
    }
  } else {
    // 1970年之前（需要反向计算）
    for y in year..<1970 {
      days -= if is_leap_year(y) { 366 } else { 365 }
    }
  }

  // 加上当年过去月份的天数
  let month_days = get_days_in_months(is_leap_year(year))
  for m in 1..<month {
    days += month_days[m - 1].to_int64()
  }

  // 加上当月的天数
  days += (day - 1).to_int64()
  days
}

///|
/// 计算从 1970-01-01 00:00:00 到指定日期时间的秒数
fn calculate_seconds_from_date(
  year : Int,
  month : Int,
  day : Int,
  hour : Int,
  minute : Int,
  second : Int,
) -> Int64 {
  let days = calculate_days_from_date(year, month, day)
  let seconds_in_day = hour * 3600 + minute * 60 + second
  days * 86400 + seconds_in_day.to_int64()
}

///|
/// 从天数（自 1970-01-01 起）计算日期
fn calculate_date_from_days(days_since_epoch : Int64) -> DateComponents {
  let mut year = 1970
  let mut remaining_days = days_since_epoch

  // 处理负天数（1970年之前）
  if remaining_days < 0 {
    let mut days = -remaining_days
    year = 1969
    while days > 0 {
      let days_in_year = if is_leap_year(year) { 366 } else { 365 }
      if days < days_in_year.to_int64() {
        days = days_in_year.to_int64() - days
        break
      }
      days -= days_in_year.to_int64()
      year -= 1
    }
    remaining_days = days
  } else {
    // 处理正天数（1970年之后）
    while true {
      let days_in_year = if is_leap_year(year) { 366 } else { 365 }
      if remaining_days < days_in_year.to_int64() {
        break
      }
      remaining_days -= days_in_year.to_int64()
      year += 1
    }
  }

  // 计算月份和日
  let month_days = get_days_in_months(is_leap_year(year))
  let mut month = 1
  while month <= 12 {
    if remaining_days < month_days[month - 1].to_int64() {
      break
    }
    remaining_days -= month_days[month - 1].to_int64()
    month += 1
  }
  let day = remaining_days.to_int() + 1
  { year, month, day }
}

///|
/// 处理1970年之前的日期（负时间戳）
fn format_pre_epoch_time(pt : PTime) -> String {
  // 使用一般化的日期计算函数处理
  let total_seconds = pt.seconds
  let day_seconds = -total_seconds % 86400

  // 计算反向时间
  let time_seconds = if day_seconds == 0 {
    0
  } else {
    86400 - day_seconds.to_int()
  }
  let hours = time_seconds / 3600
  let minutes = time_seconds % 3600 / 60
  let seconds = time_seconds % 60

  // 计算日期（使用通用计算函数）
  let days = if day_seconds == 0 {
    pt.seconds / 86400
  } else {
    pt.seconds / 86400 - 1
  }
  let date = calculate_date_from_days(days)

  // 处理皮秒部分
  let fractional = format_fractional_seconds(pt.picoseconds)

  // 格式化结果
  let date_part = format_with_padding(date.year, 4) +
    "-" +
    format_with_padding(date.month, 2) +
    "-" +
    format_with_padding(date.day, 2)
  let time_part = format_with_padding(hours, 2) +
    ":" +
    format_with_padding(minutes, 2) +
    ":" +
    format_with_padding(seconds, 2)
  let mut result = date_part + "T" + time_part
  if fractional != "" {
    result += "." + fractional
  }
  result + "Z"
}

///|
/// 判断是否为闰年（更精确的实现）
fn is_leap_year(year : Int) -> Bool {
  (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}

///|
/// 获取每个月的天数
fn get_days_in_months(leap_year : Bool) -> Array[Int] {
  if leap_year {
    [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  } else {
    [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  }
}

///|
/// 验证日期是否有效
fn is_valid_date(year : Int, month : Int, day : Int) -> Bool {
  if month < 1 || month > 12 {
    return false
  }
  let month_days = get_days_in_months(is_leap_year(year))
  if day < 1 || day > month_days[month - 1] {
    return false
  }
  true
}

///|
/// 解析小数秒并转换为皮秒
fn parse_fractional_seconds(frac_str : String) -> Int64 {
  let mut result : Int64 = 0
  let mut multiplier : Int64 = 1_000_000_000_000 // 皮秒
  for i in 0..<frac_str.length() {
    if i >= 12 { // 最多精确到皮秒
      break
    }
    let digit : Int64 = (frac_str[i] - '0').to_int64()
    multiplier = multiplier / 10
    result += digit * multiplier
  }
  result
}

///|
/// 格式化皮秒为小数秒字符串
fn format_fractional_seconds(picoseconds : Int64) -> String {
  if picoseconds == 0 {
    return ""
  }

  // 保证正数处理
  let picos = if picoseconds < 0 { -picoseconds } else { picoseconds }

  // 转换为字符串并保证12位
  let mut picos_str = picos.to_string()
  while picos_str.length() < 12 {
    picos_str = "0" + picos_str
  }

  // 移除末尾的0
  while picos_str.length() > 0 && picos_str[picos_str.length() - 1] == '0' {
    picos_str = picos_str.substring(start=0, end=picos_str.length() - 1)
  }
  picos_str
}

///|
/// 解析整数，处理前导零
fn parse_int(s : String) -> Int {
  // 简单解析数字
  let mut result = 0
  for i in 0..<s.length() {
    if s[i] >= '0' && s[i] <= '9' {
      result = result * 10 + (s[i] - '0')
    }
  }
  result
}

///|
/// 检查字符串是否为有效的 RFC 3339 格式
fn is_valid_rfc3339_format(s : String) -> Bool {
  // 基本长度检查
  if s.length() < 20 {
    return false
  }

  // 检查日期部分 (YYYY-MM-DD)
  if !is_digit(s[0]) ||
    !is_digit(s[1]) ||
    !is_digit(s[2]) ||
    !is_digit(s[3]) ||
    s[4] != '-' ||
    !is_digit(s[5]) ||
    !is_digit(s[6]) ||
    s[7] != '-' ||
    !is_digit(s[8]) ||
    !is_digit(s[9]) {
    return false
  }

  // 检查 T 分隔符
  if s[10] != 'T' && s[10] != 't' {
    return false
  }

  // 检查时间部分 (hh:mm:ss)
  if !is_digit(s[11]) ||
    !is_digit(s[12]) ||
    s[13] != ':' ||
    !is_digit(s[14]) ||
    !is_digit(s[15]) ||
    s[16] != ':' ||
    !is_digit(s[17]) ||
    !is_digit(s[18]) {
    return false
  }

  // 检查时区部分
  let mut pos = 19

  // 检查小数点部分 (可选)
  if pos < s.length() && s[pos] == '.' {
    pos += 1
    // 至少需要一位小数
    if pos >= s.length() || !is_digit(s[pos]) {
      return false
    }

    // 跳过所有小数位
    while pos < s.length() && is_digit(s[pos]) {
      pos += 1
    }
  }

  // 现在处理时区部分
  if pos >= s.length() {
    return false
  }

  // 检查 Z (UTC) 或时区偏移
  if s[pos] == 'Z' || s[pos] == 'z' {
    // 确保Z是最后一个字符
    return pos == s.length() - 1
  } else if s[pos] == '+' || s[pos] == '-' {
    // 检查时区偏移 ±hh:mm
    if pos + 6 > s.length() {
      return false
    }
    return is_digit(s[pos + 1]) &&
      is_digit(s[pos + 2]) &&
      s[pos + 3] == ':' &&
      is_digit(s[pos + 4]) &&
      is_digit(s[pos + 5]) &&
      pos + 5 == s.length() - 1
  }
  false
}

///|
/// 检查字符是否为数字
fn is_digit(c : Int) -> Bool {
  c >= '0' && c <= '9'
}

///|
/// 格式化数字，保证指定的位数（左侧补0）
fn format_with_padding(num : Int, width : Int) -> String {
  let str = num.to_string()
  let mut result = str
  let padding_needed = width - str.length()
  for _ in 0..<padding_needed {
    result = "0" + result
  }
  result
}
