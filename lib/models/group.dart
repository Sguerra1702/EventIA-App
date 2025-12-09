class Group {
  final String? id;
  final String name;
  final String? description;
  final String creatorId;
  final String? eventId;
  final String? inviteCode;
  final List<String> memberIds;
  final int maxMembers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Group({
    this.id,
    required this.name,
    this.description,
    required this.creatorId,
    this.eventId,
    this.inviteCode,
    List<String>? memberIds,
    this.maxMembers = 50,
    this.createdAt,
    this.updatedAt,
  }) : memberIds = memberIds ?? [creatorId];

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      creatorId: json['creatorId'] as String,
      eventId: json['eventId'] as String?,
      inviteCode: json['inviteCode'] as String?,
      memberIds: (json['memberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      maxMembers: json['maxMembers'] as int? ?? 50,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      'creatorId': creatorId,
      if (eventId != null) 'eventId': eventId,
      if (inviteCode != null) 'inviteCode': inviteCode,
      'memberIds': memberIds,
      'maxMembers': maxMembers,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  int get memberCount => memberIds.length;
  
  bool get hasSpace => memberIds.length < maxMembers;
  
  bool isMember(String userId) => memberIds.contains(userId);
  
  bool isCreator(String userId) => creatorId == userId;
}
