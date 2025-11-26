import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/models/user_model.dart';
import '../../bloc/auth/auth_bloc.dart';

/// Màn hình quản lý hồ sơ sinh viên.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  bool _requestedProfile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedProfile) {
      final bloc = context.read<AuthBloc>();
      bloc.add(const FetchProfile());
      final current = bloc.state;
      if (current is AuthAuthenticated) {
        _fillForm(current.user);
      }
      _requestedProfile = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _genderCtrl.dispose();
    _classCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  void _fillForm(UserModel user) {
    _nameCtrl.text = user.name;
    _emailCtrl.text = user.email;
    _phoneCtrl.text = user.student?.phone ?? '';
    _addressCtrl.text = user.student?.address ?? '';
    _genderCtrl.text = user.student?.gender ?? '';
    _classCtrl.text = user.student?.studentClass ?? '';
    _dobCtrl.text = user.student?.dateOfBirth ?? '';
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
          UpdateProfileRequested(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
            address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
            gender: _genderCtrl.text.trim().isEmpty ? null : _genderCtrl.text.trim(),
            dateOfBirth: _dobCtrl.text.trim().isEmpty ? null : _dobCtrl.text.trim(),
            studentClass: _classCtrl.text.trim().isEmpty ? null : _classCtrl.text.trim(),
          ),
        );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _dobCtrl.text.isNotEmpty ? DateTime.tryParse(_dobCtrl.text) ?? now : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 60),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      final formatted =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _dobCtrl.text = formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: () => context.read<AuthBloc>().add(const FetchProfile()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _fillForm(state.user);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AuthAuthenticated) {
            return _ProfileForm(
              formKey: _formKey,
              nameCtrl: _nameCtrl,
              emailCtrl: _emailCtrl,
              phoneCtrl: _phoneCtrl,
              addressCtrl: _addressCtrl,
              genderCtrl: _genderCtrl,
              classCtrl: _classCtrl,
              dobCtrl: _dobCtrl,
              onPickDate: _pickDate,
              onSave: _submit,
            );
          } else if (state is AuthUnauthenticated) {
            return const Center(child: Text('Bạn chưa đăng nhập.'));
          } else if (state is AuthError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          label: AppStrings.logout,
          onPressed: () => context.read<AuthBloc>().add(const LogoutRequested()),
        ),
      ),
    );
  }
}

class _ProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController genderCtrl;
  final TextEditingController classCtrl;
  final TextEditingController dobCtrl;
  final VoidCallback onPickDate;
  final VoidCallback onSave;

  const _ProfileForm({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.genderCtrl,
    required this.classCtrl,
    required this.dobCtrl,
    required this.onPickDate,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Vui lòng nhập họ tên' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailCtrl,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'Địa chỉ'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: classCtrl,
              decoration: const InputDecoration(labelText: 'Lớp'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: genderCtrl,
              decoration: const InputDecoration(labelText: 'Giới tính'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: dobCtrl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Ngày sinh (YYYY-MM-DD)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: onPickDate,
                ),
              ),
              onTap: onPickDate,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSave,
                child: const Text('Lưu thay đổi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

