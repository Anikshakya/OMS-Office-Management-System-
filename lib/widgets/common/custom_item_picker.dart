import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Opens a generic Cupertino-style item picker sheet/dialog.
///
/// Accepts any type [T] (e.g. String, int, Map, Object).
/// Returns the selected item of type [T], or null if dismissed without selecting.
Future<T?> showCustomCupertinoItemPicker<T>({
  required BuildContext context,
  required List<T> items,
  T? initialItem,
  required String Function(T item) itemLabelBuilder,
  String title = 'Select Item',
  Color? headerColor,
  Color? accentColor,
  double itemExtent = 42.0,
}) async {
  final ThemeData theme = Theme.of(context);
  final Color selectedAccentColor = accentColor ?? theme.colorScheme.primary;
  final Color dialogBackgroundColor =
      headerColor ??
      theme.dialogTheme.backgroundColor ??
      theme.colorScheme.surface;
  final Color textColor = theme.colorScheme.onSurface;

  if (items.isEmpty) return null;

  // Determine initial index
  int selectedIndex = 0;
  if (initialItem != null) {
    final index = items.indexOf(initialItem);
    if (index != -1) {
      selectedIndex = index;
    }
  }

  T tempSelectedItem = items[selectedIndex];
  final FixedExtentScrollController scrollController =
      FixedExtentScrollController(initialItem: selectedIndex);

  return showDialog<T>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: dialogBackgroundColor,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              width: 380,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. HEADER BAR: Close (X) | Title | Checkmark (✓)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close Button
                      GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: textColor.withValues(alpha: 0.08),
                            border: Border.all(
                              color: textColor.withValues(alpha: 0.12),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: textColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),

                      // Title
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Confirm Checkmark Button
                      GestureDetector(
                        onTap: () {
                          Navigator.of(dialogContext).pop(tempSelectedItem);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedAccentColor,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 2. CUPERTINO PICKER WHEEL
                  SizedBox(
                    height: 250,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness: theme.brightness,
                        primaryColor: selectedAccentColor,
                        textTheme: CupertinoTextThemeData(
                          pickerTextStyle: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      child: CupertinoPicker(
                        scrollController: scrollController,
                        itemExtent: itemExtent,
                        magnification: 1.15,
                        squeeze: 1.1,
                        useMagnifier: true,
                        selectionOverlay: Container(
                          decoration: BoxDecoration(
                            color: selectedAccentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.symmetric(
                              horizontal: BorderSide(
                                color: selectedAccentColor.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        onSelectedItemChanged: (int index) {
                          setDialogState(() {
                            selectedIndex = index;
                            tempSelectedItem = items[index];
                          });
                        },
                        children: items.map((T item) {
                          final String label = itemLabelBuilder(item);
                          final bool isSelected = items.indexOf(item) == selectedIndex;

                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: isSelected
                                      ? selectedAccentColor
                                      : textColor.withValues(alpha: 0.7),
                                  fontSize: 18,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}