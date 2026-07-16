import 'package:flutter/material.dart';
import 'package:tsty_app/api/auth.dart';
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

  @override
  void initState() {
    super.initState();
  }

  Future<void> _showInfoDialog(String title, String message) async {
    await showYiDialog<void>(
      context: context,
      builder: (context) {
        return YiDialog(
          title: title,
          message: message,
          cancelText: '关闭',
          confirmText: '知道了',
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  Future<void> _confirmClearCache() async {
    final ok = await showYiConfirmDialog(
      context: context,
      title: '清除缓存',
      message: '确定要清除缓存吗？',
      cancelText: '取消',
      confirmText: '清除',
      danger: true,
      barrierDismissible: true,
    );

    if (ok != true || !mounted) return;
    await _showInfoDialog('清除成功', '缓存已清除。');
  }

  Future<void> _openPrivacySettings() async {
    Navigator.of(context).pushNamed('/settings/privacy');
  }

  Future<void> _openThirdPartyShareList() async {
    Navigator.of(context).pushNamed('/settings/third-party-share');
  }

  Future<void> _openAbout() async {
    await _showInfoDialog(
      '关于童声同音',
      '童声同音：面向幼儿普通话学习的互动应用。\n\n版本: 1.0.0 (Build 1001)',
    );
  }

  Future<void> _openHelp() async {
    await _showInfoDialog(
      '帮助与反馈',
      '如果你在使用中遇到问题，可以按以下方式排查并反馈：\n\n常见问题\n- 听不到声音：请检查系统音量与静音状态，并确认已授予麦克风权限\n- 语音功能不可用：请确认网络连接正常，或稍后重试\n- 页面卡顿/闪退：建议先尝试“清除缓存”，再重新进入\n\n反馈方式\n- 邮箱：2629103796@qq.com\n\n为了更快定位问题，建议在邮件中附上：设备型号、系统版本、发生时间、问题描述、复现步骤与截图/录屏（如有）。',
    );
  }

  Future<void> _openChangePassword() async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    Future<void> showMsg(String msg) async {
      if (!mounted) return;
      await _showInfoDialog('提示', msg);
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

      try {
        final resp = await changePasswordAPI(
          oldPasswordMd5: md5Hex(oldPwd),
          newPasswordMd5: md5Hex(newPwd),
          confirmPasswordMd5: md5Hex(confirmPwd),
        );
        final changedAt = resp['changedAt']?.toString().trim() ?? '';
        await showMsg(changedAt.isEmpty ? '密码修改成功' : '密码修改成功\n$changedAt');
      } catch (e) {
        await showMsg(e.toString().replaceFirst('Exception: ', ''));
      }
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
    try {
      await logoutAPI();
    } catch (e) {
      if (!mounted) return;
      setState(() => _logoutLoading = false);
      await _showInfoDialog(
        '退出失败',
        e.toString().replaceFirst('Exception: ', ''),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _logoutLoading = false);

    await UserPrefs.clearLogin();
    await UserPrefs.clearAccessToken();
    await UserPrefs.clearRefreshToken();
    await UserPrefs.clearTokenMeta();
    await UserPrefs.clearChildProfile();
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
                              //             const SettingsSectionTitle(text: '系统设置'),
                              //             SettingsSection(
                              //               children: [
                              //                 SettingsItem(
                              //                   icon: Icons.volume_up,
                              //                   iconBg: const Color(0xFF339AF0),
                              //                   title: '音效',
                              //                   onTap: () async {
                              //                     setState(
                              //                       () => _soundEnabled = !_soundEnabled,
                              //                     );
                              //                     await UserPrefs.setSoundEnabled(
                              //                       _soundEnabled,
                              //                     );
                              //                     if (!mounted) return;
                              //                     await _showInfoDialog(
                              //                       '音效',
                              //                       _soundEnabled ? '音效已开启' : '音效已关闭',
                              //                     );
                              //                   },
                              //                   trailing: Transform.scale(
                              //                     scale: 1.1,
                              //                     child: Switch(
                              //                       value: _soundEnabled,
                              //                       onChanged: (v) async {
                              //                         setState(() => _soundEnabled = v);
                              //                         await UserPrefs.setSoundEnabled(v);
                              //                         if (!mounted) return;
                              //                         await _showInfoDialog(
                              //                           '音效',
                              //                           v ? '音效已开启' : '音效已关闭',
                              //                         );
                              //                       },
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 SettingsItem(
                              //                   icon: Icons.palette,
                              //                   iconBg: const Color(0xFF845EF7),
                              //                   title: '主题颜色',
                              //                   onTap: _chooseThemeColor,
                              //                 ),
                              //                 SettingsItem(
                              //                   icon: Icons.text_fields,
                              //                   iconBg: const Color(0xFFF0C000),
                              //                   title: '字体大小',
                              //                   onTap: _chooseFontSize,
                              //                 ),
                              //               ],
                              //             ),
                              const SettingsSectionTitle(text: '账号与安全'),
                              SettingsSection(
                                children: [
                                  // SettingsItem(
                                  //   icon: Icons.verified_user,
                                  //   iconBg: const Color(0xFFFF922B),
                                  //   title: '账号安全',
                                  //   onTap: () => _showInfoDialog(
                                  //     '账号安全',
                                  //     '建议你定期修改密码，并妥善保管账号信息。',
                                  //   ),
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
                              //       onTap: _chooseCharacter,
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
                                    onTap: _openPrivacySettings,
                                  ),
                                  SettingsItem(
                                    icon: Icons.share,
                                    iconBg: const Color(0xFF339AF0),
                                    title: '第三方共享个人信息清单',
                                    onTap: _openThirdPartyShareList,
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
                                    onTap: _openAbout,
                                  ),
                                  SettingsItem(
                                    icon: Icons.help,
                                    iconBg: const Color(0xFF51CF66),
                                    title: '帮助与反馈',
                                    onTap: _openHelp,
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
