import 'dart:convert'; // [新增] 用於將資料轉為 JSON 格式
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int _currentCategoryIndex = 0;
  bool _showSummary = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final Map<int, List<Map<String, dynamic>>> _menuData = {
    0: [
      {"name": "豬肉總匯", "price": 65, "img": "assets/P1_1.png"},
      {"name": "雞肉總匯", "price": 65, "img": "assets/P1_1.png"},
      {"name": "里肌總匯", "price": 70, "img": "assets/P1_1.png"}
    ],
    1: [
      {"name": "鍋燒麵", "price": 80, "img": "assets/P2_1.png"},
      {"name": "鍋燒冬粉", "price": 80, "img": "assets/P2_1.png"},
      {"name": "鍋燒雞絲", "price": 80, "img": "assets/P2_1.png"}
    ],
    2: [
      {"name": "豬肉燴飯", "price": 65, "img": "assets/P3_1.png"},
      {"name": "里肌燴飯", "price": 70, "img": "assets/P3_1.png"},
      {"name": "牛肉燴飯", "price": 120, "img": "assets/P3_1.png"},
    ],
  };

  final Map<String, int> _orderList = {};

  int get _totalPrice {
    int total = 0;
    _orderList.forEach((name, count) {
      int price = 0;
      for (var list in _menuData.values) {
        final item = list.firstWhere((e) => e['name'] == name, orElse: () => {});
        if (item.isNotEmpty) price = item['price'];
      }
      total += price * count;
    });
    return total;
  }

  // --- 功能 1：上傳到 Google 表單 ---
  Future<void> _submitToGoogleForm() async {
    const String formId = "13YN30kcFdPIqvjJg0be2d2lCiBYkCaORmHScvktCVUc";
    final url = Uri.parse("https://docs.google.com/forms/d/$formId/formResponse");

    String itemNames = _orderList.keys.join(", ");
    String itemCounts = _orderList.values.join(", ");

    try {
      await http.post(
        url,
        body: {
          "entry.2062332167": _nameController.text,
          "entry.647612156": itemNames,
          "entry.598437499": itemCounts,
          "entry.2020585095": _totalPrice.toString(),
          "entry.137647088": _phoneController.text,
          "submit": "Submit",
        },
      );
      debugPrint("Google 表單上傳成功");
    } catch (e) {
      debugPrint("Google 表單上傳失敗: $e");
    }
  }

  // --- [新增] 功能 2：上傳到 Firebase Realtime Database ---
  Future<void> _submitToFirebase() async {
    // 你的 Firebase 資料庫網址
    // 注意：REST API 需要在網址後方加上 "/節點名稱.json"
    // 這裡我們建立一個 "orders" 節點來存放每筆訂單
    const String firebaseUrl = "https://orderapp-e60fb-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json";
    final url = Uri.parse(firebaseUrl);

    try {
      // 準備要傳送的資料 (JSON 格式)
      final Map<String, dynamic> orderData = {
        "customerName": _nameController.text,
        "customerPhone": _phoneController.text,
        "totalPrice": _totalPrice,
        "items": _orderList, // 直接傳送 Map 結構 {餐點名: 數量}
        "orderTime": DateTime.now().toIso8601String(), // 紀錄下單時間
      };

      // 使用 POST 方法 (Firebase 會自動產生唯一的 ID)
      final response = await http.post(
        url,
        body: jsonEncode(orderData), // 必須使用 jsonEncode 轉成字串
      );

      if (response.statusCode == 200) {
        debugPrint("Firebase 上傳成功: ${response.body}");
      } else {
        debugPrint("Firebase 上傳失敗: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Firebase 連線錯誤: $e");
    }
  }

  void _showFinishDialog() async {
    // 顯示 Loading 指示器 (選用，避免使用者重複點擊)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    // 同時執行 Google 表單與 Firebase 上傳 (並行處理以節省時間)
    await Future.wait([
      _submitToGoogleForm(),
      _submitToFirebase(),
    ]);

    // 關閉 Loading
    if (mounted) Navigator.pop(context);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 70), // 改成勾勾比較符合成功情境
            SizedBox(height: 10),
            Text("訂購成功", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "${_nameController.text} 您好\n訂單已送出並同步至後台，\n餐點製作約 10~15 分鐘，請稍候！",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, height: 1.5),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context); // 關閉 Dialog
                Navigator.pop(context); // 回到上一頁
              },
              child: const Text("確認"),
            ),
          ),
        ],
      ),
    );
  }

  // 圖片放大功能
  void _showImageDialog(String imgPath, String name) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
            ),
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(imgPath, fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Container(color: Colors.white, padding: const EdgeInsets.all(50), child: const Icon(Icons.broken_image, size: 100))),
              ),
            ),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: const Text('我要點餐', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amberAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 頂部輸入姓名與電話
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: TextField(controller: _nameController, decoration: const InputDecoration(labelText: '姓名', prefixIcon: Icon(Icons.person), border: OutlineInputBorder(), isDense: true))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: '電話', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder(), isDense: true))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildSelectBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _menuData[_currentCategoryIndex]?.length ?? 0,
              itemBuilder: (context, index) {
                final item = _menuData[_currentCategoryIndex]![index];
                return _buildOrderItemCard(item);
              },
            ),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildSelectBar() {
    final categories = ["蛋餅", "麵食", "飯類"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(categories.length, (index) {
        bool isSelected = _currentCategoryIndex == index;
        return Column(
          children: [
            Container(width: 80, height: 6, color: isSelected ? Colors.green : Colors.grey[400]),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: isSelected ? Colors.amber : Colors.white),
              onPressed: () => setState(() { _currentCategoryIndex = index; _showSummary = false; }),
              child: Text(categories[index], style: const TextStyle(color: Colors.black)),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOrderItemCard(Map<String, dynamic> item) {
    String name = item['name'];
    int count = _orderList[name] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          Checkbox(value: count > 0, onChanged: (v) => setState(() => v! ? _orderList[name] = 1 : _orderList.remove(name))),
          Text("$name[${item['price']}]"),
          const Spacer(),
          GestureDetector(onTap: () => _showImageDialog(item['img'], name), child: Hero(tag: name, child: Image.asset(item['img'], width: 50, height: 50, errorBuilder: (c,e,s) => const Icon(Icons.fastfood)))),
          const SizedBox(width: 10),
          DropdownButton<int>(
            value: count,
            items: List.generate(11, (i) => DropdownMenuItem(value: i, child: Text("$i"))),
            onChanged: (v) => setState(() { _showSummary = false; v == 0 ? _orderList.remove(name) : _orderList[name] = v!; }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black, width: 2))),
      child: Column(
        children: [
          Row(
            children: [
              _btnItem("取消", Colors.grey[300]!, () => setState(() { _orderList.clear(); _showSummary = false; })),
              const SizedBox(width: 10),
              _btnItem("結帳", Colors.grey[300]!, () { if (_orderList.isNotEmpty) setState(() => _showSummary = true); }),
            ],
          ),
          if (_showSummary) ...[
            const Divider(color: Colors.black),
            ..._orderList.entries.map((e) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("• ${e.key}"), Text("${e.value} 份")])),
          ],
          const Divider(color: Colors.black, thickness: 1.5),
          Align(alignment: Alignment.centerLeft, child: Text("總金額： ${_showSummary ? _totalPrice : 0}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const Divider(color: Colors.black, thickness: 1.5),
          Row(
            children: [
              _btnItem("回主畫面", Colors.grey[300]!, () => Navigator.pop(context)),
              const SizedBox(width: 10),
              _btnItem(
                "確定點餐", 
                const Color(0xFFDCEDC8), 
                (_showSummary && _nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) ? _showFinishDialog : null, 
                hasBorder: true
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btnItem(String label, Color color, VoidCallback? onTap, {bool hasBorder = false}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, border: Border.all(color: hasBorder ? Colors.green : Colors.black, width: hasBorder ? 2 : 1)),
          child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}