///|
/// ptime 库可能产生的错误类型
pub(all) enum PTimeError {
  /// RFC3339 格式解析错误
  InvalidFormat(String)
  /// 值超出有效范围
  OutOfRange(String)
  /// 除以零错误
  DivideByZero(String)
  /// 无效日期错误
  InvalidDate(String)
  /// 无效时间错误
  InvalidTime(String)
  /// 其他错误
  Other(String)
} derive(Show, Eq)
