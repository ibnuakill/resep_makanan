import 'package:flutter/material.dart';

import '../services/local_store.dart';

class SettingsScreen extends StatefulWidget {
  final LocalStore store;
  final VoidCallback? onLanguageChanged;

  const SettingsScreen({
    super.key,
    required this.store,
    this.onLanguageChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentLang = 'id';
  int _favCount = 0;
  int _historyCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final lang = await widget.store.getLanguageCode();
    final favs = await widget.store.favoriteIds();
    final history = await widget.store.history();
    if (!mounted) return;
    setState(() {
      _currentLang = lang;
      _favCount = favs.length;
      _historyCount = history.length;
      _loading = false;
    });
  }

  Future<void> _selectLanguage(String code) async {
    if (_currentLang == code) return;
    await widget.store.setLanguageCode(code);
    setState(() => _currentLang = code);
    widget.onLanguageChanged?.call();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          code == 'id'
              ? '🇮🇩 Bahasa diubah ke Bahasa Indonesia'
              : '🇬🇧 Language switched to English',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isIndonesian = _currentLang == 'id';

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  // ── Header Profil Sederhana ──
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [scheme.primary, scheme.tertiary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withAlpha(50),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 46,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          isIndonesian ? 'Profil & Pengaturan' : 'Profile & Settings',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isIndonesian
                              ? 'Koki Rumahan • Asisten Resep'
                              : 'Home Chef • Recipe Assistant',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Kartu Ringkasan Aktivitas ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          icon: Icons.favorite_rounded,
                          iconColor: Colors.redAccent,
                          value: '$_favCount',
                          label: isIndonesian ? 'Favorit' : 'Favorites',
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: scheme.outlineVariant.withAlpha(100),
                        ),
                        _StatItem(
                          icon: Icons.history_rounded,
                          iconColor: scheme.primary,
                          value: '$_historyCount',
                          label: isIndonesian ? 'Dilihat' : 'Viewed',
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: scheme.outlineVariant.withAlpha(100),
                        ),
                        _StatItem(
                          icon: Icons.language_rounded,
                          iconColor: scheme.tertiary,
                          value: isIndonesian ? 'ID' : 'EN',
                          label: isIndonesian ? 'Bahasa' : 'Language',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Bagian Bahasa / Language ──
                  Text(
                    isIndonesian ? 'Pengaturan Bahasa' : 'Language Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isIndonesian
                        ? 'Pilih bahasa untuk langkah cara memasak dan antarmuka.'
                        : 'Select language for cooking steps and interface.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.outline,
                        ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _LanguageTile(
                          flag: '🇮🇩',
                          title: 'Bahasa Indonesia',
                          subtitle: 'Default - Langkah memasak otomatis diterjemahkan',
                          isSelected: _currentLang == 'id',
                          onTap: () => _selectLanguage('id'),
                          scheme: scheme,
                        ),
                        Divider(height: 1, indent: 64, endIndent: 20, color: scheme.outlineVariant.withAlpha(60)),
                        _LanguageTile(
                          flag: '🇬🇧',
                          title: 'English',
                          subtitle: 'Original instructions from recipes',
                          isSelected: _currentLang == 'en',
                          onTap: () => _selectLanguage('en'),
                          scheme: scheme,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Info Aplikasi ──
                  Text(
                    isIndonesian ? 'Tentang Aplikasi' : 'About App',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.info_outline_rounded, color: scheme.primary, size: 20),
                          ),
                          title: const Text('Resep Makanan'),
                          subtitle: const Text('Versi 1.0.0 (Material 3)'),
                        ),
                        Divider(height: 1, indent: 64, endIndent: 20, color: scheme.outlineVariant.withAlpha(60)),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.cloud_done_rounded, color: scheme.secondary, size: 20),
                          ),
                          title: Text(isIndonesian ? 'Sumber Data' : 'Data Source'),
                          subtitle: const Text('TheMealDB & Resep Nusantara Lokal'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme scheme;

  const _LanguageTile({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(flag, style: const TextStyle(fontSize: 22)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? scheme.primary : scheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.outline,
            ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: scheme.primary)
          : Icon(Icons.circle_outlined, color: scheme.outline.withAlpha(120)),
      onTap: onTap,
    );
  }
}
