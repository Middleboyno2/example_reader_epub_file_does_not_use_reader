class ReadingProgress {
  final int sectionIndex;
  final double scrollOffset;
  final double readingPercentage;

  ReadingProgress({
    required this.sectionIndex,
    required this.scrollOffset,
    required this.readingPercentage,
  });

  Map<String, dynamic> toJson() => {
    'sectionIndex': sectionIndex,
    'scrollOffset': scrollOffset,
    'readingPercentage': readingPercentage,
  };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      sectionIndex: json['sectionIndex'] ?? 0,
      scrollOffset: json['scrollOffset']?.toDouble() ?? 0.0,
      readingPercentage: json['readingPercentage']?.toDouble() ?? 0.0,
    );
  }
}