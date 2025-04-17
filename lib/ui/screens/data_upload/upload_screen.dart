//libraries
import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/core/services/csv_upload.dart';
import 'package:foretale_application/ui/widgets/custom_elevated_button.dart';
import 'package:foretale_application/ui/widgets/custom_progress_bar.dart';


class FileUpload extends StatefulWidget {
  const FileUpload({super.key});

  @override
  State<FileUpload> createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {
  final ValueNotifier<List<String>> errorNotifier = ValueNotifier<List<String>>([]);
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<List<CsvFileDetails>> csvFilesNotifier = ValueNotifier<List<CsvFileDetails>>([]);
  late CsvUpload csvUpload;

  @override
  void initState() {
    csvUpload = CsvUpload(
        errorNotifier: errorNotifier,
        progressNotifier: progressNotifier,
        csvFilesNotifier: csvFilesNotifier,
        context: super.context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomElevatedButton(
                width: 150.0,
                height: 50.0,
                text: "Upload Files",
                textSize: 16.0,
                onPressed: csvUpload.browseAndReadCsvMultiple,
              ),
              Expanded(
                child: ValueListenableBuilder<double>(
                  valueListenable: progressNotifier,
                  builder: (context, progress, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: CustomProgressBar(
                        progress: progress,
                        backgroundColor: AppColors.secondaryColor,
                        progressColor: AppColors.primaryColor,
                        height: 20.0,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Flexible(
            child: ValueListenableBuilder<List<CsvFileDetails>>(
              valueListenable: csvFilesNotifier,
              builder: (context, csvFiles, child) {
                if (csvFiles.isEmpty) {
                  return Center(
                    child: Text(
                      'No files uploaded yet.',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey.shade600),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: csvFiles.length,
                  itemBuilder: (context, index) {
                    final details = csvFiles[index];
                    return Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0), // Reduced padding for a tighter layout
                        child: CsvFileDetailsCard(details: details),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CsvFileDetailsCard extends StatelessWidget {
  final CsvFileDetails details;

  const CsvFileDetailsCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
                flex: 3,
                child: Column(children: [
                  _buildSmallDetail(context, 'File Name', details.fileName ?? ''),
                  _buildSmallDetail(context, 'Size (MB)', details.fileSize?.toString() ?? '0.0')
                ])),
            Flexible(
              flex: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFixedWidthBigMetric(
                    context, 
                    'Rows', 
                    details.rowCount?.toString() ?? '0'),
                  _buildFixedWidthBigMetric(
                    context,
                    'Columns', 
                    details.columnCount?.toString() ?? '0'),
                  _buildFixedWidthBigMetricWithIcon(
                    context,
                    'Error records',
                    details.errorRows?.toString() ?? '0',
                    Icons.download,
                    () {
                      // Implement the download functionality for error logs here
                    },
                  ),
                  _buildFixedWidthBigMetric(
                    context,
                    'Error free records', 
                    details.rowsWithoutError?.toString() ?? '0'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFixedWidthBigMetric(BuildContext context, String title, String value) {
    return Column(
        children: [
          Text(
            value,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      );
  }

  Widget _buildFixedWidthBigMetricWithIcon(BuildContext context, String title, String value, IconData icon, VoidCallback onPressed) {
    return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              IconButton(
                icon: Icon(icon, size: 18, color: Colors.blue),
                onPressed: onPressed,
              ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      );
  }

  Widget _buildSmallDetail(BuildContext context, String title, String value) {
    return Row(
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey),
        ),
        Expanded(
            child: Text(
              value,
              maxLines: 2,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.fade,
            ))
      ],
    );
  }
}
