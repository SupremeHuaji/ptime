///|
/// 返回表示 1970-01-01 00:00:00 UTC 的时间点
pub fn epoch() -> PTime {
  { seconds: 0, picoseconds: 0 }
}

///|
/// 从浮点数创建时间点
pub fn of_float(time : Float) -> PTime {
  let seconds = time.trunc().to_double().to_int64() // 获取整数部分作为秒
  let fractional_part = time - seconds.to_float() // 获取小数部分
  let picoseconds = (fractional_part * 1_000_000_000_000.0).round() // 转换为皮秒并四舍五入
  {
    seconds: seconds.to_double().to_int64(),
    picoseconds: picoseconds.to_double().to_int64(),
  }
}

///|
/// 将时间点转换为浮点数表示
pub fn to_float(pt : PTime) -> Float {
  pt.seconds.to_float() + pt.picoseconds.to_float() / 1_000_000_000_000.0
}
