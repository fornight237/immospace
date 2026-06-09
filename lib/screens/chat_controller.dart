import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatController extends ChangeNotifier {
  String _activeContactId = 'c-1';
  bool _isAgentTyping = false;
  Box? _chatBox;
  bool _isInitialized = false;

  List<Map<String, dynamic>> _contacts = [];

  ChatController() {
    _initHive();
  }

  // Données par défaut si la base est vide
  final List<Map<String, dynamic>> _defaultContacts = [
    {
      'id': 'c-1',
      'name': 'David Tagne',
      'role': 'Conseiller Prestige Neuilly',
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=120',
      'lastMessage':
          'Bonjour Ange Trecy ! Nous pouvons caler la visite de Neuilly pour demain 14h ?',
      'lastTime': '10:42',
      'unread': true,
      'messages': [
        {
          'sender': 'agent',
          'text':
              'Bonjour Ange, je m\'occupe de la commercialisation du bien situé Boulevard Victor Hugo à Neuilly-sur-Seine. Le propriétaire est d\'accord pour une visite.',
          'time': 'Hier, 16h30'
        },
        {
          'sender': 'user',
          'text':
              'Bonjour, fantastique ! Je viens de visiter le salon en 360° sur l\'application S\'PACE, c\'est somptueux.',
          'time': 'Hier, 17h15'
        },
        {
          'sender': 'agent',
          'text':
              'Bonjour Ange Trecy ! Nous pouvons caler la visite de Neuilly pour demain 14h ?',
          'time': 'Aujourd\'hui, 10:42'
        }
      ]
    },
    {
      'id': 'c-2',
      'name': 'Larissa Ottam',
      'role': 'Expert Patrimoine Lyon',
      'avatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=120',
      'lastMessage':
          'Le dossier de diagnostic financier du Penthouse à Lyon 6e (425M F CFA) est en cours de validation.',
      'lastTime': 'Hier',
      'unread': false,
      'messages': [
        {
          'sender': 'agent',
          'text':
              'Bonjour, j\'accuse bonne réception de votre demande pour le penthouse de Lyon 6e.',
          'time': 'Le 4 Juin'
        },
        {
          'sender': 'user',
          'text':
              'Est-il possible de configurer la cuisine en RA s\'il vous plaît ?',
          'time': 'Le 4 Juin'
        },
        {
          'sender': 'agent',
          'text':
              'Le dossier de diagnostic financier du Penthouse à Lyon 6e (425M F CFA) est en cours de validation.',
          'time': 'Hier, 15:20'
        }
      ]
    }
  ];

  Future<void> _initHive() async {
    _chatBox = await Hive.openBox('chat_store');

    // Charger l'ID du contact actif s'il existe
    _activeContactId = _chatBox!.get('activeContactId', defaultValue: 'c-1');

    // Charger les contacts ou utiliser les données par défaut
    final storedContacts = _chatBox!.get('contacts');
    if (storedContacts != null) {
      // Conversion nécessaire car Hive stocke en List<dynamic>
      _contacts = List<Map<String, dynamic>>.from(
          (storedContacts as List).map((e) => Map<String, dynamic>.from(e)));
    } else {
      _contacts = List.from(_defaultContacts);
      await _saveToHive();
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveToHive() async {
    await _chatBox?.put('contacts', _contacts);
    await _chatBox?.put('activeContactId', _activeContactId);
  }

  String get activeContactId => _activeContactId;
  bool get isAgentTyping => _isAgentTyping;
  List<Map<String, dynamic>> get contacts => _contacts;
  bool get isInitialized => _isInitialized;

  Map<String, dynamic> get activeContact =>
      _contacts.firstWhere((c) => c['id'] == _activeContactId,
          orElse: () => _contacts.first);

  List get messages => activeContact['messages'];

  void setActiveContact(String id) async {
    _activeContactId = id;
    await _saveToHive();
    notifyListeners();
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;

    final contact = activeContact;
    (contact['messages'] as List).add({
      'sender': 'user',
      'text': text,
      'time': 'À l\'instant',
    });
    contact['lastMessage'] = text;
    contact['lastTime'] = 'À l\'instant';
    await _saveToHive();
    _isAgentTyping = true;
    notifyListeners();

    Timer(const Duration(milliseconds: 1500), () async {
      _isAgentTyping = false;
      String reply =
          "Merci pour votre message. Je transmets vos préférences de décoration d'intérieur à notre architecte S'PACE.";
      if (text.toLowerCase().contains("visite")) {
        reply =
            "Rendez-vous bien reçu ! Je viens d'actualiser votre calendrier de visites privées S'PACE.";
      }
      (contact['messages'] as List).add({
        'sender': 'agent',
        'text': reply,
        'time': 'À l\'instant',
      });
      contact['lastMessage'] = reply;
      await _saveToHive();
      notifyListeners();
    });
  }
}
