import 'package:doctor/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

enum AlertType { urgent, pending, message }

class DashboardAlert {
  final String id;
  final String name;
  final String message;
  final AlertType type;
  final String actionText;

  DashboardAlert({
    required this.id,
    required this.name,
    required this.message,
    required this.type,
    required this.actionText,
  });

  IconData get icon {
    switch (type) {
      case AlertType.urgent:
        return Icons.priority_high;
      case AlertType.pending:
        return Icons.pending;
      case AlertType.message:
        return Icons.mark_email_unread;
    }
  }

  Color get backgroundColor {
    switch (type) {
      case AlertType.urgent:
        return AppColors.errorContainer.withOpacity(0.2);
      case AlertType.pending:
        return AppColors.surfaceContainerLow;
      case AlertType.message:
        return AppColors.surfaceContainerLow;
    }
  }

  Color get borderColor {
    switch (type) {
      case AlertType.urgent:
        return AppColors.errorContainer;
      case AlertType.pending:
        return AppColors.surfaceContainerHighest;
      case AlertType.message:
        return AppColors.surfaceContainerHighest;
    }
  }

  Color get iconColor {
    switch (type) {
      case AlertType.urgent:
        return AppColors.error;
      case AlertType.pending:
        return AppColors.outline;
      case AlertType.message:
        return AppColors.outline;
    }
  }

  factory DashboardAlert.fromJson(Map<String, dynamic> json) {
    // Parse based on your API response structure
    return DashboardAlert(
      id: json['id']?.toString() ?? '',
      name: json['patient_name'] ?? json['name'] ?? 'Unknown Patient',
      message: json['message'] ?? json['description'] ?? 'No message',
      type: _parseAlertType(json['type'] ?? ''),
      actionText: json['action_text'] ?? 'View Details',
    );
  }

  static AlertType _parseAlertType(String type) {
    switch (type.toLowerCase()) {
      case 'urgent':
      case 'emergency':
        return AlertType.urgent;
      case 'pending':
        return AlertType.pending;
      default:
        return AlertType.message;
    }
  }
}
