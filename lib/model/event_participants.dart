import 'participant.dart';

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
  final int totalParticipants;
  final List<Participant> participants;

  EventParticipants({
    required this.totalParticipants,
    required this.participants,
  });

  factory EventParticipants.fromJson(Map<String, dynamic> json) {
    return EventParticipants(
      totalParticipants: json['total_participants'] as int,
      participants: (json['participants'] as List)
          .map((p) => Participant.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_participants': totalParticipants,
      'participants': participants.map((p) => p.toJson()).toList(),
    };
  }
} 