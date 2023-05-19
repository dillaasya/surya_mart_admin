import 'package:flutter/material.dart';

class PopupMenu extends StatelessWidget {
  final List<PopupMenuEntry> menuPopup;
  final Widget icon;
  const PopupMenu({required this.menuPopup, required this.icon, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => menuPopup,
      icon: icon,
    );
  }
}
