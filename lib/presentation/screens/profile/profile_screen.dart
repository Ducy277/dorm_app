import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../bloc/auth/auth_bloc.dart';

/// Màn hình tài khoản cá nhân.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.profile)),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tên: ${user.name}', style: Theme.of(context).textTheme.titleMedium),
                  Text('Email: ${user.email}'),
                  Text('Vai trò: ${user.role}'),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: AppStrings.logout,
                    onPressed: () {
                      context.read<AuthBloc>().add(const LogoutRequested());
                    },
                  ),
                ],
              ),
            ),
          );
        } else if (state is AuthUnauthenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.profile)),
            body: const Center(child: Text('Chưa đăng nhập')),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}