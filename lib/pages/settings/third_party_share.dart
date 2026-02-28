import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/YiTopBar.dart';
import 'package:tsty_app/style/app_theme.dart';

class ThirdPartySharePage extends StatelessWidget {
  const ThirdPartySharePage({super.key});

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Column(
        children: [
          const YiTopBar(title: '第三方共享个人信息清单'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: yellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: yellow, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '为实现语音学习与互动功能，应用可能会在您主动使用相关功能时调用第三方服务。我们不会向第三方提供与学习无关的信息。',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildThirdPartyCard(
                    context,
                    name: '科大讯飞开放平台',
                    service: '语音测评 / 语音合成',
                    items: [
                      _buildInfoItem('共享信息', '语音音频（您主动录制或触发播放时）、文本内容（用于合成/评测）、设备基础信息（网络状态、设备型号/系统版本、时间戳）、必要的鉴权信息'),
                      _buildInfoItem('使用目的', '语音评测打分与语音合成播放'),
                      _buildInfoItem('隐私政策', 'https://www.xfyun.cn/doc/policy/privacy.html'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildThirdPartyCard(
                    context,
                    name: '声网 Agora',
                    service: '语音通话 / 实时音频互动',
                    items: [
                      _buildInfoItem('共享信息', '实时音频流、设备网络信息、房间标识与必要的连接参数'),
                      _buildInfoItem('使用目的', '提供实时音频互动能力'),
                      _buildInfoItem('隐私政策', 'https://www.agora.io/cn/privacy-policy'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '重要说明',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '不同版本的第三方 SDK 可能会因系统/网络环境差异而收集必要的运行信息（如崩溃日志、性能数据），用于保障服务稳定性。我们不会将您的个人身份信息（如姓名、联系方式）共享给上述第三方服务商。',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      '如您对信息共享有任何疑问，请联系：2629103796@qq.com',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPartyCard(
    BuildContext context, {
    required String name,
    required String service,
    required List<Widget> items,
  }) {
    final yellow = AppTheme.yiYellow.value;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: yellow, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: yellow.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(21),
                topRight: Radius.circular(21),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: yellow, width: 2),
                  ),
                  child: const Icon(Icons.cloud, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3D2800),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        service,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label：',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2A1E00),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
