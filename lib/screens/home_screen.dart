import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'my_events_screen.dart';
import 'my_groups_screen.dart';
import 'wallet_screen.dart';
import '../data/mock_data.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  final List<Widget> _screens = [
    const MainScreen(),
    const MyEventsScreen(),
    const MyGroupsScreen(),
    const WalletScreen(),
  ];

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
            'Necesitas tener una cuenta para acceder a esta funcionalidad.\n\n'
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens.map((screen) {
          if (screen is MainScreen) {
            return _buildMainScreenWithUserIcon(screen);
          }
          return screen;
        }).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.explore, 'Descubrir'),
                _buildNavItem(1, Icons.event, 'Mis Eventos'),
                _buildNavItem(2, Icons.groups, 'Mi Parche'),
                _buildNavItem(3, Icons.account_balance_wallet, 'Billetera'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainScreenWithUserIcon(MainScreen mainScreen) {
    return MainScreenWithUser();
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return InkWell(
      onTap: () {
        // Check if guest is trying to access restricted features
        if (_authService.isGuest && (index == 2 || index == 3)) {
          _showGuestDialog();
          return;
        }
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF6366F1).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? const Color(0xFF6366F1)
                  : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? const Color(0xFF6366F1)
                    : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected 
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreenWithUser extends StatefulWidget {
  const MainScreenWithUser({super.key});

  @override
  State<MainScreenWithUser> createState() => _MainScreenWithUserState();
}

class _MainScreenWithUserState extends State<MainScreenWithUser> {
  int _currentRecommendationIndex = 0;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Auto-rotate recommendations
    Future.delayed(const Duration(seconds: 3), _rotateRecommendation);
  }

  void _rotateRecommendation() {
    if (mounted) {
      setState(() {
        _currentRecommendationIndex = 
            (_currentRecommendationIndex + 1) % MockEventData.getAIRecommendations().length;
      });
      Future.delayed(const Duration(seconds: 4), _rotateRecommendation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = MockEventData.getAIRecommendations();
    final categories = MockEventData.getCategories();

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
          InkWell(
            onTap: () {
              if (_authService.isAuthenticated || _authService.isGuest) {
                Navigator.pushNamed(context, '/profile');
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
            borderRadius: BorderRadius.circular(18),
            child: _buildUserAvatar(),
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
                    child: Text(
                      recommendations[_currentRecommendationIndex],
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
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
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
                        Icon(
                          icons[index],
                          color: colors[index],
                          size: 24,
                        ),
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
                          '${MockEventData.getAllEvents().length}',
                          Icons.event_available,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Cerca\nde Ti',
                          '${MockEventData.getAllEvents().where((e) => e.getDistanceText().contains('0.')).length}',
                          Icons.location_on,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Esta\nSemana',
                          '${MockEventData.getAllEvents().where((e) => e.date.difference(DateTime.now()).inDays <= 7).length}',
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
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
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar() {
    final user = _authService.currentUser;
    final googleUser = _authService.googleUser;
    
    if (_authService.isAuthenticated && (user?.picture != null && user!.picture.isNotEmpty)) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(user.picture),
        backgroundColor: const Color(0xFF6366F1),
      );
    } else if (_authService.isAuthenticated && googleUser?.photoUrl != null) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(googleUser!.photoUrl!),
        backgroundColor: const Color(0xFF6366F1),
      );
    } else if (_authService.isGuest) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Colors.orange[300],
        child: const Icon(Icons.person, color: Colors.white, size: 20),
      );
    } else {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.person, color: Colors.grey, size: 20),
      );
    }
  }
}