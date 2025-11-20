import 'package:flutter/material.dart';

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
          /// ---------- Logo ---------
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.medical_services, color: Colors.white),
          ),

          const SizedBox(width: 20),

          /// ---------- SEARCH BAR ----------
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

          const SizedBox(width: 30),

          /// ---------- ICON NAV CENTERED ----------
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _navItem(Icons.home, "Home", 0),
              _navItem(Icons.work_outline, "Jobs", 1),
              _navItem(Icons.notifications_outlined, "Notifications", 2),
              _navItem(Icons.person_outline, "Me", 3),
            ],
          ),

          const SizedBox(width: 20),
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
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.black : Colors.grey, size: 28),
            const SizedBox(height: 3),
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
                margin: const EdgeInsets.only(top: 3),
                height: 2,
                width: 35,
                color: Colors.black,
              ),
          ],
        ),
      ),
    );
  }

  /// ---------------------- BUILD ----------------------
  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),

      /// ---------------------- APPBAR ----------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: isWeb ? _buildWebNavBar() : Text(widget.title),
      ),

      /// ---------------------- BODY ----------------------
      body: IndexedStack(index: currentIndex, children: widget.pages),

      /// ---------------------- BOTTOM NAV (MOBILE ONLY) ----------------------
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
