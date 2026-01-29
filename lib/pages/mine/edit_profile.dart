import 'package:flutter/material.dart';
import 'package:tsty_app/components/common/YiBaseBackground.dart';
import 'package:tsty_app/components/common/YiSideStripe.dart';
import 'package:tsty_app/components/common/YiTopBar.dart';
import 'package:tsty_app/components/profile/edit_profile/edit_profile_avatar_selector.dart';
import 'package:tsty_app/components/profile/edit_profile/edit_profile_dropdown_field.dart';
import 'package:tsty_app/components/profile/edit_profile/edit_profile_form_group.dart';
import 'package:tsty_app/components/profile/edit_profile/edit_profile_submit_button.dart';
import 'package:tsty_app/components/profile/edit_profile/edit_profile_text_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController =
      TextEditingController(text: '阿依彝');
  final TextEditingController _schoolController =
      TextEditingController(text: '向阳幼儿园二班');

  bool _loading = false;
  bool _success = false;

  int _selectedAvatar = 0;
  String? _gender = 'female';
  String? _age = '4';
  String? _grade = 'middle';

  final List<String> _avatars = const [
    'lib/assets/avatar01.webp',
    'lib/assets/avatar02.webp',
    'lib/assets/avatar03.webp',
    'lib/assets/avatar04.webp',
    'lib/assets/avatar05.webp',
  ];

  List<EditProfileDropdownOption> get _genderOptions => const [
        EditProfileDropdownOption(label: '女生', value: 'female'),
        EditProfileDropdownOption(label: '男生', value: 'male'),
      ];

  List<EditProfileDropdownOption> get _ageOptions => const [
        EditProfileDropdownOption(label: '3岁', value: '3'),
        EditProfileDropdownOption(label: '4岁', value: '4'),
        EditProfileDropdownOption(label: '5岁', value: '5'),
        EditProfileDropdownOption(label: '6岁', value: '6'),
        EditProfileDropdownOption(label: '7岁', value: '7'),
      ];

  List<EditProfileDropdownOption> get _gradeOptions => const [
        EditProfileDropdownOption(label: '小班', value: 'small'),
        EditProfileDropdownOption(label: '中班', value: 'middle'),
        EditProfileDropdownOption(label: '大班', value: 'big'),
      ];

  String get _submitText {
    if (_loading) return '正在保存...';
    if (_success) return '已保存';
    return '保存修改';
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onSave() async {
    if (_loading) return;

    final name = _nameController.text.trim();
    final school = _schoolController.text.trim();

    if (name.isEmpty) {
      _toast('请输入姓名！');
      return;
    }

    if (school.isEmpty) {
      _toast('请输入幼儿园名称！');
      return;
    }

    setState(() {
      _loading = true;
      _success = false;
    });

    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _loading = false;
      _success = true;
    });
    _toast('个人信息保存成功！');

    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
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
                              EditProfileFormGroup(
                                label: '性别',
                                child: EditProfileDropdownField(
                                  value: _gender,
                                  placeholder: '请选择性别',
                                  options: _genderOptions,
                                  onChanged: (v) {
                                    setState(() => _gender = v);
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              EditProfileFormGroup(
                                label: '年龄',
                                child: EditProfileDropdownField(
                                  value: _age,
                                  placeholder: '请选择年龄',
                                  options: _ageOptions,
                                  onChanged: (v) {
                                    setState(() => _age = v);
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              EditProfileFormGroup(
                                label: '班级',
                                child: EditProfileDropdownField(
                                  value: _grade,
                                  placeholder: '请选择班级',
                                  options: _gradeOptions,
                                  onChanged: (v) {
                                    setState(() => _grade = v);
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              EditProfileFormGroup(
                                label: '幼儿园',
                                child: EditProfileTextField(
                                  controller: _schoolController,
                                  placeholder: '请输入幼儿园名称',
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
