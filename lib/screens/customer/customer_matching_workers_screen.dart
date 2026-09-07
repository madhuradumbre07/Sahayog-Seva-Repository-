import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../l10n/l10n.dart';
import '../../models/worker_matching_model.dart';
import '../../providers/matching_provider.dart';
import '../../providers/booking_flow_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/language_selector_button.dart';
import '../../widgets/map_view.dart';
import 'customer_worker_profile_screen.dart';
import 'customer_booking_details_screen.dart';

class CustomerMatchingWorkersScreen extends StatefulWidget {
  const CustomerMatchingWorkersScreen({super.key});

  static const String routeName = '/customer/matching-workers';

  @override
  State<CustomerMatchingWorkersScreen> createState() =>
      _CustomerMatchingWorkersScreenState();
}

class _CustomerMatchingWorkersScreenState
    extends State<CustomerMatchingWorkersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<MatchingProvider>();
      if (prov.isLoading) {
        _pulseController.repeat();
      }
      prov.startSearch();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prov = context.watch<MatchingProvider>();
    if (!prov.isLoading && _pulseController.isAnimating) {
      _pulseController.stop();
    } else if (prov.isLoading && !_pulseController.isAnimating) {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          ctx.tr('helpDialogTitle'),
          style: AppTypography.heading(fontSize: 16)
              .copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          ctx.tr('findingWorkersSubtitle'),
          style: AppTypography.body(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              ctx.tr('gotIt'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    final prov = context.read<MatchingProvider>();
    double tempDistance = prov.maxDistanceKm;
    double tempRating = prov.minRating;
    int tempExp = prov.minExperience;
    bool tempAvail = prov.onlyAvailable;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ctx.tr('filterBtnLabel'),
                        style: AppTypography.heading(fontSize: 18)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          prov.resetFilters();
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          ctx.tr('resetFiltersBtn'),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Distance Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ctx.tr('filterDistance'),
                        style: AppTypography.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${tempDistance.round()} km',
                        style: AppTypography.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempDistance,
                    min: 5.0,
                    max: 30.0,
                    divisions: 5,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setModalState(() => tempDistance = val),
                  ),
                  const SizedBox(height: 12),

                  // Rating filter
                  Text(
                    ctx.tr('filterRating'),
                    style: AppTypography.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [0.0, 4.0, 4.5, 4.8].map((r) {
                      final isSelected = tempRating == r;
                      return ChoiceChip(
                        label: Text(r == 0.0 ? 'All' : '$r+ ★'),
                        selected: isSelected,
                        selectedColor: const Color(0xFFE8F0FE),
                        onSelected: (_) => setModalState(() => tempRating = r),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Experience filter
                  Text(
                    ctx.tr('filterExperience'),
                    style: AppTypography.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [0, 1, 3, 5].map((e) {
                      final isSelected = tempExp == e;
                      return ChoiceChip(
                        label: Text(e == 0 ? 'Any' : '$e+ yrs'),
                        selected: isSelected,
                        selectedColor: const Color(0xFFE8F0FE),
                        onSelected: (_) => setModalState(() => tempExp = e),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Available now switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      ctx.tr('filterAvailableOnly'),
                      style: AppTypography.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: tempAvail,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setModalState(() => tempAvail = val),
                  ),
                  const SizedBox(height: 16),

                  // Apply button
                  ElevatedButton(
                    onPressed: () {
                      prov.updateFilters(
                        maxDistanceKm: tempDistance,
                        minRating: tempRating,
                        minExperience: tempExp,
                        onlyAvailable: tempAvail,
                      );
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      ctx.tr('applyFiltersBtn'),
                      style: AppTypography.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortModal(BuildContext context) {
    final prov = context.read<MatchingProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final options = [
          ('MATCH_SCORE', ctx.tr('sortBestMatch')),
          ('NEAREST', ctx.tr('sortNearest')),
          ('PRICE_LOW', ctx.tr('sortLowestPrice')),
          ('RATING_HIGH', ctx.tr('sortHighestRating')),
          ('EXPERIENCE_HIGH', ctx.tr('sortExperience')),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ctx.tr('sortBtnLabel'),
                style: AppTypography.heading(fontSize: 18)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...options.map((opt) {
                final isSelected = prov.sortBy == opt.$1;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                  title: Text(
                    opt.$2,
                    style: AppTypography.poppins(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    prov.updateSort(opt.$1);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final matching = context.watch<MatchingProvider>();
    final activeLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('matchingWorkersTitle'),
          style: AppTypography.heading(
            fontSize: 17,
          ).copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.textPrimary),
            tooltip: context.tr('helpDialogTitle'),
            onPressed: () => _showHelpDialog(context),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSelectorButton(),
          ),
        ],
      ),
      body: matching.isLoading
          ? _buildRadarTriageView(context, matching)
          : _buildResultsView(context, matching, activeLocale),
    );
  }

  // --- Radar & Triage View ---
  Widget _buildRadarTriageView(
    BuildContext context,
    MatchingProvider matching,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr('findingWorkersRadar'),
              style: AppTypography.heading(fontSize: 20).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('findingWorkersSubtitle'),
              style: AppTypography.subtitle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Pulsing Concentric Radar
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final val = _pulseController.value;
                return SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      Container(
                        width: 130 + (val * 50),
                        height: 130 + (val * 50),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(
                            alpha: 0.08 * (1 - val),
                          ),
                        ),
                      ),
                      // Middle ring
                      Container(
                        width: 100 + (val * 35),
                        height: 100 + (val * 35),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(
                            alpha: 0.15 * (1 - val),
                          ),
                        ),
                      ),
                      // Core circle with worker icon
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8F0FE),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.engineering,
                          size: 42,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Multi-stage checklist
            _buildChecklistTile(
              context.tr('radarStep1'),
              isDone:
                  matching.stage.index >= MatchingStage.matchingSkills.index,
              isActive: matching.stage == MatchingStage.understandingService,
            ),
            _buildChecklistTile(
              context.tr('radarStep2'),
              isDone:
                  matching.stage.index >= MatchingStage.findingWorkers.index,
              isActive: matching.stage == MatchingStage.matchingSkills,
            ),
            _buildChecklistTile(
              context.tr('radarStep3'),
              isDone:
                  matching.stage.index >=
                  MatchingStage.selectingBestMatches.index,
              isActive: matching.stage == MatchingStage.findingWorkers,
            ),
            _buildChecklistTile(
              context.tr('radarStep4'),
              isDone: matching.stage == MatchingStage.completed,
              isActive: matching.stage == MatchingStage.selectingBestMatches,
            ),
            const SizedBox(height: 24),

            // Live search status badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    context.tr('liveSearchStatus'),
                    style: AppTypography.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.subtitle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(
                        Icons.groups_outlined,
                        '${matching.totalSearched}',
                        context.tr('workersSearched'),
                      ),
                      _buildMetricItem(
                        Icons.sync,
                        '${matching.matchedCount}',
                        context.tr('matchingNow'),
                      ),
                      _buildMetricItem(
                        Icons.star_outline,
                        '${matching.topPicksCount}',
                        context.tr('topPicks'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistTile(
    String label, {
    required bool isDone,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isDone
                ? Icons.check_circle
                : (isActive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off),
            color: isDone
                ? const Color(0xFF2E7D32)
                : (isActive ? AppColors.primary : Colors.grey),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTypography.poppins(
                fontSize: 13,
                fontWeight: isDone || isActive
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: isDone || isActive ? AppColors.textPrimary : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String count, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          count,
          style: AppTypography.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(label, style: AppTypography.subtitle(fontSize: 10)),
      ],
    );
  }

  // --- Results View (List & Map) ---
  Widget _buildResultsView(
    BuildContext context,
    MatchingProvider matching,
    String activeLocale,
  ) {
    if (matching.workers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                context.tr('noWorkersFoundTitle'),
                textAlign: TextAlign.center,
                style: AppTypography.heading(fontSize: 18)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('noWorkersFoundSub'),
                textAlign: TextAlign.center,
                style: AppTypography.subtitle(fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => matching.resetFilters(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.tr('resetFiltersBtn'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Controls bar: List/Map Toggle + Filter + Sort
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              // Segmented view toggle
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (matching.isMapView) matching.toggleViewMode();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: !matching.isMapView
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.view_list,
                          size: 18,
                          color: !matching.isMapView
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (!matching.isMapView) matching.toggleViewMode();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: matching.isMapView
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.map_outlined,
                          size: 18,
                          color: matching.isMapView
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Filter chip button
              OutlinedButton.icon(
                onPressed: () => _showFilterModal(context),
                icon: const Icon(
                  Icons.tune,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: Text(
                  context.tr('filterBtnLabel'),
                  style: AppTypography.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
              const SizedBox(width: 8),

              // Sort chip button
              OutlinedButton.icon(
                onPressed: () => _showSortModal(context),
                icon: const Icon(
                  Icons.sort,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: Text(
                  context.tr('sortBtnLabel'),
                  style: AppTypography.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
            ],
          ),
        ),

        // List vs Map Content
        Expanded(
          child: matching.isMapView
              ? _buildMapView(context, matching, activeLocale)
              : _buildListView(context, matching, activeLocale),
        ),
      ],
    );
  }

  // --- List View Builder ---
  Widget _buildListView(
    BuildContext context,
    MatchingProvider matching,
    String activeLocale,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matching.workers.length,
      itemBuilder: (context, index) {
        final worker = matching.workers[index];
        return _buildWorkerMatchCard(context, worker, activeLocale);
      },
    );
  }

  // --- Worker Match Card ---
  Widget _buildWorkerMatchCard(
    BuildContext context,
    WorkerMatchModel worker,
    String activeLocale,
  ) {
    final name = worker.localizedName(activeLocale);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar, Name, Verified Society, Match Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFE8F0FE),
                child: Text(
                  name.isNotEmpty ? name[0] : 'W',
                  style: AppTypography.heading(fontSize: 18).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: AppTypography.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (worker.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      worker.localizedSociety(context),
                      style: AppTypography.subtitle(fontSize: 11).copyWith(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFA000),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${worker.ratingAvg} (${worker.reviewCount})',
                          style: AppTypography.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  ${worker.experienceYears} ${context.tr('yearsExpMetric')}',
                          style: AppTypography.subtitle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Match Score Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF81C784)),
                ),
                child: Text(
                  '${worker.matchScore}% Match',
                  style: AppTypography.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Middle info row: Distance, Price, Response Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${worker.distanceKm} km',
                    style: AppTypography.subtitle(fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.currency_rupee,
                    size: 14,
                    color: Colors.grey,
                  ),
                  Text(
                    AppFormatters.formatPriceRange(
                      worker.hourlyRateMin,
                      worker.hourlyRateMax,
                      context,
                    ),
                    style: AppTypography.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${worker.responseTimeMinutes}m',
                    style: AppTypography.subtitle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // CTAs: View Details & Select
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<MatchingProvider>().selectWorker(worker);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CustomerWorkerProfileScreen(worker: worker),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: Text(
                    context.tr('viewDetailsBtn'),
                    style: AppTypography.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<MatchingProvider>().selectWorker(worker);
                    context.read<BookingFlowProvider>().initializeForWorker(
                      worker,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CustomerBookingDetailsScreen(worker: worker),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.tr('selectWorkerBtn'),
                    style: AppTypography.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Map View ---
  Widget _buildMapView(
    BuildContext context,
    MatchingProvider matching,
    String activeLocale,
  ) {
    return Stack(
      children: [
        AppMapView(
          initialPosition: LatLng(
            matching.selectedWorker?.latitude ?? 18.4800,
            matching.selectedWorker?.longitude ?? 73.8000,
          ),
          initialZoom: 13,
          markers: matching.workers.take(6).map((worker) {
            return Marker(
              point: LatLng(worker.latitude, worker.longitude),
              width: 70,
              height: 70,
              child: GestureDetector(
                onTap: () {
                  matching.selectWorker(worker);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CustomerWorkerProfileScreen(worker: worker),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${worker.matchScore}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.location_pin,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Bottom Selected Preview Card
        if (matching.workers.isNotEmpty)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildWorkerMatchCard(
              context,
              matching.selectedWorker ?? matching.workers.first,
              activeLocale,
            ),
          ),
      ],
    );
  }
}
