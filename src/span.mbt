///|
/// 规范化时间跨度，确保皮秒在有效范围内
fn normalize_span(span : Span) -> Span {
  let pico_per_sec : Int64 = 1_000_000_000_000
  if span.picoseconds >= pico_per_sec {
    let extra_seconds = span.picoseconds / pico_per_sec
    let remaining_picos = span.picoseconds % pico_per_sec
    { seconds: span.seconds + extra_seconds, picoseconds: remaining_picos }
  } else if span.picoseconds <= -pico_per_sec {
    let extra_seconds = -span.picoseconds / pico_per_sec
    let remaining_picos = -span.picoseconds % pico_per_sec
    { seconds: span.seconds - extra_seconds, picoseconds: -remaining_picos }
  } else {
    span
  }
}

///|
/// 给时间点添加时间跨度，返回新的时间点
pub fn add_span(pt : PTime, sp : Span) -> PTime {
  let norm_span = normalize_span(sp)
  let new_seconds = pt.seconds + norm_span.seconds
  let new_picos = pt.picoseconds + norm_span.picoseconds

  // 处理皮秒溢出
  if new_picos >= 1_000_000_000_000 {
    { seconds: new_seconds + 1, picoseconds: new_picos - 1_000_000_000_000 }
  } else if new_picos < 0 {
    { seconds: new_seconds - 1, picoseconds: new_picos + 1_000_000_000_000 }
  } else {
    { seconds: new_seconds, picoseconds: new_picos }
  }
}

///|
/// 计算两个时间点的差，返回时间跨度
pub fn diff(pt1 : PTime, pt2 : PTime) -> Span {
  let sec_diff = pt1.seconds - pt2.seconds
  let pico_diff = pt1.picoseconds - pt2.picoseconds
  normalize_span(Span::{ seconds: sec_diff, picoseconds: pico_diff })
}

///|
/// 比较两个时间点
pub fn compare(pt1 : PTime, pt2 : PTime) -> Int {
  if pt1.seconds > pt2.seconds {
    return 1
  } else if pt1.seconds < pt2.seconds {
    return -1
    // 秒数相同，比较皮秒
  } else if pt1.picoseconds > pt2.picoseconds {
    return 1
  } else if pt1.picoseconds < pt2.picoseconds {
    return -1
  } else {
    return 0
  }
}

///|
/// 将时间跨度乘以一个标量，返回新的时间跨度
pub fn mul_span(sp : Span, scalar : Float) -> Span {
  // 计算总皮秒数
  let total_picos = sp.seconds.to_float() * 1_000_000_000_000.0 +
    sp.picoseconds.to_float()
  // 乘以标量
  let result_picos = total_picos * scalar
  // 拆分为秒和皮秒
  let result_seconds = (result_picos / 1_000_000_000_000.0)
    .floor()
    .to_double()
    .to_int64()
  let result_picoseconds = (result_picos % 1_000_000_000_000.0)
    .to_double()
    .to_int64()
  normalize_span(Span::{
    seconds: result_seconds,
    picoseconds: result_picoseconds,
  })
}

///|
/// 将时间跨度除以一个标量，返回新的时间跨度
pub fn div_span(sp : Span, scalar : Float) -> Result[Span, PTimeError] {
  if scalar == 0.0 {
    return Err(PTimeError::DivideByZero("Cannot divide span by zero"))
  }

  // 计算总皮秒数
  let total_picos = sp.seconds.to_float() * 1_000_000_000_000.0 +
    sp.picoseconds.to_float()
  // 除以标量
  let result_picos = total_picos / scalar
  // 拆分为秒和皮秒
  let result_seconds = (result_picos / 1_000_000_000_000.0)
    .floor()
    .to_double()
    .to_int64()
  let result_picoseconds = (result_picos % 1_000_000_000_000.0)
    .to_double()
    .to_int64()
  Ok(
    normalize_span(Span::{
      seconds: result_seconds,
      picoseconds: result_picoseconds,
    }),
  )
}

///|
/// 计算时间跨度的绝对值
pub fn abs_span(sp : Span) -> Span {
  if sp.seconds < 0 || (sp.seconds == 0 && sp.picoseconds < 0) {
    // 取负值
    Span::{ seconds: -sp.seconds, picoseconds: -sp.picoseconds }
  } else {
    sp
  }
}

///|
/// 取时间跨度的相反数
pub fn negate_span(sp : Span) -> Span {
  Span::{ seconds: -sp.seconds, picoseconds: -sp.picoseconds }
}

///|
/// 将两个时间跨度相加
pub fn add_spans(sp1 : Span, sp2 : Span) -> Span {
  let new_seconds = sp1.seconds + sp2.seconds
  let new_picos = sp1.picoseconds + sp2.picoseconds
  normalize_span(Span::{ seconds: new_seconds, picoseconds: new_picos })
}

///|
/// 将第二个时间跨度从第一个中减去
pub fn sub_spans(sp1 : Span, sp2 : Span) -> Span {
  let new_seconds = sp1.seconds - sp2.seconds
  let new_picos = sp1.picoseconds - sp2.picoseconds
  normalize_span(Span::{ seconds: new_seconds, picoseconds: new_picos })
}

///|
/// 将时间跨度转换为秒数（包含小数部分）
pub fn to_seconds(sp : Span) -> Float {
  sp.seconds.to_float() + sp.picoseconds.to_float() / 1_000_000_000_000.0
}

///|
/// 判断时间跨度是否为零
pub fn is_zero(sp : Span) -> Bool {
  sp.seconds == 0 && sp.picoseconds == 0
}

///|
/// 比较两个时间跨度的大小
pub fn compare_spans(sp1 : Span, sp2 : Span) -> Int {
  if sp1.seconds > sp2.seconds {
    return 1
  } else if sp1.seconds < sp2.seconds {
    return -1
  } else if sp1.picoseconds > sp2.picoseconds {
    return 1
  } else if sp1.picoseconds < sp2.picoseconds {
    return -1
  } else {
    return 0
  }
}
