import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'pages/order_page.dart'; // 確保您的專案中有此檔案

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
// 2. 主內容區域：點擊「點餐紀錄」後觸發登入驗證
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

  // 彈出驗證視窗：要求輸入個人資訊或管理員密碼
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("查詢驗證", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("客戶請輸入資訊查詢：", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "姓名", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "電話號碼", border: OutlineInputBorder()),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(thickness: 2),
              ),
              const Text("店家管理員登入：", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _adminPwdController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "管理密碼 (123)", border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("取消")),
          ElevatedButton(
            onPressed: () {
              // 優先判斷管理員登入
              if (_adminPwdController.text == "123") {
                _adminPwdController.clear();
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminStorePage()));
              } 
              // 其次判斷客戶端登入
              else if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                String name = _nameController.text;
                String phone = _phoneController.text;
                _nameController.clear();
                _phoneController.clear();
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CustomerQueryPage(currentUserName: name, currentUserPhone: phone)
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("請輸入客戶資訊或管理密碼"), backgroundColor: Colors.red),
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
            child: Text('點餐功能選單', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(30),
              crossAxisCount: 2,
              mainAxisSpacing: 30,
              crossAxisSpacing: 30,
              children: [
                _menuItem('assets/P1_1.png', () {
                  // 原有的點餐功能跳轉
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderPage()));
                }),
                _menuItem('assets/P4_1.png', _showLoginDialog), // 點擊點餐紀錄，彈出登入對話框
                _menuItem('assets/P3_1.png', () {}),
                _menuItem('assets/P2_1.png', () {}),
              ],
            ),
          ),
          // 底部 Firebase 查詢按鈕 (保留)
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FirebaseLogicPage())),
            child: Container(
              width: double.infinity,
              height: 60,
              color: Colors.grey[400],
              alignment: Alignment.center,
              child: const Text("查詢FireBase雲端資料庫", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

// ==========================================
// 3. 客戶端頁面 (根據輸入的姓名與電話篩選)
// ==========================================
class CustomerQueryPage extends StatelessWidget {
  final String currentUserName;
  final String currentUserPhone;
  const CustomerQueryPage({super.key, required this.currentUserName, required this.currentUserPhone});

  Future<List<String>> _fetchMyData() async {
    const String url = "https://orderapp-e60fb-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200 && response.body != 'null') {
      Map<String, dynamic> data = json.decode(response.body);
      return data.values
          .where((v) => v.toString().contains(currentUserName) || v.toString().contains(currentUserPhone))
          .map((v) => v.toString()).toList();
    }
    return ["查無您的相關資料"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("$currentUserName 的訂單紀錄"), backgroundColor: Colors.amber),
      body: FutureBuilder<List<String>>(
        future: _fetchMyData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.grey),
            itemBuilder: (context, index) => Text(list[index], style: const TextStyle(color: Colors.white, fontSize: 16)),
          );
        },
      ),
    );
  }
}

// ==========================================
// 4. 店家端頁面 (顯示所有資料)
// ==========================================
class AdminStorePage extends StatelessWidget {
  const AdminStorePage({super.key});

  Future<List<String>> _fetchAll() async {
    const String url = "https://orderapp-e60fb-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200 && response.body != 'null') {
      Map<String, dynamic> data = json.decode(response.body);
      return data.values.map((v) => v.toString()).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("店家端後台管理"), backgroundColor: Colors.amber),
      body: FutureBuilder<List<String>>(
        future: _fetchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data ?? [];
          return Column(
            children: [
              Container(
                width: double.infinity, color: Colors.amber, padding: const EdgeInsets.all(15),
                child: Text("全系統總訂單筆數: ${list.length}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(list[index]),
                    subtitle: const Text("---------------------------------"),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==========================================
// 5. Firebase 邏輯展示頁面
// ==========================================
class FirebaseLogicPage extends StatelessWidget {
  const FirebaseLogicPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(width: double.infinity, color: const Color(0xFFFFC107), padding: const EdgeInsets.all(15),
              child: const Text("查詢FireBase雲端資料庫", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            Container(width: double.infinity, color: Colors.black, padding: const EdgeInsets.all(12),
              child: const Text("Firebase Logic Page\nStatus: Online", style: TextStyle(color: Colors.white))),
            const Expanded(child: Center(child: Text("這裡是 Firebase 原始資料對應頁面"))),
          ],
        ),
      ),
    );
  }
}