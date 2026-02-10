import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/YiBaseBackground.dart';
import 'package:tsty_app/components/common/YiSideStripe.dart';
import 'package:tsty_app/components/common/YiTopBar.dart';
import 'package:tsty_app/components/profile/edit_profile/edit_profile_avatar_selector.dart';
import 'package:tsty_app/components/profile/edit_profile/edit_profile_form_group.dart';
import 'package:tsty_app/components/profile/edit_profile/edit_profile_submit_button.dart';
import 'package:tsty_app/components/profile/edit_profile/edit_profile_text_field.dart';
import 'package:tsty_app/api/child.dart';
import 'package:tsty_app/utils/ToastUtils.dart';
import 'package:tsty_app/utils/user_prefs.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController =
      TextEditingController(text: '阿依彝');

  bool _loading = false;
  bool _success = false;

  int _selectedAvatar = 0;

  final List<String> _avatars = const [
    'lib/assets/avatar01.webp',
    'lib/assets/avatar02.webp',
    'lib/assets/avatar03.webp',
    'lib/assets/avatar04.webp',
    'lib/assets/avatar05.webp',
  ];

  String get _submitText {
    if (_loading) return '正在保存...';
    if (_success) return '已保存';
    return '保存修改';
  }

  void _toast(String msg) {
    ToastUtils.showToast(context, msg);
  }

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final avatarIndex = await UserPrefs.getSelectedAvatarIndex();
    final profile = await UserPrefs.getChildProfile();
    final nickname = (profile?['nickname']?.toString() ?? '').trim();
    if (!mounted) return;
    setState(() {
      _selectedAvatar = avatarIndex;
      if (nickname.isNotEmpty) {
        _nameController.text = nickname;
      }
    });
  }

  Future<void> _onSave() async {
    if (_loading) return;

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _toast('请输入姓名！');
      return;
    }

    setState(() {
      _loading = true;
      _success = false;
    });

    try {
      await UserPrefs.setSelectedAvatarIndex(_selectedAvatar);

      final resp = await updateChildProfileAPI(nickname: name);
      final newNickname = (resp['nickname']?.toString() ?? '').trim();

      final existing = await UserPrefs.getChildProfile();
      final merged = <String, dynamic>{};
      if (existing != null) {
        merged.addAll(existing);
      }
      merged['nickname'] = newNickname.isEmpty ? name : newNickname;
      await UserPrefs.setChildProfile(merged);

      if (!mounted) return;
      setState(() {
        _loading = false;
        _success = true;
      });
      _toast('个人信息保存成功！');
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _toast(e.toString().replaceFirst('Exception: ', ''));
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
                  const YiTopBar(title: '修改个人信息'),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              EditProfileFormGroup(
                                label: '头像选择',
                                child: EditProfileAvatarSelector(
                                  avatarAssets: _avatars,
                                  selectedIndex: _selectedAvatar,
                                  onSelect: (i) {
                                    setState(() => _selectedAvatar = i);
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              EditProfileFormGroup(
                                label: '姓名',
                                child: EditProfileTextField(
                                  controller: _nameController,
                                  placeholder: '请输入姓名',
                                ),
                              ),
                              const SizedBox(height: 16),
                              EditProfileSubmitButton(
                                text: _submitText,
                                loading: _loading,
                                onPressed: _onSave,
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
