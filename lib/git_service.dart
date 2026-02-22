import 'dart:convert';
import 'dart:io';
import 'commit_info.dart';

class GitService {

  String _buildVersion(int commitCount) {
    return 'v0.0.$commitCount';
  }

  /// Проверка
  Future<bool> isGitRepository(String path) async {
    final result = await Process.run(
      'git',
      ['rev-parse', '--is-inside-work-tree'],
      workingDirectory: path,
      stdoutEncoding: utf8,
    );

    return result.exitCode == 0;
  }

  /// Инициализация репозитория
  Future<bool> initRepository(String path) async {
    final result = await Process.run(
      'git',
      ['init'],
      workingDirectory: path,
      stdoutEncoding: utf8,
    );

    await Process.run(
    'git',
    ['config', 'core.quotepath', 'false'],
    workingDirectory: path,
    stdoutEncoding: utf8,
  );

    return result.exitCode == 0;
  }

  /// Есть ли незакоммиченные изменения
  Future<bool> hasChanges(String path) async {
    final result = await Process.run(
      'git',
      ['status', '--porcelain'],
      workingDirectory: path,
      stdoutEncoding: utf8,
    );

    if (result.exitCode != 0) return false;

    return result.stdout.toString().trim().isNotEmpty;
  }

  /// Количество commit
  Future<int> getCommitCount(String path) async {
    final result = await Process.run(
      'git',
      ['rev-list', '--count', 'HEAD'],
      workingDirectory: path,
      stdoutEncoding: utf8,
    );

    if (result.exitCode != 0) return 0;

    return int.tryParse(result.stdout.toString().trim()) ?? 0;
  }

  /// Последний commit + вычисленная версия
  Future<CommitInfo> getLastCommit(String path) async {
    final commitCount = await getCommitCount(path);
    final version = _buildVersion(commitCount);

    if (commitCount == 0) {
      return CommitInfo(
        hash: '-',
        author: '-',
        date: '-',
        message: 'Нет коммитов',
        version: version,
      );
    }

    final result = await Process.run(
      'git',
      ['log', '-1', '--pretty=format:%H|%an|%ad|%s'],
      workingDirectory: path,
      stdoutEncoding: utf8,
    );

    if (result.exitCode != 0) {
      throw Exception('Не удалось получить git log');
    }

    final parts = result.stdout.toString().trim().split('|');

    return CommitInfo(
      hash: parts[0],
      author: parts[1],
      date: parts[2],
      message: parts[3],
      version: version,
    );
  }

  /// СОЗДАТЬ ОБЫЧНЫЙ COMMIT
  Future<bool> createCommit(String path, String message) async {

    /// добавить файлы
    final addResult = await Process.run(
      'git',
      ['add', '.'],
      workingDirectory: path,
      stdoutEncoding: utf8,
    );

    if (addResult.exitCode != 0) return false;
    final commitResult = await Process.run(
      'git',
      ['commit', '-m', message],
      workingDirectory: path,
      stdoutEncoding: utf8,
    );

    return commitResult.exitCode == 0;
  }

  Future<List<String>> getChangedFiles(String path) async {
  final result = await Process.run(
    'git',
    ['status', '--porcelain'],
    workingDirectory: path,
    stdoutEncoding: utf8,
  );

  if (result.exitCode != 0) return [];

  final lines = result.stdout.toString().trim().split('\n');

  return lines
      .where((line) => line.isNotEmpty)
      .map((line) => line.substring(2)) 
      .toList();
}

Future<void> fixEncoding(String path) async {
  await Process.run(
    'git',
    ['config', '--local', 'core.quotepath', 'false'],
    workingDirectory: path,
    stdoutEncoding: utf8,
  );
}
}