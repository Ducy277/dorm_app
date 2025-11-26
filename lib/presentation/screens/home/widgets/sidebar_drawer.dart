import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_gradients.dart';
import '../../../bloc/auth/auth_bloc.dart';

class SidebarDrawer extends StatelessWidget {
  final void Function(String route) onNavigate;
  const SidebarDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;
    final userName = isAuthenticated ? authState.user.name : 'Khách';

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(gradient: AppGradients.heroBlue),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(Icons.person_outline, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            isAuthenticated ? 'Sinh viên' : 'Chưa đăng nhập',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      _DrawerTile(
                        icon: Icons.home_outlined,
                        label: 'Trang chủ',
                        onTap: () => onNavigate('/'),
                      ),
                      _DrawerTile(
                        icon: Icons.person_outline,
                        label: 'Hồ sơ',
                        onTap: () => onNavigate('/profile'),
                      ),
                      _DrawerTile(
                        icon: Icons.settings_outlined,
                        label: 'Cài đặt (đang phát triển)',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      if (isAuthenticated)
                        _DrawerTile(
                          icon: Icons.logout,
                          label: 'Đăng xuất',
                          iconColor: Colors.red,
                          textColor: Colors.red,
                          onTap: () {
                            context.read<AuthBloc>().add(const LogoutRequested());
                            onNavigate('/login');
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black87),
      title: Text(label, style: TextStyle(color: textColor ?? Colors.black87)),
      onTap: onTap,
    );
  }
}
