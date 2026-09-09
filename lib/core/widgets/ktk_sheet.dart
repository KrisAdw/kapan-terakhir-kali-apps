import 'package:flutter/material.dart';

import '../design/app_tokens.dart';

/// Bottom sheet container bergaya neo-brutalism (design.md §7):
/// overlay rgba(0,0,0,0.55), slide-up 280 ms, cream container dengan border
/// ink 2.5px di atas, dan drag handle 44×5.
Future<T?> showKtkSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppT.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            border: Border(
              top: BorderSide(color: AppT.ink, width: AppT.borderW),
              left: BorderSide(color: AppT.ink, width: AppT.borderW),
              right: BorderSide(color: AppT.ink, width: AppT.borderW),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppT.ink.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: Builder(builder: builder),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Tombol utama sheet — full-width, kuning, hard shadow (design.md §4/§7).
final class KtkPrimaryButton extends StatelessWidget {
  const KtkPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.background = AppT.yellow,
    this.foreground = AppT.ink,
  });

  final String label;
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    // Fill lives in the SAME BoxDecoration as the shadow: a BoxDecoration
    // paints its shadows behind its own fill. If the fill were on the
    // Material instead, the shadow would paint on top of it and cover the
    // button face.
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppT.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppT.radius),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: AppT.ink, width: AppT.borderW),
            borderRadius: BorderRadius.circular(AppT.radius),
            boxShadow: const [BoxShadow(offset: Offset(3, 3), color: AppT.ink)],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppT.fontDisplay,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}
