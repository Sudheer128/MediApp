import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {
  final String url;
  final String title;

  const PdfViewerPage({Key? key, required this.url, required this.title})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SfPdfViewer.network(
        'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        onDocumentLoaded: (details) {
          print('PDF loaded with ${details} pages');
        },
        onDocumentLoadFailed: (details) {
          print('Failed to load PDF: ${details.error}');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to load PDF')));
        },
      ),
    );
  }
}
