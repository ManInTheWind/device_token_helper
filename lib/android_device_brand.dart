enum AndroidDeviceBrand {
  /// 华为
  huawei1("Huawei"),

  /// 华为
  huawei2("HUAWEI"),

  /// 华为
  huawei3("HONOR"),

  /// ⼩⽶
  xiaomi("xiaomi"),

  /// OPPO
  oppo1("OPPO"),

  /// OPPO
  oppo2("realme"),

  /// 魅族
  meizu("Meizu"),

  /// 索尼
  sony("sony"),

  /// 三星
  samsung("samsung"),

  /// LG
  lg("lg"),

  /// HTC
  htc("htc"),

  /// NOVA
  nova("nova"),

  /// 乐视
  leMobile("LeMobile"),

  /// 联想
  lenovo("lenovo"),

  /// 未知
  unknown("unknown"),
  ;

  final String brand;

  const AndroidDeviceBrand(this.brand);

  factory AndroidDeviceBrand.fromBrand(String brand) {
    return values.firstWhere(
      (element) => element.brand == brand,
      orElse: () => AndroidDeviceBrand.unknown,
    );
  }
}
