import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../data/home_models.dart';

/// Linimasa era (`#timeline-track`) beserta kartu detail di bawahnya
/// (`#timeline-detail`). Memilih node mengganti isi kartu detail.
///
/// Tombol "Lihat Koleksi Era Ini" memanggil [onOpenCollection] dengan nilai
/// filter era (mis. `Tumapel`), dan disembunyikan untuk era yang tidak
/// punya filter.
class EraTimeline extends StatefulWidget {
  const EraTimeline({super.key, required this.eras, required this.onOpenCollection})
    : assert(eras.length > 0);

  final List<EraInfo> eras;
  final ValueChanged<String> onOpenCollection;

  @override
  State<EraTimeline> createState() => _EraTimelineState();
}

class _EraTimelineState extends State<EraTimeline> {
  int _selected = 0;
  late final List<GlobalKey> _nodeKeys = List.generate(widget.eras.length, (_) => GlobalKey());

  void _select(int index) {
    setState(() => _selected = index);
    final nodeContext = _nodeKeys[index].currentContext;
    if (nodeContext != null) {
      Scrollable.ensureVisible(
        nodeContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final era = widget.eras[_selected];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(AppDimens.gutter, 6, AppDimens.gutter, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.eras.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: SizedBox(
                      width: 26,
                      height: 2,
                      child: ColoredBox(color: AppColors.stoneLine),
                    ),
                  ),
                _TimelineNode(
                  key: _nodeKeys[i],
                  era: widget.eras[i],
                  active: i == _selected,
                  onTap: () => _select(i),
                ),
              ],
            ],
          ),
        ),
        _EraDetailCard(era: era, onOpenCollection: widget.onOpenCollection),
      ],
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({super.key, required this.era, required this.active, required this.onTap});

  final EraInfo era;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: '${era.name}, ${era.period}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 78,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(bottom: 9),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.amber : AppColors.offwhite,
                  border: Border.all(
                    color: active ? AppColors.amber : AppColors.stoneMid,
                    width: 2.5,
                  ),
                  boxShadow: active
                      ? [BoxShadow(color: AppColors.amber.withValues(alpha: 0.2), spreadRadius: 4)]
                      : null,
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                textAlign: TextAlign.center,
                style: AppTextStyles.serif(
                  12.5,
                  color: active ? AppColors.stoneDark : AppColors.inkSoft,
                  height: 1.25,
                ),
                child: Text(era.name, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 3),
              Text(
                era.period,
                textAlign: TextAlign.center,
                style: AppTextStyles.sans(9.5, color: AppColors.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EraDetailCard extends StatelessWidget {
  const _EraDetailCard({required this.era, required this.onOpenCollection});

  final EraInfo era;
  final ValueChanged<String> onOpenCollection;

  @override
  Widget build(BuildContext context) {
    final filter = era.katalogFilter;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(AppDimens.gutter, 0, AppDimens.gutter, 26),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: AssetImage(era.backgroundAsset),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 168),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.17, -0.98), // 190deg
            end: Alignment(-0.17, 0.98),
            colors: [Color(0x1F141413), Color(0xB80F0F0E), Color(0xF00C0C0B)],
            stops: [0, 0.55, 1],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              era.label.toUpperCase(),
              style: AppTextStyles.sans(
                10,
                weight: FontWeight.w700,
                color: AppColors.amber,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              era.title,
              style: AppTextStyles.serif(
                19,
                weight: FontWeight.w400,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                era.description,
                style: AppTextStyles.sans(12, color: AppColors.onDarkSoft, height: 1.6),
              ),
            ),
            if (filter != null) ...[
              const SizedBox(height: 14),
              AppPillButton(
                label: 'Lihat Koleksi Era Ini',
                fontSize: 12,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                onPressed: () => onOpenCollection(filter),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
