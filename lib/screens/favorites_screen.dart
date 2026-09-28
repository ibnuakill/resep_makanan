import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/local_store.dart';
import '../services/recipe_repository.dart';
import '../widgets/recipe_card.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final RecipeRepository repo;
  final LocalStore store;

  const FavoritesScreen({
    super.key,
    required this.repo,
    required this.store,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Recipe>> _future;
  Map<String, int> _ratings = {};

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Recipe>> _load() async {
    final meals = await widget.store.getFavorites();
    final ratings = await widget.store.ratings();
    if (mounted) setState(() => _ratings = ratings);
    meals.sort((a, b) {
      final ra = ratings[a.id] ?? 0;
      final rb = ratings[b.id] ?? 0;
      if (ra != rb) return rb.compareTo(ra);
      return a.name.compareTo(b.name);
    });
    return meals;
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
      if (mounted) setState(() => _future = _load());
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: FutureBuilder<List<Recipe>>(
        future: _future,
        builder: (context, snap) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, topPad + 20, 20, 20),
                  color: scheme.surface,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Favorit Saya',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if (snap.data != null && snap.data!.isNotEmpty)
                              Text(
                                '${snap.data!.length} resep tersimpan',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: scheme.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Segarkan',
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: () =>
                            setState(() => _future = _load()),
                      ),
                    ],
                  ),
                ),
              ),
              if (snap.connectionState != ConnectionState.done)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snap.hasError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('Gagal: ${snap.error}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                )
              else if ((snap.data ?? []).isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyFavorites(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final meals = snap.data!;
                        return RecipeCard(
                          recipe: meals[i],
                          compact: true,
                          isFavorite: true,
                          rating: _ratings[meals[i].id] ?? 0,
                          onTap: () => _open(meals[i]),
                        );
                      },
                      childCount: snap.data!.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 56,
                color: scheme.error.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada favorit',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap ikon ♥ di halaman detail\nresep untuk menyimpannya di sini',
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
}
