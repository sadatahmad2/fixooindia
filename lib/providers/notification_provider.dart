import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppNotification {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  bool isUnread;

  AppNotification({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    this.isUnread = true,
  });
}

class NotificationProvider with ChangeNotifier {
  bool _isListening = false;
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void deleteNotification(int index) {
    _notifications.removeAt(index);
    notifyListeners();
  }

  void initRealtime(String userId) {
    if (_isListening) return;
    _isListening = true;

    Supabase.instance.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((data) {
          _notifications.clear();
          for (var item in data) {
            _notifications.add(AppNotification(
              title: item['title'] ?? 'Notification',
              body: item['body'] ?? '',
              time: 'Recently',
              icon: _getIconForName(item['icon_name']),
              isUnread: !(item['is_read'] ?? false),
            ));
          }
          notifyListeners();
        });
  }

  IconData _getIconForName(String? name) {
    switch (name) {
      case 'zap': return LucideIcons.zap;
      case 'wallet': return LucideIcons.wallet;
      case 'list-todo': return LucideIcons.listTodo;
      case 'check': return LucideIcons.circleCheckBig;
      default: return LucideIcons.bell;
    }
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isUnread = false;
    }
    notifyListeners();
  }
}
