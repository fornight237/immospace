import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/property.dart';
import '../data/mock_data.dart';
import 'vr_tour_screen.dart';
import 'ar_placement_screen.dart';
import 'owner_admin_screen.dart';
import 'chat_controller.dart';
import 'auth_screen.dart';
import '../data/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeTabIndex =
      0; // 0: Recherche, 1: Favoris, 2: Messages, 3: Profil

  // Storage & State
  final List<String> _favoriteIds = ['prop-1', 'prop-2'];
  String _searchQuery = '';
  int? _minRooms;
  double _maxPrice = 1000000000;

  // Real Messenger state
  final _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final ChatController _chatController = ChatController();

  // Appointment states
  final List<Map<String, String>> _appointments = [
    {
      'id': 'apt-1',
      'title': 'Appartement de standing - Neuilly-sur-Seine',
      'address': 'Boulevard Victor Hugo, Neuilly-sur-Seine',
      'date': 'Demain',
      'time': '14:00',
      'agent': 'David Tagne',
    },
    {
      'id': 'apt-2',
      'title': 'Studio d\'Architecte - Paris 16e',
      'address': 'Avenue de Versailles, Paris 16e',
      'date': '12 juin 2026',
      'time': '10:30',
      'agent': 'Claire Rousseau',
    }
  ];

  void _toggleFavorite(String propId) {
    setState(() {
      if (_favoriteIds.contains(propId)) {
        _favoriteIds.remove(propId);
        _showToast("Bien retiré des favoris");
      } else {
        _favoriteIds.add(propId);
        _showToast("Bien ajouté aux favoris S'PACE");
      }
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle,
                color: Color(0xFFC5A153), size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text(message, style: const TextStyle(fontSize: 12))),
          ],
        ),
        backgroundColor: const Color(0xFF1C1917),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Map<String, String>? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = AuthService.getCurrentUser();
    _chatController.addListener(() {
      if (mounted) {
        setState(() {});
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_chatScrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _chatController.sendMessage(text);
    _scrollToBottom();
  }

  void _verifyOwnerAccess() {
    final passwordController = TextEditingController();
    bool obscureText = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1917), // stone-900
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFC5A153), width: 1.5),
              ),
              title: Center(
                child: Text(
                  "ACCÈS SÉCURISÉ",
                  style: GoogleFonts.playfairDisplay(
                    color: const Color(0xFFC5A153),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Veuillez saisir votre mot de passe pour accéder à l'Espace Propriétaire.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 54,
                    decoration: ShapeDecoration(
                      color: const Color(0x1AFFFFFF),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1.0, color: Color(0x66C9A84C)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: passwordController,
                            obscureText: obscureText,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Mot de passe',
                              hintStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
                            size: 18,
                            color: Colors.white54,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscureText = !obscureText;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "ANNULER",
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A153),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {
                    final enteredPass = passwordController.text;
                    if (AuthService.verifyCurrentPassword(enteredPass)) {
                      Navigator.pop(context); // Close dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OwnerAdminScreen(
                            onPropertyAdded: () {
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Mot de passe incorrect.",
                            style: TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "VALIDER",
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _bookViewing(Property prop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1917),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        String date = "14 Juin 2026";
        String heure = "15:30";
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "RÉSERVER UNE VISITE PRIVÉE",
                style: TextStyle(
                    color: Color(0xFFC5A153),
                    fontSize: 13,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                prop.title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontFamily: 'serif'),
              ),
              const SizedBox(height: 20),
              const Text(
                "DATE DU RENDEZ-VOUS",
                style: TextStyle(
                    color: Color(0xFF78716C),
                    fontSize: 9,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: date,
                dropdownColor: const Color(0xFF1C1917),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(
                      value: "14 Juin 2026", child: Text("14 Juin 2026")),
                  DropdownMenuItem(
                      value: "15 Juin 2026", child: Text("15 Juin 2026")),
                  DropdownMenuItem(
                      value: "16 Juin 2026", child: Text("16 Juin 2026")),
                ],
                onChanged: (val) => date = val!,
              ),
              const SizedBox(height: 16),
              const Text(
                "CRENEAU HORAIRE",
                style: TextStyle(
                    color: Color(0xFF78716C),
                    fontSize: 9,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: heure,
                dropdownColor: const Color(0xFF1C1917),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: "10:30", child: Text("10:30")),
                  DropdownMenuItem(value: "14:00", child: Text("14:00")),
                  DropdownMenuItem(value: "15:30", child: Text("15:30")),
                  DropdownMenuItem(value: "17:00", child: Text("17:00")),
                ],
                onChanged: (val) => heure = val!,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC5A153)),
                  onPressed: () {
                    setState(() {
                      _appointments.insert(0, {
                        'id': 'apt-${DateTime.now().millisecondsSinceEpoch}',
                        'title': prop.title,
                        'address': prop.address,
                        'date': date,
                        'time': heure,
                        'agent': 'David Tagne',
                      });
                    });
                    Navigator.pop(context);
                    _showToast(
                        "Visite privée réservée ! Retrouvez-la dans l'onglet Agenda.");
                  },
                  child: const Text("CONFIRMER LE RENDEZ-VOUS",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProps = MockData.properties.where((prop) {
      final matchesQuery =
          prop.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              prop.address.toLowerCase().contains(_searchQuery.toLowerCase());
      final priceNum = int.tryParse(
              prop.price.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
      final matchesPrice = priceNum <= _maxPrice;
      final matchesRooms =
          _minRooms == null ? true : prop.bedroomsCount >= _minRooms!;
      return matchesQuery && matchesPrice && matchesRooms;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF6), // Elegant Warm White/Sand
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D), // Obsidian Black
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side:
                        const BorderSide(width: 1.18, color: Color(0xFFC9A84C)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Icon(LucideIcons.menu,
                    color: Color(0xFFC9A84C), size: 16),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Text(
          "S'PACE",
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFFC9A84C),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.30,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1.18, color: Color(0xFFC9A84C)),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Icon(LucideIcons.bell,
                  color: Color(0xFFC9A84C), size: 16),
            ),
            onPressed: () => _showToast("Aucune notification non lue"),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildTabBody(filteredProps),
      drawer: Drawer(
        backgroundColor: const Color(0xFF0C0A09), // stone-950
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1C1917), // stone-900
                border: Border(
                    bottom: BorderSide(color: Color(0xFFC5A153), width: 1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFC5A153)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.compass,
                          color: Color(0xFFC5A153), size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "S'PACE",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'serif',
                              fontSize: 18,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            (_currentUser?['name'] ?? "ANGE TRECY (PROPRIÉTAIRE)").toUpperCase(),
                            style: TextStyle(
                              color: const Color(0xFFC5A153)
                                  .withValues(alpha: 0.8),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: LucideIcons.search,
                    title: "Recherche & Catalogue",
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _activeTabIndex = 0;
                      });
                    },
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.heart,
                    title: "Mes Favoris",
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _activeTabIndex = 1;
                      });
                    },
                  ),
                  // HIGHLIGHTED OWNER DIRECT ACCESS IN SIDE MENU!
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5A153).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              const Color(0xFFC5A153).withValues(alpha: 0.25)),
                    ),
                    child: _buildDrawerItem(
                      icon: LucideIcons.camera,
                      title: "Espace Propriétaire (360°)",
                      titleColor: const Color(0xFFC5A153),
                      iconColor: const Color(0xFFC5A153),
                      onTap: () {
                        Navigator.pop(context);
                        _verifyOwnerAccess();
                      },
                    ),
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.messageSquare,
                    title: "Messagerie Privée",
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _activeTabIndex = 2;
                      });
                    },
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.sparkles,
                    title: "Simulateur Réalité Augmentée",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ArPlacementScreen(
                                initialFurniture: null)),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: LucideIcons.user,
                    title: "Mon Profil S'PACE",
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _activeTabIndex = 3;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "S'PACE PRESTIGE v2.5.0",
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activeTabIndex,
        onTap: (index) {
          setState(() {
            _activeTabIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0C0A09),
        selectedItemColor: const Color(0xFFC5A153),
        unselectedItemColor: const Color(0xFF78716C),
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(LucideIcons.search, size: 20), label: 'Recherche'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(LucideIcons.heart, size: 20),
                if (_favoriteIds.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: Color(0xFFC5A153), shape: BoxShape.circle),
                      constraints:
                          const BoxConstraints(minWidth: 10, minHeight: 10),
                    ),
                  )
              ],
            ),
            label: 'Favoris',
          ),
          const BottomNavigationBarItem(
              icon: Icon(LucideIcons.messageSquare, size: 20),
              label: 'Messages'),
          const BottomNavigationBarItem(
              icon: Icon(LucideIcons.user, size: 20), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildTabBody(List<Property> filteredProps) {
    switch (_activeTabIndex) {
      case 0:
        return _buildRechercheTab(filteredProps);
      case 1:
        return _buildFavorisTab();
      case 2:
        return _buildMessagesTab();
      case 3:
        return _buildProfilTab();
      default:
        return const Center(child: Text("S'PACE"));
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color titleColor = Colors.white70,
    Color iconColor = const Color(0xFFC5A153),
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 20),
      title: Text(
        title,
        style: TextStyle(
            color: titleColor, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }

  // --- TAB 1: SEARCH & PORTFOLIO ---
  Widget _buildRechercheTab(List<Property> filteredProps) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Welcome Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${_currentUser?['name'] ?? "Ange Trecy"}',
                  style: GoogleFonts.playfairDisplay(
                    color: const Color(0xFF0D0D0D),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explorons ensemble.',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B6B6B),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Elegant Search Box & Filter Card
        Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1.18,
                color: Color(0xFFE8DDD0),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (text) => setState(() => _searchQuery = text),
                decoration: InputDecoration(
                  prefixIcon: const Icon(LucideIcons.search,
                      color: Color(0xFFC5A153), size: 18),
                  hintText: "Rechercher un bien...",
                  hintStyle: GoogleFonts.inter(
                      color: const Color(0x7F0D0D0D), fontSize: 15),
                  filled: true,
                  fillColor: const Color(0xFFFCFAF6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text("Chambres min : ",
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF57534E))),
                  const SizedBox(width: 8),
                  _buildRoomFilterButton(null, "Tous"),
                  const SizedBox(width: 6),
                  _buildRoomFilterButton(2, "2+"),
                  const SizedBox(width: 6),
                  _buildRoomFilterButton(3, "3+"),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Budget maximum",
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF57534E))),
                  Text(NumberFormat.currency(symbol: 'F CFA', decimalDigits: 0, locale: 'fr').format(_maxPrice),
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC49A45))),
                ],
              ),
              Slider(
                value: _maxPrice,
                min: 200000000,
                max: 1000000000,
                divisions: 16,
                activeColor: const Color(0xFFC5A153),
                inactiveColor: const Color(0xFFEDE6D9),
                onChanged: (val) {
                  setState(() {
                    _maxPrice = val;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section Title: Aménagement en Réalité Augmentée
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 3.99,
              height: 24,
              decoration: ShapeDecoration(
                color: const Color(0xFFC9A84C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Aménagement en Réalité Augmentée',
              style: GoogleFonts.inter(
                color: const Color(0xFF0D0D0D),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // AR Quick Access Card (Figma style)
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const ArPlacementScreen(initialFurniture: null),
              ),
            );
          },
          child: Container(
            height: 220,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1.18,
                  color: Color(0x33C9A84C),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x1E000000),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                )
              ],
            ),
            child: Column(
              children: [
                // Card header gradient preview
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0x26C9A84C), Color(0xFFFAF7F2)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC5A153)
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.sparkles,
                              color: Color(0xFFC5A153),
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Projetez des meubles 3D réels chez vous",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF57534E),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Card Footer CTA
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0C0A09),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "LANCER LA SIMULATION RA",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Icon(
                        LucideIcons.arrowRight,
                        color: Color(0xFFC5A153),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Owner Quick Access Banner (styled)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0A09), // Black Obsidian card
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFC5A153), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC5A153).withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A153).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.camera,
                    color: Color(0xFFC5A153), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ESPACE PROPRIÉTAIRE",
                      style: GoogleFonts.inter(
                          color: const Color(0xFFC5A153),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Filmez votre lieu à 360°",
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Ajoutez une visite virtuelle S'PACE",
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC5A153),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OwnerAdminScreen(
                        onPropertyAdded: () {
                          setState(() {
                            // Refresh listings in UI
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("OUVRIR",
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0)),
                    const SizedBox(width: 4),
                    const Icon(LucideIcons.arrowRight, size: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Listings Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${filteredProps.length} PROPRIÉTÉS DISPONIBLES",
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF78716C),
                    letterSpacing: 1.0)),
            Text("PARIS • LYON",
                style: GoogleFonts.inter(
                    fontSize: 9, color: const Color(0xFFA8A29E))),
          ],
        ),
        const SizedBox(height: 12),

        // Properties Grid / List
        ...filteredProps.map((prop) {
          final isFav = _favoriteIds.contains(prop.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1.18,
                  color: Color(0x19C9A84C),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x1EC9A84C),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(14)),
                      child: Image.network(prop.image,
                          height: 192,
                          width: double.infinity,
                          fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: IconButton(
                        icon: Icon(
                            isFav ? LucideIcons.heart : LucideIcons.heart,
                            color:
                                isFav ? const Color(0xFFC5A153) : Colors.white),
                        onPressed: () => _toggleFavorite(prop.id),
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.black45),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 7),
                        decoration: ShapeDecoration(
                          color: const Color(0xBF0D0D0D),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1.18,
                              color: Color(0xFFC9A84C),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          prop.price,
                          style: GoogleFonts.inter(
                              color: const Color(0xFFC9A84C),
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${prop.areaSqm} m² • ${prop.bedroomsCount + 1} pièces",
                        style: GoogleFonts.inter(
                            color: const Color(0xFF0D0D0D),
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 14, color: Color(0xFFC5A153)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              prop.address.contains("Neuilly")
                                  ? "Neuilly-sur-Seine"
                                  : (prop.address.contains("Paris")
                                      ? "Paris 16e"
                                      : "Lyon 6e"),
                              style: GoogleFonts.inter(
                                  color: const Color(0xFF6B6B6B), fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        prop.description,
                        style: const TextStyle(
                            color: Color(0xFF57534E),
                            fontSize: 12,
                            height: 1.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(LucideIcons.compass,
                                  size: 14, color: Color(0xFFC5A153)),
                              label: const Text("VISITE 360°",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8)),
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFFEDE6D9)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VrTourScreen(
                                          property: prop,
                                          startRoom: prop.rooms.first)),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(LucideIcons.sparkles,
                                  size: 14, color: Color(0xFFC5A153)),
                              label: const Text("AMÉNAGER RA",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1C1917),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ArPlacementScreen(
                                              initialFurniture: null)),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: TextButton.icon(
                          onPressed: () => _bookViewing(prop),
                          icon: const Icon(LucideIcons.calendar,
                              size: 12, color: Color(0xFFC5A153)),
                          label: const Text(
                            "RÉSERVER UNE VISITE PRIVÉE",
                            style: TextStyle(
                                color: Color(0xFFC5A153),
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRoomFilterButton(int? rooms, String label) {
    bool isSelected = _minRooms == rooms;
    return GestureDetector(
      onTap: () => setState(() => _minRooms = rooms),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC5A153) : const Color(0xFFFCFAF6),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFFC5A153)
                  : const Color(0xFFEDE6D9)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: isSelected ? Colors.black : const Color(0xFF1C1917),
              fontSize: 11,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- TAB 2: FAVORIS ---
  Widget _buildFavorisTab() {
    final favProps =
        MockData.properties.where((p) => _favoriteIds.contains(p.id)).toList();
    if (favProps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.heart, size: 48, color: Color(0xFFEDE6D9)),
            const SizedBox(height: 12),
            const Text("Aucun bien favori",
                style: TextStyle(fontFamily: 'serif', fontSize: 16)),
            TextButton(
                onPressed: () => setState(() => _activeTabIndex = 0),
                child: const Text("Parcourir le catalogue d'exception")),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("SÉLECTION EXCLUSIVE",
            style: TextStyle(
                color: Color(0xFFC5A153),
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.bold)),
        const Text("Mes Coups de Cœur",
            style: TextStyle(
                fontSize: 26, fontFamily: 'serif', color: Color(0xFF1C1917))),
        const SizedBox(height: 16),
        ...favProps.map((prop) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(prop.image,
                    width: 70, height: 70, fit: BoxFit.cover),
              ),
              title: Text(prop.title,
                  style: const TextStyle(fontFamily: 'serif', fontSize: 14)),
              subtitle: Text(prop.price,
                  style: const TextStyle(
                      color: Color(0xFFC5A153), fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(LucideIcons.trash2,
                    color: Colors.redAccent, size: 18),
                onPressed: () => _toggleFavorite(prop.id),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- TAB 4: PRIVATE MESSENGER ---
  Widget _buildMessagesTab() {
    final messages = _chatController.messages;

    return Column(
      children: [
        // Contact Selector row
        Container(
          height: 72,
          color: const Color(0xFF0C0A09),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _chatController.contacts.map((c) {
              bool isSelected = c['id'] == _chatController.activeContactId;
              return GestureDetector(
                onTap: () => _chatController.setActiveContact(c['id']),
                child: Container(
                  width: 220,
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1C1917)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isSelected
                            ? const Color(0xFFC5A153).withValues(alpha: 0.3)
                            : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(c['avatar']),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(c['name'],
                                style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFFC5A153)
                                        : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            Text(c['role'],
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 9),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      if (c['unread'] == true)
                        Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                color: Color(0xFFC5A153),
                                shape: BoxShape.circle)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Messages Box
        Expanded(
          child: Container(
            color: const Color(0xFFFCFAF6),
            child: ListView.builder(
              controller: _chatScrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  messages.length + (_chatController.isAgentTyping ? 1 : 0),
              itemBuilder: (context, idx) {
                if (idx == messages.length) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      constraints: const BoxConstraints(maxWidth: 80),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16).copyWith(
                          topLeft: Radius.zero,
                        ),
                        border: Border.all(color: const Color(0xFFEDE6D9)),
                      ),
                      child: const _TypingIndicator(),
                    ),
                  );
                }

                final m = messages[idx];
                bool isUser = m['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.topRight : Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: const BoxConstraints(maxWidth: 290),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF1C1917) : Colors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight:
                            isUser ? Radius.zero : const Radius.circular(16),
                        topLeft:
                            isUser ? const Radius.circular(16) : Radius.zero,
                      ),
                      border: isUser
                          ? null
                          : Border.all(color: const Color(0xFFEDE6D9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m['text']!,
                          style: TextStyle(
                              color: isUser ? Colors.white : Colors.black,
                              fontSize: 12,
                              height: 1.5),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          m['time']!,
                          style: TextStyle(
                              color: isUser
                                  ? Colors.white54
                                  : const Color(0xFFA8A29E),
                              fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Text input field
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Écrivez votre message à l'agence...",
                    hintStyle:
                        const TextStyle(color: Color(0xFFA8A29E), fontSize: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFEDE6D9))),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(LucideIcons.send, color: Color(0xFFC5A153)),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 5: PROFILE ---
  Widget _buildProfilTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          // ─── AVATAR with Initials + Gold Gradient ───
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFC9A84C), Color(0xFFA8893A)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC9A84C).withValues(alpha: 0.25),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'AT',
                    style: GoogleFonts.playfairDisplay(
                      color: const Color(0xFF0D0D0D),
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Camera edit badge
                Positioned(
                  right: 0,
                  bottom: 4,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A84C),
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2.5,
                        color: const Color(0xFFFAF7F2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.camera,
                        color: Color(0xFF0D0D0D), size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Name ───
          Text(
            'Ange Trecy',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFF0D0D0D),
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Membre depuis janvier 2024',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF6B6B6B),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 32),

          // ─── 3 Stat Cards ───
          Row(
            children: [
              Expanded(child: _buildStatCard('23', 'Visites')),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard('${_favoriteIds.length}', 'Favoris')),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('12', 'Messages')),
            ],
          ),

          const SizedBox(height: 32),

          // ─── Section Title: Informations personnelles ───
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFC9A84C),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informations personnelles',
                style: GoogleFonts.inter(
                  color: const Color(0xFF0D0D0D),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Info Card ───
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC9A84C).withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC9A84C).withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow(
                    LucideIcons.user, 'Nom complet', _currentUser?['name'] ?? 'Ange Trecy Demanou',
                    showDivider: true),
                _buildInfoRow(
                    LucideIcons.mail, 'E-mail', _currentUser?['email'] ?? 'angedemanou0@gmail.com',
                    showDivider: true),
                _buildInfoRow(
                    LucideIcons.phone, 'Téléphone', _currentUser?['phone'] ?? '+237 6 80 46 08 09',
                    showDivider: false),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ─── Section Title: Paramètres ───
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFC9A84C),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Paramètres',
                style: GoogleFonts.inter(
                  color: const Color(0xFF0D0D0D),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Settings Card ───
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC9A84C).withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC9A84C).withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingsRow(LucideIcons.bell, 'Notifications',
                    onTap: () => _showToast('Notifications activées'),
                    showDivider: true),
                _buildSettingsRow(LucideIcons.shield, 'Confidentialité',
                    onTap: () => _showToast('Paramètres de confidentialité'),
                    showDivider: true),
                _buildSettingsRow(LucideIcons.helpCircle, 'Aide & Support',
                    onTap: () => _showToast('Centre d\'aide'),
                    showDivider: false),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ─── Studio & AR Shortcut Banner ───
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0A09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFC5A153).withValues(alpha: 0.4),
                  width: 1.0),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFC5A153).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC5A153).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.camera,
                          color: Color(0xFFC5A153), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "STUDIO DE CAPTURE PROPRIÉTAIRE",
                        style: GoogleFonts.inter(
                            color: const Color(0xFFC5A153),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Publier une visite 360°",
                  style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "Filmez et assemblez un panorama de votre bien immobilier à l'aide de notre gyroscope.",
                  style: GoogleFonts.inter(
                      color: Colors.white70, fontSize: 11, height: 1.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A84C),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(LucideIcons.aperture,
                        color: Color(0xFF0D0D0D), size: 16),
                    label: Text(
                      "FILMER MON LIEU EN PANORAMA",
                      style: GoogleFonts.inter(
                          color: const Color(0xFF0D0D0D),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0),
                    ),
                    onPressed: () {
                      _verifyOwnerAccess();
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── AR Shortcut ───
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC9A84C).withValues(alpha: 0.15),
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFC9A84C).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(LucideIcons.sparkles,
                    color: Color(0xFFC9A84C), size: 22),
              ),
              title: Text("Simulateur RA",
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0D0D0D))),
              subtitle: Text("Meublez votre intérieur en réalité augmentée",
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF6B6B6B))),
              trailing: const Icon(LucideIcons.chevronRight,
                  color: Color(0xFFC9A84C), size: 20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const ArPlacementScreen(initialFurniture: null)),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // ─── Logout Button ───
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE8DDD0), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(LucideIcons.logOut,
                  color: Color(0xFFCF6679), size: 18),
              label: Text(
                'Déconnexion',
                style: GoogleFonts.inter(
                  color: const Color(0xFFCF6679),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                await AuthService.logoutUser();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (route) => false,
                );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Stat Card (Visites / Favoris / Messages) ───
  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC9A84C).withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC9A84C).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFFC9A84C),
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF6B6B6B),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Info Row (for personal info card) ───
  Widget _buildInfoRow(IconData icon, String label, String value,
      {required bool showDivider}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFC9A84C).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFFC9A84C), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B6B6B),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF0D0D0D),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE8DDD0),
              indent: 20,
              endIndent: 20),
      ],
    );
  }

  // ─── Settings Row ───
  Widget _buildSettingsRow(IconData icon, String title,
      {required VoidCallback onTap, required bool showDivider}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9A84C).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: const Color(0xFFC9A84C), size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF0D0D0D),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(LucideIcons.chevronRight,
                    color: Color(0xFF6B6B6B), size: 20),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE8DDD0),
              indent: 20,
              endIndent: 20),
      ],
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double delay = index * 0.2;
            final double value =
                math.sin((_controller.value * 2 * math.pi) - delay);
            final double opacity = ((value + 1) / 2).clamp(0.2, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFC5A153).withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
