///|
/// 返回表示 1970-01-01 00:00:00 UTC 的时间点
pub fn epoch() -> PTime {
  { seconds: 0, picoseconds: 0 }
}

///|
/// 从浮点数创建时间点
pub fn of_float(f : Float) -> PTime {
  let seconds = f.floor().to_double()
  let frac = f.to_double() - seconds
  let picoseconds = (frac * 1_000_000_000_000.0).to_int64()
  { seconds: seconds.to_int64(), picoseconds }
}

///|
/// 将时间点转换为浮点数表示
pub fn to_float(pt : PTime) -> Float {
  pt.seconds.to_float() + pt.picoseconds.to_float() / 1_000_000_000_000.0
}
