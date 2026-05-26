enum ResultRecordStatus {
  notListening('notListening'),
  listening('listening'),
  done('done'),
  error('error');

  final String value;
  const ResultRecordStatus(this.value);
}
