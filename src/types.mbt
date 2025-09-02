///|
/// 表示时间点 (Unix 时间 + 皮秒)
pub(all) struct PTime {
  seconds : Int64 // 从 1970-01-01 00:00:00 UTC 起的秒数
  picoseconds : Int64 // 皮秒部分 (0-999_999_999_999)
}

///|
/// 表示时间跨度 (可正可负)
pub(all) struct Span {
  seconds : Int64 // 秒数部分
  picoseconds : Int64 // 皮秒部分
}

///|
/// 从天数计算日期（年月日）
pub(all) struct DateComponents {
  year : Int
  month : Int
  day : Int
}
