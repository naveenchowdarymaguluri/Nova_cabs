import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';
import '../../../core/app_providers.dart';
import '../../../core/models.dart';
import '../../../core/firestore_service.dart';

class NotificationDesktopScreen extends ConsumerStatefulWidget {
  const NotificationDesktopScreen({super.key});

  @override
  ConsumerState<NotificationDesktopScreen> createState() => _NotificationDesktopScreenState();
}

class _NotificationDesktopScreenState extends ConsumerState<NotificationDesktopScreen> {
  String? _selectedTemplateId;
  final TextEditingController _templateCtrl = TextEditingController();
  final TextEditingController _announceCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _templateCtrl.dispose();
    _announceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(firestoreNotificationTemplatesProvider);

    return templatesAsync.when(
      data: (templates) {
        final filteredTemplates = templates.where((t) =>
          t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.type.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();

        // Auto-select first template on initial load
        if (_selectedTemplateId == null && filteredTemplates.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {
              _selectedTemplateId = filteredTemplates.first.id;
              _templateCtrl.text = filteredTemplates.first.template;
            });
          });
        }

        final selectedTemplate = templates.where((t) => t.id == _selectedTemplateId).firstOrNull;

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

              _buildAnnouncementSection(context),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Template list panel
                  SizedBox(
                    width: 280,
                    child: Container(
                      decoration: BoxDecoration(
                        color: DesktopTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DesktopTheme.border),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: DesktopTheme.contentBg,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              border: Border(bottom: BorderSide(color: DesktopTheme.border)),
                            ),
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
                          if (filteredTemplates.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('No templates', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
                            )
                          else
                            ...filteredTemplates.map((t) => _buildTemplateItem(t, selectedTemplate)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Template editor panel
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: DesktopTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DesktopTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.edit_note_rounded, size: 20, color: DesktopTheme.primaryBlue),
                            const SizedBox(width: 8),
                            Text(
                              selectedTemplate?.name ?? 'Select a template',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            if (selectedTemplate != null)
                              PrimaryButton(
                                label: 'Save Template',
                                icon: Icons.save_rounded,
                                onPressed: () {
                                  ref.read(firestoreServiceProvider).saveNotificationTemplate(
                                    selectedTemplate.copyWith(template: _templateCtrl.text),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Template saved!'), backgroundColor: DesktopTheme.successGreen),
                                  );
                                },
                              ),
                          ]),
                          const SizedBox(height: 16),
                          const Text('Template Variables', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DesktopTheme.textMuted)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              for (final v in ['{customerName}', '{agencyName}', '{driverName}', '{bookingId}', '{pickupLocation}', '{pickupTime}', '{carModel}', '{carNumber}', '{agencyPhone}', '{customerPhone}', '{mapLink}'])
                                GestureDetector(
                                  onTap: () => _templateCtrl.text = _templateCtrl.text + v,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: DesktopTheme.accentTeal.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: DesktopTheme.accentTeal.withValues(alpha: 0.2)),
                                    ),
                                    child: Text(v, style: const TextStyle(fontSize: 11, color: DesktopTheme.accentTeal, fontWeight: FontWeight.w500, fontFamily: 'monospace')),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text('Template Content', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DesktopTheme.textMuted)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _templateCtrl,
                            enabled: selectedTemplate != null,
                            maxLines: 12,
                            style: const TextStyle(fontSize: 13, fontFamily: 'monospace', height: 1.6),
                            decoration: InputDecoration(
                              hintText: selectedTemplate == null ? 'Select a template from the left panel' : 'Enter template content...',
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildTemplateItem(NotificationTemplate t, NotificationTemplate? selected) {
    final isSelected = t.id == _selectedTemplateId;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedTemplateId = t.id;
        _templateCtrl.text = t.template;
      }),
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
            Text(
              t.name,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? DesktopTheme.primaryBlue : DesktopTheme.textPrimary),
              maxLines: 2,
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (t.type == 'Customer' ? DesktopTheme.primaryBlue : DesktopTheme.accentTeal).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                t.type,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: t.type == 'Customer' ? DesktopTheme.primaryBlue : DesktopTheme.accentTeal),
              ),
            ),
          ])),
          Switch(
            value: t.isEnabled,
            onChanged: (v) {
              ref.read(firestoreServiceProvider).saveNotificationTemplate(t.copyWith(isEnabled: v));
            },
            activeThumbColor: DesktopTheme.successGreen,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ]),
      ),
    );
  }

  Widget _buildAnnouncementSection(BuildContext context) {
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
                    width: 200,
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
