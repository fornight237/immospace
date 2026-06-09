import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/property.dart';
import '../data/mock_data.dart';

class OwnerAdminScreen extends StatefulWidget {
  final VoidCallback onPropertyAdded;

  const OwnerAdminScreen({
    super.key,
    required this.onPropertyAdded,
  });

  @override
  State<OwnerAdminScreen> createState() => _OwnerAdminScreenState();
}

class _OwnerAdminScreenState extends State<OwnerAdminScreen>
    with TickerProviderStateMixin {
  // Navigation State within Admin
  int _adminStep =
      0; // 0: Formulaire Infos, 1: Capturer Panorama 360°, 2: Relier & Configurer Hotspots, 3: Confirmation de publication

  // Form Controllers
  final _titleController =
      TextEditingController(text: "Villa d'Élite Panoramique");
  final _addressController =
      TextEditingController(text: "75 Chemin des Collines, 06400 Cannes");
  final _priceController = TextEditingController(text: "1 450 000 €");
  final _descriptionController = TextEditingController(
      text:
          "Une somptueuse villa contemporaine offrant des prestations d'exception, nichée sur les hauteurs de Cannes avec une vue panoramique infinie sur la mer Méditerranée.");
  final _areaController = TextEditingController(text: "210");
  final _bedroomsController = TextEditingController(text: "4");
  final _bathroomsController = TextEditingController(text: "3");

  // Custom Preset Images for newly captured rooms
  final List<Map<String, String>> _roomPresetPanoramas = [
    {
      'name': 'Séjour Royal Azur (Vue Mer)',
      'url':
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&q=80&w=1600',
      'type': 'salon',
    },
    {
      'name': 'Cuisine Épurée High-Tech',
      'url':
          'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?auto=format&fit=crop&q=80&w=1600',
      'type': 'cuisine',
    },
    {
      'name': 'Suite Sommet d\'Exception',
      'url':
          'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&q=80&w=1600',
      'type': 'chambre',
    },
    {
      'name': 'Terrasse Suspendue Infiniti',
      'url':
          'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?auto=format&fit=crop&q=80&w=1600',
      'type': 'terrasse',
    }
  ];

  int _selectedPanoramaPresetIndex = 0;

  // AR/Panorama Interactive Capture Simulator States
  double _captureProgress = 0.0;
  bool _isCapturing = false;
  double _compassAngle = 0.0;
  double _tiltOffset = 0.0;
  String _captureStatusMessage =
      "Positionnez votre téléphone à niveau pour commencer.";
  Timer? _captureTimer;

  // Custom Hotspots configuration states
  final List<Hotspot> _customHotspots = [];
  String _selectedTargetRoomToLink = 'room-neuilly-salon';

  @override
  void dispose() {
    _captureTimer?.cancel();
    _titleController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  // Starts the elegant 360° sensor-simulation scanning
  void _startCameraScanning() {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
      _captureProgress = 0.0;
      _captureStatusMessage = "Stabilisation gyroscopique de l'optique...";
    });

    const frequency = Duration(milliseconds: 100);
    _captureTimer = Timer.periodic(frequency, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        // Simulating turning the device to assemble the 360 photo
        _compassAngle += 0.08;
        _tiltOffset =
            math.sin(_compassAngle * 5) * 8.0; // Simulated micro-vibration

        if (_captureProgress < 1.0) {
          _captureProgress +=
              0.025; // progress 2.5% every 100ms --> 4 seconds total

          if (_captureProgress < 0.25) {
            _captureStatusMessage =
                "Scan du secteur Ouest S'PACE (Mise au point)...";
          } else if (_captureProgress < 0.50) {
            _captureStatusMessage =
                "Assemblage secteur Nord (Calibrage de l'exposition)...";
          } else if (_captureProgress < 0.75) {
            _captureStatusMessage =
                "Analyse secteur Est (Lissage de la colorimétrie)...";
          } else {
            _captureStatusMessage =
                "Suture stéréoscopique finale (Rendu HD 10K)...";
          }
        } else {
          _captureProgress = 1.0;
          _isCapturing = false;
          _tiltOffset = 0.0;
          _captureStatusMessage = "Panorama 360° capturé avec succès !";
          timer.cancel();

          _showActionFeedback(
              "S'PACE Horizon a généré votre panorama interactif.");
        }
      });
    });
  }

  void _showActionFeedback(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.sparkles,
                color: Color(0xFFC5A153), size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
          ],
        ),
        backgroundColor: const Color(0xFF1C1917),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Inserts a customized hotspot dot simulated on screen coordinates
  void _addHotspotAtCurrentCenter() {
    final nextId = "h-admin-${DateTime.now().millisecondsSinceEpoch}";
    final labels = [
      "Passer au Salon",
      "Vers la cuisine d'art",
      "Vers la terrasse",
      "Aller à la Suite parentale"
    ];
    final targetLabel = labels[_customHotspots.length % labels.length];

    setState(() {
      _customHotspots.add(Hotspot(
        id: nextId,
        label: targetLabel,
        x: 0.3 +
            (_customHotspots.length * 0.1) %
                0.4, // Distribute along screen width
        y: 0.4 + (_customHotspots.length * 0.05) % 0.2, // Center-ish height
        targetRoomId: _selectedTargetRoomToLink,
      ));
    });

    _showActionFeedback("Lien virtuel interactif ('$targetLabel') placé.");
  }

  // Publishes the newly built immersive property
  void _publishProperty() {
    final areaVal = int.tryParse(_areaController.text) ?? 150;
    final bedVal = int.tryParse(_bedroomsController.text) ?? 3;
    final bathVal = double.tryParse(_bathroomsController.text) ?? 2.0;

    // Build unique rooms out of captured panorama
    final listRooms = [
      Room(
        id: 'room-admin-custom-${DateTime.now().millisecondsSinceEpoch}',
        name: _roomPresetPanoramas[_selectedPanoramaPresetIndex]['name']!,
        type: _roomPresetPanoramas[_selectedPanoramaPresetIndex]['type']!,
        panoramaUrl: _roomPresetPanoramas[_selectedPanoramaPresetIndex]['url']!,
        colorTheme: '#c5a153',
        hotspots: List.from(_customHotspots),
      ),
      // Automatically add a secondary fallback room for transition feel
      Room(
        id: 'room-neuilly-salon',
        name: 'Salon Haussmannien principal S\'PACE',
        type: 'salon',
        panoramaUrl:
            'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&q=80&w=1600',
        colorTheme: '#c5a153',
        hotspots: [],
      )
    ];

    final newProp = Property(
      id: 'prop-captured-${DateTime.now().millisecondsSinceEpoch}',
      title: "${_titleController.text} (Annonce Prop.)",
      address: _addressController.text,
      price: _priceController.text,
      description: _descriptionController.text,
      image:
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&q=80&w=800', // high resolution
      bedroomsCount: bedVal,
      bathroomsCount: bathVal,
      areaSqm: areaVal,
      rooms: listRooms,
    );

    // Insert into static MockData properties! Côté client, il sera lu instantanément dans le catalogue!
    MockData.properties.insert(0, newProp);

    setState(() {
      _adminStep = 3; // Forward to publication confirmation screen
    });

    // Notify listeners
    widget.onPropertyAdded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0A09), // stone-950
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1917),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ESPACE PROPRIÉTAIRE",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "STUDIO DESIGN ET VISITE EN RÉALITÉ VIRTUELLE",
              style: TextStyle(
                  color: Color(0xFFC5A153),
                  fontSize: 8,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFC5A153).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: const Color(0xFFC5A153).withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.shieldCheck,
                    color: Color(0xFFC5A153), size: 12),
                SizedBox(width: 4),
                Text("MODE ADMIN",
                    style: TextStyle(
                        color: Color(0xFFC5A153),
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Step Progress Timeline bar
          _buildStepBar(),

          // Form content vs Capture content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),

          // Bottom controller buttons
          _buildBottomActionNavigation(),
        ],
      ),
    );
  }

  Widget _buildStepBar() {
    final stepLabels = [
      "1. Annonce",
      "2. Panorama 360°",
      "3. Liens 3D",
      "4. Publier"
    ];
    return Container(
      color: const Color(0xFF131110),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(stepLabels.length, (idx) {
          bool isSelected = _adminStep == idx;
          bool isPassed = _adminStep > idx;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFFC5A153)
                      : isPassed
                          ? const Color(0xFF131110)
                          : const Color(0xFF292524),
                  border: Border.all(
                    color: isSelected || isPassed
                        ? const Color(0xFFC5A153)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isPassed
                      ? const Icon(LucideIcons.check,
                          size: 12, color: Color(0xFFC5A153))
                      : Text(
                          "${idx + 1}",
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white60,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                stepLabels[idx],
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFC5A153)
                      : const Color(0xFF78716C),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_adminStep) {
      case 0:
        return _buildStep0Form();
      case 1:
        return _buildStep1CameraCapture();
      case 2:
        return _buildStep2HotspotConfig();
      case 3:
        return _buildStep3Confirmation();
      default:
        return Container();
    }
  }

  // STEP 0: DETAILS FORM
  Widget _buildStep0Form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ENREGISTRER LE BIEN PRESTIGE",
          style: TextStyle(
              color: Color(0xFFC5A153),
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        const Text(
          "Informations Commerciales",
          style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'serif',
              fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 4),
        const Text(
          "Configurez l'annonce de votre client d'élite avant de filmer ou d'assembler la scène virtuelle 360° S'PACE.",
          style: TextStyle(color: Color(0xFFA8A29E), fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 24),
        _buildAdminInput("Titre de l'Annonce de standing", _titleController,
            hint: "Appartement d'architecte - Paris 8e"),
        const SizedBox(height: 16),
        _buildAdminInput("Localisation / Adresse complète", _addressController,
            hint: "12 Avenue Montaigne, 75008 Paris"),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildAdminInput(
                    "Budget de prestige estimé", _priceController,
                    hint: "1 200 000 €")),
            const SizedBox(width: 14),
            Expanded(
                child: _buildAdminInput(
                    "Superficie habitable (m²)", _areaController,
                    hint: "150", keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildAdminInput(
                    "Nombre de Chambres", _bedroomsController,
                    hint: "3", keyboardType: TextInputType.number)),
            const SizedBox(width: 14),
            Expanded(
                child: _buildAdminInput("Salles de Bain", _bathroomsController,
                    hint: "2.5",
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true))),
          ],
        ),
        const SizedBox(height: 16),
        _buildAdminInput(
            "Description de standing & Signature", _descriptionController,
            hint: "Moulures, double séjour d'architecte, suite de maître...",
            maxLines: 3),
        const SizedBox(height: 20),
      ],
    );
  }

  // STEP 1: CAPTURE OVERVIEW AND DEVICE ORIENTATION SIMULATOR
  Widget _buildStep1CameraCapture() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "S'PACE HORIZON 360° SENSOR",
          style: TextStyle(
              color: Color(0xFFC5A153),
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        const Text(
          "Capture Immersive du Panorama",
          style:
              TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'serif'),
        ),
        const SizedBox(height: 4),
        const Text(
          "Associez un panorama 360° prestigieux. Vous pouvez filmer virtuellement le lieu à l'aide de notre gyroscope d'orientation autonome.",
          style: TextStyle(color: Color(0xFFA8A29E), fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 20),

        // Visual Selector of prestance rooms presets
        const Text(
          "CHOISIR LA PIÈCE DE PRESTIGE À CAPTURER :",
          style: TextStyle(
              color: Color(0xFF78716C),
              fontSize: 9,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 74,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _roomPresetPanoramas.length,
            itemBuilder: (context, index) {
              final preset = _roomPresetPanoramas[index];
              bool isSelected = _selectedPanoramaPresetIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPanoramaPresetIndex = index;
                  });
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1C1917) : Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? const Color(0xFFC5A153) : Colors.white12,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: const Color(0xFF0C0A09),
                            borderRadius: BorderRadius.circular(6)),
                        child: Icon(
                          preset['type'] == 'salon'
                              ? LucideIcons.home
                              : preset['type'] == 'cuisine'
                                  ? LucideIcons.utensils
                                  : preset['type'] == 'chambre'
                                      ? LucideIcons.bed
                                      : LucideIcons.sunset,
                          color: const Color(0xFFC5A153),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              preset['name']!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              preset['type']!.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 8),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Simulated Camera HUD / Sensor Box
        Container(
          height: 260,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF292524)),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFC5A153).withValues(alpha: 0.04),
                  blurRadius: 15,
                  spreadRadius: 1),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              // Faux background camera stream of a noble room with a grid structure
              Positioned.fill(
                child: Opacity(
                  opacity: 0.4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: Image.network(
                      _roomPresetPanoramas[_selectedPanoramaPresetIndex]
                          ['url']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Simulated 360° Alignment Grid
              Positioned.fill(
                child: CustomPaint(
                  painter: _CameraGridPainter(
                      compassAngle: _compassAngle, tiltOffset: _tiltOffset),
                ),
              ),

              // UI overlay inside simulated Camera HUD
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(5)),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.radio,
                              color: Colors.white, size: 10),
                          SizedBox(width: 4),
                          Text("REC 360°",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Text(
                      "COMPASS: ${(_compassAngle * 180 / math.pi).toInt() % 360}°",
                      style: const TextStyle(
                          color: Color(0xFFC5A153),
                          fontSize: 9,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isCapturing && _captureProgress == 0.0) ...[
                      GestureDetector(
                        onTap: _startCameraScanning,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC5A153),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFFC5A153)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  spreadRadius: 3),
                            ],
                          ),
                          child: const Icon(LucideIcons.camera,
                              color: Colors.black, size: 28),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "DÉMARRER LA CAPTURE",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                      ),
                    ] else if (_isCapturing) ...[
                      // Rotating compass loading circle
                      SizedBox(
                        width: 74,
                        height: 74,
                        child: CircularProgressIndicator(
                          value: _captureProgress,
                          strokeWidth: 4.0,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFC5A153)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "${(_captureProgress * 100).toInt()}% SCAN",
                        style: const TextStyle(
                            color: Color(0xFFC5A153),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace'),
                      ),
                    ] else ...[
                      // Success captured state
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(LucideIcons.check,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _startCameraScanning,
                        icon: const Icon(LucideIcons.refreshCw,
                            size: 12, color: Color(0xFFC5A153)),
                        label: const Text("RECOMMENCER LA CAPTURE",
                            style: TextStyle(
                                color: Color(0xFFC5A153),
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom status line of camera
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(
                        _captureProgress == 1.0
                            ? LucideIcons.checkCircle2
                            : LucideIcons.info,
                        color: _captureProgress == 1.0
                            ? Colors.green
                            : const Color(0xFFC5A153),
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _captureStatusMessage,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // STEP 2: LINK REALITY HOTSPOTS/LINKS CONFIGURATION
  Widget _buildStep2HotspotConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CARTOGRAPHIE DIRECTIONNELLE S'PACE",
          style: TextStyle(
              color: Color(0xFFC5A153),
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        const Text(
          "Placer les Liens Virtuels (Hotspots)",
          style:
              TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'serif'),
        ),
        const SizedBox(height: 4),
        const Text(
          "Créez des raccourcis immersifs pour permettre aux clients d'élite de naviguer d'une pièce à l'autre depuis ce panorama.",
          style: TextStyle(color: Color(0xFFA8A29E), fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 20),

        // Hotspot target links picker
        const Text(
          "DESTINATION DES HOTSPOTS PLACÉS :",
          style: TextStyle(
              color: Color(0xFF78716C),
              fontSize: 9,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFF1C1917),
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedTargetRoomToLink,
                dropdownColor: const Color(0xFF1C1917),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: "Chambre cible de transition",
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'room-neuilly-salon',
                      child: Text("Grand Salon principal (Neuilly)")),
                  DropdownMenuItem(
                      value: 'room-neuilly-cuisine',
                      child: Text("Cuisine Îlot Marbre")),
                  DropdownMenuItem(
                      value: 'room-neuilly-chambre',
                      child: Text("Chambre Parentale Prestige")),
                  DropdownMenuItem(
                      value: 'room-neuilly-terrasse',
                      child: Text("Balcon suspendu")),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedTargetRoomToLink = val!;
                  });
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  icon: const Icon(LucideIcons.plus,
                      size: 14, color: Colors.black),
                  label: const Text("AJOUTER UN LIEN INTER-PIÈCES",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC5A153)),
                  onPressed: _addHotspotAtCurrentCenter,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Placed Hotspots list
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "HOTSPOTS AJOUTÉS :",
              style: TextStyle(
                  color: Color(0xFF78716C),
                  fontSize: 9,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "${_customHotspots.length} placements",
              style: const TextStyle(
                  color: Color(0xFFC5A153),
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_customHotspots.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(LucideIcons.compass, color: Colors.white24, size: 28),
                  SizedBox(height: 6),
                  Text("Aucun hotspot spatial n'est configuré pour le moment.",
                      style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
          )
        else
          ..._customHotspots.map((h) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFF131110),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin,
                          color: Color(0xFFC5A153), size: 14),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.label,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white)),
                          Text(
                              "Cible: ${h.targetRoomId} • X: ${h.x.toStringAsFixed(2)} Y: ${h.y.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.white54)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2,
                        color: Colors.redAccent, size: 16),
                    onPressed: () {
                      setState(() {
                        _customHotspots.removeWhere((item) => item.id == h.id);
                      });
                    },
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 20),
      ],
    );
  }

  // STEP 3: CONFIRMATION SUCCESS
  Widget _buildStep3Confirmation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        // Big sparkling check seal
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFC5A153).withValues(alpha: 0.08),
            border: Border.all(color: const Color(0xFFC5A153), width: 1.5),
          ),
          child: const Center(
            child: Icon(LucideIcons.checkCheck,
                color: Color(0xFFC5A153), size: 42),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "PUBLICATION S'PACE VALIDÉE",
          style: TextStyle(
              color: Color(0xFFC5A153),
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _titleController.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'serif',
              fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Votre visite virtuelle 360° et le simulator AR associé ont été assemblés de façon stéréoscopique et intégrés instantanément à l'application immobilière S'PACE S'PACE.",
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Color(0xFFA8A29E), fontSize: 12, height: 1.6),
          ),
        ),
        const SizedBox(height: 24),

        // Link with summary specifications of created app
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1917),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF292524)),
          ),
          child: Column(
            children: [
              _buildCompactBadgeRow(
                  "Fiche immo :", "Publiée et accessible au public"),
              const Divider(color: Colors.white10),
              _buildCompactBadgeRow("Nombre de scènes :",
                  "2 (1 panorama capturé + 1 salon central)"),
              const Divider(color: Colors.white10),
              _buildCompactBadgeRow("Portail acheteurs :",
                  "Activation des demandes de visite privée"),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCompactBadgeRow(String left, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left,
            style: const TextStyle(
                color: Color(0xFF78716C),
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        Text(right,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildAdminInput(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF78716C),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF57534E), fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionNavigation() {
    return Container(
      color: const Color(0xFF1C1917),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_adminStep > 0 && _adminStep < 3)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF292524)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  setState(() {
                    _adminStep--;
                  });
                },
                child: const Text("RETOUR",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              )
            else
              const SizedBox(width: 1),
            if (_adminStep == 0)
              ElevatedButton.icon(
                icon: const Text("CONTINUER RECHERCHE",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0)),
                label: const Icon(LucideIcons.chevronRight,
                    size: 14, color: Colors.black),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A153)),
                onPressed: () {
                  setState(() {
                    _adminStep = 1;
                  });
                },
              )
            else if (_adminStep == 1)
              ElevatedButton.icon(
                icon: const Text("PASSER AUX HOTSPOTS",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0)),
                label: const Icon(LucideIcons.chevronRight,
                    size: 14, color: Colors.black),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _captureProgress == 1.0
                      ? const Color(0xFFC5A153)
                      : const Color(0xFF78716C),
                ),
                onPressed: _captureProgress == 1.0
                    ? () {
                        setState(() {
                          _adminStep = 2;
                        });
                      }
                    : null, // Disabled until photo is captured
              )
            else if (_adminStep == 2)
              ElevatedButton.icon(
                icon: const Text("PUBLIER L'IMMOBILIER",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0)),
                label: const Icon(LucideIcons.sparkles,
                    size: 14, color: Colors.black),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A153)),
                onPressed: _publishProperty,
              )
            else
              ElevatedButton.icon(
                icon: const Text("RETOUR AU DOCK",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0)),
                label:
                    const Icon(LucideIcons.home, size: 14, color: Colors.black),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A153)),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    setState(() {
                      _adminStep = 0;
                    });
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

// Custom camera grid aligning overlays
class _CameraGridPainter extends CustomPainter {
  final double compassAngle;
  final double tiltOffset;

  _CameraGridPainter({required this.compassAngle, required this.tiltOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw centering targeting circle
    final center = Offset(size.width / 2, size.height / 2 + tiltOffset);
    canvas.drawCircle(center, 40, gridPaint);

    // Draw horizon alignment bars
    final horizonPaint = Paint()
      ..color = const Color(0xFFC5A153).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Left marker static
    canvas.drawLine(
        Offset(20, size.height / 2), Offset(60, size.height / 2), horizonPaint);
    // Right marker static
    canvas.drawLine(Offset(size.width - 60, size.height / 2),
        Offset(size.width - 20, size.height / 2), horizonPaint);

    // Rotating compass indicators in center with the gyroscope
    final degreeIndicatorPaint = Paint()
      ..color = const Color(0xFFC5A153)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const rayLength = 12.0;
    for (int i = 0; i < 8; i++) {
      double angle = compassAngle + (i * math.pi / 4);
      double startX = center.dx + math.cos(angle) * 44;
      double startY = center.dy + math.sin(angle) * 44;
      double endX = center.dx + math.cos(angle) * (44 + rayLength);
      double endY = center.dy + math.sin(angle) * (44 + rayLength);
      canvas.drawLine(
          Offset(startX, startY), Offset(endX, endY), degreeIndicatorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
