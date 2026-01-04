import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int _currentCategoryIndex = 0;
  bool _showSummary = false; // 控制是否顯示結帳明細

  // 菜單資料
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

  // 訂單狀態 {品項名稱: 數量}
  final Map<String, int> _orderList = {};

  // 計算總金額
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

  // --- 新增：放大圖片的對話框 ---
  void _showImageDialog(String imgPath, String name) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, // 背景透明
        insetPadding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 頂部關閉按鈕與標題
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // 使用 InteractiveViewer 讓使用者可以縮放圖片
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: InteractiveViewer(
                child: Image.asset(
                  imgPath,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(50),
                    child: const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 點餐完成彈窗
  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Column(
          children: [
            Icon(Icons.report_problem_outlined, color: Colors.orange, size: 70),
            SizedBox(height: 10),
            Text("提示", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "您好\n訂單已送出，\n餐點現在約10~15分鐘，請稍候，謝謝您！",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("確認"),
          ),
        ],
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
          const SizedBox(height: 15),
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

          // 底部控制區域
          _buildBottomPanel(),
        ],
      ),
    );
  }

  // 分類選擇
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
              onPressed: () => setState(() {
                _currentCategoryIndex = index;
                _showSummary = false; 
              }),
              child: Text(categories[index]),
            ),
          ],
        );
      }),
    );
  }

  // 單行餐點卡片
  Widget _buildOrderItemCard(Map<String, dynamic> item) {
    String name = item['name'];
    int count = _orderList[name] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          Checkbox(
            value: count > 0, 
            onChanged: (v) => setState(() => v! ? _orderList[name] = 1 : _orderList.remove(name))
          ),
          Text("$name[${item['price']}]"),
          const Spacer(),
          // --- 修改：增加 GestureDetector 點擊放大 ---
          GestureDetector(
            onTap: () => _showImageDialog(item['img'], name),
            child: Hero( // 加上 Hero 動畫讓放大效果更順滑
              tag: name,
              child: Image.asset(
                item['img'], 
                width: 50, 
                height: 50, 
                errorBuilder: (c,e,s) => const Icon(Icons.fastfood)
              ),
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<int>(
            value: count,
            items: List.generate(11, (i) => DropdownMenuItem(value: i, child: Text("$i"))),
            onChanged: (v) => setState(() {
              _showSummary = false; 
              v == 0 ? _orderList.remove(name) : _orderList[name] = v!;
            }),
          ),
        ],
      ),
    );
  }

  // 底部按鈕面板
  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
      decoration: const BoxDecoration(
        color: Colors.white, 
        border: Border(top: BorderSide(color: Colors.black, width: 2))
      ),
      child: Column(
        children: [
          Row(
            children: [
              _btnItem("取消", Colors.grey[300]!, () => setState(() {
                _orderList.clear();
                _showSummary = false;
              })),
              const SizedBox(width: 10),
              _btnItem("結帳", Colors.grey[300]!, () {
                if (_orderList.isNotEmpty) setState(() => _showSummary = true);
              }),
            ],
          ),
          
          if (_showSummary) ...[
            const Divider(color: Colors.black),
            Column(
              children: _orderList.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("• ${e.key}", style: const TextStyle(fontSize: 16)),
                    Text("${e.value} 份", style: const TextStyle(fontSize: 16)),
                  ],
                ),
              )).toList(),
            ),
          ],

          const Divider(color: Colors.black, thickness: 1.5),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "總金額： ${_showSummary ? _totalPrice : 0}", 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
          ),
          const Divider(color: Colors.black, thickness: 1.5),

          Row(
            children: [
              _btnItem("回主畫面", Colors.grey[300]!, () => Navigator.pop(context)),
              const SizedBox(width: 10),
              _btnItem(
                "確定點餐", 
                const Color(0xFFDCEDC8), 
                _showSummary ? _showFinishDialog : null, 
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
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: hasBorder ? Colors.green : Colors.black, width: hasBorder ? 2 : 1),
          ),
          child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}