//groups info stored acc to this
class GroupModel {
  final String id;
  final String name;
  final List<String> members;
  final List<String> transactionIds;

  GroupModel({
    required this.id,
    required this.name,
    required this.members,
    this.transactionIds = const [],
  });

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      transactionIds: List<String>.from(map['transactionIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'transactionIds': transactionIds,
    };
  }
}
