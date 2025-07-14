import 'package:flutter/material.dart';
import 'package:foretale_application/ui/screens/datagrids/generic_data_grid/sfdg_generic_grid.dart';

class PaginationExample extends StatefulWidget {
  const PaginationExample({super.key});

  @override
  State<PaginationExample> createState() => _PaginationExampleState();
}

class _PaginationExampleState extends State<PaginationExample> {
  late GlobalKey<GenericDataGridState> _gridKey;
  List<Map<String, dynamic>> sampleData = [];

  @override
  void initState() {
    super.initState();
    _gridKey = GlobalKey<GenericDataGridState>();
    _generateSampleData();
  }

  void _generateSampleData() {
    sampleData = List.generate(150, (index) {
      return {
        'id': index + 1,
        'name': 'Item ${index + 1}',
        'description': 'This is a sample description for item ${index + 1}',
        'category': ['Category A', 'Category B', 'Category C'][index % 3],
        'status': ['Active', 'Inactive', 'Pending'][index % 3],
        'date': DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generic DataGrid with Pagination'),
        actions: [
          // Example of external pagination controls
          IconButton(
            onPressed: _gridKey.currentState?.hasPreviousPage == true
                ? () => _gridKey.currentState?.previousPage()
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: _gridKey.currentState?.hasNextPage == true
                ? () => _gridKey.currentState?.nextPage()
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Page info display
            if (_gridKey.currentState != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Page ${_gridKey.currentState?.currentPage ?? 1} of ${_gridKey.currentState?.totalPages ?? 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            
            // The GenericDataGrid with pagination enabled
            GenericDataGrid(
              key: _gridKey,
              columns: [
                const GenericGridColumn(
                  columnName: 'id',
                  label: 'ID',
                  width: 80,
                  cellType: GenericGridCellType.number,
                ),
                const GenericGridColumn(
                  columnName: 'name',
                  label: 'Name',
                  width: 200,
                ),
                const GenericGridColumn(
                  columnName: 'description',
                  label: 'Description',
                  width: 300,
                ),
                const GenericGridColumn(
                  columnName: 'category',
                  label: 'Category',
                  width: 150,
                ),
                const GenericGridColumn(
                  columnName: 'status',
                  label: 'Status',
                  width: 120,
                  cellType: GenericGridCellType.badge,
                ),
                const GenericGridColumn(
                  columnName: 'date',
                  label: 'Date',
                  width: 120,
                ),
              ],
              data: sampleData,
              enablePagination: true,
              pageSize: 10,
              showPageSizeSelector: true,
              pageSizes: const [5, 10, 20, 50],
              onRowTap: (rowData, rowIndex) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tapped on row ${rowIndex + 1}: ${rowData['name']}'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 