import 'package:flutter/material.dart';
import 'package:foretale_application/models/inquiry_response_model.dart';
import 'package:foretale_application/ui/themes/text_styles.dart';

class AvatarWithSpacer extends StatelessWidget {
  final String name;
  final String responseByMachineId;
  final bool isUser;
  final int index;
  final List<InquiryResponse> responses;
  final double avatarSize;

  const AvatarWithSpacer({
    super.key,
    required this.name,
    required this.responseByMachineId,
    required this.isUser,
    required this.index,
    required this.responses,
    this.avatarSize = 36.0,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    return name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase())
        .take(2)
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);

    // Check if the current index is the last item in the list
    final isLastInList = index == responses.length - 1;

    // Check if the next item has a different machine ID (only if it's not the last item)
    final isNextResponseByDifferentMachine = index < responses.length - 1 &&
        responses[index + 1].responseByMachineId != responseByMachineId;

    final showAvatar = isLastInList || isNextResponseByDifferentMachine;

    Widget avatarWidget;
    if (!isUser && showAvatar) {
      avatarWidget = Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          color: Colors.orange.shade700,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: TextStyles.titleText(context).copyWith(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      );
    } else if (!isUser && !showAvatar) {
      avatarWidget = const SizedBox(width: 36);
    } else {
      avatarWidget = const SizedBox.shrink();
    }

    return Row(
      children: [
        avatarWidget,
        const SizedBox(width: 8), // Adjust spacing as needed
        // Add other message or content widgets here
      ],
    );
  }
}

class ResponseItem {
  final String responseBy;
  final String responseByMachineId;

  ResponseItem({
    required this.responseBy,
    required this.responseByMachineId,
  });
}
