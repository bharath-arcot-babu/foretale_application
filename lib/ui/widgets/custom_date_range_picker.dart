import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class CustomDateRangePicker extends StatefulWidget {
  final String title;
  final String hintText;
  final DateTimeRange? selectedDateRange;
  final ValueChanged<DateTimeRange?> onChanged;
  final bool isEnabled;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomDateRangePicker({
    super.key,
    required this.title,
    required this.hintText,
    this.selectedDateRange,
    required this.onChanged,
    this.isEnabled = true,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  final TextEditingController _dateRangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateDateRangeText();
  }

  @override
  void didUpdateWidget(CustomDateRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDateRange != widget.selectedDateRange) {
      _updateDateRangeText();
    }
  }

  void _updateDateRangeText() {
    if (widget.selectedDateRange != null) {
      final startDate = DateFormat('MMM dd, yyyy').format(widget.selectedDateRange!.start);
      final endDate = DateFormat('MMM dd, yyyy').format(widget.selectedDateRange!.end);
      _dateRangeController.text = '$startDate - $endDate';
    } else {
      _dateRangeController.text = '';
    }
  }

  Future<void> _selectDateRange() async {
    if (!widget.isEnabled) return;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: widget.firstDate ?? DateTime(2020),
      lastDate: widget.lastDate ?? DateTime.now().add(const Duration(days: 365)),
      initialDateRange: widget.selectedDateRange ?? DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != widget.selectedDateRange) {
      widget.onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyles.subtitleText(context).copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.isEnabled ? _selectDateRange : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: BorderColors.secondaryColor.withOpacity(0.7),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: widget.isEnabled ? Colors.white : Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateRangeController,
                    enabled: false,
                    style: TextStyles.inputMainTextStyle(context),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyles.inputHintTextStyle(context),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: widget.isEnabled 
                      ? AppColors.primaryColor 
                      : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _dateRangeController.dispose();
    super.dispose();
  }
} 