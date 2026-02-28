import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/YiTopBar.dart';
import 'package:tsty_app/style/app_theme.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final yellow = AppTheme.yiYellow.value;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Column(
        children: [
          const YiTopBar(title: '隐私设置'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    title: '系统权限管理',
                    icon: Icons.security,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPermissionItem(
                          icon: Icons.mic,
                          title: '麦克风权限',
                          description: '用于语音练习、测评和语音合成功能',
                        ),
                        const SizedBox(height: 12),
                        _buildPermissionItem(
                          icon: Icons.camera_alt,
                          title: '相机/相册权限',
                          description: '用于上传头像或反馈截图',
                        ),
                        const SizedBox(height: 12),
                        _buildPermissionItem(
                          icon: Icons.notifications,
                          title: '通知权限',
                          description: '用于学习提醒和进度通知',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    title: '数据使用说明',
                    icon: Icons.data_usage,
                    content: const Text(
                      '我们仅在提供学习服务与改进产品所必需的范围内处理您的信息。您的语音数据仅用于实时评测和合成，不会长期存储。学习进度数据用于生成个性化学习报告。',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF2A1E00),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    title: '缓存与记录管理',
                    icon: Icons.storage,
                    content: const Text(
                      '您可以在"清除缓存"中删除本地缓存文件，包括临时音频文件和图片缓存。退出登录后，我们将清除您的登录态和本地存储的学习记录。',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF2A1E00),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    title: '账号与安全',
                    icon: Icons.account_circle,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '如需注销账号或删除个人信息，请通过以下方式联系我们：',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Color(0xFF2A1E00),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: yellow.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: yellow, width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.email, color: primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '2629103796@qq.com',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      '童声同音致力于保护您的隐私安全',
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

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget content,
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: yellow, width: 2),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3D2800),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFCC0000), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2A1E00),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
