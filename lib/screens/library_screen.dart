import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state.dart';
import '../services/story_service.dart';
import '../widgets/kid_ui.dart';
import 'story_reader_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedTantra = 'All Tantras';
  String _selectedBand = 'All';
  late final TextEditingController _searchController;

  final List<String> _tantras = [
    'All Tantras',
    'Book 1: Mitra-bheda',
    'Book 2: Mitra-prapti',
    'Book 3: Kakolukiyam',
    'Book 4: Labdhapranasam',
    'Book 5: Apariksitakaraka',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<AppState>().searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final stories = StoryService.allStories.where((s) {
      final matchesTantra = _selectedTantra == 'All Tantras' ||
          s.tantraBook.contains(_selectedTantra.split(':').last.trim());
      final matchesBand = _selectedBand == 'All' || s.ageBand == _selectedBand;
      final matchesSearch = appState.searchQuery.isEmpty ||
          s.title.toLowerCase().contains(appState.searchQuery.toLowerCase()) ||
          s.moral.toLowerCase().contains(appState.searchQuery.toLowerCase()) ||
          s.characters.any(
            (c) => c.toLowerCase().contains(appState.searchQuery.toLowerCase()),
          );
      return matchesTantra && matchesBand && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          KidPageHeader(
            title: 'Story Library',
            subtitle: '${StoryService.allStories.length} handpicked fables from the five Tantras',
            trailing: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: const Text('📚', style: TextStyle(fontSize: 21)),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.headerDark.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: appState.setSearchQuery,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Find a fable, animal or moral...',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.textLight,
                            size: 22,
                          ),
                          suffixIcon: appState.searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    appState.setSearchQuery('');
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: AppColors.textLight,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 13, bottom: 4),
                    child: SizedBox(
                      height: 38,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: _tantras.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final tantra = _tantras[index];
                          final selected = _selectedTantra == tantra;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedTantra = tantra),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected ? AppColors.headerPrimary : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.headerPrimary.withValues(alpha: 0.25),
                                          blurRadius: 12,
                                          offset: const Offset(0, 5),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                tantra == 'All Tantras'
                                    ? 'All stories'
                                    : tantra.replaceFirst('Book ', 'Tantra '),
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: selected ? Colors.white : AppColors.textMedium,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                    child: Row(
                      children: [
                        Text(
                          '${stories.length} ${stories.length == 1 ? 'story' : 'stories'}',
                          style: GoogleFonts.baloo2(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        _AgeFilter(
                          selected: _selectedBand,
                          onSelected: (band) => setState(() => _selectedBand = band),
                        ),
                      ],
                    ),
                  ),
                ),
                if (stories.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyLibraryState(),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      MediaQuery.paddingOf(context).bottom + 105,
                    ),
                    sliver: SliverList.separated(
                      itemCount: stories.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final story = stories[index];
                        return _StoryLibraryCard(
                          story: story,
                          index: index,
                          onTap: () {
                            appState.setActiveStory(story);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StoryReaderScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _AgeFilter({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selected,
      onSelected: onSelected,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'All', child: Text('All ages')),
        PopupMenuItem(value: '4-9', child: Text('Ages 4–9')),
        PopupMenuItem(value: '9+', child: Text('Ages 9+')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.headerPrimary.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.tune_rounded,
              size: 14,
              color: AppColors.headerPrimary,
            ),
            const SizedBox(width: 5),
            Text(
              selected == 'All' ? 'All ages' : 'Ages $selected',
              style: GoogleFonts.nunito(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.headerPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryLibraryCard extends StatelessWidget {
  final dynamic story;
  final int index;
  final VoidCallback onTap;

  const _StoryLibraryCard({
    required this.story,
    required this.index,
    required this.onTap,
  });

  static const List<List<Color>> _gradients = [
    [Color(0xFFFFD9CD), Color(0xFFFFB39A)],
    [Color(0xFFFFEBC0), Color(0xFFFFD37C)],
    [Color(0xFFD6E9FF), Color(0xFFAED5FF)],
    [Color(0xFFE7DCFA), Color(0xFFC9B0EC)],
    [Color(0xFFDDF1E5), Color(0xFFB5DFC6)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[index % _gradients.length];

    return KidCard(
      onTap: onTap,
      padding: const EdgeInsets.all(13),
      radius: 24,
      shadow: [
        BoxShadow(
          color: AppColors.headerDark.withValues(alpha: 0.055),
          blurRadius: 16,
          offset: const Offset(0, 7),
        ),
      ],
      child: Row(
        children: [
          Container(
            width: 68,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -12,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.26),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    story.coverEmoji,
                    style: const TextStyle(fontSize: 34),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  style: GoogleFonts.baloo2(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    MetaPill(
                      label: 'Ages ${story.ageBand}',
                      foreground: AppColors.headerPrimary,
                      background: AppColors.chipPurple,
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${story.readingMinutes} min',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  story.moral,
                  style: GoogleFonts.nunito(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.chipPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              size: 17,
              color: AppColors.headerPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLibraryState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔎', style: TextStyle(fontSize: 42)),
            const SizedBox(height: 10),
            Text(
              'No fables found',
              style: GoogleFonts.baloo2(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try another animal, moral or Tantra.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
