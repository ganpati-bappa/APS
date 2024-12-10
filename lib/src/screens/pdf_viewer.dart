import 'dart:io';

import 'package:aps/blocs/pdf_viewer_bloc/pdf_viewer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewer extends StatelessWidget {
  final String pdfUrl;
  final String pdfName;
  const PDFViewer({super.key, required this.pdfUrl, required this.pdfName});

  @override
  Widget build(BuildContext context) {
    String localFilePath = "";
    context.read<PdfViewerBloc>().add(PdfLoadingRequired(url: pdfUrl));
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(pdfName, style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          onPressed: () async {
            if (localFilePath.isNotEmpty) {
              final File file = File(localFilePath);
              if (file.existsSync()) {
                file.deleteSync();
              }
              Navigator.pop(context);
            }
            else {
              Navigator.pop(context);
            }
          }, icon: const Icon(Icons.arrow_back, color: Colors.white60,)),
      ),
      body: BlocBuilder<PdfViewerBloc, PdfViewerState>(
        builder: (context, state) {
          if (state is PdfLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white60,),);
          } else if (state is PdfLoaded) {
            localFilePath = state.localFilePath;
            return PDFView(
              filePath: state.localFilePath,
              enableSwipe: true,
              swipeHorizontal: true,
              backgroundColor: Colors.black,
              autoSpacing: true,
              pageSnap: true,
              fitEachPage: false,
              onError: (error) {
                print(error);
              },
              onPageError: (page, error) {
                print('$page: ${error.toString()}');
              },
            );
          } else {
            return const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white70,),)); 
          }
        }
      ),
    );
  }
}