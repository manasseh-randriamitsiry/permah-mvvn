import 'participant.dart';

class Event {
  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final int availablePlaces;
  final double price;
  final String imageUrl;
  final int attendeesCount;
  final bool isFull;
  final bool? isJoined;
  final Map<String, dynamic>? creator;
  final List<Participant>? participants;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.availablePlaces,
    required this.price,
    required this.imageUrl,
    this.attendeesCount = 0,
    this.isFull = false,
    this.isJoined,
    this.creator,
    this.participants,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String,
      availablePlaces: json['available_places'] as int,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String? ?? 'https://picsum.photos/800/400',
      attendeesCount: json['attendees_count'] as int? ?? 0,
      isFull: json['is_full'] as bool? ?? false,
      isJoined: json['is_joined'] as bool?,
      creator: json['creator'] as Map<String, dynamic>?,
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((p) => Participant.fromJson(p as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'available_places': availablePlaces,
      'price': price,
      'image_url': imageUrl,
      'attendees_count': attendeesCount,
      'is_full': isFull,
      'is_joined': isJoined,
      'creator': creator,
      'participants': participants?.map((p) => p.toJson()).toList(),
    };
  }

  String get creatorName => creator?['name'] as String? ?? 'Unknown';
  int get creatorId => creator?['id'] as int? ?? 0;
  String get creatorEmail => creator?['email'] as String? ?? '';

  bool isCreator(String userEmail) {
    return creator != null && creatorEmail == userEmail;
  }

  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    int? availablePlaces,
    double? price,
    String? imageUrl,
    int? attendeesCount,
    bool? isFull,
    bool? isJoined,
    Map<String, dynamic>? creator,
    List<Participant>? participants,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      availablePlaces: availablePlaces ?? this.availablePlaces,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      isFull: isFull ?? this.isFull,
      isJoined: isJoined ?? this.isJoined,
      creator: creator ?? this.creator,
      participants: participants ?? this.participants,
    );
  }
} 