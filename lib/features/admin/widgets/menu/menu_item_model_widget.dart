import 'package:flutter/material.dart';

import '../../../../model/menu_item.dart';
import 'menu_add_dialog_widget.dart';

class MenuItemModelWidget extends StatefulWidget {
  final MenuItem? item;
  final Function(MenuItem) onSave;
  final VoidCallback? onDelete;

  const MenuItemModelWidget({
    super.key,
    this.item,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<MenuItemModelWidget> createState() => MenuAddDialogWidget();
}
