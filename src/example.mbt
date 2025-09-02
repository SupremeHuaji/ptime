///|
/// 测试解析 RFC 3339 时间字符串并计算与模拟当前时间的差
test "parse RFC 3339 and calculate difference from simulated now" {
  // 使用固定时间点模拟"当前时间" (2023-09-15T08:30:00Z)
  // 自 1970-01-01 00:00:00Z 起的秒数: 1694764200
  let now_time = PTime::{ seconds: 1694764200, picoseconds: 0 }

  // 1. 解析一个固定的 RFC 3339 时间字符串
  let time_str = "2023-01-01T12:00:00Z"
  match of_rfc3339(time_str) {
    Ok(parsed_time) => {
      // 2. 计算时间差（当前时间 - 解析时间）
      let time_diff = diff(now_time, parsed_time)

      // 3. 验证时间差的有效性
      // 2023-09-15 肯定在 2023-01-01 之后，差值应为正
      assert_true(time_diff.seconds > 0)

      // 4. 将差值转换为天数（近似值）
      let days_diff = time_diff.seconds / 86400

      // 5. 输出结果
      println("Parsed time: \{time_str}")
      println("Simulated current time: \{to_rfc3339(now_time)}")
      println("Time difference: \{time_diff.seconds} seconds")
      println("Approximately \{days_diff} days difference")

      // 6. 测试时间比较功能
      let comparison = compare(now_time, parsed_time)
      assert_eq(comparison, 1)

      // 7. 验证具体的差值（2023-09-15 与 2023-01-01 的差值应约为 257 天）
      // 257天 ≈ 22,204,800 秒
      let expected_diff_approx = 22_204_800
      let actual_diff = time_diff.seconds.to_int()
      // 允许1天的误差（因为具体小时可能导致差异）
      assert_true(
        actual_diff > expected_diff_approx - 86400 &&
        actual_diff < expected_diff_approx + 86400,
      )
    }
    Err(e) =>
      // 8. 处理解析错误

      fail("Failed to parse RFC 3339 time string:\{e}")
  }
}

///|
/// 测试未来时间与模拟当前时间的差值
test "calculate difference with future time" {
  // 使用固定时间点模拟"当前时间" (2023-09-15T08:30:00Z)
  let now_time = PTime::{ seconds: 1694764200, picoseconds: 0 }

  // 1. 创建一个未来时间点（当前时间 + 30天）
  let thirty_days_in_seconds = 30 * 24 * 60 * 60
  let future_span = Span::{
    seconds: thirty_days_in_seconds.to_int64(),
    picoseconds: 0,
  }
  let future_time = add_span(now_time, future_span)

  // 2. 计算时间差（未来时间 - 当前时间）
  let time_diff = diff(future_time, now_time)

  // 3. 验证差值
  assert_eq(time_diff.seconds, thirty_days_in_seconds.to_int64())

  // 4. 将未来时间格式化为 RFC 3339 (应为 2023-10-15T08:30:00Z)
  let future_str = to_rfc3339(future_time)
  println("Simulated current time: \{to_rfc3339(now_time)}")
  println("Future time: \{future_str}")
  println("Time difference: \{time_diff.seconds} seconds (30 days)")

  // 5. 验证格式化结果
  assert_true(future_str.contains("2023-10-15"))
}
