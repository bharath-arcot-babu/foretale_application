import 'package:flutter/material.dart';
import 'package:foretale_application/core/constants/colors/app_colors.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';
import 'package:foretale_application/ui/widgets/custom_loading_indicator.dart';
import 'custom_dropdown_search.dart';

// Global cache to store fetched data across widget rebuilds
class _DropdownDataCache {
  static final Map<String, Future<List<String>>> _cache = {};
  
  static Future<List<String>> getCachedData(String key, Future<List<String>> Function() fetchFunction) {
    if (!_cache.containsKey(key)) {
      _cache[key] = fetchFunction();
    }
    return _cache[key]!;
  }
}

class FutureDropdownSearch extends StatefulWidget {
  final Future<List<String>> Function() fetchData;
  final String labelText;
  final String hintText;
  final bool isEnabled;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;
  bool showSearchBox = false;

  FutureDropdownSearch(
      {super.key,
      required this.fetchData,
      required this.labelText,
      required this.hintText,
      required this.isEnabled,
      this.selectedItem,
      required this.onChanged,
      this.showSearchBox = false});

  @override
  State<FutureDropdownSearch> createState() => _FutureDropdownSearchState();
}

class _FutureDropdownSearchState extends State<FutureDropdownSearch> {
  late String _cacheKey;
  late Future<List<String>> _cachedFuture;

  @override
  void initState() {
    super.initState();
    // Create a unique cache key based on the widget's properties
    _cacheKey = '${widget.labelText}_${widget.hintText}_${widget.showSearchBox}';
    _cachedFuture = _DropdownDataCache.getCachedData(_cacheKey, widget.fetchData);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _cachedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearLoadingIndicator(
            isLoading: true,
            width: 200,
            height: 6,
            color: AppColors.primaryColor,
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return Center(
              child: Text("\"${widget.labelText}\"",
                  style: TextStyles.inputHintTextStyle(context)));
        } else {
          return CustomDropdownSearch(
            isEnabled: widget.isEnabled,
            items: snapshot.data!,
            hintText: widget.hintText,
            title: widget.labelText,
            selectedItem: widget.selectedItem,
            showSearchBox: widget.showSearchBox,
            onChanged: widget.onChanged,
          );
        }
      },
    );
  }
}
