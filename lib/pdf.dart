import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {
  final String url;
  final Color color;

  const PdfViewerPage({Key? key, required this.url, required this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF Viewer'), backgroundColor: color),
      body: SfPdfViewer.network(
        url,
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
