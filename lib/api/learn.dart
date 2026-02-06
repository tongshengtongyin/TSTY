import 'package:tsty_app/constants/index.dart';
import 'package:tsty_app/utils/dio_utils.dart';
import 'package:tsty_app/viewmodels/learn.dart';

// 获取单元进度 API
Future<UnitProgressResponse> getUnitProgressAPI(String unitId) async {
  final String url = HttpConstants.unitProgress.replaceFirst(
    "{unitId}",
    unitId,
  );
  final result = await dioUtils.get(url);
  return UnitProgressResponse.fromJSON(result);
}

// 获取关卡详情 API
Future<LevelContent> getLevelDetailsAPI(String levelId) async {
  final String url = HttpConstants.levelDetails.replaceFirst(
    "{levelId}",
    levelId,
  );
  final result = await dioUtils.get(url);
  return LevelContent.fromJSON(result);
}

// 提交测评结果 API
Future<void> submitLevelEvaluationAPI({
  required String levelId,
  required Map<String, dynamic> data,
  String? accessToken,
}) async {
  final url = HttpConstants.submitEvaluation.replaceFirst('{levelId}', levelId);
  final token = (accessToken ?? '').trim();
  final headers = <String, dynamic>{
    'Content-Type': 'application/json',
    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  final result = await dioUtils.post(url, data: data, headers: headers);

  if (result is Map) {
    if (result.containsKey('code')) {
      final code = result['code'];
      if (code == GlobalConstants.successState) {
        return;
      }
      throw Exception(result['message']?.toString() ?? '提交测评失败');
    }
    return;
  }

  return;
}

Future<Map<String, dynamic>> recordLearningDurationAPI({
  required int duration,
  required String activityType,
  String? accessToken,
}) async {
  final token = (accessToken ?? '').trim();
  final headers = <String, dynamic>{
    'Content-Type': 'application/json',
    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  final body = <String, dynamic>{
    'duration': duration,
    'activityType': activityType,
  };

  final result = await dioUtils.post(
    HttpConstants.learningDuration,
    data: body,
    headers: headers,
  );

  if (result is Map) {
    if (result.containsKey('code')) {
      final code = result['code'];
      if (code == GlobalConstants.successState) {
        final data = result['data'];
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
        return const <String, dynamic>{};
      }
      throw Exception(result['message']?.toString() ?? '学习时长记录失败');
    }
    return Map<String, dynamic>.from(result);
  }

  return const <String, dynamic>{};
}
