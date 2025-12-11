import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isAttending = false;
  bool _isFavorite = false;
  bool _isLoadingAttendance = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAttendanceStatus();
  }

  Future<void> _checkAttendanceStatus() async {
    print('🔍 Checking attendance status for event: ${widget.event.id}');
    
    if (_authService.isGuest || widget.event.id == null) {
      print('❌ User is guest or event ID is null');
      setState(() {
        _isLoadingAttendance = false;
      });
      return;
    }

    try {
      final user = await AuthService.getCurrentUser();
      print('👤 Current user MongoDB ID: ${user?.id}');
      print('👤 Current user Provider ID: ${user?.providerUserId}');
      
      if (user?.id != null && user?.providerUserId != null) {
        final attendees = await ApiService.getEventAttendees(widget.event.id!);
        print('📋 Attendees for event ${widget.event.id}: $attendees');
        
        // TEMPORARY WORKAROUND: Check both MongoDB ID and Provider ID
        // Backend is incorrectly storing providerUserId instead of MongoDB user ID
        final isAttending = attendees.contains(user!.id) || 
                           attendees.contains(user.providerUserId);
        print('✅ User ${user.id} is attending: $isAttending');
        print('⚠️ WARNING: Backend is storing providerUserId (${user.providerUserId}) instead of MongoDB ID (${user.id})');
        
        if (mounted) {
          setState(() {
            _isAttending = isAttending;
            _isLoadingAttendance = false;
          });
          print('🔄 State updated: _isAttending = $_isAttending');
        }
      } else {
        print('❌ User ID or Provider ID is null');
        setState(() {
          _isLoadingAttendance = false;
        });
      }
    } catch (e) {
      print('❌ Error checking attendance status: $e');
      if (mounted) {
        setState(() {
          _isLoadingAttendance = false;
        });
      }
    }
  }

  Future<void> _openGoogleMaps() async {
    // Usar el nombre del lugar directamente (ej: "Movistar Arena")
    final placeName = Uri.encodeComponent(widget.event.location);

    // Intentar primero con la app de Google Maps (geo: URI)
    final geoUri = Uri.parse('geo:0,0?q=$placeName');

    // URL alternativa para navegador web
    final webUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$placeName',
    );

    try {
      // Intentar primero abrir con la app de Google Maps
      bool launched = false;

      try {
        if (await canLaunchUrl(geoUri)) {
          launched = await launchUrl(
            geoUri,
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (_) {
        // Si falla geo:, intentar con URL web
      }

      // Si no funcionó con geo:, intentar con URL web
      if (!launched) {
        launched = await launchUrl(
          webUrl,
          mode: LaunchMode.externalApplication,
        );
      }

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir Google Maps'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir Google Maps: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showGuestDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_off,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Cuenta Requerida'),
            ],
          ),
          content: const Text(
            'Necesitas tener una cuenta para asistir a eventos.\n\n'
            '¿Te gustaría iniciar sesión o crear una cuenta?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Ir a Login'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelAttendanceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Cancelar Asistencia',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: const Text(
            '¿Estás seguro que deseas cancelar tu asistencia a este evento?\n\n'
            'Esta acción se puede revertir confirmando nuevamente.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'No, mantener',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _cancelAttendance();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelAttendance() async {
    try {
      await ApiService.cancelAttendance(widget.event.id!);
      
      if (mounted) {
        setState(() {
          _isAttending = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asistencia cancelada exitosamente'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar asistencia: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF6366F1),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Forzar actualización cuando regresamos
                Navigator.pop(context, _isAttending);
              },
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isFavorite
                            ? 'Evento guardado en favoritos'
                            : 'Evento removido de favoritos',
                      ),
                      backgroundColor: _isFavorite ? Colors.green : Colors.grey,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compartir evento'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.8),
                          const Color(0xFF8B5CF6).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Category Badge
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        widget.event.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Event Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.event.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: widget.event.price == 0
                              ? Colors.green
                              : const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.event.getFormattedPrice(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Organizer
                  Text(
                    'Organizado por ${widget.event.organizer}',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Rating and Attendees
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.event.rating}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people,
                              color: Colors.blue,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.event.attendees}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Date and Time
                  _buildInfoSection(
                    'Fecha y Hora',
                    Icons.calendar_today,
                    widget.event.getFormattedDate(),
                    Colors.green,
                  ),
                  const SizedBox(height: 20),

                  // Location
                  _buildInfoSection(
                    'Ubicación',
                    Icons.location_on,
                    '${widget.event.location}\n${widget.event.getDistanceText()} de distancia',
                    Colors.red,
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.event.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tags
                  if (widget.event.tags.isNotEmpty) ...[
                    const Text(
                      'Etiquetas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.event.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 150), // Space for floating buttons
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Action Buttons
      floatingActionButton: _isLoadingAttendance
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Attend/Cancel Button
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: _isAttending
                      ? FloatingActionButton.extended(
                          onPressed: _showCancelAttendanceDialog,
                          backgroundColor: Colors.orange,
                          label: const Text(
                            'Cancelar Asistencia',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: const Icon(Icons.cancel_outlined),
                        )
                      : FloatingActionButton.extended(
                          onPressed: () async {
                            // Check if user is guest
                            if (_authService.isGuest) {
                              _showGuestDialog();
                              return;
                            }

                            try {
                              // Confirmar asistencia
                              await ApiService.confirmAttendance(widget.event.id!);
                              
                              if (mounted) {
                                setState(() {
                                  _isAttending = true;
                                });
                                
                                Navigator.pushNamed(
                                  context,
                                  '/confirmation',
                                  arguments: widget.event,
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          },
                          backgroundColor: const Color(0xFF6366F1),
                          label: const Text(
                            'Asistir al Evento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: const Icon(Icons.event_seat),
                        ),
                ),
                const SizedBox(height: 12),

                // Secondary Actions
                FloatingActionButton(
                  heroTag: 'directions',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6366F1),
                  onPressed: _openGoogleMaps,
                  child: const Icon(Icons.directions),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoSection(
    String title,
    IconData icon,
    String content,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
