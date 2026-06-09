class Hotspot {
  final String id;
  final String label;
  final double x; // Horizontal position ratio (0.0 to 1.0)
  final double y; // Vertical position ratio (0.0 to 1.0)
  final String targetRoomId;

  Hotspot({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.targetRoomId,
  });

  factory Hotspot.fromJson(Map<String, dynamic> json) {
    return Hotspot(
      id: json['id'] as String,
      label: json['label'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      targetRoomId: json['targetRoomId'] as String,
    );
  }
}

class Room {
  final String id;
  final String name;
  final String type; // 'salon', 'cuisine', 'chambre', 'terrasse'
  final String panoramaUrl; // Nom de l'asset ou URL de l'image 360
  final String colorTheme;
  final List<Hotspot> hotspots;

  Room({
    required this.id,
    required this.name,
    required this.type,
    required this.panoramaUrl,
    required this.colorTheme,
    required this.hotspots,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    var list = json['hotspots'] as List? ?? [];
    List<Hotspot> hotspotsList = list.map((i) => Hotspot.fromJson(i as Map<String, dynamic>)).toList();

    return Room(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      panoramaUrl: json['panoramaUrl'] as String,
      colorTheme: json['colorTheme'] as String,
      hotspots: hotspotsList,
    );
  }
}

class Property {
  final String id;
  final String title;
  final String address;
  final String price;
  final String description;
  final String image;
  final int bedroomsCount;
  final double bathroomsCount;
  final int areaSqm;
  final List<Room> rooms;

  Property({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.description,
    required this.image,
    required this.bedroomsCount,
    required this.bathroomsCount,
    required this.areaSqm,
    required this.rooms,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    var list = json['rooms'] as List? ?? [];
    List<Room> roomsList = list.map((i) => Room.fromJson(i as Map<String, dynamic>)).toList();

    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      address: json['address'] as String,
      price: json['price'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      bedroomsCount: json['bedroomsCount'] as int,
      bathroomsCount: (json['bathroomsCount'] as num).toDouble(),
      areaSqm: json['areaSqm'] as int,
      rooms: roomsList,
    );
  }
}
