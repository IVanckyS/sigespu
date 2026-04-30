class SyncError implements Exception {
  final String message;
  final int retryCount;

  SyncError(this.message, this.retryCount);

  @override
  String toString() => 'SyncError: \$message (Retries: \$retryCount)';
}
