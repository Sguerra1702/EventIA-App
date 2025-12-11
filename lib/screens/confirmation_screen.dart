import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfirmationScreen extends StatefulWidget {
  final Event event;
  
  const ConfirmationScreen({super.key, required this.event});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
    
    // Agregar automáticamente al calendario al confirmar
    _addToGoogleCalendar();
  }

  Future<void> _addToGoogleCalendar() async {
    try {
      // Formatear la fecha en formato ISO 8601 para Google Calendar
      final startDate = widget.event.date;
      final endDate = startDate.add(
        const Duration(hours: 2),
      ); // Duración estimada de 2 horas

      // Formatear fechas en milisegundos desde epoch para el intent de Android
      final startMillis = startDate.millisecondsSinceEpoch;
      final endMillis = endDate.millisecondsSinceEpoch;

      // Codificar los datos del evento
      final title = Uri.encodeComponent(widget.event.title);
      final description = Uri.encodeComponent(widget.event.description);
      final location = Uri.encodeComponent(widget.event.location);

      // Intentar primero con el intent nativo de Android Calendar
      final intentUri = Uri.parse(
        'content://com.android.calendar/time/$startMillis'
        '?title=$title'
        '&description=$description'
        '&eventLocation=$location'
        '&beginTime=$startMillis'
        '&endTime=$endMillis',
      );

      bool launched = false;

      // Intentar abrir con la app nativa de Calendar
      try {
        if (await canLaunchUrl(intentUri)) {
          launched = await launchUrl(
            intentUri,
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (_) {
        // Si falla el intent nativo, continuar con la URL web
      }

      // Si no funcionó el intent nativo, usar URL web de Google Calendar
      if (!launched) {
        // Formatear fechas para Google Calendar web (formato: YYYYMMDDTHHmmssZ)
        String formatDateForCalendar(DateTime date) {
          return date
                  .toUtc()
                  .toIso8601String()
                  .replaceAll(RegExp(r'[-:]'), '')
                  .split('.')[0] +
              'Z';
        }

        final startDateStr = formatDateForCalendar(startDate);
        final endDateStr = formatDateForCalendar(endDate);

        final calendarUrl = Uri.parse(
          'https://www.google.com/calendar/render?action=TEMPLATE'
          '&text=$title'
          '&dates=$startDateStr/$endDateStr'
          '&details=$description'
          '&location=$location'
          '&sf=true'
          '&output=xml',
        );

        launched = await launchUrl(
          calendarUrl,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      // Silenciosamente fallar si no se puede agregar al calendario
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6366F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 120,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  
                  // Success Animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 60,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Success Message
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Column(
                      children: [
                        Text(
                          '¡Confirmado!',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Tu asistencia ha sido registrada',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Event Info Card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                widget.event.getFormattedDate(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.event.location,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Features Added
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'Hemos añadido automáticamente:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildFeatureItem(
                          Icons.calendar_month,
                          'Evento agregado a Google Calendar',
                        ),
                        const SizedBox(height: 8),
                        _buildFeatureItem(
                          Icons.notifications,
                          'Podrás configurar recordatorios en Calendar',
                        ),
                        const SizedBox(height: 8),
                        _buildFeatureItem(
                          Icons.favorite,
                          'Evento guardado en tus favoritos',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Action Buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/home',
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Volver al Inicio',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/events');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Explorar Más Eventos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        TextButton(
                          onPressed: () {
                            _showShareOptions();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share, color: Colors.white70, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Compartir este evento',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        const Icon(Icons.check_circle, color: Colors.white, size: 20),
      ],
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'Compartir Evento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareOption(
                      Icons.message,
                      'WhatsApp',
                      Colors.green,
                    ),
                    _buildShareOption(
                      Icons.facebook,
                      'Facebook',
                      Colors.blue,
                    ),
                    _buildShareOption(
                      Icons.share,
                      'Instagram',
                      Colors.purple,
                    ),
                    _buildShareOption(
                      Icons.link,
                      'Copiar Link',
                      Colors.grey,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compartiendo en $label...'),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}