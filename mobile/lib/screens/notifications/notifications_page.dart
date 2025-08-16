import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Color(0xFFF7F7FA),
    ));
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await _db.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      if (mounted) {
        setState(() {
          _error = 'Bildirimler yüklenirken bir hata oluştu';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final success = await _db.markAllNotificationsAsRead();
      if (success && mounted) {
        setState(() {
          for (var notification in _notifications) {
            notification['is_read'] = true;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tüm bildirimler okundu olarak işaretlendi'),
            backgroundColor: Color(0xFFB8835A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      print('Error marking notifications as read: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markNotificationAsRead(int index) async {
    if (_notifications[index]['is_read'] == true) return;
    
    try {
      final notificationId = _notifications[index]['id'];
      if (notificationId == null) return;

      final success = await _db.markNotificationAsRead(notificationId.toString());
      if (success && mounted) {
        setState(() {
          _notifications[index]['is_read'] = true;
        });
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bildirim işaretlenirken bir hata oluştu'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Text(
            'Bildirimler',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 0.2,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: _markAllAsRead,
              icon: Icon(Icons.done_all, color: theme.colorScheme.onPrimary, size: 18),
              label: Text(
                'Tümünü Okundu',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
              : _error.isNotEmpty
                  ? Center(
                      child: Text(
                        _error,
                        style: TextStyle(color: theme.colorScheme.error, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    )
                  : _notifications.isEmpty
                      ? Center(
                          child: Text(
                            'Henüz bildiriminiz bulunmuyor',
                            style: TextStyle(
                              color: theme.hintColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            final isRead = notification['is_read'] == true;
                            return GestureDetector(
                              onTap: () => _markNotificationAsRead(index),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 18),
                                decoration: BoxDecoration(
                                  color: isRead ? theme.cardColor : theme.colorScheme.primary.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isRead 
                                          ? Colors.black.withOpacity(0.03)
                                          : theme.colorScheme.primary.withOpacity(0.10),
                                      blurRadius: isRead ? 6 : 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: isRead
                                        ? theme.dividerColor.withOpacity(0.12)
                                        : theme.colorScheme.primary.withOpacity(0.25),
                                    width: isRead ? 1 : 2,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                  leading: Stack(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: isRead ? theme.colorScheme.primary.withOpacity(0.10) : theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                          boxShadow: isRead ? [] : [
                                            BoxShadow(
                                              color: theme.colorScheme.primary.withOpacity(0.18),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.notifications,
                                          color: isRead ? theme.colorScheme.primary : theme.colorScheme.onPrimary,
                                          size: 24,
                                        ),
                                      ),
                                      if (!isRead)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.secondary,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  title: Text(
                                    notification['title'] ?? 'Bildirim',
                                    style: TextStyle(
                                      fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                      color: isRead ? theme.colorScheme.onBackground : theme.colorScheme.primary,
                                      fontSize: 16,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      notification['message'] ?? 'Mesaj bulunamadı',
                                      style: TextStyle(
                                        color: isRead ? theme.textTheme.bodyMedium?.color : theme.colorScheme.onBackground,
                                        fontSize: 14,
                                        height: 1.4,
                                        fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  trailing: !isRead ? 
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'YENİ',
                                        style: TextStyle(
                                          color: theme.colorScheme.onPrimary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ) : 
                                    Icon(
                                      Icons.check_circle,
                                      color: theme.colorScheme.primary.withOpacity(0.5),
                                      size: 20,
                                    ),
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}