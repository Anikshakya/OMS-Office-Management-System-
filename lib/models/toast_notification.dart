class ToastNotification {
  final String id;
  final String title;
  final String message;
  final ToastType type;

  const ToastNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
  });
}

enum ToastType { success, error, warning, info }
