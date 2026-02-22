class CommitInfo {
  final String hash;
  final String author;
  final String date;
  final String message;
  final String version;

  CommitInfo({
    required this.hash,
    required this.author,
    required this.date,
    required this.message,
    required this.version,
  });
}