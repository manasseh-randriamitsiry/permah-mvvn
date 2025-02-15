class Event {
  final int? id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final int totalPlaces;
  final int attendeesCount;
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
    required this.totalPlaces,
    required this.attendeesCount,
    required this.price,
    required this.imageUrl,
    this.isJoined,
    this.creator,
  });

  // Calculate available places based on total places minus attendees
  int get availablePlaces => totalPlaces - attendeesCount;

  factory Event.fromJson(Map<String, dynamic> json) {
    // First try to get total_participants from the participants endpoint response
    final totalParticipants = json['total_participants'] as int?;
    
    // Try different fields for attendees count in order of priority
    final attendeesCount = totalParticipants ?? // First try total_participants
                          (json['attendees_count'] as num?)?.toInt() ?? // Then try attendees_count
                          (json['participants']?.length as int?) ?? // Then try participants array length
                          0; // Default to 0 if none found

    final totalPlaces = (json['total_places'] as num?)?.toInt() ?? // First try total_places
                       (json['available_places'] as int?) ?? // Then try available_places
                       0; // Default to 0 if none found

    return Event(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String,
      totalPlaces: totalPlaces,
      attendeesCount: attendeesCount,
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
      'total_places': totalPlaces,
      'attendees_count': attendeesCount,
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
    int? totalPlaces,
    int? attendeesCount,
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
      totalPlaces: totalPlaces ?? this.totalPlaces,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isJoined: isJoined ?? this.isJoined,
      creator: creator ?? this.creator,
    );
  }
} 