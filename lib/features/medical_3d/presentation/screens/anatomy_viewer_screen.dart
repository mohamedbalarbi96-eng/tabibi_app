import 'package:flutter/material.dart';

/// TABIBI (طبيبي) - 3D Interactive Medical Anatomy Viewer Screen
class AnatomyViewerScreen extends StatefulWidget {
  const AnatomyViewerScreen({super.key});

  @override
  State<AnatomyViewerScreen> createState() => _AnatomyViewerScreenState();
}

class _AnatomyViewerScreenState extends State<AnatomyViewerScreen> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المكتبة الطبية ثلاثية الأبعاد 3D'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'حول المكتبة',
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. حاوية العرض التفاعلي ثلاثي الأبعاد
          Column(
            children: [
              // شريط تعليمات الاستخدام
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_rounded, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'اسحب للتدوير، قرّب للتكبير، واضغط على النقاط التفاعلية لقراءة التفاصيل الفسيولوجية.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // بطاقة بيئة العرض التفاعلي
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // مساحة العرض التشريحي
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🧬', style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 16),
                            const Text(
                              'TABIBI 3D Anatomy Atelier',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'مستودع تشريح تفاعلي ثلاثي الأبعاد مدعوم سحابياً',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'القلب • الدماغ • الرئتان • الكبد • الكلى',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // مؤشر التحميل الخفيف عند التهيئة
                      if (_isLoading)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                SizedBox(width: 6),
                                Text('جاري تهيئة المجسمات...', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Text('🧬'),
            SizedBox(width: 8),
            Text('المكتبة الطبية ثلاثية الأبعاد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'تتيح لك المكتبة الطبية ثلاثية الأبعاد في طبيبي استعراض وفحص الأعضاء البشرية بدقة سريرية عالية، لمساعدة المريض على فهم حالته الصحية ومساعدة الطبيب في الشرح الطبي التوضيحي.',
          style: TextStyle(fontSize: 13, height: 1.6),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
  }
}