import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  static const String _usersBoxName = 'users_box';
  static const String _sessionBoxName = 'session_box';

  static Box? _usersBox;
  static Box? _sessionBox;

  /// Initialise Hive pour l'authentification et ouvre les boîtes nécessaires.
  static Future<void> init() async {
    await Hive.initFlutter();
    _usersBox = await Hive.openBox(_usersBoxName);
    _sessionBox = await Hive.openBox(_sessionBoxName);
  }

  /// Enregistre un nouvel utilisateur. Retourne un message d'erreur en cas d'échec, ou null en cas de succès.
  static Future<String?> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (_usersBox!.containsKey(cleanEmail)) {
      return "Cette adresse e-mail est déjà utilisée par un autre compte.";
    }

    final userData = {
      'name': name.trim(),
      'email': cleanEmail,
      'phone': phone.trim(),
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _usersBox!.put(cleanEmail, userData);
    
    // Connecte automatiquement l'utilisateur après l'inscription
    await _sessionBox!.put('current_user_email', cleanEmail);
    return null;
  }

  /// Tente de connecter l'utilisateur avec l'e-mail et le mot de passe.
  /// Retourne un message d'erreur en cas d'échec, ou null en cas de succès.
  static Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!_usersBox!.containsKey(cleanEmail)) {
      return "Aucun compte n'est associé à cette adresse e-mail.";
    }

    final userData = Map<String, dynamic>.from(_usersBox!.get(cleanEmail));
    if (userData['password'] != password) {
      return "Mot de passe incorrect. Veuillez réessayer.";
    }

    // Enregistre l'e-mail dans la session
    await _sessionBox!.put('current_user_email', cleanEmail);
    return null;
  }

  /// Supprime la session de l'utilisateur (Déconnexion).
  static Future<void> logoutUser() async {
    await _sessionBox?.delete('current_user_email');
  }

  /// Indique si un utilisateur est actuellement connecté.
  static bool isLoggedIn() {
    return _sessionBox?.get('current_user_email') != null;
  }

  /// Récupère l'utilisateur connecté sous forme de Map simple.
  static Map<String, String>? getCurrentUser() {
    final email = _sessionBox?.get('current_user_email');
    if (email == null) return null;

    final data = _usersBox?.get(email);
    if (data == null) return null;

    final userData = Map<String, dynamic>.from(data);
    return {
      'name': userData['name'] as String? ?? 'Utilisateur',
      'email': userData['email'] as String? ?? '',
      'phone': userData['phone'] as String? ?? '',
    };
  }

  /// Vérifie si le mot de passe fourni correspond à celui de l'utilisateur actuellement connecté.
  static bool verifyCurrentPassword(String password) {
    final email = _sessionBox?.get('current_user_email');
    if (email == null) return false;

    final data = _usersBox?.get(email);
    if (data == null) return false;

    final userData = Map<String, dynamic>.from(data);
    return userData['password'] == password;
  }
}
