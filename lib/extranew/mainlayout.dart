import 'package:flutter/material.dart';
import 'package:medicalapp/googlesignin.dart';
import 'package:medicalapp/index.dart';

class MainLayout extends StatefulWidget {
  final List<Widget> pages;
  final int initialIndex;
  final bool showSearchBar;
  final String title;

  const MainLayout({
    super.key,
    required this.pages,
    this.initialIndex = 0,
    this.showSearchBar = true,
    this.title = "",
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  /// ---------------------- WEB NAVBAR ----------------------
  Widget _buildWebNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          /// --------- LOGO ----------
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.medical_services, color: Colors.white),
          ),

          const SizedBox(width: 20),

          /// --------- SEARCH BAR ----------
          if (widget.showSearchBar)
            Expanded(
              child: Container(
                height: 36,
                padding: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Search...",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(width: 40),

          /// --------- CENTER NAV MENU ----------
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _navItem(Icons.home, "Home", 0),
              _navItem(Icons.work_outline, "Jobs", 1),
              _navItem(Icons.notifications_outlined, "Notifications", 2),
            ],
          ),

          const SizedBox(width: 40),

          /// --------- ME DROPDOWN ----------
          _meMenu(),
        ],
      ),
    );
  }

  /// ---------------------- NAV ITEM ----------------------
  Widget _navItem(IconData icon, String label, int index) {
    final bool isActive = currentIndex == index;

    return InkWell(
      onTap: () => setState(() => currentIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.black : Colors.grey, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.black : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 2),
                height: 2,
                width: 35,
                color: Colors.black,
              ),
          ],
        ),
      ),
    );
  }

  /// ---------------------- "ME" MENU WITH LOGOUT ----------------------
  Widget _meMenu() {
    return PopupMenuButton<int>(
      tooltip: "Me",
      position: PopupMenuPosition.under,
      offset: const Offset(0, 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) {
        if (value == 1) {
          // Profile
          setState(() => currentIndex = 3);
        } else if (value == 2) {
          // Logout
          signOutGoogle();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Index()),
            (route) => false,
          );
        }
      },
      child: Column(
        children: [
          Icon(
            Icons.person_outline,
            size: 28,
            color: currentIndex == 3 ? Colors.black : Colors.grey,
          ),
          const SizedBox(height: 2),
          Text(
            "Me",
            style: TextStyle(
              fontSize: 12,
              color: currentIndex == 3 ? Colors.black : Colors.grey,
              fontWeight:
                  currentIndex == 3 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (currentIndex == 3)
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 2,
              width: 30,
              color: Colors.black,
            ),
        ],
      ),
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 10),
                  Text("View Profile"),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 2,
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: Colors.red),
                  SizedBox(width: 10),
                  Text("Logout", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
    );
  }

  /// ---------------------- BUILD ----------------------
  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: isWeb ? _buildWebNavBar() : Text(widget.title),
      ),

      body: IndexedStack(index: currentIndex, children: widget.pages),

      bottomNavigationBar:
          !isWeb
              ? BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (i) => setState(() => currentIndex = i),
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.work_outline),
                    label: "Jobs",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications_outlined),
                    label: "Notifications",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: "Me",
                  ),
                ],
              )
              : null,
    );
  }
}
