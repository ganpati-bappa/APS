import 'dart:io';

import 'package:aps/blocs/pdf_viewer_bloc/pdf_viewer_bloc.dart';
import 'package:aps/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PDFViewer extends StatefulWidget {
  final String pdfUrl;
  final String pdfName;
  final bool offlineAvalaibility;

  const PDFViewer({
    super.key,
    required this.pdfUrl,
    required this.pdfName,
    required this.offlineAvalaibility,
  });

  @override
  PDFViewerState createState() => PDFViewerState();
}

class PDFViewerState extends State<PDFViewer> {
  String localFilePath = "";
  bool? storagePermission;

  @override
  void initState()  {
    super.initState();
      _fetchStoragePermission();
      context
        .read<PdfViewerBloc>()
        .add(PdfLoadingRequired(url: widget.pdfUrl, pdfName: widget.pdfName));
    
  }

  Future<void> _fetchStoragePermission() async {
    final result = await requestStoragePermission();
    setState(() {
      storagePermission = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PdfViewerBloc, PdfViewerState>(
      listener: (context, state) {
        if (state is PDFDownloadingState) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context)
              .showSnackBar( SnackBar(content: customSnackbar(context, "Downloading PDF")));
        } else if (state is PDFDownloadedState) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: customSnackbar(context, "PDF Successfully Downloaded")));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(widget.pdfName,
              style: Theme.of(context).textTheme.titleLarge),
          actions: (widget.offlineAvalaibility)
              ? [
                  BlocBuilder<PdfViewerBloc, PdfViewerState>(
                    builder: (context, state) {
                      if (state is PDFDownloadingState) {
                        return const CircularProgressIndicator(
                          color: Colors.white70,
                          strokeWidth: 2,
                        );
                      } else if (state is PdfLoaded) {
                        return IconButton(
                          onPressed: () async {
                            if (localFilePath.isNotEmpty) {
                              final File file = File(localFilePath);
                              if (file.existsSync() && file.lengthSync() != 0) {
                                bool storagePermission =
                                    await requestStoragePermission();
                                if (storagePermission) {
                                  setState(() {
                                    context
                                        .read<PdfViewerBloc>()
                                        .add(PDFDownloading());
                                  });
                                  String filePath = '/storage/emulated/0/APS/';
                                  if (Platform.isAndroid) {
                                    Directory directory = Directory(filePath);
                                    if (!directory.existsSync()) {
                                      directory.createSync(recursive: true);
                                    }
                                  } else {
                                    Directory path =
                                        await getApplicationDocumentsDirectory();
                                    filePath = path.path;
                                  }
                                  Uri uri = Uri.parse(widget.pdfUrl);
                                  String? pdfToken = uri.queryParameters["token"];
                                  filePath += '${widget.pdfName}-$pdfToken.pdf';
                                  file.copySync(filePath);
                                  setState(() {
                                    context
                                        .read<PdfViewerBloc>()
                                        .add(PDFDownloaded());
                                    context.read<PdfViewerBloc>().add(
                                        PdfLoadingRequired(
                                            url: widget.pdfUrl,
                                            pdfName: widget.pdfName));
                                  });
                                }
                              } else {}
                            }
                          },
                          icon: const Icon(
                            Icons.download,
                            color: Colors.white,
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ]
              : [],
          leading: IconButton(
            onPressed: () async {
              if (localFilePath.isNotEmpty) {
                final File file = File(localFilePath);
                if (file.existsSync()) {
                  file.deleteSync();
                }
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white60,
            ),
          ),
        ),
        body: BlocBuilder<PdfViewerBloc, PdfViewerState>(
          builder: (context, state) {
            if (state is PdfLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white60,
                ),
              );
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
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white70,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
