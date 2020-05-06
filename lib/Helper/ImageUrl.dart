class ImageUrl {
  final String url;

  ImageUrl(this.url);

  String get low => _withSize(100, 100);
  String get middle => _withSize(800, 400);
  String get high => _withSize(1080, 1920);

  String _withSize(int x1, x2) {
    if (url == null || url.isEmpty) return null;
    List<String> splitted = url.split(".jpg");
    return "${splitted[0]}_${x1}x$x2.jpg${splitted[1]}";
  }
}
