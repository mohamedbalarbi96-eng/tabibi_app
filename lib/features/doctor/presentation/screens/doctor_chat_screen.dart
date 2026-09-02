import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_bento_card.dart';

/// TABIBI (طبيبي) - Ultra-Modern Doctor Secure Chat & Medical Consultations Hub
/// Matched 100% with the official Doctor Chat screenshot
class DoctorChatScreen extends StatefulWidget {
  const DoctorChatScreen({super.key});

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _searchContactCtrl = TextEditingController();
  final TextEditingController _msgInputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  int? _selectedContactIndex;

  // قائمة جهات الاتصال المطابقة للصورة
  final List<Map<String, dynamic>> _contacts = [
    {'name': 'بلعربي الهادي', 'role': 'المريض', 'unread': 1, 'avatar_color': Color(0xFF10B981)},
    {'name': 'محمد بلعربي', 'role': 'المريض', 'unread': 0, 'avatar_color': Color(0xFF0284C7)},
    {'name': 'Azer Azee', 'role': 'المريض', 'unread': 0, 'avatar_color': Color(0xFF8B5CF6)},
    {'name': 'jtjrjjrrj dndnc cm', 'role': 'المريض', 'unread': 0, 'avatar_color': Color(0xFFF59E0B)},
    {'name': 'test test', 'role': 'المريض', 'unread': 0, 'avatar_color': Colors.grey},
    {'name': 'المدير العام', 'role': 'المدير العام', 'unread': 0, 'avatar_color': Color(0xFF059669)},
  ];

  // سجل المحادثة مع المريض المحدد
  final List<Map<String, dynamic>> _messages = [
    {
      'is_me': false,
      'text': 'السلام عليكم دكتور، قمت بإجراء تحاليل الدم وتخطيط القلب كما طلبت مني.',
      'time': '09:15',
    },
    {
      'is_me': true,
      'text': 'وعليكم السلام ورحمة الله، ممتاز يا بلعربي. كيف تشعر الآن مع دواء Doliprane؟',
      'time': '09:18',
    },
    {
      'is_me': false,
      'text': 'الحمد لله الألم خف كثيراً وضغط الدم مستقر عند 120/80.',
      'time': '09:20',
    },
  ];

  @override
  void dispose() {
    _searchContactCtrl.dispose();
    _msgInputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgInputCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'is_me': true,
        'text': text,
        'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      });
      _msgInputCtrl.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = _contacts.where((c) {
      final q = _searchContactCtrl.text.trim().toLowerCase();
      return c['name'].toString().toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('طبيبي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppTheme.primary)),
            SizedBox(width: 6),
            Text('| مركز الرسائل والمحادثات الطبية', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: AmbientLightBackground(
        child: _selectedContactIndex == null
            ? _buildContactsListView(filteredContacts)
            : _buildActiveChatView(_contacts[_selectedContactIndex!]),
      ),
    );
  }

  Widget _buildContactsListView(List<Map<String, dynamic>> contacts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // بانر الترحيب بالمحادثات
          GlassBentoCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(18),
            enableGlow: true,
            glowColor: AppTheme.secondary,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.secondary, size: 36),
                ),
                const SizedBox(height: 10),
                const Text(
                  'مرحباً بك في مركز المحادثات والرسائل الآمنة',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textMain),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'اختر مريضاً أو زميلاً من القائمة أدناه لبدء المحادثة ومتابعة الفحوصات الطبية بأمان وتشفير كامل.',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // حقل البحث في جهات الاتصال
          TextField(
            controller: _searchContactCtrl,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5),
            decoration: InputDecoration(
              hintText: 'البحث في جهات الاتصال النشطة...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),

          // عنوان القائمة
          Row(
            children: [
              Container(width: 4, height: 16, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 8),
              const Text('💬 جهات الاتصال النشطة', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
            ],
          ),
          const SizedBox(height: 10),

          // قائمة جهات الاتصال المطابقة للصورة
          ...List.generate(contacts.length, (i) {
            final c = contacts[i];
            final int unread = c['unread'] ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GlassBentoCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(12),
                onTap: () => setState(() => _selectedContactIndex = _contacts.indexOf(c)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: (c['avatar_color'] as Color).withValues(alpha: 0.15),
                      child: Text(
                        c['name'].toString().isNotEmpty ? c['name'][0] : '👤',
                        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: c['avatar_color'] as Color, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.textMain)),
                          Text(c['role'], style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    if (unread > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                        child: Text('$unread جديد', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                      )
                    else
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildActiveChatView(Map<String, dynamic> contact) {
    return Column(
      children: [
        // شريط رأس المحادثة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                onPressed: () => setState(() => _selectedContactIndex = null),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: (contact['avatar_color'] as Color).withValues(alpha: 0.15),
                child: Text(contact['name'][0], style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: contact['avatar_color'] as Color)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact['name'], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 13)),
                    const Text('متصل الآن 🟢 (تشفير طبي آمن)', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // قائمة الرسائل
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final bool isMe = msg['is_me'] == true;

              return Align(
                alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isMe ? AppTheme.primaryGradient : null,
                    color: isMe ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 4 : 16),
                      bottomRight: Radius.circular(isMe ? 16 : 4),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: [
                      Text(
                        msg['text'].toString(),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isMe ? Colors.white : AppTheme.textMain,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg['time'].toString(),
                        style: TextStyle(fontFamily: 'monospace', fontSize: 9.5, color: isMe ? Colors.white70 : Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // حقل إدخال الرسالة ومشاركة المرفقات
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -3)),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file_rounded, color: AppTheme.secondary),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('إرفاق وصفة أو تقرير أشعة في المحادثة...', style: TextStyle(fontFamily: 'Cairo'))),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _msgInputCtrl,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك أو التوجيه الطبي...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
