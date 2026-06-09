import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:panorama_viewer/panorama_viewer.dart' as pv;
import '../models/property.dart';

class VrTourScreen extends StatefulWidget {
  final Property property;
  final Room startRoom;

  const VrTourScreen({
    super.key,
    required this.property,
    required this.startRoom,
  });

  @override
  State<VrTourScreen> createState() => _VrTourScreenState();
}

class _VrTourScreenState extends State<VrTourScreen> {
  late Room _currentRoom;

  @override
  void initState() {
    super.initState();
    _currentRoom = widget.startRoom;
  }

  void _navigateToRoom(String roomId) {
    final nextRoom = widget.property.rooms.firstWhere(
      (r) => r.id == roomId,
      orElse: () => _currentRoom,
    );
    if (nextRoom.id != _currentRoom.id) {
      setState(() {
        _currentRoom = nextRoom;
      });
      _showRoomTransitionBreadcrumb(nextRoom.name);
    }
  }

  void _showRoomTransitionBreadcrumb(String roomName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Entrée dans la pièce : $roomName",
          style: const TextStyle(fontSize: 12),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1C1917),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Convert hotspots coordinates to suitable latitudes and longitudes for Panorama
    final List<pv.Hotspot> panoramaHotspots = _currentRoom.hotspots.map((h) {
      // Map 0.0 -> 1.0 coordinates to -90 to 90 degrees or -180 to 180
      double latitude = (h.y - 0.5) * -120; // vertical angle
      double longitude = (h.x - 0.5) * 360; // horizontal angle

      return pv.Hotspot(
        latitude: latitude,
        longitude: longitude,
        width: 150,
        height: 60,
        widget: GestureDetector(
          onTap: () => _navigateToRoom(h.targetRoomId),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1917).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFFC5A153), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26, blurRadius: 4, spreadRadius: 1),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.compass,
                        size: 12, color: Color(0xFFC5A153)),
                    const SizedBox(width: 6),
                    Text(
                      h.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronDown,
                color: Color(0xFFC5A153),
                size: 16,
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 3D Spherical Panorama Viewer for high real tactile interaction
          Positioned.fill(
            child: pv.PanoramaViewer(
              animSpeed: 0.1,
              sensorControl:
                  pv.SensorControl.orientation, // interactive motion gyroscopic
              hotspots: panoramaHotspots,
              child: Image.network(
                _currentRoom.panoramaUrl,
                fit: BoxFit.cover,
                // Soft local fallback if networks cannot load
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF1C1917),
                    child: const Center(
                      child: Text(
                        "Rendu 360 S'PACE dynamique...",
                        style:
                            TextStyle(color: Color(0xFFC5A153), fontSize: 13),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Upper controller header
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131110).withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Icon(LucideIcons.arrowLeft,
                        color: Colors.white, size: 18),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131110).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFC5A153).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _currentRoom.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentRoom.type.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFC5A153),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
                // Indicator representing orientation sensory
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131110).withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(LucideIcons.compass,
                      color: Color(0xFFC5A153), size: 18),
                ),
              ],
            ),
          ),

          // Lower Quick room swapper bar
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 6.0, bottom: 8.0),
                  child: Text(
                    "NAVIGATION DIRECTE",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: 64,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: widget.property.rooms.map((r) {
                      bool isCurrent = r.id == _currentRoom.id;
                      return GestureDetector(
                        onTap: () => _navigateToRoom(r.id),
                        child: Container(
                          width: 156,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color(0xFF1C1917)
                                : Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCurrent
                                  ? const Color(0xFFC5A153)
                                  : Colors.white12,
                              width: isCurrent ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Icon(
                                    r.type == 'salon'
                                        ? LucideIcons.home
                                        : r.type == 'cuisine'
                                            ? LucideIcons.utensils
                                            : r.type == 'chambre'
                                                ? LucideIcons.bed
                                                : LucideIcons.sunset,
                                    color: const Color(0xFFC5A153),
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      r.name,
                                      style: TextStyle(
                                        color: isCurrent
                                            ? const Color(0xFFC5A153)
                                            : Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Text("À distance",
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 8)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
