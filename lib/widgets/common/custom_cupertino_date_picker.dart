import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<DateTime?> showCustomCupertinoDatePicker({
  required BuildContext context,
  required TextEditingController controller,
  DateTime? minDate,
  DateTime? maxDate,
  Color? headerColor,
  Color? accentColor,
  String title = 'Select Date',
  String dateFormat = 'yyyy-MM-dd',
  bool showTime = false,
  String timeFormat = 'h:mm a',
  Locale? locale, // Optional explicit locale override (e.g. Locale('ja'))
}) async {
  final ThemeData theme = Theme.of(context);
  final Color selectedAccentColor = accentColor ?? theme.colorScheme.primary;

  // Resolve active locale (passed locale -> context locale -> default fallback)
  final Locale activeLocale = locale ?? Localizations.localeOf(context);
  final String localeString = activeLocale.toString();

  final DateFormat dateFormatter = DateFormat(dateFormat, localeString);
  final DateFormat timeFormatter = DateFormat(timeFormat, localeString);
  final DateTime now = DateTime.now();

  final DateFormat combinedFormatter = showTime
      ? DateFormat('$dateFormat $timeFormat', localeString)
      : dateFormatter;

  // Bounds & normalization
  final DateTime normalizedMinDate = minDate != null
      ? DateTime(minDate.year, minDate.month, minDate.day)
      : DateTime(1900, 1, 1);
  final DateTime normalizedMaxDate = maxDate != null
      ? DateTime(
          maxDate.year,
          maxDate.month,
          maxDate.day,
          23,
          59,
          59,
        )
      : DateTime(2100, 12, 31);

  DateTime initialDateTime;
  if (controller.text.trim().isNotEmpty) {
    try {
      initialDateTime = combinedFormatter.parseStrict(controller.text.trim());
    } catch (_) {
      try {
        initialDateTime = dateFormatter.parseStrict(controller.text.trim());
      } catch (_) {
        initialDateTime = now;
      }
    }
  } else {
    initialDateTime = now;
  }

  if (initialDateTime.isBefore(normalizedMinDate)) {
    initialDateTime = normalizedMinDate;
  }
  if (initialDateTime.isAfter(normalizedMaxDate)) {
    initialDateTime = normalizedMaxDate;
  }

  DateTime tempSelectedDate = initialDateTime;
  bool isEditingTime = false;

  return showDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      final Color dialogBackgroundColor =
          headerColor ??
          theme.dialogTheme.backgroundColor ??
          theme.colorScheme.surface;
      final Color pillBackgroundColor =
          theme.cardTheme.color ?? theme.colorScheme.surface;
      final Color textColor = theme.colorScheme.onSurface;

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
              width: 360,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. TOP HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.text =
                              combinedFormatter.format(tempSelectedDate);
                          Navigator.of(dialogContext).pop(tempSelectedDate);
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

                  // 2. BUBBLY PILLS (Localized Date & Time String)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (isEditingTime) {
                            setDialogState(() {
                              isEditingTime = false;
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: showTime ? 150 : 180,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: pillBackgroundColor,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: !isEditingTime
                                  ? selectedAccentColor.withValues(alpha: 0.3)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            DateFormat.yMMMd(localeString)
                                .format(tempSelectedDate),
                            style: TextStyle(
                              color: !isEditingTime
                                  ? selectedAccentColor
                                  : textColor.withValues(alpha: 0.6),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (showTime) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (!isEditingTime) {
                              setDialogState(() {
                                isEditingTime = true;
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 110,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: pillBackgroundColor,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: isEditingTime
                                    ? selectedAccentColor.withValues(alpha: 0.3)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              timeFormatter.format(tempSelectedDate),
                              style: TextStyle(
                                color: isEditingTime
                                    ? selectedAccentColor
                                    : textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 3. DYNAMIC PICKER CONTENT
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: isEditingTime
                        ? SizedBox(
                            key: const ValueKey("TimePicker"),
                            height: 320,
                            child: CupertinoTheme(
                              data: CupertinoThemeData(
                                brightness: theme.brightness,
                                primaryColor: selectedAccentColor,
                                textTheme: CupertinoTextThemeData(
                                  dateTimePickerTextStyle: TextStyle(
                                    color: textColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.time,
                                initialDateTime: tempSelectedDate,
                                onDateTimeChanged: (DateTime newDateTime) {
                                  setDialogState(() {
                                    tempSelectedDate = DateTime(
                                      tempSelectedDate.year,
                                      tempSelectedDate.month,
                                      tempSelectedDate.day,
                                      newDateTime.hour,
                                      newDateTime.minute,
                                    );
                                  });
                                },
                              ),
                            ),
                          )
                        : SizedBox(
                            key: const ValueKey("CalendarPicker"),
                            height: 330,
                            child: Theme(
                              data: theme.copyWith(
                                colorScheme: theme.colorScheme.copyWith(
                                  primary: selectedAccentColor,
                                  onPrimary: theme.colorScheme.onPrimary,
                                  surface: dialogBackgroundColor,
                                  onSurface: textColor,
                                ),
                                iconTheme: IconThemeData(
                                  color: selectedAccentColor,
                                  size: 24,
                                ),
                                // Fine-tuned DatePickerTheme to fix circle size & text padding
                                datePickerTheme: DatePickerThemeData(
                                  dayShape: WidgetStateProperty.all(
                                    const CircleBorder(),
                                  ),
                                  dayStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                textTheme: theme.textTheme.copyWith(
                                  titleMedium: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  bodyLarge: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  bodyMedium: TextStyle(
                                    color: textColor.withValues(alpha: 0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              child: Localizations.override(
                                context: context,
                                locale: activeLocale,
                                child: CalendarDatePicker(
                                  initialDate: tempSelectedDate,
                                  firstDate: normalizedMinDate,
                                  lastDate: normalizedMaxDate,
                                  onDateChanged: (DateTime newDate) {
                                    setDialogState(() {
                                      tempSelectedDate = DateTime(
                                        newDate.year,
                                        newDate.month,
                                        newDate.day,
                                        tempSelectedDate.hour,
                                        tempSelectedDate.minute,
                                      );
                                    });
                                  },
                                ),
                              ),
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