abstract class ValueWriter {
  void write(String path, dynamic value);
}

class MapWriter implements ValueWriter {
  final Map<String, dynamic> _target;

  MapWriter(this._target);

  @override
  void write(String path, value) {
    _target[path] = value;
  }
}
