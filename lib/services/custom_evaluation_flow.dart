import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tsty_app/api/ise.dart';
import 'package:tsty_app/components/learn/level_detail/level_detail_eval_dialog.dart';
import 'package:tsty_app/constants/index.dart';
import 'package:tsty_app/services/flutter_tts_service.dart';
import 'package:tsty_app/utils/toast_utils.dart';
import 'package:tsty_app/utils/custom_eval_store.dart';
import 'package:tsty_app/utils/user_prefs.dart';
import 'package:tsty_app/utils/yi_recorder.dart';
import 'package:tsty_app/utils/yi_speech_evaluator.dart';

class CustomEvaluationFlow {
  final CustomEvalItem item;
  final VoidCallback onEvaluationCompleted;
  final VoidCallback onFinish;
  final FlutterTtsService ttsPlayer;

  CustomEvaluationFlow({
    required this.item,
    required this.onEvaluationCompleted,
    required this.onFinish,
    required this.ttsPlayer,
  });

  Future<IseAuthCache?> _ensureIseAuth() async {
    final cached = await UserPrefs.getIseAuthCache();
    if (cached != null) {
      final ageMs = DateTime.now().millisecondsSinceEpoch - cached.timestamp;
      final ttlMs = const Duration(minutes: 4).inMilliseconds;
      if (ageMs >= 0 && ageMs <= ttlMs) {
        if (kDebugMode) {
          debugPrint('ISE auth cache hit: ageMs=$ageMs');
        }
        return cached;
      }
      if (kDebugMode) {
        debugPrint('ISE auth cache expired, clearing');
      }
      await UserPrefs.clearIseAuthCache();
    }
    if (kDebugMode) {
      debugPrint('ISE auth cache miss, fetching...');
    }
    try {
      final auth = await getIseAuthAPI();
      await UserPrefs.setIseAuthCache(auth);
      return auth;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('getIseAuthAPI failed: $e');
      }
      return null;
    }
  }

  List<LevelEvalPoint> _buildEvalPoints({
    required int totalScore,
    int? fluency,
    int? tone,
    int? phone,
    int? integrity,
    int? exceptInfo,
  }) {
    bool ok(int v, {int pass = 80}) => v >= pass;

    String dimText({
      required String good,
      required String mid,
      required String ok,
      required String bad,
      required int v,
    }) {
      if (v >= 90) return good;
      if (v >= 80) return mid;
      if (v >= 70) return ok;
      return bad;
    }

    final points = <LevelEvalPoint>[
      LevelEvalPoint(
        success: totalScore >= 75,
        text: totalScore >= 90
            ? '整体表现优秀'
            : totalScore >= 75
                ? '整体不错'
                : '多练习会更好',
      ),
    ];

    if (tone != null) {
      points.add(LevelEvalPoint(
        success: ok(tone),
        text: dimText(
            good: '声调很准',
            mid: '声调不错',
            ok: '声调需再稳一点',
            bad: '声调需要加强',
            v: tone),
      ));
    }

    if (phone != null) {
      points.add(LevelEvalPoint(
        success: ok(phone),
        text: dimText(
            good: '发音很清晰',
            mid: '发音不错',
            ok: '发音需更清晰',
            bad: '发音需要加强',
            v: phone),
      ));
    }

    if (fluency != null) {
      points.add(LevelEvalPoint(
        success: ok(fluency),
        text: dimText(
            good: '表达很流畅',
            mid: '表达比较流畅',
            ok: '流利度需提升',
            bad: '流利度需要加强',
            v: fluency),
      ));
    }

    if (integrity != null) {
      points.add(LevelEvalPoint(
        success: ok(integrity),
        text: dimText(
            good: '内容很完整',
            mid: '内容比较完整',
            ok: '注意不要吞音',
            bad: '完整度需要加强',
            v: integrity),
      ));
    }

    if (exceptInfo != null && exceptInfo != 0) {
      points.add(const LevelEvalPoint(success: false, text: '录音质量待提升'));
    }

    return points;
  }

  String _buildLearningTip({
    required int totalScore,
    int? fluency,
    int? tone,
    int? phone,
    int? integrity,
    int? exceptInfo,
  }) {
    if (exceptInfo != null && exceptInfo != 0) {
      return '尽量在安静环境录音，靠近麦克风，避免喷麦和背景噪音。';
    }

    final dims = <String, int?>{
      'tone': tone,
      'phone': phone,
      'fluency': fluency,
      'integrity': integrity,
    };

    String? worstKey;
    int worst = 101;
    for (final e in dims.entries) {
      final v = e.value;
      if (v == null) continue;
      if (v < worst) {
        worst = v;
        worstKey = e.key;
      }
    }

    if (worstKey == 'tone') {
      return '注意四声变化，跟读标准音，把声调读得更到位一些。';
    }
    if (worstKey == 'phone') {
      return '把声母韵母咬清楚，嘴型更夸张一点，发音会更清晰。';
    }
    if (worstKey == 'fluency') {
      return '放慢一点，保持语速均匀，连读更自然流畅。';
    }
    if (worstKey == 'integrity') {
      return '注意把音节/词读完整，结尾不要吞音。';
    }

    if (totalScore >= 90) {
      return '保持这个状态！可以再试着读得更自然、更有感情。';
    }
    if (totalScore >= 75) {
      return '整体不错！再多跟读几遍标准音，分数会更稳。';
    }
    return '多听标准发音，慢一点跟读，注意嘴型和声调。';
  }

  String _buildTtsFeedback(int score, String learningTip) {
    if (score >= 90) return '小朋友真棒！你读得非常好，$learningTip';
    if (score >= 75) return '不错呀小朋友！$learningTip';
    if (score >= 60) return '加油呀小朋友！$learningTip';
    return '别灰心呀小朋友！$learningTip';
  }

  Future<void> evaluateAndShowDialog({
    required BuildContext context,
    required YiRecorderResult recordResult,
  }) async {
    final endpoint = Uri.parse(GlobalConstants.xfyunIseEndpoint);
    final authCache = await _ensureIseAuth();
    if (authCache == null) {
      if (context.mounted) {
        ToastUtils.showToast(context, '获取语音测评鉴权失败');
      }
      return;
    }

    final authQuery = YiIseAuthQuery(
      authorization: authCache.authorization,
      host: authCache.host,
      date: authCache.date,
    );
    final appId = authCache.appId;
    final category = item.category;
    final evaluator = YiIseEvaluator(
      YiIseConfig(
        endpoint: endpoint,
        appId: appId,
        category: category,
        ent: 'cn_vip',
      ),
    );

    try {
      final result = await evaluator.evaluateFileToResult(
        filePath: recordResult.path,
        text: item.text,
        authQuery: authQuery,
        timeout: const Duration(seconds: 20),
      );
      if (kDebugMode) {
        debugPrint('Custom ISE result xml: ${result.xml}');
      }
      final score = (result.totalScore ?? 0).round().clamp(0, 100);

      final fluency = YiIseXml.extractFluencyScore(result.xml)?.round();
      final tone = YiIseXml.extractToneScore(result.xml)?.round();
      final phone = YiIseXml.extractPhoneScore(result.xml)?.round();
      final integrity = YiIseXml.extractIntegrityScore(result.xml)?.round();
      final exceptInfo = YiIseXml.extractExceptInfo(result.xml);

      final stars = score >= 95
          ? 3
          : score >= 80
              ? 2
              : score >= 60
                  ? 1
                  : 0;
      final flowers = stars;
      final accuracyText = score >= 90
          ? '太棒了！'
          : score >= 75
              ? '不错哦！'
              : score >= 60
                  ? '继续加油！'
                  : '再试一次！';

      final points = _buildEvalPoints(
        totalScore: score,
        fluency: fluency,
        tone: tone,
        phone: phone,
        integrity: integrity,
        exceptInfo: exceptInfo,
      );
      final learningTip = _buildLearningTip(
        totalScore: score,
        fluency: fluency,
        tone: tone,
        phone: phone,
        integrity: integrity,
        exceptInfo: exceptInfo,
      );

      if (!context.mounted) return;

      final feedbackText = _buildTtsFeedback(score, learningTip);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          ttsPlayer.speak(context: context, text: feedbackText);
        }
      });

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return LevelDetailEvalDialog(
            score: score,
            accuracyText: accuracyText,
            stars: stars,
            flowers: flowers,
            points: points,
            learningTip: learningTip,
            onTryAgain: () {
              Navigator.of(dialogContext).pop();
              onEvaluationCompleted();
            },
            onNext: () {
              Navigator.of(dialogContext).pop();
              onFinish();
            },
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Custom evaluation failed: $e');
      }
      if (context.mounted) {
        ToastUtils.showToast(context, '测评失败');
      }
    }
  }
}
