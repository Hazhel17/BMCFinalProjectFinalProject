class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String genre;
  final String format;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.genre,
    required this.format,
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    // Safe extraction of all fields
    return Product(
      id: id,
      name: data['name'] ?? 'Untitled Product',
      description: data['description'] ?? 'No description provided.',
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : data['price'] ?? 0.0,
      imageUrl: data['imageUrl'] ?? 'https://placehold.co/1024x1024/DDDDDD/000000?text=NO+IMAGE',

      // NEW: Safely extract genre and format, providing defaults
      genre: data['genre'] ?? 'N/A',
      format: data['format'] ?? 'N/A',
    );
  }
}