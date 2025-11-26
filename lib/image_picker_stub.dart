// lib/image_picker_stub.dart
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickImageWeb() async {
  // Mobile devices never call this
  return null;
}
