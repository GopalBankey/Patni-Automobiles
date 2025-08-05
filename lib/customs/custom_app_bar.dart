import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberplatefinder/utils/app_colors.dart';

import '../views/about_app_screen.dart' show AboutAppScreen;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool isHome;
  final List<Widget>? actions;
  final Color backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.isHome = false,
    this.actions,
    this.backgroundColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, Color(0xff367ead)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      foregroundColor: AppColors.white,
      backgroundColor: backgroundColor,
      leadingWidth: 70,

      leading:
          showBackButton
              ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pop(),
              )
              : IconButton(
                onPressed: () {
                  Get.to(AboutAppScreen());
                },
                icon: Image.asset(
                  'assets/images/info.png',
                  scale: 18,
                  color: Colors.white,
                ),
              ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      actions: actions,
      elevation: 4.0,
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
