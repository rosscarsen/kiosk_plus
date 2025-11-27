class Config {
  /// hive box名称
  static String kioskHiveBox = "kioskHiveBox";

  ///数据键名
  static String loginData = 'loginData'; //登录信息
  static String localLanguage = "localLanguage"; //本地语言
  static String innerPrinterInfo = 'innerPrinterInfo'; //内置打印机信息
  static String remember = 'remember'; //记住密码
  static String calendarDiscount = 'calendarDiscount'; //日历折扣
  static String categoryTreeProduct = 'categoryTreeProduct'; //分类树产品
  static String productRemarks = 'productRemarks'; //产品备注
  static String productSetMeal = 'productSetMeal'; //产品套餐
  static String productSetMealLimit = 'productSetMealLimit'; //套餐限制

  /// API基础地址
  //static String baseurl = "https://api.friendsclub.com/kioskPlus";
  static String baseurl = "http://www.api.cn/kioskPlus";
  // 登录
  static String login = "/Login/login";
  // 获取数据列表
  static String getDataList = "/Home/getDataList";
}
