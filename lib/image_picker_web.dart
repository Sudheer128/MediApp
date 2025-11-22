// lib/image_picker_web.dart
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickImageWeb() async {
  final completer = Completer<XFile?>();

  final input = html.FileUploadInputElement()..accept = 'image/*';

  input.onChange.listen((event) {
    if (input.files == null || input.files!.isEmpty) {
      completer.complete(null);
      return;
    }

    final file = input.files!.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);

    reader.onLoadEnd.listen((event) {
      final data = reader.result as Uint8List;
      completer.complete(XFile.fromData(data, name: file.name));
    });
  });

  input.click();
  return completer.future;
}
