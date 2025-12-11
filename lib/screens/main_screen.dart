import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentRecommendationIndex = 0;
  List<Event> _recommendations = [];
  List<String> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final events = await ApiService.getAllEvents();

      // Get unique categories
      final categories = events.map((e) => e.category).toSet().toList();
      categories.sort();

      if (!mounted) return;

      setState(() {
        _recommendations = events
            .take(5)
            .toList(); // Tomar los primeros 5 como recomendaciones
        _categories = categories;
        _isLoading = false;
      });

      // Start auto-rotation after loading
      if (_recommendations.isNotEmpty) {
        Future.delayed(const Duration(seconds: 3), _rotateRecommendation);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      print('Error loading data: $e');
      // Fallback to empty lists
      _recommendations = [];
      _categories = [];
    }
  }

  void _rotateRecommendation() {
    if (mounted && _recommendations.isNotEmpty) {
      setState(() {
        _currentRecommendationIndex =
            (_currentRecommendationIndex + 1) % _recommendations.length;
      });
      Future.delayed(const Duration(seconds: 4), _rotateRecommendation);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'IA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'EventIA',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Recommendations Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Recomendación IA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _recommendations.isEmpty
                        ? const Text(
                            'Cargando recomendaciones...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          )
                        : Text(
                            _recommendations[_currentRecommendationIndex].title,
                            key: ValueKey(_currentRecommendationIndex),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Explore Events Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/events');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.explore),
                    SizedBox(width: 8),
                    Text(
                      'Explorar Eventos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Quick Categories
            const Text(
              'Categorías Populares',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Categories Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final icons = [
                  Icons.music_note,
                  Icons.restaurant,
                  Icons.palette,
                  Icons.sports_soccer,
                  Icons.theater_comedy,
                  Icons.school,
                ];
                final colors = [
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.green,
                  Colors.blue,
                  Colors.teal,
                ];

                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/events',
                      arguments: {'category': category},
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors[index].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors[index].withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(icons[index], color: colors[index], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: colors[index],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Recent Activity or Quick Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estadísticas Rápidas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Eventos\nDisponibles',
                          '${_recommendations.length}',
                          Icons.event_available,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Categorías',
                          '${_categories.length}',
                          Icons.category,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Nuevos',
                          '${_recommendations.where((e) => e.date.isAfter(DateTime.now())).length}',
                          Icons.calendar_today,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
