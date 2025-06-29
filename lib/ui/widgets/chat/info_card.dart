import 'package:flutter/material.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class InfoCard extends StatefulWidget {
  final String question;
  final String reason;
  final String? initialValue;
  final String? calloutText;
  final int? calloutTextFontSize;
  final int? questionFontSize;

  const InfoCard({
    super.key,
    required this.question,
    required this.reason,
    this.initialValue,
    this.calloutText,
    this.calloutTextFontSize,
    this.questionFontSize,
  });

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Question and Callout Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyles.titleText(context).copyWith(
                        fontSize: widget.questionFontSize?.toDouble() ?? 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.calloutText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.calloutText!,
                        style: TextStyles.responseText(context).copyWith(
                          fontSize: widget.calloutTextFontSize?.toDouble() ?? 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                ],
              ),
              if (widget.reason.isNotEmpty)
                const SizedBox(height: 16),
              if (widget.reason.isNotEmpty) 
              // Reason
              Text(
                widget.reason,
                style: TextStyles.responseText(context),
              )
            ],
          ),
        ),
      ),
    );
  }
}
