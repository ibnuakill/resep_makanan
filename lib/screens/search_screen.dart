import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/local_store.dart';
import '../services/recipe_repository.dart';
import '../widgets/recipe_card.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final RecipeRepository repo;
  final LocalStore store;

  const SearchScreen({
    super.key,
    required this.repo,
    required this.store,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Recipe> _results = [];
  bool _loading = false;
  String? _error;
  bool _searched = false;
  int _activeFilter = 0; // 0=semua, 1=lokal

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
      _results = const [];
    });
    try {
      final results = await widget.repo.search(q);
      if (!mounted) return;
      setState(() => _results = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _open(Recipe recipe) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          id: recipe.id,
          title: recipe.name,
          thumbnail: recipe.thumbnail,
          repo: widget.repo,
          store: widget.store,
        ),
      ),
    )
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  List<Recipe> get _filtered {
    if (_activeFilter == 0) return _results;
    return _results.where((r) => r.isLocal).toList();
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _results = [];
      _searched = false;
      _error = null;
      _activeFilter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, topPad + 20, 20, 16),
            color: scheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cari Resep',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Temukan inspirasi masakan favoritmu',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _search(),
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Cari resep... (misal: Ayam, Nasi)',
                          fillColor: scheme.surfaceContainerLow,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: _clear,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _search,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_searched && _results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Text(
                    '${_filtered.length} hasil',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  _Chip(
                    label: 'Semua',
                    active: _activeFilter == 0,
                    onTap: () => setState(() => _activeFilter = 0),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    label: '🇮🇩 Lokal',
                    active: _activeFilter == 1,
                    onTap: () => setState(() => _activeFilter = 1),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildBody(scheme)),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme scheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 56, color: scheme.outline),
              const SizedBox(height: 16),
              Text('Pencarian gagal',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('$_error',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (!_searched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color:
                      scheme.primaryContainer.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Text('🔍', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 20),
              Text('Cari resep favoritmu',
                  style:
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
              const SizedBox(height: 8),
              Text(
                'Ketikkan nama masakan atau bahan\npada kolom pencarian di atas',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🥺', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text('Tidak ada hasil',
                style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
            const SizedBox(height: 8),
            Text(
              'Coba dengan kata kunci lain',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      itemCount: _filtered.length,
      itemBuilder: (context, i) => RecipeCard(
        recipe: _filtered[i],
        onTap: () => _open(_filtered[i]),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: active,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
    );
  }
}
