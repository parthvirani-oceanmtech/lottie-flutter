import '../model/font.dart';
import 'moshi/json_reader.dart';

class FontParser {
  static final JsonReaderOptions _names = JsonReaderOptions.of([
    'fFamily',
    'fName',
    'fStyle',
    'ascent',
    'origion',
    'fPath',
    'fClass',
    'fWeight',
  ]);

  FontParser._();

  static Font parse(JsonReader reader) {
    String? family;
    String? name;
    String? style;
    int? origion;
    String? fPath;
    String? fClass;
    String? fWeight;
    var ascent = 0.0;

    reader.beginObject();
    while (reader.hasNext()) {
      switch (reader.selectName(_names)) {
        case 0:
          family = reader.nextString();
        case 1:
          name = reader.nextString();
        case 2:
          style = reader.nextString();
        case 3:
          ascent = reader.nextDouble();
        case 4:
          origion = reader.nextInt();
        case 5:
          fPath = reader.nextString();
        case 6:
          fClass = reader.nextString();
        case 7:
          fWeight = reader.nextString();
        default:
          reader.skipName();
          reader.skipValue();
      }
    }
    reader.endObject();

    return Font(
      family: family ?? '',
      name: name ?? '',
      style: style ?? '',
      ascent: ascent,
      fWeight: fWeight ?? '',
      fontClass: fClass ?? '',
      fontPath: fPath ?? '',
      origion: origion ?? 0,
    );
  }
}
