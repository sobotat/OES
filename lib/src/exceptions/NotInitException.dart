
class NotInitException implements Exception {

  NotInitException({
    required this.message,
  });

  String message;

  @override
  String toString() {
    return 'NotInitException(message: $message)';
  }
}