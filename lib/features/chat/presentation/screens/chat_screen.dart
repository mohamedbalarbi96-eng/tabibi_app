import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// TABIBI (طبيبي) - Secure Telemedicine Chat & Messaging Screen
class ChatScreen extends StatefulWidget {
  final int? initialReceiverId;
  final String? initialReceiverName;

  const ChatScreen({
    super.key,
    this.initialReceiverId,
    this.initialReceiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int? _activeReceiverId;
  String _activeReceiverName = '';
  List<Map<String, dynamic>> _contacts = [];
  List<Map<String, dynamic>> _messages = [];
  bool _isLoadingContacts = true;
  bool _isSending = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _activeReceiverId = widget.initialReceiverId;
    _activeReceiverName = widget.initialReceiverName ?? 'محادثة طبية';
    _fetchContacts();

    if (_activeReceiverId != null) {
      _startMessagesPolling();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startMessagesPolling() {
    _pollingTimer?.cancel();
    _fetchMessages();
    // فحص وجلب الرسائل الجديدة كل 4 ثوانٍ
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) => _fetchMessages());
  }

  Future<void> _fetchContacts() async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.baseUrl}/doctors/list.php');
      final data = response.data;
      if (data['success'] == true) {
        final docs = (data['data']['doctors'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        setState(() {
          _contacts = docs;
          _isLoadingContacts = false;
        });
      }
    } catch (_) {
      setState(() => _isLoadingContacts = false);
    }
  }

  Future<void> _fetchMessages() async {
    if (_activeReceiverId == null) return;

    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.baseUrl}/chat/messages.php',
        queryParameters: {'receiver_id': _activeReceiverId},
      );
      final data = response.data;
      if (data['success'] == true) {
        final msgs = (data['data']['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        setState(() {
          _messages = msgs;
        });
      }
    } catch (_) {
      // تجنب مقاطعة المستخدم عند حدوث تذبذب مؤقت في الاتصال
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _activeReceiverId == null || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await _apiClient.post(
        '${ApiEndpoints.baseUrl}/chat/messages.php',
        data: {
          'action': 'send_message',
          'receiver_id': _activeReceiverId,
          'message_text': text,
        },
      );

      setState(() => _isSending = false);
      _fetchMessages();
      _scrollToBottom();
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الإرسال: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_activeReceiverId == null ? 'الرسائل والمحادثات الطبية' : _activeReceiverName),
        centerTitle: true,
        leading: _activeReceiverId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  _pollingTimer?.cancel();
                  setState(() {
                    _activeReceiverId = null;
                    _messages = [];
                  });
                },
              )
            : null,
      ),
      body: _activeReceiverId == null ? _buildContactsView(theme) : _buildChatConversationView(theme),
    );
  }

  /// 1. واجهة قائمة جهات الاتصال المتاحة
  Widget _buildContactsView(ThemeData theme) {
    if (_isLoadingContacts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_contacts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 54, color: Colors.grey),
              SizedBox(height: 12),
              Text('لا توجد محادثات نشطة حالياً.', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        final name = contact['full_name'] ?? 'طبيب';
        final spec = contact['specialization_name'] ?? 'استشارة طبية';
        final userId = contact['user_id'] as int? ?? contact['doctor_id'] as int;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Text('👨‍⚕️', style: TextStyle(fontSize: 22, color: theme.colorScheme.primary)),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(spec, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            onTap: () {
              setState(() {
                _activeReceiverId = userId;
                _activeReceiverName = name;
              });
              _startMessagesPolling();
            },
          ),
        );
      },
    );
  }

  /// 2. واجهة غرفة المحادثة الفورية والرسائل
  Widget _buildChatConversationView(ThemeData theme) {
    return Column(
      children: [
        // شريط الأمان والتشفير
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          color: Colors.green.shade50,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF047857)),
              SizedBox(width: 6),
              Text(
                'المحادثة مشفرة وآمنة وفق معايير خصوصية المريض TABIBI',
                style: TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // قائمة فقاعات الرسائل
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mark_chat_unread_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text('لا توجد رسائل سابقة. اكتب رسالتك بالأسفل لبدء المحادثة.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe = msg['is_me'] == true || msg['sender_id'] == null;
                    final text = msg['message_text']?.toString() ?? '';
                    final time = msg['created_at'] != null ? msg['created_at'].toString().split(' ').last.substring(0, 5) : '';

                    return Align(
                      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? theme.colorScheme.primary : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(isMe ? 2 : 14),
                            bottomRight: Radius.circular(isMe ? 14 : 2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                          children: [
                            Text(
                              text,
                              style: TextStyle(fontSize: 13, color: isMe ? Colors.white : Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: TextStyle(fontSize: 9, color: isMe ? Colors.white70 : Colors.black45),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // صندوق كتابة وإرسال الرسالة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك الطبية هنا...',
                      hintStyle: const TextStyle(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.grey.shade300)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  radius: 22,
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}