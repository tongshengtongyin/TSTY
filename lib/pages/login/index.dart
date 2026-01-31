import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/YiBaseBackground.dart';
import 'package:tsty_app/components/common/select_character_dialog.dart';
import 'package:tsty_app/components/common/yi_stripe_frame.dart';
import 'package:tsty_app/components/common/yi_dialog.dart';
import 'package:tsty_app/components/login/login_primary_button.dart';
import 'package:tsty_app/components/login/login_text_field.dart';
import 'package:tsty_app/utils/ToastUtils.dart';
import 'package:tsty_app/utils/user_prefs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onHelpTap() async {
    await showYiDialog<void>(
      context: context,
      builder: (context) {
        return YiDialog(
          title: '需要帮助？',
          message: '请让大人帮助输入账号和密码。\n如忘记密码，请联系老师重置。',
          cancelText: '知道了',
          confirmText: '我明白了',
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  Future<void> _login() async {
    if (_loading) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorText = '请输入账号和密码');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 700));

      final ok = password.length >= 6;
      if (!ok) {
        setState(() => _errorText = '账号或密码错误');
        return;
      }

      if (!mounted) return;

      await UserPrefs.setLoggedIn(true);
      if (!mounted) return;
      var selectedCharacter = await UserPrefs.getSelectedCharacter();
      if (!mounted) return;

      if (selectedCharacter == null) {
        selectedCharacter = await showSelectCharacterDialog(context: context);
        if (selectedCharacter == null || !mounted) {
          await UserPrefs.setLoggedIn(false);
          return;
        }
        await UserPrefs.setSelectedCharacter(selectedCharacter);
      }

      if (!mounted) return;
      ToastUtils.showToast(context, '登录成功');
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: YiBaseBackground(
        child: Stack(
          children: [
            const Positioned.fill(
              child: YiStripeFrame(
                inset: EdgeInsets.zero,
                thickness: 10,
                blockExtent: 10,
                radius: 0,
                opacity: 0.82,
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TeacherHeader(red: red),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: red.withValues(alpha: 0.10),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 20,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                '账号登录',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF3D2800),
                                ),
                              ),
                              const SizedBox(height: 24),
                              LoginTextField(
                                controller: _usernameController,
                                placeholder: '请输入账号',
                                icon: Icons.person_rounded,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) {},
                              ),
                              const SizedBox(height: 24),
                              LoginTextField(
                                controller: _passwordController,
                                placeholder: '请输入密码',
                                icon: Icons.lock_rounded,
                                obscureText: !_showPassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _login(),
                                suffix: IconButton(
                                  onPressed: () {
                                    setState(
                                      () => _showPassword = !_showPassword,
                                    );
                                  },
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                              ),
                              if (_errorText != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  _errorText!,
                                  style: const TextStyle(
                                    color: Color(0xFFBE0003),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 36),
                              LoginPrimaryButton(
                                text: '登录',
                                loading: _loading,
                                onPressed: _login,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '不会登录？',
                                    style: TextStyle(
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: _onHelpTap,
                                    child: Text(
                                      '让大人帮忙吧～',
                                      style: TextStyle(
                                        color: red,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherHeader extends StatelessWidget {
  final Color red;

  const _TeacherHeader({required this.red});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 124,
          height: 124,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, red.withValues(alpha: 0.10)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Image.asset('lib/assets/girl.webp', fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '你好小朋友，欢迎来学普通话～',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF3D2800),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '请输入账号和密码开始学习吧！',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
