import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  final Function(int) onTap;
  final int selectedIndex;

  const BottomNavBar(
      {super.key, required this.onTap, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color.fromARGB(255, 174, 149, 214),
      currentIndex: selectedIndex,
      elevation: 4,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.stethoscope),
          label: "Doctors",
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.book),
          label: "Appointments",
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.bell),
          label: "Notifications",
        ),
      ],
    );
  }
}
