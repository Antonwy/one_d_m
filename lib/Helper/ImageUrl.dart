class ImageUrl {
  final String url;

  ImageUrl(this.url);

  String get low => _withSize(100, 100);
  String get middle => _withSize(200, 200);
  String get high => _withSize(800, 400);

  String _withSize(int x1, x2) {
    List<String> splitted = url.split(".jpg");

    return url;

    // TODO: Ab 7. Mai resized images!
    // return "${splitted[0]}_${x1}x$x2.jpg${splitted[1]}";
  }
}
