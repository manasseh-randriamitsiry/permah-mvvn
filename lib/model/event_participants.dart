class Participant {
  final int id;
  final String name;
  final String email;

  Participant({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class EventParticipants {
  final int eventId;
  final String eventTitle;
  final int totalParticipants;
  final List<Participant> participants;

  EventParticipants({
    required this.eventId,
    required this.eventTitle,
    required this.totalParticipants,
    required this.participants,
  });

  factory EventParticipants.fromJson(Map<String, dynamic> json) {
    return EventParticipants(
      eventId: json['event_id'] as int,
      eventTitle: json['event_title'] as String,
      totalParticipants: json['total_participants'] as int,
      participants: (json['participants'] as List)
          .map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'event_title': eventTitle,
      'total_participants': totalParticipants,
      'participants': participants.map((e) => e.toJson()).toList(),
    };
  }
} 