class EventStatistics {
  final int totalPlaces;
  final int attendeesCount;
  final int availablePlaces;
  final double occupancyRate;
  final bool isFull;

  EventStatistics({
    required this.totalPlaces,
    required this.attendeesCount,
    required this.availablePlaces,
    required this.occupancyRate,
    required this.isFull,
  });

  factory EventStatistics.fromJson(Map<String, dynamic> json) {
    return EventStatistics(
      totalPlaces: json['total_places'] as int,
      attendeesCount: json['attendees_count'] as int,
      availablePlaces: json['available_places'] as int,
      occupancyRate: json['occupancy_rate'] as double,
      isFull: json['is_full'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_places': totalPlaces,
      'attendees_count': attendeesCount,
      'available_places': availablePlaces,
      'occupancy_rate': occupancyRate,
      'is_full': isFull,
    };
  }
} 