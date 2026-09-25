import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/mascot/mascot_widget.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/feature_illustration_banner.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../missions/providers/missions_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/running_repository.dart';
import '../providers/running_providers.dart';

/// Corrida Online com GPS.
///
/// Usa o pacote `geolocator` para rastrear posi├º├úo em tempo real,
/// calculando dist├óncia acumulada, ritmo m├®dio e calorias estimadas.
///
/// OBS: o mapa visual (google_maps_flutter) est├í preparado no pubspec
/// mas comentado ÔÇö habilite ao configurar a chave da Google Maps API.
class RunningScreen extends ConsumerStatefulWidget {
  const RunningScreen({super.key});

  @override
  ConsumerState<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends ConsumerState<RunningScreen> {
  StreamSubscription<Position>? _posSub;
  Timer? _timer;

  bool _running = false;
  bool _permissionError = false;
  double _distanceKm = 0;
  Duration _elapsed = Duration.zero;
  Position? _lastPosition;

  double get _paceMinPerKm =>
      _distanceKm > 0 ? (_elapsed.inSeconds / 60) / _distanceKm : 0;
  int get _kcal => (_distanceKm * 60).round(); // ~60 kcal/km estimado

  Future<bool> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> _start() async {
    final ok = await _ensurePermission();
    if (!mounted) return; // usu├íria saiu da tela durante o di├ílogo de permiss├úo
    if (!ok) {
      setState(() => _permissionError = true);
      return;
    }
    setState(() {
      _running = true;
      _permissionError = false;
    });
    FeedbackService.play(FeedbackEvent.toqueLeve);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });

    // `high` (Ôëê10m) em vez de `best`: precis├úo suficiente para corrida e
    // consumo de bateria bem menor. distanceFilter evita updates parados.
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) {
        if (!mounted) return;
        if (_lastPosition != null) {
          final meters = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            pos.latitude,
            pos.longitude,
          );
          // Descarta saltos de GPS (> 100 m em 1 update) que inflam a dist├óncia.
          if (meters < 100) {
            setState(() => _distanceKm += meters / 1000);
          }
        }
        _lastPosition = pos;
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() => _permissionError = true);
      },
      cancelOnError: false,
    );
  }

  void _stop() {
    _posSub?.cancel();
    _timer?.cancel();
    setState(() => _running = false);
    // Miss├úo: corrida conclu├¡da.
    ref.read(missionsProvider.notifier).report(MissionEvent.corridaConcluida);
    FeedbackService.play(FeedbackEvent.sucesso);
    _showSummary();
  }

  void _reset() {
    setState(() {
      _distanceKm = 0;
      _elapsed = Duration.zero;
      _lastPosition = null;
    });
  }

  void _showSummary() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('­ƒÅü Corrida finalizada!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('${_distanceKm.toStringAsFixed(2)} km em ${_fmt(_elapsed)}',
                style: const TextStyle(
                    color: AppColors.secondary, fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
                'Sess├úo ser├í salva no seu hist├│rico de corridas.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final userId =
                    ref.read(currentUserProvider)?.id ?? 'demo';
                await ref.read(runningRepositoryProvider).save(
                      userId,
                      RunningSession(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        date: DateTime.now(),
                        distanceKm: _distanceKm,
                        durationSeconds: _elapsed.inSeconds,
                        kcal: _kcal,
                      ),
                    );
                if (!context.mounted) return;
                Navigator.pop(context);
                _reset();
              },
              child: const Text('Salvar e concluir (+70 XP)'),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Corrida Online ­ƒÅâ')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Lili correndo ÔÇö pose cardio em destaque (~40% da faixa superior).
            ColoredBox(
              color: Colors.black,
              child: LiliFitMascot(
                pose: MascotePose.forte,
                assetPath: MascotAssets.running,
                role: LiliDisplayRole.hero,
                heightFraction: 0.38,
                maxHeight: 280,
                semanticsLabel: 'Lili Fit correndo',
              ),
            ),
            const SizedBox(height: 12),
            // ├ürea "mapa" (placeholder at├® configurar Google Maps).
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.splashGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Center(
                  child: _running || _permissionError
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _running
                                  ? Icons.gps_fixed
                                  : Icons.map_outlined,
                              size: 56,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _permissionError
                                  ? 'Permiss├úo de localiza├º├úo negada.\nAtive o GPS para rastrear.'
                                  : 'Rastreando sua corrida via GPS...',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '(Mapa Google Maps: habilite a chave da API)',
                              style: TextStyle(
                                  color: AppColors.textTertiary, fontSize: 11),
                            ),
                          ],
                        )
                      : const Padding(
                          padding: EdgeInsets.all(12),
                          child: FeatureIllustrationBanner(
                            assetPath: AppAssets.illustCorridaGpsApp,
                            height: 180,
                            backgroundColor: Colors.transparent,
                            semanticLabel: 'Ilustra├º├úo de corrida com GPS',
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // M├®tricas
            Row(
              children: [
                _Metric(
                    value: _distanceKm.toStringAsFixed(2),
                    unit: 'km',
                    label: 'Dist├óncia'),
                _Metric(value: _fmt(_elapsed), unit: '', label: 'Tempo'),
                _Metric(
                    value: _paceMinPerKm > 0
                        ? _paceMinPerKm.toStringAsFixed(1)
                        : '0.0',
                    unit: 'min/km',
                    label: 'Ritmo'),
                _Metric(value: '$_kcal', unit: 'kcal', label: 'Calorias'),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _running ? AppColors.danger : AppColors.success,
                ),
                onPressed: _running ? _stop : _start,
                icon: Icon(_running ? Icons.stop : Icons.play_arrow),
                label: Text(_running ? 'Finalizar corrida' : 'Iniciar corrida'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.unit, required this.label});
  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              children: [
                TextSpan(
                    text: unit.isEmpty ? '' : ' $unit',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
