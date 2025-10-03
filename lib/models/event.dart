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
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return "${date.day} ${months[date.month - 1]} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  // Método para obtener el precio formateado
  String getFormattedPrice() {
    if (price == 0) return "Gratis";
    return "\$${price.toStringAsFixed(0)}";
  }
}