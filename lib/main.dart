import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pages/order_page.dart'; // 確保路徑正確
// 引入您剛建立的兩個檔案
import 'customer_query_page.dart';
import 'admin_store_page.dart';

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

// ==========================================
// 1. 主頁面與頂部導覽列
// ==========================================
class FloatingIslandAppBar extends StatelessWidget
    implements PreferredSizeWidget {
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

// ==========================================
// 2. 主內容區域：整合跳轉邏輯
// ==========================================
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _adminPwdController = TextEditingController();

  // 在 _HomeContentState 中新增開啟網址的方法
  Future<void> _launchURL() async {
    final Uri url = Uri.parse(
      'https://docs.google.com/spreadsheets/d/1HbxMsxEZxmKM-OJVsJHbPs-CyO4frGbP2kgNuvEjjJ4/edit?resourcekey=&gid=1083875815#gid=1083875815',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('無法開啟網址 $url');
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "查詢驗證",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "客戶請輸入資訊查詢：",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "姓名",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "電話號碼",
                  border: OutlineInputBorder(),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(thickness: 2),
              ),
              const Text(
                "店家管理員登入：",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _adminPwdController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "管理密碼 (123)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_adminPwdController.text == "123") {
                _adminPwdController.clear();
                Navigator.pop(context);
                // 跳轉至獨立的店家管理頁面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminStorePage(),
                  ),
                );
              } else if (_nameController.text.isNotEmpty &&
                  _phoneController.text.isNotEmpty) {
                String name = _nameController.text;
                String phone = _phoneController.text;
                _nameController.clear();
                _phoneController.clear();
                Navigator.pop(context);
                // 跳轉至獨立的客戶查詢頁面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerQueryPage(
                      currentUserName: name,
                      currentUserPhone: phone,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("請輸入客戶資訊或管理密碼"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("確認"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '點餐功能選單',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(30),
              crossAxisCount: 2,
              mainAxisSpacing: 30,
              crossAxisSpacing: 30,
              children: [
                _menuItem('assets/P1_1.png', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderPage()),
                  );
                }),
                _menuItem('assets/P4_1.png', _showLoginDialog),
                _menuItem('assets/P3_1.png', () {
                  _launchURL(); // 點擊 P3_1 開啟 Google Excel
                }),
                _menuItem('assets/P2_1.png', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String imagePath, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        //InkWell是一個 Flutter (及 Dart) UI 元件，它允許你在任何 Widget 上添加可點擊的功能
        onTap: onTap,
        borderRadius: BorderRadius.circular(20), //圓角
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 3), //黑邊
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Image.asset(imagePath),
            ),
          ), //edgeInsets 與邊邊距離
        ),
      ),
    );
  }
}
