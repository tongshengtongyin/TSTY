import 'package:flutter/material.dart';
import 'package:tsty_app/api/auth.dart';
import 'package:tsty_app/components/common/YiBaseBackground.dart';
import 'package:tsty_app/components/common/YiTopBar.dart';
import 'package:tsty_app/style/app_theme.dart';
import 'package:tsty_app/utils/ToastUtils.dart';

class ParentChangePasswordPage extends StatefulWidget {
  const ParentChangePasswordPage({super.key});

  @override
  State<ParentChangePasswordPage> createState() =>
      _ParentChangePasswordPageState();
}

class _ParentChangePasswordPageState extends State<ParentChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final oldPwd = _oldPasswordController.text.trim();
    final newPwd = _newPasswordController.text.trim();
    final confirmPwd = _confirmPasswordController.text.trim();

    if (oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      ToastUtils.showToast(context, '请填写完整密码信息');
      return;
    }

    if (newPwd.length < 6 || newPwd.length > 32) {
      ToastUtils.showToast(context, '密码长度应为 6-32 位');
      return;
    }

    if (newPwd != confirmPwd) {
      ToastUtils.showToast(context, '两次输入的密码不一致');
      return;
    }

    setState(() => _loading = true);

    try {
      await parentChangePasswordAPI(
        oldPassword: oldPwd,
        newPassword: newPwd,
        confirmPassword: confirmPwd,
      );
      if (!mounted) return;
      ToastUtils.showToast(context, '密码修改成功');
      Navigator.of(context).pushReplacementNamed('/mine/parent-center');
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showToast(
        context,
        '修改失败：${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;
    final yellow = AppTheme.yiYellow.value;

    return Scaffold(
      body: YiBaseBackground(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: YiTopBar(
                title: '修改密码',
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_reset_rounded,
                      size: 80,
                      color: Color(0xFF3D2800),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '为了账号安全',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3D2800),
                      ),
                    ),
                    const Text(
                      '请设置新的家长密码',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildPasswordField(
                      controller: _oldPasswordController,
                      label: '原密码',
                      hint: '请输入原密码',
                      obscure: _obscureOld,
                      onToggle: () =>
                          setState(() => _obscureOld = !_obscureOld),
                      yellow: yellow,
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: '新密码',
                      hint: '请输入 6-32 位新密码',
                      obscure: _obscureNew,
                      onToggle: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      yellow: yellow,
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: '确认新密码',
                      hint: '请再次输入新密码',
                      obscure: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      yellow: yellow,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _loading ? null : _onSubmit,
                        child: Text(
                          _loading ? '提交中...' : '确认修改并进入',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required Color yellow,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF666666),
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: yellow, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
