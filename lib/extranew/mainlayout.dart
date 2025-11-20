import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  final List<Widget> pages; // Pages for Home / Page 2 / Page 3 / Page 4
  final int initialIndex; // Optional
  final bool showSearchBar; // For web navbar
  final String title; // AppBar Title for Mobile

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

  Widget _buildWebNavBar() {
    return Row(
      children: [
        Icon(Icons.medical_services, color: Colors.blue),
        const SizedBox(width: 10),

        if (widget.showSearchBar)
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(child: Text("Search...")),
                ],
              ),
            ),
          ),

        const SizedBox(width: 20),

        _navItem(Icons.home, 0),
        _navItem(Icons.work_outline, 1),
        _navItem(Icons.notifications_outlined, 2),
        _navItem(Icons.person_outline, 3),
      ],
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => setState(() => currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.black : Colors.grey),
            const SizedBox(height: 2),
            if (isSelected)
              Container(height: 2, width: 30, color: Colors.black),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: isWeb ? _buildWebNavBar() : Text(widget.title),
        automaticallyImplyLeading: false,
        elevation: 1,
      ),

      body: IndexedStack(index: currentIndex, children: widget.pages),

      bottomNavigationBar:
          !isWeb
              ? BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (i) => setState(() => currentIndex = i),
                selectedItemColor: Colors.black,
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
