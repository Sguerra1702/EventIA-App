class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String imageUrl;
  final String category;
  final double price;
  final int attendees;
  final double rating;
  final String organizer;
  final List<String> tags;
  final double latitude;
  final double longitude;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.attendees,
    required this.rating,
    required this.organizer,
    required this.tags,
    required this.latitude,
    required this.longitude,
  });

  // Método para calcular distancia desde una ubicación
  String getDistanceText() {
    // Simulamos cálculo de distancia
    return "${(latitude * longitude * 0.1).abs().toStringAsFixed(1)} km";
  }

  // Método para obtener fecha formateada
  String getFormattedDate() {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return "${date.day} ${months[date.month - 1]} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  // Método para obtener el precio formateado
  String getFormattedPrice() {
    if (price == 0) return "Gratis";
    return "\$${price.toStringAsFixed(0)}";
  }

  // Parsear desde JSON del backend
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/400x200',
      category: json['category'] ?? 'General',
      price: (json['price'] ?? 0).toDouble(),
      attendees: json['attendees'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      organizer: json['organizer'] ?? 'EventIA',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'category': category,
      'price': price,
      'attendees': attendees,
      'rating': rating,
      'organizer': organizer,
      'tags': tags,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
