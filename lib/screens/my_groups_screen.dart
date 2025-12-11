import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/group.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class MyGroupsScreen extends StatefulWidget {
  const MyGroupsScreen({super.key});

  @override
  State<MyGroupsScreen> createState() => _MyGroupsScreenState();
}

class _MyGroupsScreenState extends State<MyGroupsScreen> {
  List<Group> _groups = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await AuthService.getCurrentUser();
      if (!mounted) return;
      
      if (user != null && user.id != null) {
        final groups = await ApiService.getGroupsByMember(user.id!);
        if (!mounted) return;
        
        setState(() {
          _groups = groups;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        
        setState(() {
          _error = 'No hay usuario autenticado';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = 'Error cargando grupos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mi Parche',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF6366F1)),
            onPressed: () => _showCreateGroupDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF6366F1)),
            onPressed: () => _showJoinGroupDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadGroups,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                        const SizedBox(height: 24),
                        _buildGroupsList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadGroups,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.groups, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Tus Grupos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Organiza eventos con tus amigos y administra gastos grupales',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip('${_groups.length} Grupos', Icons.group),
              const SizedBox(width: 12),
              _buildStatChip(
                  '${_groups.where((g) => g.memberIds.length > 1).length} Activos',
                  Icons.people),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showCreateGroupDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Crear Nuevo Grupo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6366F1),
              side: const BorderSide(color: Color(0xFF6366F1)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showJoinGroupDialog(),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Unirse con Código'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupsList() {
    if (_groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.groups_outlined,
                  size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No tienes grupos aún',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Crea un grupo nuevo o únete usando un código de invitación',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mis Grupos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._groups.map((group) => _buildGroupCard(group)).toList(),
      ],
    );
  }

  Widget _buildGroupCard(Group group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => _showGroupDetails(group),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.groups,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (group.description != null &&
                            group.description!.isNotEmpty)
                          Text(
                            group.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  FutureBuilder<bool>(
                    future: _isUserCreator(group),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.people, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${group.memberCount} / ${group.maxMembers} miembros',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  if (group.inviteCode != null)
                    TextButton.icon(
                      onPressed: () => _shareInviteCode(group),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Compartir'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showGroupDetails(group),
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('Ver Detalles'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                        side: const BorderSide(color: Color(0xFF6366F1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _isUserCreator(Group group) async {
    final user = await AuthService.getCurrentUser();
    return user?.id == group.creatorId;
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final maxMembersController = TextEditingController(text: '50');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.group_add, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text('Crear Nuevo Grupo'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Grupo',
                  hintText: 'Ej: Rockeros Unidos',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe tu grupo',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: maxMembersController,
                decoration: const InputDecoration(
                  labelText: 'Máximo de Miembros',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('El nombre del grupo es requerido')),
                );
                return;
              }

              try {
                final user = await AuthService.getCurrentUser();
                if (user == null || user.id == null) {
                  throw Exception('Usuario no autenticado');
                }

                final maxMembers = int.tryParse(maxMembersController.text) ?? 50;

                final group = await ApiService.createGroup(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  creatorId: user.id!,
                  maxMembers: maxMembers,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Grupo "${group.name}" creado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadGroups();
                  _showInviteCodeDialog(group);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error creando grupo: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showJoinGroupDialog() {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text('Unirse a un Grupo'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa el código de invitación del grupo al que deseas unirte:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Código de Invitación',
                hintText: 'Ej: ABC123',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim().toUpperCase();
              if (code.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Ingresa un código de invitación')),
                );
                return;
              }

              try {
                final user = await AuthService.getCurrentUser();
                if (user == null || user.id == null) {
                  throw Exception('Usuario no autenticado');
                }

                final group =
                    await ApiService.joinGroupWithInviteCode(code, user.id!);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Te uniste al grupo "${group.name}"'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadGroups();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error uniéndose al grupo: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Unirse'),
          ),
        ],
      ),
    );
  }

  void _showInviteCodeDialog(Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text('¡Grupo Creado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tu grupo ha sido creado exitosamente. Comparte este código para que otros se unan:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1)),
              ),
              child: Column(
                children: [
                  Text(
                    group.inviteCode ?? '',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: group.inviteCode ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Código copiado al portapapeles')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar Código'),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareInviteCode(Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.share, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text('Código de Invitación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Comparte este código para invitar a otros a "${group.name}":',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1)),
              ),
              child: Column(
                children: [
                  Text(
                    group.inviteCode ?? '',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: group.inviteCode ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Código copiado al portapapeles')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar Código'),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGroupDetails(Group group) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GroupDetailsSheet(
        group: group,
        onGroupUpdated: _loadGroups,
      ),
    );
  }
}

class _GroupDetailsSheet extends StatefulWidget {
  final Group group;
  final VoidCallback onGroupUpdated;

  const _GroupDetailsSheet({
    required this.group,
    required this.onGroupUpdated,
  });

  @override
  State<_GroupDetailsSheet> createState() => _GroupDetailsSheetState();
}

class _GroupDetailsSheetState extends State<_GroupDetailsSheet> {
  bool _isUserCreator = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfCreator();
  }

  Future<void> _checkIfCreator() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      _isUserCreator = user?.id == widget.group.creatorId;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
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
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.groups,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.group.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.group.description != null &&
                                widget.group.description!.isNotEmpty)
                              Text(
                                widget.group.description!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          icon: Icons.people,
                          label: 'Miembros',
                          value: '${widget.group.memberCount}/${widget.group.maxMembers}',
                        ),
                        Container(width: 1, height: 40, color: Colors.grey[300]),
                        _buildStat(
                          icon: Icons.calendar_today,
                          label: 'Creado',
                          value: _formatDate(widget.group.createdAt),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Event Assignment Section
                  if (_isUserCreator) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.event, color: Color(0xFF6366F1)),
                              const SizedBox(width: 8),
                              const Text(
                                'Evento del Grupo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (widget.group.eventId != null) ...[
                            Text(
                              'Evento asignado: ${widget.group.eventId}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _removeEventFromGroup(),
                                    icon: const Icon(Icons.remove_circle_outline),
                                    label: const Text('Quitar Evento'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _confirmGroupAttendance(),
                                    icon: const Icon(Icons.group_add),
                                    label: const Text('Confirmar Grupo'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            const Text(
                              'No hay evento asignado a este grupo',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _assignEventToGroup(),
                              icon: const Icon(Icons.add),
                              label: const Text('Asignar Evento'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Miembros del Grupo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: widget.group.memberIds.length,
                            itemBuilder: (context, index) {
                              final memberId = widget.group.memberIds[index];
                              final isCreator = memberId == widget.group.creatorId;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF6366F1),
                                  child: Text(
                                    memberId.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text('Usuario $memberId'),
                                subtitle: Text(isCreator ? 'Creador' : 'Miembro'),
                                trailing: isCreator
                                    ? const Chip(
                                        label: Text('Admin'),
                                        backgroundColor: Color(0xFF6366F1),
                                        labelStyle: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      )
                                    : _isUserCreator
                                        ? IconButton(
                                            icon: const Icon(Icons.remove_circle_outline,
                                                color: Colors.red),
                                            onPressed: () => _removeMember(memberId),
                                          )
                                        : null,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isUserCreator) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await ApiService.deleteGroup(widget.group.id!);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Grupo eliminado exitosamente'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              widget.onGroupUpdated();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error eliminando grupo: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Eliminar Grupo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final user = await AuthService.getCurrentUser();
                          if (user?.id != null) {
                            try {
                              await ApiService.removeMemberFromGroup(
                                  widget.group.id!, user!.id!);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Saliste del grupo'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                widget.onGroupUpdated();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error saliendo del grupo: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Salir del Grupo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6366F1)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _removeMember(String memberId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de querer eliminar este miembro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.removeMemberFromGroup(widget.group.id!, memberId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Miembro eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
          widget.onGroupUpdated();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error eliminando miembro: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _assignEventToGroup() async {
    try {
      // Obtener lista de eventos disponibles
      final events = await ApiService.getAllEvents();
      
      if (!mounted) return;

      final selectedEvent = await showDialog<Event>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seleccionar Evento'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text(event.title),
                  subtitle: Text(event.getFormattedDate()),
                  onTap: () => Navigator.pop(context, event),
                );
              },
            ),
          ),
        ),
      );

      if (selectedEvent != null && selectedEvent.id != null) {
        await ApiService.assignEventToGroup(
          widget.group.id!,
          selectedEvent.id!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento asignado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
          widget.onGroupUpdated();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error asignando evento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeEventFromGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de querer quitar el evento de este grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.removeEventFromGroup(widget.group.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento removido exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
          widget.onGroupUpdated();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removiendo evento: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmGroupAttendance() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Asistencia Grupal'),
        content: Text(
          '¿Confirmar asistencia de todos los ${widget.group.memberCount} miembros al evento asignado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await ApiService.confirmGroupAttendance(widget.group.id!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Asistencia confirmada para ${result['confirmedMembers']} miembros',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
          widget.onGroupUpdated();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error confirmando asistencia: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
