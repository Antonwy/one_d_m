class StreamResult<T> {
  final bool fromCache;
  final T? data;

  StreamResult({this.fromCache = false, this.data});
}
