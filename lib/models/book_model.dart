class BookModel {
  final String id;
  final String? isbn;
  final String title;
  final String author;
  final String? publisher;
  final int totalCopies;
  final int availableCopies;
  final String? barcode;
  final String? categoryName;

  BookModel({
    required this.id,
    this.isbn,
    required this.title,
    required this.author,
    this.publisher,
    required this.totalCopies,
    required this.availableCopies,
    this.barcode,
    this.categoryName,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] ?? '',
      isbn: json['isbn'],
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      publisher: json['publisher'],
      totalCopies: json['total_copies'] ?? 1,
      availableCopies: json['available_copies'] ?? 1,
      barcode: json['barcode'],
      categoryName: json['category_name'] ?? 'General',
    );
  }
}
