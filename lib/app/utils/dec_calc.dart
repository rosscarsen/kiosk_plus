import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';

/// 高精度数值计算工具类
/// 基于 Decimal 包，避免浮点数精度问题
class DecUtil {
  /// 安全创建 Decimal（避免 double 精度污染）
  ///
  /// [value] 支持 null、Decimal、num、String 类型
  /// 返回对应的 Decimal 值，null 时返回 Decimal.zero
  ///
  /// 抛出 [FormatException] 当字符串格式无效时
  static Decimal from(dynamic value) {
    if (value == null) return Decimal.zero;
    if (value is Decimal) return value;

    try {
      return Decimal.parse(value.toString());
    } catch (e) {
      throw FormatException('无法解析为 Decimal: $value');
    }
  }

  /// 加法运算
  ///
  /// [a] 被加数
  /// [b] 加数
  /// [scale] 可选的小数位数，null 时保持原精度
  static Decimal add(dynamic a, dynamic b, {int? scale}) {
    _validateScale(scale);
    final result = from(a) + from(b);
    return scale == null ? result : _scale(result, scale);
  }

  /// 减法运算
  ///
  /// [a] 被减数
  /// [b] 减数
  /// [scale] 可选的小数位数，null 时保持原精度
  static Decimal sub(dynamic a, dynamic b, {int? scale}) {
    _validateScale(scale);
    final result = from(a) - from(b);
    return scale == null ? result : _scale(result, scale);
  }

  /// 乘法运算
  ///
  /// [a] 被乘数
  /// [b] 乘数
  /// [scale] 可选的小数位数，null 时保持原精度
  static Decimal mul(dynamic a, dynamic b, {int? scale}) {
    _validateScale(scale);
    final result = from(a) * from(b);
    return scale == null ? result : _scale(result, scale);
  }

  /// 除法运算（默认 2 位小数）
  ///
  /// [a] 被除数
  /// [b] 除数
  /// [scale] 小数位数，默认 2 位
  ///
  /// 当除数为零或接近零时返回 Decimal.zero
  /// 抛出 [ArgumentError] 当 scale 为负数时
  static Decimal div(dynamic a, dynamic b, {int scale = 2}) {
    _validateScale(scale);

    final dividend = from(a);
    final divisor = from(b);

    if (divisor.abs() < Decimal.parse('1e-10')) {
      return Decimal.zero;
    }

    final rational = dividend / divisor;
    final result = rational.toDecimal();
    return _scale(result, scale);
  }

  /// 统一精度控制（四舍五入）
  ///
  /// [value] 要处理的 Decimal 值
  /// [scale] 保留的小数位数
  static Decimal _scale(Decimal value, int scale) {
    return Decimal.parse(value.toStringAsFixed(scale));
  }

  /// 验证 scale 参数的有效性
  static void _validateScale(int? scale) {
    if (scale != null && scale < 0) {
      throw ArgumentError('scale 不能为负数: $scale');
    }
  }

  /// 转换为 double（仅用于显示，可能丢失精度）
  ///
  /// [decimal] 要转换的 Decimal 值
  /// 返回对应的 double 值
  static double toDouble(Decimal decimal) => double.parse(decimal.toString());

  /// 转换为固定小数位的字符串
  ///
  /// [value] 要转换的值
  /// [scale] 小数位数
  /// 返回格式化后的字符串
  static String toFixed(dynamic value, int scale) {
    _validateScale(scale);
    return _scale(from(value), scale).toString();
  }

  /// 比较两个数值是否相等（考虑精度）
  ///
  /// [a] 第一个数值
  /// [b] 第二个数值
  /// [precision] 比较精度，默认 1e-10
  static bool equals(dynamic a, dynamic b, {Decimal? precision}) {
    final decA = from(a);
    final decB = from(b);
    final diff = (decA - decB).abs();
    final threshold = precision ?? Decimal.parse('1e-10');
    return diff < threshold;
  }

  /// 获取较大值
  static Decimal max(dynamic a, dynamic b) {
    final decA = from(a);
    final decB = from(b);
    return decA > decB ? decA : decB;
  }

  /// 获取较小值
  static Decimal min(dynamic a, dynamic b) {
    final decA = from(a);
    final decB = from(b);
    return decA < decB ? decA : decB;
  }

  /// 绝对值
  static Decimal abs(dynamic value) {
    return from(value).abs();
  }

  /// 判断是否为零
  static bool isZero(dynamic value) {
    return from(value) == Decimal.zero;
  }

  /// 判断是否为正数
  static bool isPositive(dynamic value) {
    return from(value) > Decimal.zero;
  }

  /// 判断是否为负数
  static bool isNegative(dynamic value) {
    return from(value) < Decimal.zero;
  }

  /// 格式化金額
  ///
  /// [value] 要格式化的金額
  /// 返回格式化後的金額字串
  static String formatAmount(dynamic value) {
    final amount = from(value);
    final formatter = DecimalFormatter(NumberFormat("#,##0.00", "en-US"));
    return formatter.format(amount);
  }
}
