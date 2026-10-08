String formatWon(int value) {
  final text = value.toString();
  final buffer = StringBuffer();

  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(text[i]);
  }

  return '₩${buffer.toString()}';
}

String formatDate(DateTime value) {
  final y = value.year.toString();
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  return '$y.$m.$d';
}
