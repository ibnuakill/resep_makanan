import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/local_store.dart';
import '../services/recipe_repository.dart';
import '../services/translation_service.dart';
import '../widgets/recipe_card.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  final String title;
  final String? thumbnail;
  final RecipeRepository repo;
  final LocalStore store;

  const DetailScreen({
    super.key,
    required this.id,
    required this.title,
    this.thumbnail,
    required this.repo,
    required this.store,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final Future<Recipe?> _future;
  bool _fav = false;
  int _rating = 0;
  String _lang = 'id';

  @override
  void initState() {
    super.initState();
    _future = _fetchData();
    _loadLocal();
  }

  Future<Recipe?> _fetchData() async {
    try {
      final r = await widget.repo.detail(widget.id);
      if (r != null) return r;
    } catch (_) {}
    final favs = await widget.store.getFavorites();
    try {
      return favs.firstWhere((e) => e.id == widget.id);
    } catch (_) {
      throw Exception('Gagal terkoneksi dan tidak ada di favorit offline');
    }
  }

  Future<void> _loadLocal() async {
    final favs = await widget.store.favoriteIds();
    final ratings = await widget.store.ratings();
    final lang = await widget.store.getLanguageCode();
    await widget.store.pushHistory(widget.id);
    if (!mounted) return;
    setState(() {
      _fav = favs.contains(widget.id);
      _rating = ratings[widget.id] ?? 0;
      _lang = lang;
    });
  }

  Future<void> _toggleFav(Recipe recipe) async {
    await widget.store.toggleFavorite(recipe);
    if (!mounted) return;
    setState(() => _fav = !_fav);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_fav ? '❤️ Ditambahkan ke favorit' : '🗑️ Dihapus dari favorit'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FutureBuilder<Recipe?>(
        future: _future,
        builder: (context, snap) {
          final recipe = snap.data;

          return CustomScrollView(
            slivers: [
              // ── Hero Image App Bar ─────────────────────────────────
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: scheme.surface,
                foregroundColor: scheme.onSurface,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: _CircleIconButton(
                      icon: _fav
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      iconColor: _fav ? Colors.redAccent : null,
                      onTap: (snap.connectionState !=
                                  ConnectionState.done &&
                              recipe == null)
                          ? null
                          : () => _toggleFav(recipe!),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Hero(
                    tag: widget.id,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        RecipeImage(
                          url:
                              recipe?.thumbnail ?? widget.thumbnail ?? '',
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black54
                              ],
                              stops: [0.5, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    if (snap.connectionState != ConnectionState.done &&
                        recipe == null) {
                      return const Padding(
                        padding: EdgeInsets.all(80),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.wifi_off_rounded,
                                  size: 48, color: scheme.outline),
                              const SizedBox(height: 12),
                              Text('Gagal memuat resep',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                            ],
                          ),
                        ),
                      );
                    }
                    if (recipe == null) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                            child: Text('Resep tidak ditemukan')),
                      );
                    }
                    return _RecipeContent(
                      recipe: recipe,
                      rating: _rating,
                      language: _lang,
                      scheme: scheme,
                      onRatingChanged: (next) async {
                        await widget.store.setRating(widget.id, next);
                        if (!mounted) return;
                        setState(() => _rating = next);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recipe Content Body
// ---------------------------------------------------------------------------
class _RecipeContent extends StatefulWidget {
  final Recipe recipe;
  final int rating;
  final String language;
  final ColorScheme scheme;
  final Future<void> Function(int) onRatingChanged;

  const _RecipeContent({
    required this.recipe,
    required this.rating,
    required this.language,
    required this.scheme,
    required this.onRatingChanged,
  });

  @override
  State<_RecipeContent> createState() => _RecipeContentState();
}

class _RecipeContentState extends State<_RecipeContent> {
  late String _activeLang;
  String? _translatedInstructions;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    _activeLang = widget.language;
    if (_activeLang == 'id' && !widget.recipe.isLocal) {
      _translateToIndonesian();
    }
  }

  @override
  void didUpdateWidget(covariant _RecipeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      _activeLang = widget.language;
      if (_activeLang == 'id' && !widget.recipe.isLocal && _translatedInstructions == null) {
        _translateToIndonesian();
      }
    }
  }

  Future<void> _translateToIndonesian() async {
    final raw = widget.recipe.instructions;
    if (raw == null || raw.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    final translated = await TranslationService.translateInstructions(raw, targetLang: 'id');
    if (!mounted) return;
    setState(() {
      _translatedInstructions = translated;
      _isTranslating = false;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _activeLang = _activeLang == 'id' ? 'en' : 'id';
      if (_activeLang == 'id' && _translatedInstructions == null && !widget.recipe.isLocal) {
        _translateToIndonesian();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    final recipe = widget.recipe;

    // Tentukan teks instruksi yang aktif
    String displayedInstructions;
    if (recipe.isLocal || _activeLang == 'en') {
      displayedInstructions = recipe.instructions ?? 'Tidak ada instruksi';
    } else {
      displayedInstructions = _translatedInstructions ?? recipe.instructions ?? 'Tidak ada instruksi';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + tags
          Text(
            recipe.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (recipe.category != null)
                _Tag(
                    label: recipe.category!,
                    icon: Icons.category_rounded),
              if (recipe.area != null)
                _Tag(label: recipe.area!, icon: Icons.public_rounded),
            ],
          ),

          // ── Rating ───────────────────────────────────────────────
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Penilaianmu',
                    style:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (i) => GestureDetector(
                      onTap: () {
                        final next = (widget.rating == i + 1) ? 0 : i + 1;
                        widget.onRatingChanged(next);
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          i < widget.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 28,
                          color: Colors.amber.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Ingredients ──────────────────────────────────────────
          const SizedBox(height: 24),
          _SectionHeader(
            icon: Icons.restaurant_rounded,
            title: 'Bahan-bahan',
            subtitle: '${recipe.ingredients.length} bahan',
          ),
          const SizedBox(height: 12),
          ...recipe.ingredients.map(
            (ing) => _IngredientTile(
              ingredient: ing,
              scheme: scheme,
            ),
          ),

          // ── Instructions ──────────────────────────────────────────
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionHeader(
                icon: Icons.menu_book_rounded,
                title: 'Cara Memasak',
              ),
              if (!recipe.isLocal)
                InkWell(
                  onTap: _toggleLanguage,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _activeLang == 'id' ? '🇮🇩 ID' : '🇬🇧 EN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 16,
                          color: scheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: _isTranslating
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Menerjemahkan ke Bahasa Indonesia...',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Text(
                    displayedInstructions,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.65,
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper Widgets
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child:
              Icon(icon, size: 18, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const Spacer(),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final dynamic ingredient;
  final ColorScheme scheme;

  const _IngredientTile({
    required this.ingredient,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.egg_alt_rounded,
                  size: 18,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      ingredient.measure,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Tag({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.onSecondaryContainer),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _CircleIconButton(
      {required this.icon, this.iconColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 22,
            color: iconColor ?? scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
