import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../core/stylesheet.dart';

class MainScreen extends StatefulWidget {

  const MainScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) {
          setState(() {
            this.index = index;
          });
          widget.navigationShell.goBranch(index, initialLocation: index == widget.navigationShell.currentIndex);
        },
        selectedItemColor: Stylesheet.theme,
        unselectedItemColor: Stylesheet.themeLight,
        backgroundColor: Stylesheet.primary,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: index == 0 ? SvgPicture.asset('assets/icons/Book_open_fill.svg', width: 24, height: 24, color: Stylesheet.theme) : SvgPicture.asset('assets/icons/Book_open_light.svg', width: 24, height: 24, color: Stylesheet.themeLight),
            label: '성경',
          ),
          BottomNavigationBarItem(
            icon: index == 1 ? SvgPicture.asset('assets/icons/Bookmark_fill.svg', width: 24, height: 24, color: Stylesheet.theme) : SvgPicture.asset('assets/icons/Bookmark_light.svg', width: 24, height: 24, color: Stylesheet.themeLight),
            label: '말씀노트',
          ),
          BottomNavigationBarItem(
            icon: index == 2 ? SvgPicture.asset('assets/icons/User_fill.svg', width: 24, height: 24, color: Stylesheet.theme) : SvgPicture.asset('assets/icons/User_light.svg', width: 24, height: 24, color: Stylesheet.themeLight),
            label: '나',
          ),
        ],
      ),
    );
  }
}
