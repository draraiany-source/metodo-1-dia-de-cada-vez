import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/premium_feature_icon.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../auth/providers/auth_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../data/running_repository.dart';
import '../providers/running_providers.dart';

enum _LocState {
  checking,
  needPermission,
  gpsOff,
  ready,
  error,
}

/// Corrida / GPS — métricas reais, pausa, histórico e mapa (OSM via flutter_map).
class RunningScreen extends ConsumerStatefulWidget {
  const RunningScreen({super.key});

  @override
  ConsumerState<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends ConsumerState<RunningScreen> {
  /// Centro de fallback no Web quando GPS nativo não responde (São Paulo).
  static const LatLng _webFallbackCenter = LatLng(-23.5505, -46.6333);

  StreamSubscription<Position>? _posSub;
  Timer? _timer;
  final MapController _mapController = MapController();

  _LocState _locState = _LocState.checking;
  bool _webDemoMode = false;
  bool _mapLoadFailed = false;
  bool _running = false;
  bool _paused = false;

  double _distanceKm = 0;
  Duration _elapsed = Duration.zero;
  Position? _lastPosition;
  double _currentSpeedKmh = 0;
  final List<LatLng> _track = [];
  LatLng? _currentLatLng;

  List<RunningSession> _history = [];
  bool _historyLoading = true;

  double get _paceMinPerKm =>
      _distanceKm > 0 ? (_elapsed.inSeconds / 60) / _distanceKm : 0;

  double get _avgSpeedKmh =>
      _elapsed.inSeconds > 0 ? _distanceKm / (_elapsed.inSeconds / 3600) : 0;

  int get _kcal => (_distanceKm * 60).round();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _refreshPermission(request: false);
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'demo';
    try {
      final list =
          await ref.read(runningRepositoryProvider).fetchAll(userId);
      if (!mounted) return;
      setState(() {
        _history = list;
        _historyLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _historyLoading = false);
    }
  }

  void _activateWebFallback() {
    setState(() {
      _webDemoMode = true;
      _locState = _LocState.ready;
      _mapLoadFailed = false;
      _currentLatLng ??= _webFallbackCenter;
    });
    try {
      _mapController.move(_currentLatLng!, 15);
    } catch (_) {/* mapa ainda não montado */}
  }

  Future<void> _refreshPermission({required bool request}) async {
    setState(() {
      _locState = _LocState.checking;
      _mapLoadFailed = false;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        if (kIsWeb) {
          _activateWebFallback();
          return;
        }
        setState(() => _locState = _LocState.gpsOff);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && request) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        if (kIsWeb) {
          _activateWebFallback();
          return;
        }
        setState(() => _locState = _LocState.needPermission);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _webDemoMode = false;
        _locState = _LocState.ready;
        _currentLatLng = LatLng(pos.latitude, pos.longitude);
        _lastPosition = pos;
      });
      try {
        _mapController.move(_currentLatLng!, 16);
      } catch (_) {/* mapa ainda não montado */}
    } catch (_) {
      if (!mounted) return;
      if (kIsWeb) {
        _activateWebFallback();
        return;
      }
      setState(() => _locState = _LocState.error);
    }
  }

  Future<void> _start() async {
    if (_locState != _LocState.ready) {
      await _refreshPermission(request: true);
      if (_locState != _LocState.ready) return;
    }

    setState(() {
      _running = true;
      _paused = false;
      if (_track.isEmpty && _currentLatLng != null) {
        _track.add(_currentLatLng!);
      }
    });
    FeedbackService.play(FeedbackEvent.toqueLeve);
    _startTimer();
    _startGps();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _paused) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  void _startGps() {
    _posSub?.cancel();
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) {
        if (!mounted || _paused) return;
        final point = LatLng(pos.latitude, pos.longitude);
        if (_lastPosition != null) {
          final meters = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            pos.latitude,
            pos.longitude,
          );
          if (meters < 100) {
            setState(() {
              _distanceKm += meters / 1000;
              _currentSpeedKmh = (pos.speed.isFinite && pos.speed > 0)
                  ? pos.speed * 3.6
                  : _avgSpeedKmh;
              _track.add(point);
              _currentLatLng = point;
              _lastPosition = pos;
            });
            try {
              _mapController.move(point, _mapController.camera.zoom);
            } catch (_) {}
            return;
          }
        }
        setState(() {
          _currentLatLng = point;
          _lastPosition = pos;
          if (_track.isEmpty) _track.add(point);
        });
      },
      onError: (_) {
        if (!mounted) return;
        if (_webDemoMode) return;
        setState(() => _locState = _LocState.error);
      },
    );
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
    setState(() => _paused = true);
    FeedbackService.play(FeedbackEvent.toqueLeve);
  }

  void _resume() {
    setState(() => _paused = false);
    _startTimer();
    FeedbackService.play(FeedbackEvent.toqueLeve);
  }

  Future<void> _finish() async {
    _posSub?.cancel();
    _timer?.cancel();
    setState(() {
      _running = false;
      _paused = false;
    });
    ref.read(missionsProvider.notifier).report(MissionEvent.corridaConcluida);
    await FeedbackService.play(FeedbackEvent.sucesso);
    if (!mounted) return;
    await _showSummary();
  }

  Future<void> _showSummary() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        final now = DateTime.now();
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            24 + MediaQuery.paddingOf(sheetCtx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Treino concluído', style: AppTextStyles.h2()),
              const SizedBox(height: 6),
              Text(
                '${now.day.toString().padLeft(2, '0')}/'
                '${now.month.toString().padLeft(2, '0')}/${now.year}  ·  '
                '${now.hour.toString().padLeft(2, '0')}:'
                '${now.minute.toString().padLeft(2, '0')}',
                style: AppTextStyles.caption(),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _SummaryChip(
                    label: 'Distância',
                    value: '${_distanceKm.toStringAsFixed(2)} km',
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(label: 'Tempo', value: _fmt(_elapsed)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _SummaryChip(
                    label: 'Ritmo médio',
                    value: _paceMinPerKm > 0
                        ? '${_paceMinPerKm.toStringAsFixed(1)} min/km'
                        : '—',
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    label: 'Vel. média',
                    value: '${_avgSpeedKmh.toStringAsFixed(1)} km/h',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _SummaryChip(
                label: 'Calorias estimadas',
                value: '$_kcal kcal',
                full: true,
              ),
              if (_track.length >= 2) ...[
                const SizedBox(height: 14),
                SizedBox(
                  height: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _RunMap(
                      controller: MapController(),
                      track: _track,
                      current: _track.last,
                      interactive: false,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Salvar corrida',
                icon: Icons.check_rounded,
                onPressed: () async {
                  final userId =
                      ref.read(currentUserProvider)?.id ?? 'demo';
                  final session = RunningSession(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    date: DateTime.now(),
                    distanceKm: _distanceKm,
                    durationSeconds: _elapsed.inSeconds,
                    kcal: _kcal,
                  );
                  await ref.read(runningRepositoryProvider).save(userId, session);
                  ref.invalidate(runningHistoryProvider(userId));
                  if (!sheetCtx.mounted) return;
                  Navigator.pop(sheetCtx);
                  if (!mounted) return;
                  setState(() {
                    _distanceKm = 0;
                    _elapsed = Duration.zero;
                    _lastPosition = null;
                    _currentSpeedKmh = 0;
                    _track.clear();
                    _history = [session, ..._history];
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _timer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_running,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !_running) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('Sair da corrida?', style: AppTextStyles.title()),
            content: Text(
              'Sua atividade ainda está em andamento. Deseja finalizar e sair?',
              style: AppTextStyles.bodySecondary(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Continuar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Finalizar',
                    style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        );
        if (leave == true && mounted) {
          await _finish();
          if (mounted) AppNavigation.back(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PremiumAppBar(
          title: 'Minha Corrida',
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AppIconImage(
                AppIcons.gps,
                size: 28,
                fallbackIcon: Icons.directions_run_rounded,
                semanticLabel: 'GPS',
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: AppPage(
            scrollable: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                Text(
                  'Acompanhe seu treino em tempo real',
                  style: AppTextStyles.bodySecondary(),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    AppAssets.illustCorridaGpsDark,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 14),
                _LocationBanner(
                  state: _locState,
                  isWeb: kIsWeb,
                  webDemoMode: _webDemoMode,
                  onActivate: () => _refreshPermission(request: true),
                ),
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: 16 / 11,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildMapArea(),
                  ),
                ),
                const SizedBox(height: 14),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _MetricTile(
                            label: 'DISTÂNCIA',
                            value: _distanceKm.toStringAsFixed(2),
                            unit: 'km',
                          ),
                          _MetricTile(
                            label: 'TEMPO',
                            value: _fmt(_elapsed),
                            unit: '',
                          ),
                          _MetricTile(
                            label: 'RITMO',
                            value: _paceMinPerKm > 0
                                ? _paceMinPerKm.toStringAsFixed(1)
                                : '—',
                            unit: 'min/km',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _MetricTile(
                            label: 'VELOCIDADE',
                            value: _currentSpeedKmh > 0
                                ? _currentSpeedKmh.toStringAsFixed(1)
                                : _avgSpeedKmh.toStringAsFixed(1),
                            unit: 'km/h',
                          ),
                          _MetricTile(
                            label: 'CALORIAS',
                            value: '$_kcal',
                            unit: 'kcal',
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (!_running)
                  PrimaryButton(
                    label: 'INICIAR CORRIDA',
                    icon: Icons.play_arrow_rounded,
                    iconAsset: AppIcons.play,
                    onPressed: _locState == _LocState.checking ? null : _start,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _paused ? _resume : _pause,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.border),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: AppIconImage(
                            _paused ? AppIcons.play : AppIcons.pause,
                            size: 20,
                            fallbackIcon: _paused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                          ),
                          label: Text(_paused ? 'CONTINUAR' : 'PAUSAR'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PrimaryButton(
                          label: 'FINALIZAR',
                          icon: Icons.stop_rounded,
                          iconAsset: AppIcons.complete,
                          onPressed: _finish,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 22),
                SectionHeader(title: 'Minhas corridas'),
                const SizedBox(height: 10),
                if (_historyLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                      ),
                    ),
                  )
                else if (_history.isEmpty)
                  AppCard(
                    child: Text(
                      'Suas corridas salvas aparecerão aqui.',
                      style: AppTextStyles.bodySecondary(),
                    ),
                  )
                else
                  ..._history.take(20).map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            onTap: () => _openDetail(s),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                PremiumFeatureIcon.running(
                                  size: PremiumIconSize.card,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${s.date.day.toString().padLeft(2, '0')}/'
                                        '${s.date.month.toString().padLeft(2, '0')}/'
                                        '${s.date.year}',
                                        style: AppTextStyles.title()
                                            .copyWith(fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${s.distanceKm.toStringAsFixed(2)} km  ·  '
                                        '${_fmt(Duration(seconds: s.durationSeconds))}  ·  '
                                        '${s.paceMinPerKm > 0 ? '${s.paceMinPerKm.toStringAsFixed(1)} min/km' : '—'}',
                                        style: AppTextStyles.caption(),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    color: AppColors.textTertiary),
                              ],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapArea() {
    if (_locState == _LocState.checking) {
      return Container(
        color: AppColors.surface2,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.secondary),
            SizedBox(height: 12),
            Text(
              'Carregando localização…',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_mapLoadFailed) {
      return Container(
        color: AppColors.surface2,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, color: AppColors.warning, size: 40),
            const SizedBox(height: 12),
            Text(
              'Erro ao carregar mapa',
              textAlign: TextAlign.center,
              style: AppTextStyles.title().copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              kIsWeb
                  ? 'Verifique sua conexão. No celular o mapa usa GPS com precisão total.'
                  : 'Verifique sua conexão e tente novamente.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary(),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => setState(() => _mapLoadFailed = false),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_currentLatLng != null &&
        (_locState == _LocState.ready || _running || _track.isNotEmpty)) {
      return _RunMap(
        controller: _mapController,
        track: _track,
        current: _currentLatLng!,
        interactive: true,
        onTileError: () {
          if (!mounted) return;
          setState(() => _mapLoadFailed = true);
        },
      );
    }

    return Container(
      color: AppColors.surface2,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PremiumFeatureIcon.running(size: PremiumIconSize.highlight),
          const SizedBox(height: 12),
          Text(
            _locState == _LocState.needPermission
                ? 'Aguardando permissão de localização'
                : _locState == _LocState.gpsOff
                    ? 'Localização indisponível — ative o GPS'
                    : kIsWeb
                        ? 'Ative a localização ou use o modo demonstração abaixo'
                        : 'Ative a localização para ver o mapa e o percurso',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary(),
          ),
          if (_locState == _LocState.needPermission ||
              _locState == _LocState.gpsOff ||
              _locState == _LocState.error) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _refreshPermission(request: true),
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
          if (kIsWeb && _locState != _LocState.checking) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _activateWebFallback,
              child: const Text('Usar mapa demonstrativo (Web)'),
            ),
          ],
        ],
      ),
    );
  }

  void _openDetail(RunningSession s) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalhes da corrida', style: AppTextStyles.h3()),
            const SizedBox(height: 12),
            Text(
              '${s.date.day.toString().padLeft(2, '0')}/'
              '${s.date.month.toString().padLeft(2, '0')}/${s.date.year}  '
              '${s.date.hour.toString().padLeft(2, '0')}:'
              '${s.date.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.caption(),
            ),
            const SizedBox(height: 14),
            Text('${s.distanceKm.toStringAsFixed(2)} km',
                style: AppTextStyles.h2(color: AppColors.secondary)),
            const SizedBox(height: 8),
            Text(
              'Tempo ${_fmt(Duration(seconds: s.durationSeconds))}  ·  '
              'Ritmo ${s.paceMinPerKm > 0 ? '${s.paceMinPerKm.toStringAsFixed(1)} min/km' : '—'}  ·  '
              '${s.kcal} kcal',
              style: AppTextStyles.bodySecondary(),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Fechar',
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunMap extends StatelessWidget {
  const _RunMap({
    required this.controller,
    required this.track,
    required this.current,
    required this.interactive,
    this.onTileError,
  });

  final MapController controller;
  final List<LatLng> track;
  final LatLng current;
  final bool interactive;
  final VoidCallback? onTileError;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: current,
        initialZoom: 16,
        interactionOptions: InteractionOptions(
          flags: interactive
              ? InteractiveFlag.all
              : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.metodo1dia.app',
          errorTileCallback: (_, __, ___) => onTileError?.call(),
        ),
        if (track.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: track,
                color: AppColors.secondary,
                strokeWidth: 4,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: current,
              width: 28,
              height: 28,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.45),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationBanner extends StatelessWidget {
  const _LocationBanner({
    required this.state,
    required this.isWeb,
    required this.webDemoMode,
    required this.onActivate,
  });

  final _LocState state;
  final bool isWeb;
  final bool webDemoMode;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final (title, action, accent) = switch (state) {
      _LocState.checking => (
          'Verificando localização…',
          null,
          AppColors.secondary,
        ),
      _LocState.needPermission => (
          'Permissão necessária para rastrear sua corrida',
          'Ativar localização',
          AppColors.warning,
        ),
      _LocState.gpsOff => (
          'GPS desligado — ative a localização do aparelho',
          'Tentar novamente',
          AppColors.danger,
        ),
      _LocState.ready => (
          webDemoMode
              ? 'Modo demonstração Web — GPS real no celular'
              : isWeb
                  ? 'Localização disponível (melhor precisão no celular)'
                  : 'Localização disponível',
          webDemoMode ? 'Tentar GPS' : null,
          webDemoMode ? AppColors.info : AppColors.success,
        ),
      _LocState.error => (
          isWeb
              ? 'GPS indisponível no navegador — use o mapa demonstrativo'
              : 'Erro ao localizar — tente novamente',
          'Tentar novamente',
          AppColors.danger,
        ),
    };

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.my_location_rounded, color: accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: AppTextStyles.caption(color: Colors.white)),
          ),
          if (action != null)
            TextButton(
              onPressed: onActivate,
              child: Text(
                action,
                style: AppTextStyles.caption(color: AppColors.secondary)
                    .copyWith(fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTextStyles.caption().copyWith(fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.title().copyWith(fontSize: 18)),
          if (unit.isNotEmpty)
            Text(unit, style: AppTextStyles.caption().copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    this.full = false,
  });

  final String label;
  final String value;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: full ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption()),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.title().copyWith(fontSize: 15)),
        ],
      ),
    );
    return full ? child : Expanded(child: child);
  }
}
