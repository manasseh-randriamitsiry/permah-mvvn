class Event {
  final int? id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final int availablePlaces;
  final double price;
  final String imageUrl;
  final bool? isJoined;
  final Map<String, dynamic>? creator;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.availablePlaces,
    required this.price,
    required this.imageUrl,
    this.isJoined,
    this.creator,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String,
      availablePlaces: json['available_places'] as int,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String,
      isJoined: json['is_joined'] as bool?,
      creator: json['creator'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'location': location,
      'available_places': availablePlaces,
      'price': price,
      'image_url': imageUrl,
      if (creator != null) 'creator': creator,
    };
  }

  bool isCreator(String userEmail) {
    return creator != null && creator!['email'] == userEmail;
  }

  Event copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    int? availablePlaces,
    double? price,
    String? imageUrl,
    bool? isJoined,
    Map<String, dynamic>? creator,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      availablePlaces: availablePlaces ?? this.availablePlaces,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isJoined: isJoined ?? this.isJoined,
      creator: creator ?? this.creator,
    );
  }
} 