import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';
    
    final errorString = error.toString();
    
    // Network errors
    if (errorString.contains('SocketException') || 
        errorString.contains('NetworkException')) {
      return 'No internet connection. Please check your network.';
    }
    
    // Timeout errors
    if (errorString.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    
    // Authentication errors
    if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      return 'Session expired. Please login again.';
    }
    
    // Server errors
    if (errorString.contains('500') || errorString.contains('502') || 
        errorString.contains('503')) {
      return 'Server error. Please try again later.';
    }
    
    // Not found
    if (errorString.contains('404')) {
      return 'Resource not found.';
    }
    
    // Generic error
    return 'Something went wrong. Please try again.';
  }

  static Future<void> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    if (!context.mounted) return;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
