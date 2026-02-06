// 全局常量
class GlobalConstants {
  static const String appName = "TSTY App";

  static const String apiBaseUrl = "http://y4134647y5.qicp.vip:10573";
  static const Duration timeoutDuration = Duration(seconds: 10);
  static const int successState = 0;

  static const String xfyunIseEndpoint = "wss://ise-api.xfyun.cn/v2/open-ise";
  static const String xfyunIseAppId = "";
}

// HTTP 接口常量
class HttpConstants {
  // 获取单元进度接口
  static const String unitProgress = "/api/v1/learning/units/{unitId}/progress";
  // 获取关卡详情接口
  static const String levelDetails =
      "/api/v1/learning/levels/{levelId}/content";

  static const String iseAuth = "/api/v1/learning/ise/auth";

  static const String submitEvaluation =
      "/api/v1/learning/levels/{levelId}/submit-evaluation";

  static const String learningDuration = "/api/v1/learning/duration";
}

// 单元UnitId常量
class UnitConstants {
  static const String initialUnitId = "550e8400-e29b-41d4-a716-446655440000";
  static const String finalUnitId = "550e8400-e29b-41d4-a716-446655440001";
  static const String hanziUnitId = "550e8400-e29b-41d4-a716-446655440002";
  static const String wordUnitId = "550e8400-e29b-41d4-a716-446655440003";
}
