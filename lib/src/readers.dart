abstract class ValueReader {
  dynamic read(String path);
}

class MapWriter implements ValueReader {
  final Map<String, dynamic> _source;

  MapWriter(this._source);

  @override
  dynamic read(String path) {
    return _source[path];
  }
}