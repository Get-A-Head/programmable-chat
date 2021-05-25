part of twilio_programmable_chat;

class Attributes {
  //#region Private API properties
  final AttributesType _type;

  final String? _json;
  //#endregion

  /// Returns attributes type
  AttributesType get type => _type;

  Attributes(this._type, this._json) : assert((_type == AttributesType.NULL && _json == null) || (_type != AttributesType.NULL && _json != null));

  factory Attributes.fromMap(Map<String, dynamic> map) {
    var type = EnumToString.fromString(AttributesType.values, map['type']) ?? AttributesType.NULL;
    var json = map['data'];
    return Attributes(type, json);
  }

  Map<String, dynamic>? getJSONObject() {
    var json = _json;
    if (type != AttributesType.OBJECT || json == null) {
      return null;
    } else {
      return jsonDecode(json);
    }
  }

  List<Map<String, dynamic>>? getJSONArray() {
    var json = _json;
    if (type != AttributesType.ARRAY || json == null) {
      return null;
    } else {
      return List<Map<String, dynamic>>.from(jsonDecode(json));
    }
  }

  String? getString() {
    if (type != AttributesType.STRING) {
      return null;
    } else {
      return _json;
    }
  }

  num? getNumber() {
    var json = _json;
    if (type != AttributesType.NUMBER || json == null) {
      return null;
    } else {
      return num.tryParse(json);
    }
  }

  bool? getBoolean() {
    if (type != AttributesType.BOOLEAN) {
      return null;
    } else {
      return _json == 'true';
    }
  }
}

enum AttributesType {
  OBJECT,
  ARRAY,
  STRING,
  NUMBER,
  BOOLEAN,
  NULL,
}
