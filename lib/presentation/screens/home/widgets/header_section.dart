import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/room/room_bloc.dart';

class HeaderSection extends StatelessWidget {
  final VoidCallback onAvatarTap;
  final VoidCallback onNotificationTap;

  const HeaderSection({super.key, required this.onAvatarTap, required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.heroStart, AppColors.heroEnd],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white.withAlpha(77),
              child: const Icon(Icons.person_outline, size: 32, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final name = state is AuthAuthenticated ? state.user.name : 'Bạn';
                  return Text(
                    'Xin chào, $name',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                  );
                },
              ),
              BlocBuilder<RoomBloc, RoomState>(builder: (context, state) {
                String roomText = '—';
                if (state is RoomLoaded) {
                  roomText = state.room.roomCode;
                } else if (state is RoomsLoaded && state.rooms.isNotEmpty) {
                  roomText = state.rooms.first.roomCode;
                }
                return Text(
                  'Phòng $roomText',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 28),
            onPressed: onNotificationTap,
          ),
        ],
      ),
    );
  }
}
