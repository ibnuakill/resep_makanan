import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/local_store.dart';
import '../services/recipe_repository.dart';
import '../widgets/recipe_card.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final RecipeRepository repo;
  final LocalStore store;

  const HomeScreen({
    super.key,
    required this.repo,
    required this.store,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(repo: widget.repo, store: widget.store),
      SearchScreen(repo: widget.repo, store: widget.store),
      FavoritesScreen(repo: widget.repo, store: widget.store),
      SettingsScreen(
        store: widget.store,
        onLanguageChanged: () => setState(() {}),
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Cari',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorit',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HOME TAB
// ---------------------------------------------------------------------------
class _HomeTab extends StatefulWidget {
  final RecipeRepository repo;
  final LocalStore store;
  const _HomeTab({required this.repo, required this.store});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  late Future<List<String>> _filterOptions;
  late Future<List<Recipe>> _recipes;
  late Future<Recipe?> _featured;
  String _selected = 'Indonesia';
  bool _isAreaFilter = false;
  final Map<String, int> _ratings = {};

  @override
  void initState() {
    super.initState();
    _filterOptions = widget.repo.categories();
    _recipes = widget.repo.byCategory(_selected);
    _featured = widget.repo.random();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    final r = await widget.store.ratings();
    if (mounted) setState(() => _ratings.addAll(r));
  }

  void _select(String c) {
    setState(() {
      _selected = c;
      _recipes =
          _isAreaFilter ? widget.repo.byArea(c) : widget.repo.byCategory(c);
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _filterOptions =
          _isAreaFilter ? widget.repo.areas() : widget.repo.categories();
      _recipes = _isAreaFilter
          ? widget.repo.byArea(_selected)
          : widget.repo.byCategory(_selected);
      _featured = widget.repo.random();
    });
    await _loadRatings();
  }

  void _toggleFilterMode() {
    setState(() {
      _isAreaFilter = !_isAreaFilter;
      _selected = 'Indonesia';
      _filterOptions =
          _isAreaFilter ? widget.repo.areas() : widget.repo.categories();
      _recipes = _isAreaFilter
          ? widget.repo.byArea(_selected)
          : widget.repo.byCategory(_selected);
    });
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
      if (mounted) _loadRatings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header()),
          SliverToBoxAdapter(child: _featuredCard()),
          SliverToBoxAdapter(child: _sectionTitle('Jelajahi')),
          SliverToBoxAdapter(child: _filterChips()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            sliver: FutureBuilder<List<Recipe>>(
              future: _recipes,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(onRetry: _refresh),
                  );
                }
                final meals = snap.data ?? const <Recipe>[];
                if (meals.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('Tidak ada resep')),
                  );
                }
                return SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => RecipeCard(
                      recipe: meals[i],
                      compact: true,
                      rating: _ratings[meals[i].id] ?? 0,
                      onTap: () => _open(meals[i]),
                    ),
                    childCount: meals.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final scheme = Theme.of(context).colorScheme;
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, topPad + 24, 22, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                radius: 20,
                child: const Text('👨‍🍳', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                'Selamat Datang!',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimary.withValues(alpha: 0.9),
                      letterSpacing: 0.3,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Mau masak apa\nhari ini? 🍳',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Temukan ribuan resep lezat untukmu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _featuredCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: FutureBuilder<Recipe?>(
        future: _featured,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return _ShimmerBox(
                height: 200, radius: BorderRadius.circular(24));
          }
          final r = snap.data;
          if (r == null) return const SizedBox.shrink();
          final scheme = Theme.of(context).colorScheme;
          return Material(
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            child: InkWell(
              onTap: () => _open(r),
              child: SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RecipeImage(url: r.thumbnail),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                          stops: [0.35, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('✨ Rekomendasi hari ini',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                        color: scheme.onPrimary,
                                        fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            r.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                          ),
                          if (r.area != null || r.category != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.place_rounded,
                                    size: 13, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(r.area ?? r.category ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white70)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: _PlayBadge(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterChips() {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Tooltip(
            message:
                _isAreaFilter ? 'Ganti ke Kategori' : 'Ganti ke Area',
            child: InkWell(
              onTap: _toggleFilterMode,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isAreaFilter
                          ? Icons.public_rounded
                          : Icons.category_rounded,
                      size: 16,
                      color: scheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isAreaFilter ? 'Area' : 'Kategori',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                            color: scheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 28, color: scheme.outlineVariant),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _filterOptions,
              builder: (context, snap) {
                final options = snap.data ?? const <String>[];
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: options.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final c = options[i];
                    final selected = c == _selected;
                    return ChoiceChip(
                      label: Text(c == 'Indonesia' ? '🇮🇩 $c' : c),
                      selected: selected,
                      showCheckmark: false,
                      onSelected: (_) => _select(c),
                      selectedColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------
class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30),
      ),
      child: const Icon(Icons.open_in_new_rounded,
          color: Colors.white, size: 18),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final BorderRadius radius;
  const _ShimmerBox({required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text('Gagal memuat resep',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Periksa koneksi internetmu',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
