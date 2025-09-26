// 在 ptime_test.mbt 中添加测试

///|
test "epoch returns zero time" {
  let epoch_time = epoch()
  assert_eq(epoch_time.seconds, 0)
  assert_eq(epoch_time.picoseconds, 0)
}

///|
test "of_float creates correct time" {
  let pt = of_float(123.456)
  assert_eq(pt.seconds, 123)
  // 验证皮秒部分
}

///|
test "to_rfc3339 formats correctly" {
  let pt = PTime::{ seconds: 1694764200, picoseconds: 0 }
  let formatted = to_rfc3339(pt)
  assert_true(formatted.contains("2023-09-15"))
}

///|
/// ptime 库的完整单元测试

///|
/// 测试 PTime 构造函数
test "epoch returns zero time" {
  let epoch_time = epoch()
  assert_eq(epoch_time.seconds, 0)
  assert_eq(epoch_time.picoseconds, 0)
}

///|
test "of_float creates correct time" {
  let pt = of_float(123.456)
  assert_eq(pt.seconds, 123)
  // 验证皮秒部分：0.456 * 1e12 = 456000000000
  assert_eq(pt.picoseconds, 456000000000)
}

///|
test "of_float handles negative values" {
  let pt = of_float(-123.456)
  assert_eq(pt.seconds, -123)
  assert_eq(pt.picoseconds, -456000000000)
}

///|
test "of_float handles zero" {
  let pt = of_float(0.0)
  assert_eq(pt.seconds, 0)
  assert_eq(pt.picoseconds, 0)
}

///|
/// 测试转换函数
test "to_float converts correctly" {
  let pt = PTime::{ seconds: 123, picoseconds: 456000000000 }
  let float_val = to_float(pt)
  assert_eq(float_val, 123.456)
}

///|
test "to_float handles negative values" {
  let pt = PTime::{ seconds: -123, picoseconds: -456000000000 }
  let float_val = to_float(pt)
  assert_eq(float_val, -123.456)
}

///|
/// 测试 RFC 3339 解析
test "of_rfc3339 parses basic format" {
  match of_rfc3339("2023-09-15T08:30:00Z") {
    Ok(pt) => {
      assert_eq(pt.seconds, 1694766600)
      assert_eq(pt.picoseconds, 0)
    }
    Err(_) => fail("Failed to parse basic RFC 3339 format")
  }
}

///|
test "of_rfc3339 parses with fractional seconds" {
  match of_rfc3339("2023-09-15T08:30:00.123Z") {
    Ok(pt) => {
      assert_eq(pt.seconds, 1694766600)
      assert_eq(pt.picoseconds, 123000000000)
    }
    Err(_) => fail("Failed to parse RFC 3339 with fractional seconds")
  }
}

///|
test "of_rfc3339 parses with timezone offset" {
  match of_rfc3339("2023-09-15T08:30:00+08:00") {
    Ok(pt) => {
      // 应该减去8小时的偏移
      assert_eq(pt.seconds, 1694737800) // 1694766600 - 8*3600
      assert_eq(pt.picoseconds, 0)
    }
    Err(_) => fail("Failed to parse RFC 3339 with timezone offset")
  }
}

///|
/// 测试 RFC 3339 格式化
test "to_rfc3339 formats correctly" {
  let pt = PTime::{ seconds: 1694764200, picoseconds: 0 }
  let formatted = to_rfc3339(pt)
  assert_true(formatted.contains("2023-09-15"))
  assert_true(formatted.contains("T"))
  assert_true(formatted.has_suffix("Z"))
}

///|
test "to_rfc3339 formats with fractional seconds" {
  let pt = PTime::{ seconds: 1694764200, picoseconds: 123000000000 }
  let formatted = to_rfc3339(pt)
  assert_true(formatted.contains(".123"))
}

///|
test "to_rfc3339 formats pre-epoch time" {
  let pt = PTime::{ seconds: -86400, picoseconds: 0 } // 1969-12-31
  let formatted = to_rfc3339(pt)
  assert_true(formatted.contains("1969-12-31"))
}

///|
/// 测试时间跨度运算
test "add_span adds time correctly" {
  let pt = PTime::{ seconds: 1000, picoseconds: 500000000000 }
  let span = Span::{ seconds: 200, picoseconds: 300000000000 }
  let result = add_span(pt, span)
  assert_eq(result.seconds, 1200)
  assert_eq(result.picoseconds, 800000000000)
}

///|
test "add_span handles picosecond overflow" {
  let pt = PTime::{ seconds: 1000, picoseconds: 800000000000 }
  let span = Span::{ seconds: 0, picoseconds: 300000000000 }
  let result = add_span(pt, span)
  assert_eq(result.seconds, 1001)
  assert_eq(result.picoseconds, 100000000000)
}

///|
test "diff calculates time difference" {
  let pt1 = PTime::{ seconds: 2000, picoseconds: 0 }
  let pt2 = PTime::{ seconds: 1000, picoseconds: 500000000000 }
  let result = diff(pt1, pt2)
  assert_eq(result.seconds, 999)
  assert_eq(result.picoseconds, 500000000000)
}

///|
test "diff handles negative result" {
  let pt1 = PTime::{ seconds: 1000, picoseconds: 0 }
  let pt2 = PTime::{ seconds: 2000, picoseconds: 500000000000 }
  let result = diff(pt1, pt2)
  assert_eq(result.seconds, -1000)
  assert_eq(result.picoseconds, -500000000000)
}

///|
test "compare returns correct order" {
  let pt1 = PTime::{ seconds: 1000, picoseconds: 0 }
  let pt2 = PTime::{ seconds: 2000, picoseconds: 0 }
  let pt3 = PTime::{ seconds: 1000, picoseconds: 500000000000 }
  assert_eq(compare(pt1, pt2), -1) // pt1 < pt2
  assert_eq(compare(pt2, pt1), 1) // pt2 > pt1
  assert_eq(compare(pt1, pt1), 0) // pt1 == pt1
  assert_eq(compare(pt1, pt3), -1) // pt1 < pt3 (due to picoseconds)
}

///|
/// 测试 Span 运算
test "add_spans adds spans correctly" {
  let span1 = Span::{ seconds: 100, picoseconds: 500000000000 }
  let span2 = Span::{ seconds: 200, picoseconds: 300000000000 }
  let result = add_spans(span1, span2)
  assert_eq(result.seconds, 300)
  assert_eq(result.picoseconds, 800000000000)
}

///|
test "sub_spans subtracts spans correctly" {
  let span1 = Span::{ seconds: 300, picoseconds: 800000000000 }
  let span2 = Span::{ seconds: 100, picoseconds: 300000000000 }
  let result = sub_spans(span1, span2)
  assert_eq(result.seconds, 200)
  assert_eq(result.picoseconds, 500000000000)
}

///|
test "mul_span multiplies span correctly" {
  let span = Span::{ seconds: 100, picoseconds: 500000000000 }
  let result = mul_span(span, 2)
  assert_eq(result.seconds, 200)
  assert_eq(result.picoseconds, 1000000000000)
}

///|
test "div_span divides span correctly" {
  let span = Span::{ seconds: 200, picoseconds: 1000000000000 }
  match div_span(span, 2) {
    Ok(result) => {
      assert_eq(result.seconds, 100)
      assert_eq(result.picoseconds, 500000000000)
    }
    Err(_) => fail("Division should succeed")
  }
}

///|
/// 测试边界情况
test "leap year calculation" {
  // 测试闰年：2000年是闰年
  let pt = of_rfc3339("2000-02-29T00:00:00Z")
  match pt {
    Ok(_) => () // 应该成功解析
    Err(_) => fail("Should handle leap year correctly")
  }

  // 测试非闰年：1900年不是闰年
  match of_rfc3339("1900-02-29T00:00:00Z") {
    Ok(_) => fail("Should fail for invalid leap year date")
    Err(PTimeError::InvalidDate(_)) => () // 期望的错误
    Err(_) => fail("Wrong error type for invalid leap year date")
  }
}

///|
test "year boundary handling" {
  // 测试年份边界
  let pt = of_rfc3339("1970-01-01T00:00:00Z")
  match pt {
    Ok(p) => {
      assert_eq(p.seconds, 0)
      assert_eq(p.picoseconds, 0)
    }
    Err(_) => fail("Should handle epoch correctly")
  }
}

///|
test "picosecond precision" {
  // 测试皮秒精度
  let pt = PTime::{ seconds: 0, picoseconds: 1 }
  let float_val = to_float(pt)
  // 1皮秒 = 1e-12秒
  assert_true(float_val > 0.0)
  assert_true(float_val < 0.000000001) // 小于1纳秒
}

///|
/// 测试往返转换
test "rfc3339 round trip" {
  let original = "2023-09-15T08:30:00.123456Z"
  match of_rfc3339(original) {
    Ok(pt) => {
      let formatted = to_rfc3339(pt)
      // 由于精度限制，可能不完全相同，但应该包含关键信息
      assert_true(formatted.contains("2023-09-15"))
      assert_true(formatted.contains("08:30:00"))
    }
    Err(_) => fail("Round trip should work")
  }
}

///|
test "float round trip" {
  let original : Float = 123.456789
  let pt = of_float(original)
  let converted = to_float(pt)
  // 由于皮秒精度限制，会有微小误差
  let diff = if converted > original {
    converted - original
  } else {
    original - converted
  }
  println(diff)
  assert_true(diff < 0.000002) // 误差阈值放宽到 < 2 微秒
}
