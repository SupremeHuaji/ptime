///|
/// 返回表示 1970-01-01 00:00:00 UTC 的时间点
pub fn epoch() -> PTime {
  { seconds: 0, picoseconds: 0 }
}

///|
/// 从浮点数创建时间点
pub fn of_float(time : Float) -> PTime {
  // 先将总秒数转换为“总微秒”，用四舍五入减少浮点误差
  let total_micros = (time * 1_000_000.0).round().to_double().to_int64()
  let seconds = total_micros / 1_000_000
  let micros = total_micros % 1_000_000
  {
    seconds: seconds.to_double().to_int64(),
    picoseconds: (micros * 1_000_000).to_double().to_int64(),
  }
}

///|
/// 将时间点转换为浮点数表示
pub fn to_float(pt : PTime) -> Float {
  pt.seconds.to_float() + pt.picoseconds.to_float() / 1_000_000_000_000.0
}
