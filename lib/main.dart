import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pages/order_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: mainPage(),
    );
  }
}

// 頂部導覽列：點餐系統APP
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
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 15)),
        ],
      ),
      child: const Center(
        child: Text('點餐系統APP', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      ),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isLoggedIn = false;
  String _userName = "";

  // 實作：開啟點餐紀錄 (對應您的拼塊 Image 2 與 Image 6)
  Future<void> _launchOrderSheet() async {
    // 這是您指定的試算表網址
    final Uri url = Uri.parse('https://docs.google.com/spreadsheets/d/1HbxMsxEZxmKM-OJVsJHbPs-CyO4frGbP2kgNuvEjjJ4/edit?usp=sharing');
    
    // 使用外部應用程式開啟，可避免內置瀏覽器因未登入 Google 而產生的報錯
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('無法開啟試算表網址')));
    }
  }

  // 實作：模擬 Google 帳號登入 (解決您看到的 Image 3/4 報錯)
  Future<void> _handleMockLogin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );

    // 模擬網路驗證延遲 1.5 秒
    await Future.delayed(const Duration(milliseconds: 1500));
    
    Navigator.pop(context); // 關閉讀取動畫

    setState(() {
      _isLoggedIn = true;
      _userName = "管理員用戶";
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("模擬 Google 帳號驗證成功！")));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_isLoggedIn ? '歡迎，$_userName' : '點餐系統', 
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(30),
              crossAxisCount: 2,
              mainAxisSpacing: 30,
              crossAxisSpacing: 30,
              children: [
                _menuItem('assets/P1_1.png', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderPage()));
                }),
                _menuItem('assets/P4_1.png', () {
                  _launchOrderSheet(); // 執行開啟試算表
                }),
                _menuItem('assets/P3_1.png', () {
                  _showInfoDialog("設計團隊", "本 App 由 Flutter 實作模擬");
                }),
                _menuItem('assets/P2_1.png', () {
                  // 點擊「關於系統」執行模擬登入，解決找不到帳號的報錯
                  _showInfoDialog("關於系統", "本 App 由 Flutter 實作模擬");
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("確定"))],
      ),
    );
  }

  Widget _menuItem(String imagePath, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 8))],
          ),
          child: Center(child: Padding(padding: const EdgeInsets.all(15), child: Image.asset(imagePath))),
        ),
      ),
    );
  }
}

class mainPage extends StatelessWidget {
  const mainPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.amberAccent,
      appBar: FloatingIslandAppBar(),
      body: HomeContent(),
    );
  }
}