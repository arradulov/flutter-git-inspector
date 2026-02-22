import 'package:create_scada_version_control/commit_info.dart';
import 'package:create_scada_version_control/git_service.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GitService _gitService = GitService();

  String? _selectedPath;
  CommitInfo? _commit;
  List<String> _changes = [];

  bool _isLoading = false;
  

  Future<void> _pickFolder() async {
    final String? path = await getDirectoryPath();
    if (path == null) return;
    await _gitService.fixEncoding(path);
    setState(() {
      _selectedPath = path;
      _isLoading = true;
    });

    /// Проверяем есть ли git
    final isRepo = await _gitService.isGitRepository(path);

    if (!isRepo) {
      setState(() => _isLoading = false);

      final create = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Это не Git репозиторий'),
          content: const Text('Инициализировать новый репозиторий?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Нет')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Да')),
          ],
        ),
      );

      if (create == true) {
        await _gitService.initRepository(path);
      } else {
        return;
      }
    }
   
    await _loadRepositoryInfo();
  }


  Future<void> _showCommitDialog() async {
  if (_selectedPath == null) return;

  final changes = await _gitService.getChangedFiles(_selectedPath!);

  if (changes.isEmpty) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Нет изменений'),
        content: Text('В выбранной директории изменений нет!'),
      ),
    );
    return;
  }

  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Создать коммит', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      backgroundColor: Color.fromARGB(255, 78, 128, 246),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Изменённые файлы:', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
            const SizedBox(height: 10),
            Container(
              height: 120,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
                children: changes
                    .map((f) => Text(
                          f,
                          style: const TextStyle(color: Colors.white70),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Сообщение коммита', 
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        ),
        ElevatedButton(
          onPressed: () async {
            final msg = controller.text.trim();
            if (msg.isEmpty) return;

            Navigator.pop(context);

            setState(() => _isLoading = true);

            await _gitService.createCommit(_selectedPath!, msg);
            final commit = await _gitService.getLastCommit(_selectedPath!);

            setState(() {
              _commit = commit;
              _changes = [];
              _isLoading = false;
            });
          },
          child: const Text('Commit'),
        ),
      ],
    ),
  );
}


  Future<void> _loadRepositoryInfo() async {
    if (_selectedPath == null) return;

    setState(() => _isLoading = true);

    final commit = await _gitService.getLastCommit(_selectedPath!);
    final changes = await _gitService.getChangedFiles(_selectedPath!);
    
    setState(() {
      _commit = commit;
      _changes = changes;
      _isLoading = false;
    });
  }
  

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFE5E7EB),
            fontSize: 15,
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Инспектор репозитория',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickFolder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                      ),
                      child: const Text('Выбрать папку', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton(
                      onPressed: _loadRepositoryInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                      ),
                      child: const Text('Обновить', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton(
                      onPressed: _showCommitDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                      ),
                      child: const Text('Создать commit', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),


                if (_commit != null)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Version ${_commit!.version}',
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _infoRow('Author', _commit!.author),
                        const SizedBox(height: 14),
                        _infoRow('Date', _commit!.date),
                        const SizedBox(height: 14),
                        _infoRow('Message', _commit!.message),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

  
                if (_changes.isNotEmpty) ...[
                  const Text(
                    'Изменения',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _changes.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          _changes[i],
                          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}