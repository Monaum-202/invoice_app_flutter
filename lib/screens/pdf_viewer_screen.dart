import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class PdfViewerScreen extends StatefulWidget {
  final Uint8List pdfBytes;
  final String title;

  const PdfViewerScreen({
    Key? key,
    required this.pdfBytes,
    required this.title,
  }) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _pdfPath;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _savePdfToTemp();
  }

  Future<void> _savePdfToTemp() async {
    if (kIsWeb) {
      final blob = html.Blob([widget.pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      setState(() {
        _pdfPath = url;
      });
    } else {
      final tempDir = await getTemporaryDirectory();
      final tempFile = io.File('${tempDir.path}/${widget.title}.pdf');
      await tempFile.writeAsBytes(widget.pdfBytes);
      setState(() {
        _pdfPath = tempFile.path;
      });
    }
  }

  Widget _buildWebPdfView() {
    final viewType = 'pdf-view-${DateTime.now().millisecondsSinceEpoch}';
    if (kIsWeb) {
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..src = _pdfPath!;
      return iframe;
    });
    }

    return HtmlElementView(viewType: viewType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show menu options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              child: _pdfPath == null
                  ? const Center(child: CircularProgressIndicator())
                  : kIsWeb
                      ? _buildWebPdfView()
                      : PDFView(
                          filePath: _pdfPath!,
                          enableSwipe: true,
                          swipeHorizontal: true,
                          autoSpacing: false,
                          pageFling: false,
                          pageSnap: false,
                          defaultPage: _currentPage,
                          fitPolicy: FitPolicy.BOTH,
                          preventLinkNavigation: false,
                          onRender: (_pages) {
                            setState(() {
                              _totalPages = _pages!;
                            });
                          },
                          onError: (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())),
                            );
                          },
                          onPageChanged: (int? page, int? total) {
                            if (page != null) {
                              setState(() {
                                _currentPage = page;
                              });
                            }
                          },
                        ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: () async {
                    if (_pdfPath != null && !kIsWeb) {
                      await Share.shareXFiles(
                        [XFile(_pdfPath!)],
                        text: widget.title,
                      );
                    }
                  },
                ),
                _buildActionButton(
                  icon: Icons.send,
                  label: 'Send',
                  onTap: () {
                    // Implement send functionality
                  },
                ),
                _buildActionButton(
                  icon: Icons.print,
                  label: 'Print',
                  onTap: () {
                    // Implement print functionality
                  },
                ),
                _buildActionButton(
                  icon: Icons.copy,
                  label: 'Clone',
                  onTap: () {
                    // Implement clone functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
