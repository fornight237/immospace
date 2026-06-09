import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/furniture.dart';
import '../data/mock_data.dart';

// ─── Design tokens ──────────────────────────────────────────────────────────
const _kGold = Color(0xFFC9A84C);
const _kPanel = Color(0xFF0C0A09);
const _kCard = Color(0xFF1C1917);

// ─── Placed furniture model ─────────────────────────────────────────────────
class PlacedFurniture {
  final String id;
  final Furniture furniture;
  Offset position;
  double rotation;
  double scale;
  FurnitureColor activeColor;

  PlacedFurniture({
    required this.id,
    required this.furniture,
    required this.position,
    this.rotation = 0.0,
    this.scale = 1.0,
    required this.activeColor,
  });
}

// ─── Scanning state ─────────────────────────────────────────────────────────
enum _ScanState { initializing, scanning, ready, error }

// ═══════════════════════════════════════════════════════════════════════════════
class ArPlacementScreen extends StatefulWidget {
  final Furniture? initialFurniture;

  const ArPlacementScreen({super.key, this.initialFurniture});

  @override
  State<ArPlacementScreen> createState() => _ArPlacementScreenState();
}

class _ArPlacementScreenState extends State<ArPlacementScreen>
    with TickerProviderStateMixin {
  // Camera
  CameraController? _cameraCtrl;
  _ScanState _scanState = _ScanState.initializing;
  String _errorMsg = '';

  // AR scene
  final List<PlacedFurniture> _placedItems = [];
  PlacedFurniture? _selectedItem;
  String _activeCategory = 'all';

  // Scan animation
  late AnimationController _scanAnimCtrl;
  late Animation<double> _scanLineAnim;
  double _scanProgress = 0.0;
  Timer? _scanTimer;

  // Surface detection state
  bool _surfaceDetected = false;
  int _surfacePointCount = 0;

  @override
  void initState() {
    super.initState();

    _scanAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _scanLineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimCtrl, curve: Curves.easeInOut),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    // 1. Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _scanState = _ScanState.error;
        _errorMsg = status.isPermanentlyDenied
            ? 'Permission caméra refusée définitivement.\nAllez dans Paramètres > Applications > ImmoSpace > Permissions.'
            : 'Permission caméra requise pour la Réalité Augmentée.';
      });
      return;
    }

    // 2. Get available cameras
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _scanState = _ScanState.error;
          _errorMsg = 'Aucune caméra trouvée sur cet appareil.';
        });
        return;
      }

      // Pick the rear camera
      final cam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraCtrl = CameraController(
        cam,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraCtrl!.initialize();

      if (!mounted) return;

      setState(() => _scanState = _ScanState.scanning);
      _startSurfaceScan();
    } catch (e) {
      setState(() {
        _scanState = _ScanState.error;
        _errorMsg = 'Erreur initialisation caméra:\n$e';
      });
    }
  }

  /// Simulates surface scanning (ARCore-style) by gradually detecting
  /// "feature points" on the floor. In a production app this would
  /// use ARCore/ARKit via ar_flutter_plugin.
  void _startSurfaceScan() {
    _scanTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _scanProgress += 0.02;
        _surfacePointCount = (_scanProgress * 120).toInt();

        if (_scanProgress >= 0.3 && !_surfaceDetected) {
          _surfaceDetected = true;
        }

        if (_scanProgress >= 1.0) {
          timer.cancel();
          _scanState = _ScanState.ready;
          _scanAnimCtrl.stop();

          if (widget.initialFurniture != null) {
            _placeFurniture(widget.initialFurniture!);
          }
        }
      });
    });
  }

  void _placeFurniture(Furniture f) {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      final newItem = PlacedFurniture(
        id: 'placed-${DateTime.now().millisecondsSinceEpoch}',
        furniture: f,
        position: Offset(
          screenSize.width / 2 - 40,
          screenSize.height / 2 - 60,
        ),
        activeColor: f.colors.first,
      );
      _placedItems.add(newItem);
      _selectedItem = newItem;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(LucideIcons.checkCircle, color: _kGold, size: 16),
          const SizedBox(width: 8),
          Text('${f.name} placé sur la surface détectée !',
              style: GoogleFonts.inter(fontSize: 12)),
        ]),
        backgroundColor: _kCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteSelected() {
    if (_selectedItem == null) return;
    setState(() {
      _placedItems.removeWhere((i) => i.id == _selectedItem!.id);
      _selectedItem = null;
    });
  }

  int _totalBudget() =>
      _placedItems.fold(0, (s, i) => s + i.furniture.price);

  @override
  void dispose() {
    _scanTimer?.cancel();
    _scanAnimCtrl.dispose();
    _cameraCtrl?.dispose();
    super.dispose();
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera feed or fallback ──────────────────────────────────────
          _buildCameraLayer(),

          // ── Scanning overlay ────────────────────────────────────────────
          if (_scanState == _ScanState.scanning) _buildScanOverlay(),

          // ── Surface grid (after detection) ──────────────────────────────
          if (_surfaceDetected)
            Positioned.fill(
              child: CustomPaint(painter: _ArGridPainter(
                opacity: _scanState == _ScanState.ready ? 0.08 : 0.15,
              )),
            ),

          // ── Placed furniture items ──────────────────────────────────────
          if (_scanState == _ScanState.ready) ..._buildPlacedItems(),

          // ── Top header ──────────────────────────────────────────────────
          _buildHeader(),

          // ── Transform controls ──────────────────────────────────────────
          if (_selectedItem != null && _scanState == _ScanState.ready)
            _buildTransformControls(),

          // ── Bottom catalog ──────────────────────────────────────────────
          if (_scanState == _ScanState.ready) _buildCatalogPanel(),

          // ── Scan status indicator ───────────────────────────────────────
          if (_scanState == _ScanState.scanning) _buildScanStatus(),

          // ── Error state ─────────────────────────────────────────────────
          if (_scanState == _ScanState.error) _buildErrorOverlay(),
        ],
      ),
    );
  }

  // ── Camera layer ────────────────────────────────────────────────────────
  Widget _buildCameraLayer() {
    if (_cameraCtrl == null || !(_cameraCtrl!.value.isInitialized)) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: _kGold, strokeWidth: 2),
        ),
      );
    }

    return Positioned.fill(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraCtrl!.value.previewSize!.height,
          height: _cameraCtrl!.value.previewSize!.width,
          child: CameraPreview(_cameraCtrl!),
        ),
      ),
    );
  }

  // ── Scan overlay with animated scan line ────────────────────────────────
  Widget _buildScanOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _scanLineAnim,
        builder: (context, child) {
          return CustomPaint(
            painter: _ScanLinePainter(
              progress: _scanLineAnim.value,
              surfaceDetected: _surfaceDetected,
            ),
          );
        },
      ),
    );
  }

  // ── Scan status bar ─────────────────────────────────────────────────────
  Widget _buildScanStatus() {
    return Positioned(
      bottom: 120,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _kPanel.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _surfaceDetected
                ? _kGold.withValues(alpha: 0.5)
                : Colors.white24,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _surfaceDetected
                        ? _kGold.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _surfaceDetected
                        ? LucideIcons.checkCircle
                        : LucideIcons.scan,
                    color: _surfaceDetected ? _kGold : Colors.white54,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _surfaceDetected
                            ? 'Surface détectée !'
                            : 'Analyse de la pièce en cours...',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _surfaceDetected
                            ? 'Calibration de la surface — $_surfacePointCount points'
                            : 'Déplacez lentement votre appareil\nvers le sol pour scanner la surface.',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _scanProgress,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _surfaceDetected ? _kGold : Colors.white38,
                ),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(_scanProgress * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    color: _kGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$_surfacePointCount pts de référence',
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Error overlay ───────────────────────────────────────────────────────
  Widget _buildErrorOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.cameraOff,
                      color: Colors.redAccent, size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  'Caméra non disponible',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMsg,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildErrorButton(
                      'Réessayer',
                      LucideIcons.refreshCw,
                      () {
                        setState(() {
                          _scanState = _ScanState.initializing;
                          _scanProgress = 0;
                          _surfaceDetected = false;
                          _surfacePointCount = 0;
                        });
                        _scanAnimCtrl.repeat();
                        _initCamera();
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildErrorButton(
                      'Paramètres',
                      LucideIcons.settings,
                      () => openAppSettings(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kGold.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _kGold, size: 16),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _kPanel.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: _kGold.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(LucideIcons.arrowLeft,
                      color: Colors.white, size: 18),
                ),
              ),
              // Title badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _kPanel.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: _kGold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _scanState == _ScanState.ready
                            ? Colors.green
                            : _kGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _scanState == _ScanState.ready
                          ? 'RA ACTIVE'
                          : _scanState == _ScanState.scanning
                              ? 'SCAN EN COURS'
                              : 'INITIALISATION',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Item counter
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _kPanel.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_placedItems.length} obj.',
                  style: GoogleFonts.inter(
                    color: _kGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Budget bar
          if (_placedItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kCard.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF292524)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ESTIMATION DEVIS IMMO S'PACE :",
                    style: GoogleFonts.inter(
                      color: const Color(0xFFA8A29E),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(symbol: 'F CFA', decimalDigits: 0, locale: 'fr').format(_totalBudget()),
                    style: GoogleFonts.inter(
                      color: _kGold,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Placed draggable items ──────────────────────────────────────────────
  List<Widget> _buildPlacedItems() {
    return _placedItems.map((item) {
      final isSelected = _selectedItem?.id == item.id;
      return Positioned(
        left: item.position.dx,
        top: item.position.dy,
        child: GestureDetector(
          onPanUpdate: (d) {
            setState(() {
              item.position += d.delta;
              _selectedItem = item;
            });
          },
          onTap: () => setState(() => _selectedItem = item),
          child: Transform.rotate(
            angle: item.rotation * (math.pi / 180),
            child: Transform.scale(
              scale: item.scale,
              child: Container(
                width: 180,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  border: Border.all(
                    color: isSelected ? _kGold : Colors.white24,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _kGold.withValues(alpha: 0.3),
                            blurRadius: 16,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    // Header handle for dragging and selecting
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            LucideIcons.gripVertical,
                            color: Colors.white60,
                            size: 14,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                item.furniture.name,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          // Small color dot
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Color(int.parse(item.activeColor.hex
                                  .replaceFirst('#', '0xFF'))),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Model Viewer content
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                        child: item.furniture.model3DUrl.isNotEmpty
                            ? ModelViewer(
                                key: ValueKey('${item.id}_${item.activeColor.hex}'),
                                src: item.furniture.model3DUrl,
                                alt: item.furniture.name,
                                ar: true,
                                arModes: const ['scene-viewer', 'webxr', 'quick-look'],
                                autoRotate: true,
                                cameraControls: true,
                                disableZoom: false,
                                backgroundColor: Colors.transparent,
                              )
                            : Center(
                                child: Text(
                                  item.furniture.iconEmoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // ── Transform controls ──────────────────────────────────────────────────
  Widget _buildTransformControls() {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).padding.top + 100,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: _kCard.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kGold.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ctrlBtn(LucideIcons.rotateCw, _kGold, 'Tourner', () {
              setState(() {
                _selectedItem!.rotation =
                    (_selectedItem!.rotation + 15) % 360;
              });
            }),
            _ctrlBtn(LucideIcons.maximize, Colors.white, 'Agrandir', () {
              setState(() {
                if (_selectedItem!.scale < 1.8) {
                  _selectedItem!.scale += 0.1;
                }
              });
            }),
            _ctrlBtn(LucideIcons.minimize, Colors.white, 'Réduire', () {
              setState(() {
                if (_selectedItem!.scale > 0.5) {
                  _selectedItem!.scale -= 0.1;
                }
              });
            }),
            const Divider(color: Colors.white10, height: 16),
            _ctrlBtn(LucideIcons.trash2, Colors.redAccent, 'Retirer',
                _deleteSelected),
          ],
        ),
      ),
    );
  }

  Widget _ctrlBtn(
      IconData icon, Color color, String tip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onTap,
      tooltip: tip,
    );
  }

  // ── Catalog panel ───────────────────────────────────────────────────────
  Widget _buildCatalogPanel() {
    final categories = [
      {'id': 'all', 'label': 'Tous'},
      {'id': 'tables', 'label': 'Tables'},
      {'id': 'fauteuils', 'label': 'Fauteuils'},
      {'id': 'lampes', 'label': 'Lampes'},
      {'id': 'decorations', 'label': 'Décorations'},
    ];

    final filtered = _activeCategory == 'all'
        ? MockData.furnitureCatalog
        : MockData.furnitureCatalog
            .where((f) => f.category == _activeCategory)
            .toList();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kPanel,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: _kGold.withValues(alpha: 0.2)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Category tabs
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories.map((cat) {
                  bool selected = _activeCategory == cat['id'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _activeCategory = cat['id']!),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? _kGold : _kCard,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat['label']!,
                        style: GoogleFonts.inter(
                          color: selected ? Colors.black : Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Items carousel
            SizedBox(
              height: 108,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filtered.length,
                itemBuilder: (context, idx) {
                  final item = filtered[idx];
                  return GestureDetector(
                    onTap: () => _placeFurniture(item),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _kCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.iconEmoji,
                                  style: const TextStyle(fontSize: 20)),
                              Text(
                                NumberFormat.currency(symbol: 'F CFA', decimalDigits: 0, locale: 'fr').format(item.price),
                                style: GoogleFonts.inter(
                                  color: _kGold,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.widthCm}×${item.heightCm} cm',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF78716C),
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════════════════════

/// Draws a perspective-style AR grid on the floor surface
class _ArGridPainter extends CustomPainter {
  final double opacity;
  _ArGridPainter({this.opacity = 0.08});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kGold.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    // Draw grid
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw center crosshair
    final cx = size.width / 2;
    final cy = size.height / 2;
    final crossPaint = Paint()
      ..color = _kGold.withValues(alpha: 0.4)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - 20, cy), Offset(cx + 20, cy), crossPaint);
    canvas.drawLine(Offset(cx, cy - 20), Offset(cx, cy + 20), crossPaint);
  }

  @override
  bool shouldRepaint(covariant _ArGridPainter old) =>
      old.opacity != opacity;
}

/// Draws the scanning line that sweeps vertically
class _ScanLinePainter extends CustomPainter {
  final double progress;
  final bool surfaceDetected;

  _ScanLinePainter({
    required this.progress,
    required this.surfaceDetected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scan line
    final y = progress * size.height;
    final lineColor = surfaceDetected ? _kGold : Colors.white60;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          lineColor.withValues(alpha: 0),
          lineColor.withValues(alpha: 0.8),
          lineColor.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, y - 1, size.width, 2));
    canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 2), paint);

    // Scatter random "feature points" below the scan line
    final rng = math.Random(42);
    final pointPaint = Paint()
      ..color = (surfaceDetected ? _kGold : Colors.white)
          .withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final count = (progress * 60).toInt();
    for (int i = 0; i < count; i++) {
      final px = rng.nextDouble() * size.width;
      final py = rng.nextDouble() * y;
      canvas.drawCircle(Offset(px, py), 1.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter old) =>
      old.progress != progress || old.surfaceDetected != surfaceDetected;
}
