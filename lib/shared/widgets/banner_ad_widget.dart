import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';

/// ╔══════════════════════════════════════════════════════════════════════════╗
/// ║  AdMob Banner Ad Unit IDs                                               ║
/// ║                                                                          ║
/// ║  TEST (current):  ca-app-pub-3940256099942544/6300978111                ║
/// ║  PRODUCTION:      replace [_bannerAdUnitId] with your real unit ID.     ║
/// ║                   Format: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX        ║
/// ╚══════════════════════════════════════════════════════════════════════════╝
const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

/// Self-loading, self-disposing banner ad widget.
/// Displays a standard 320×50 AdMob banner; hidden until the ad is loaded.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final ad = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    ad.load();
    _ad = ad;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _loaded ? 1.0 : 0.0,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.abyss,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        alignment: Alignment.center,
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
