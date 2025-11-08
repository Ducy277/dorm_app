import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const QuickAction({required this.icon, required this.label, required this.color, this.onTap});
}

class QuickActions extends StatefulWidget {
  final List<QuickAction> actions;
  final int itemsPerPage;
  const QuickActions({super.key, required this.actions, this.itemsPerPage = 8});

  @override
  State<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final totalPages = (widget.actions.length / widget.itemsPerPage).ceil();
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * widget.itemsPerPage;
              final endIndex = (startIndex + widget.itemsPerPage).clamp(0, widget.actions.length);
              final pageItems = widget.actions.sublist(startIndex, endIndex);
              return GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                childAspectRatio: 1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: pageItems.map((action) {
                  return GestureDetector(
                    onTap: action.onTap,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(color: action.color.withOpacity(0.2), shape: BoxShape.circle),
                          padding: const EdgeInsets.all(12),
                          child: Icon(action.icon, color: action.color, size: 28),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          action.label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalPages, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isActive ? 16 : 6,
              decoration: BoxDecoration(color: isActive ? Colors.black87 : Colors.black26, borderRadius: BorderRadius.circular(3)),
            );
          }),
        )
      ],
    );
  }
}

