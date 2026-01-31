import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/YiBaseBackground.dart';
import 'package:tsty_app/components/common/YiSideStripe.dart';
import 'package:tsty_app/components/common/YiTopBar.dart';
import 'package:tsty_app/components/common/yi_dialog.dart';
import 'package:tsty_app/components/settings/settings_item.dart';
import 'package:tsty_app/components/settings/settings_logout_button.dart';
import 'package:tsty_app/components/settings/settings_section.dart';
import 'package:tsty_app/components/settings/settings_section_title.dart';
import 'package:tsty_app/utils/user_prefs.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _logoutLoading = false;

  Future<void> _showTips(String title) async {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title功能开发中...')));
  }

  Future<void> _confirmClearCache() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('清除缓存'),
          content: const Text('确定要清除缓存吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    if (ok == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('缓存已清除')));
    }
  }

  Future<void> _openChangePassword() async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    Future<void> showMsg(String msg) async {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }

    bool? ok;
    try {
      ok = await showYiDialog<bool>(
        context: context,
        builder: (context) {
          return YiDialog(
            title: '修改密码',
            cancelText: '取消',
            confirmText: '确认',
            onCancel: () => Navigator.of(context).pop(false),
            onConfirm: () => Navigator.of(context).pop(true),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '原密码'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '新密码(6-20位)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '确认新密码'),
                ),
              ],
            ),
          );
        },
      );

      if (ok != true) return;

      final oldPwd = oldController.text.trim();
      final newPwd = newController.text.trim();
      final confirmPwd = confirmController.text.trim();

      if (oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
        await showMsg('请完整填写密码信息');
        return;
      }

      if (newPwd.length < 6 || newPwd.length > 20) {
        await showMsg('密码长度应为6-20位');
        return;
      }

      if (newPwd != confirmPwd) {
        await showMsg('两次输入的密码不一致');
        return;
      }

      await showMsg('密码修改成功');
    } finally {
      oldController.dispose();
      newController.dispose();
      confirmController.dispose();
    }
  }

  Future<void> _logout() async {
    if (_logoutLoading) return;

    final ok = await showYiConfirmDialog(
      context: context,
      title: '退出确认',
      message: '确定退出登录吗？',
      danger: true,
      cancelText: '取消',
      confirmText: '退出',
    );

    if (ok != true) return;

    setState(() => _logoutLoading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _logoutLoading = false);

    await UserPrefs.clearLogin();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: YiBaseBackground(
          child: Stack(
            children: [
              const YiSideStripe(direction: 'left', topRatio: 0.30),
              const YiSideStripe(direction: 'right', topRatio: 0.40),
              Column(
                children: [
                  const YiTopBar(title: '设置'),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // const SettingsSectionTitle(text: '系统设置'),
                              // SettingsSection(
                              //   children: [
                              //     SettingsItem(
                              //       icon: Icons.volume_up,
                              //       iconBg: const Color(0xFF339AF0),
                              //       title: '音效',
                              //       trailing: Transform.scale(
                              //         scale: 1.1,
                              //         child: Switch(
                              //           value: _soundEnabled,
                              //           onChanged: (v) {
                              //             setState(() => _soundEnabled = v);
                              //             ScaffoldMessenger.of(
                              //               context,
                              //             ).showSnackBar(
                              //               SnackBar(
                              //                 content: Text(
                              //                   v ? '音效已开启' : '音效已关闭',
                              //                 ),
                              //               ),
                              //             );
                              //           },
                              //         ),
                              //       ),
                              //     ),
                              //     SettingsItem(
                              //       icon: Icons.palette,
                              //       iconBg: const Color(0xFF845EF7),
                              //       title: '主题颜色',
                              //       onTap: () => _showTips('主题颜色'),
                              //     ),
                              //     SettingsItem(
                              //       icon: Icons.text_fields,
                              //       iconBg: const Color(0xFFF0C000),
                              //       title: '字体大小',
                              //       onTap: () => _showTips('字体大小'),
                              //     ),
                              //   ],
                              // ),
                              const SettingsSectionTitle(text: '账号与安全'),
                              SettingsSection(
                                children: [
                                  // SettingsItem(
                                  //   icon: Icons.verified_user,
                                  //   iconBg: const Color(0xFFFF922B),
                                  //   title: '账号安全',
                                  //   onTap: () => _showTips('账号安全'),
                                  // ),
                                  SettingsItem(
                                    icon: Icons.key,
                                    iconBg: const Color(0xFF51CF66),
                                    title: '修改密码',
                                    onTap: _openChangePassword,
                                  ),
                                ],
                              ),
                              // const SettingsSectionTitle(text: '个性化设置'),
                              // SettingsSection(
                              //   children: [
                              //     SettingsItem(
                              //       icon: Icons.emoji_emotions,
                              //       iconBg: const Color(0xFF845EF7),
                              //       title: '卡通人物选择',
                              //       onTap: () => _showTips('卡通人物选择'),
                              //     ),
                              //   ],
                              // ),
                              const SettingsSectionTitle(text: '隐私与安全'),
                              SettingsSection(
                                children: [
                                  SettingsItem(
                                    icon: Icons.shield,
                                    iconBg: const Color(0xFFCC0000),
                                    title: '隐私设置',
                                    onTap: () => _showTips('隐私设置'),
                                  ),
                                  SettingsItem(
                                    icon: Icons.share,
                                    iconBg: const Color(0xFF339AF0),
                                    title: '第三方共享个人信息清单',
                                    onTap: () => _showTips('第三方共享个人信息清单'),
                                  ),
                                  SettingsItem(
                                    icon: Icons.delete,
                                    iconBg: const Color(0xFF868E96),
                                    title: '清除缓存',
                                    onTap: _confirmClearCache,
                                  ),
                                ],
                              ),
                              const SettingsSectionTitle(text: '关于'),
                              SettingsSection(
                                children: [
                                  SettingsItem(
                                    icon: Icons.info,
                                    iconBg: const Color(0xFF339AF0),
                                    title: '关于童声同音',
                                    onTap: () => _showTips('关于童声同音'),
                                  ),
                                  SettingsItem(
                                    icon: Icons.help,
                                    iconBg: const Color(0xFF51CF66),
                                    title: '帮助与反馈',
                                    onTap: () => _showTips('帮助与反馈'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SettingsLogoutButton(
                                loading: _logoutLoading,
                                onPressed: _logout,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '版本: 1.0.0 (Build 1001)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF999999),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
