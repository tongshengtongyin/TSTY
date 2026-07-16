import 'package:flutter/material.dart';
import 'package:tsty_app/api/auth.dart';
import 'package:tsty_app/components/common/YiBaseBackground.dart';
import 'package:tsty_app/components/common/YiTopBar.dart';
import 'package:tsty_app/components/mine/parent_entry/parent_entry_feature_list.dart';
import 'package:tsty_app/components/mine/parent_entry/parent_entry_password_card.dart';
import 'package:tsty_app/utils/ToastUtils.dart';
import 'package:tsty_app/utils/parent_center_prefs.dart';

class ParentEntryPage extends StatefulWidget {
  const ParentEntryPage({super.key});

  @override
  State<ParentEntryPage> createState() => _ParentEntryPageState();
}

class _ParentEntryPageState extends State<ParentEntryPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      if (_errorText != null) {
        setState(() {
          _errorText = null;
        });
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_loading) return;
    final pwd = _passwordController.text.trim();
    if (pwd.isEmpty) return;

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final resp = await parentLoginAPI(password: pwd);
      if (!mounted) return;

      await ParentCenterPrefs.setParentLoggedIn(true);
      if (!mounted) return;

      if (resp.forceChangePassword) {
        Navigator.of(
          context,
        ).pushReplacementNamed('/mine/parent-change-password');
      } else {
        Navigator.of(context).pushReplacementNamed('/mine/parent-center');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        if (errorMsg.contains('40101')) {
          _errorText = '幼儿未登录，请重新登录';
        } else if (errorMsg.contains('40102')) {
          _errorText = 'Token已过期，请重新登录';
        } else if (errorMsg.contains('40103')) {
          _errorText = '密码错误，请重试';
        } else if (errorMsg.contains('40302')) {
          _errorText = '家长账号已被禁用';
        } else if (errorMsg.contains('40401')) {
          _errorText = '家长未绑定该幼儿';
        } else {
          _errorText = errorMsg;
        }
        _passwordController.text = '';
      });
      ToastUtils.showToast(context, _errorText ?? '密码验证失败');
      return;
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final red = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: YiBaseBackground(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: YiTopBar(
                title: '家长入口',
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [red, red.withValues(alpha: 0.75)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: red.withValues(alpha: 0.25),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 46,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      '家长验证',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3D2800),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '请输入家长密码以查看学习报告',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ParentEntryPasswordCard(
                      controller: _passwordController,
                      obscureText: _obscure,
                      onToggleObscure: () => setState(() {
                        _obscure = !_obscure;
                      }),
                      errorText: _errorText,
                      loading: _loading,
                      onSubmit: _onSubmit,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '默认密码：123456',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () {
                            ToastUtils.showToast(context, '请联系老师重置密码');
                          },
                          child: Text(
                            '忘记密码？',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const ParentEntryFeatureList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
