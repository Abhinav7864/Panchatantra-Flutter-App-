import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryChipItem {
  final String label;
  final String emoji;
  final String subtitle;

  const CategoryChipItem({
    required this.label,
    required this.emoji,
    required this.subtitle,
  });
}

class CategoryChipRow extends StatelessWidget {
  final String selectedLabel;
  final ValueChanged<String> onSelected;

  const CategoryChipRow({
    super.key,
    required this.selectedLabel,
    required this.onSelected,
  });

  static const List<CategoryChipItem> items = [
    CategoryChipItem(label: 'Books', emoji: '📖', subtitle: 'Fables'),
    CategoryChipItem(label: 'Games', emoji: '🎮', subtitle: 'Play'),
    CategoryChipItem(label: 'Quiz', emoji: '❓', subtitle: 'Think'),
    CategoryChipItem(label: 'Writing', emoji: '📝', subtitle: 'Create'),
    CategoryChipItem(label: 'Lessons', emoji: '🎓', subtitle: 'Learn'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 11),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedLabel == item.label;

          return GestureDetector(
            onTap: () => onSelected(item.label),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 62,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: isSelected ? 0.98 : 0.16),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: isSelected ? 0.95 : 0.22),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? Colors.black.withValues(alpha: 0.16)
                              : Colors.black.withValues(alpha: 0.04),
                          blurRadius: isSelected ? 14 : 6,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 27, height: 1),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.label,
                    style: GoogleFonts.nunito(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: Colors.white.withValues(alpha: isSelected ? 1 : 0.74),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
