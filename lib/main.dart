import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OrderingPage(),
    );
  }
}

// 浮動島 AppBar 獨立出來
class FloatingIslandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FloatingIslandAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 50, 20, 10),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(239, 191, 51, 1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '點餐系統APP',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

// 主內容獨立出來
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('點餐系統', 
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ),
          
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(30),
              crossAxisCount: 2,
              mainAxisSpacing: 30,
              crossAxisSpacing: 30,
              children: [
                _menuItem('assets/P1_1.png', () {
                  // 點擊我要點餐
                }),
                _menuItem('assets/P2_1.png', () {
                  // 點擊點餐紀錄
                }),
                _menuItem('assets/P3_1.png', () {
                  // 點擊設計團隊
                }),
                _menuItem('assets/P4_1.png', () {
                  // 點擊關於系統
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
Widget _menuItem(String imagePath,  VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(//裝飾
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),//圓邊
          border: Border.all(color: Colors.black, width: 3),//黑邊
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 8))//黑影
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 140, height: 140),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
// 主頁面只負責組裝
class OrderingPage extends StatelessWidget {
  const OrderingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FloatingIslandAppBar(),
      body: const HomeContent(),
    );
  }
}