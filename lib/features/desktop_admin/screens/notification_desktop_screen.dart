import 'package:flutter/material.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';

class NotificationDesktopScreen extends StatefulWidget {
  const NotificationDesktopScreen({super.key});

  @override
  State<NotificationDesktopScreen> createState() => _NotificationDesktopScreenState();
}

class _NotificationDesktopScreenState extends State<NotificationDesktopScreen> {
  int _selectedTemplate = 0;
  final TextEditingController _templateCtrl = TextEditingController();
  final TextEditingController _announceCtrl = TextEditingController();

  final List<Map<String, dynamic>> _templates = [
    {'name': 'Booking Confirmation - Customer', 'type': 'Customer', 'enabled': true, 'template': '✅ *Booking Confirmed - Nova Cabs*\n\n🚖 *Travel Agency:* {agencyName}\n📞 *Agency Contact:* {agencyPhone}\n\n🚗 *Car Details:*\n• Model: {carModel}\n• Number: {carNumber}\n\n📍 *Pickup:* {pickupLocation}\n⏰ *Pickup Time:* {pickupTime}\n🎫 *Booking ID:* #{bookingId}\n\nThank you for choosing Nova Cabs! 🙏'},
    {'name': 'Booking Confirmation - Agency', 'type': 'Agency', 'enabled': true, 'template': '🔔 *New Booking - Nova Cabs*\n\n👤 *Customer:* {customerName}\n📞 *Contact:* {customerPhone}\n\n📍 *Pickup:* {pickupLocation}\n🗺️ *Map:* {mapLink}\n⏰ *Pickup Time:* {pickupTime}\n🎫 *Booking ID:* #{bookingId}\n\nPlease confirm the booking. Thank you!'},
    {'name': 'Trip Update', 'type': 'Customer', 'enabled': true, 'template': '🚗 *Trip Update - Nova Cabs*\n\nYour driver is on the way!\n📍 *Pickup:* {pickupLocation}\n🎫 *Booking ID:* #{bookingId}\n\nTrack your driver in real-time.'},
    {'name': 'Cancellation Alert', 'type': 'Customer', 'enabled': false, 'template': '❌ *Booking Cancelled - Nova Cabs*\n\nYour booking #{bookingId} has been cancelled.\n💰 Refund will be processed in 3-5 business days.\n\nFor support: +91 80000 00000'},
    {'name': 'Driver Assignment', 'type': 'Customer', 'enabled': true, 'template': '🎉 *Driver Assigned - Nova Cabs*\n\nYour driver {driverName} is assigned.\n📞 *Driver Contact:* {driverPhone}\n🚗 *Vehicle:* {vehicleNumber}\n\nHappy Journey! 🙏'},
  ];

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _templateCtrl.text = _templates[0]['template'] as String;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTemplates = _templates.where((t) => 
      (t['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (t['type'] as String).toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesktopTheme.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Notification Management',
            subtitle: 'Manage WhatsApp templates and system announcements',
          ),
          const SizedBox(height: 20),

          // Announcements
          _buildAnnouncementSection(),
          const SizedBox(height: 20),

          // Templates
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template list
              SizedBox(
                width: 280,
                child: Container(
                  decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(color: DesktopTheme.contentBg, borderRadius: BorderRadius.vertical(top: Radius.circular(12)), border: Border(bottom: BorderSide(color: DesktopTheme.border))),
                        child: Column(
                          children: [
                            Row(children: [
                              const Icon(Icons.message_rounded, size: 16, color: DesktopTheme.primaryBlue),
                              const SizedBox(width: 8),
                              const Text('WhatsApp Templates', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text('${filteredTemplates.length}', style: const TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
                            ]),
                            const SizedBox(height: 12),
                            DesktopSearchBar(
                              hint: 'Search templates...',
                              width: double.infinity,
                              onChanged: (v) => setState(() => _searchQuery = v),
                            ),
                          ],
                        ),
                      ),
                      ...filteredTemplates.asMap().entries.map((e) {
                        final i = e.key;
                        final t = e.value;
                        final isSelected = t['name'] == _templates[_selectedTemplate]['name'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              final originalIndex = _templates.indexWhere((temp) => temp['name'] == t['name']);
                              _selectedTemplate = originalIndex;
                              _templateCtrl.text = t['template'] as String;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? DesktopTheme.primaryBlue.withValues(alpha: 0.06) : Colors.transparent,
                              border: Border(
                                bottom: const BorderSide(color: DesktopTheme.borderLight),
                                left: BorderSide(color: isSelected ? DesktopTheme.primaryBlue : Colors.transparent, width: 3),
                              ),
                            ),
                            child: Row(children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(t['name'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? DesktopTheme.primaryBlue : DesktopTheme.textPrimary), maxLines: 2),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (t['type'] == 'Customer' ? DesktopTheme.primaryBlue : DesktopTheme.accentTeal).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(t['type'] as String, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: t['type'] == 'Customer' ? DesktopTheme.primaryBlue : DesktopTheme.accentTeal)),
                                ),
                              ])),
                              Switch(
                                value: t['enabled'] as bool,
                                onChanged: (v) => setState(() => _templates[i]['enabled'] = v),
                                activeColor: DesktopTheme.successGreen,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ]),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Template editor
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.edit_note_rounded, size: 20, color: DesktopTheme.primaryBlue),
                        const SizedBox(width: 8),
                        Text(_templates[_selectedTemplate]['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        PrimaryButton(label: 'Save Template', icon: Icons.save_rounded, onPressed: () {
                          setState(() => _templates[_selectedTemplate]['template'] = _templateCtrl.text);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template saved!'), backgroundColor: DesktopTheme.successGreen));
                        }),
                      ]),
                      const SizedBox(height: 16),
                      const Text('Template Variables', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DesktopTheme.textMuted)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 6, children: [
                        for (final v in ['{customerName}', '{agencyName}', '{driverName}', '{bookingId}', '{pickupLocation}', '{pickupTime}', '{carModel}', '{carNumber}', '{agencyPhone}', '{customerPhone}', '{mapLink}'])
                          GestureDetector(
                            onTap: () {
                              final text = _templateCtrl.text + v;
                              _templateCtrl.text = text;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: DesktopTheme.accentTeal.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4), border: Border.all(color: DesktopTheme.accentTeal.withValues(alpha: 0.2))),
                              child: Text(v, style: const TextStyle(fontSize: 11, color: DesktopTheme.accentTeal, fontWeight: FontWeight.w500, fontFamily: 'monospace')),
                            ),
                          ),
                      ]),
                      const SizedBox(height: 14),
                      const Text('Template Content', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DesktopTheme.textMuted)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _templateCtrl,
                        maxLines: 12,
                        style: const TextStyle(fontSize: 13, fontFamily: 'monospace', height: 1.6),
                        decoration: InputDecoration(
                          hintText: 'Enter template content...',
                          filled: true,
                          fillColor: DesktopTheme.contentBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DesktopTheme.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DesktopTheme.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DesktopTheme.primaryBlue, width: 1.5)),
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

  Widget _buildAnnouncementSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: DesktopTheme.warningAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.campaign_rounded, color: DesktopTheme.warningAmber, size: 18)),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Send Announcement', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Text('Broadcast to all drivers, agencies, or customers', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
            ]),
          ]),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _announceCtrl,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Type your announcement message here...',
                    filled: true,
                    fillColor: DesktopTheme.contentBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DesktopTheme.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DesktopTheme.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: DesktopTheme.primaryBlue, width: 1.5)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Send To', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DesktopTheme.textMuted)),
                  const SizedBox(height: 8),
                  for (final group in ['All Users', 'All Drivers', 'All Agencies', 'All Customers'])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _CheckRow(label: group),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 200, // Fixed width or remove SizedBox to let it size to content
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement sent!'), backgroundColor: DesktopTheme.successGreen));
                        _announceCtrl.clear();
                      },
                      icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                      label: const Text('Send Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesktopTheme.warningAmber, 
                        foregroundColor: Colors.white, 
                        elevation: 0, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), 
                        padding: const EdgeInsets.symmetric(vertical: 12)
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatefulWidget {
  final String label;
  const _CheckRow({required this.label});

  @override
  State<_CheckRow> createState() => _CheckRowState();
}

class _CheckRowState extends State<_CheckRow> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _checked = !_checked),
      child: Row(children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: _checked ? DesktopTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _checked ? DesktopTheme.primaryBlue : DesktopTheme.border, width: 2),
          ),
          child: _checked ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
        ),
        const SizedBox(width: 8),
        Text(widget.label, style: const TextStyle(fontSize: 13, color: DesktopTheme.textPrimary)),
      ]),
    );
  }
}
