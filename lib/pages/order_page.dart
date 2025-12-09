// lib/order_page.dart
import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我要點餐'),
        backgroundColor: Colors.amberAccent,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          SelectBar(),
          Expanded(
            child: switch (_SelectBarState._selected) {
              0 => OrderTable(items: ["原味蛋餅[25]", "蔥燒蛋餅[30]", "玉米蛋餅[30]"]),
              1 => OrderTable(items: ["鍋燒麵[80]", "鍋燒冬粉[80]", "鍋燒烏龍[80]"]),
              2 => OrderTable(items: ["豬肉燴飯[65]", "雞肉燴飯[65]", "里肌燴飯[70]"]),
              _ => Center(child: Text("請選擇左側分類")),
            },
          ),
          // Expanded(
          //   child: OrderTable(items: ["原味蛋餅[25]", "蔥燒蛋餅[30]", "玉米蛋餅[30]"]),
          // ), //要用Exapanded
          // Expanded(
          //   child: OrderTable(items: ["鍋燒麵[80]", "鍋燒冬粉[80]", "鍋燒烏龍[80]"]),
          // ), //要用Exapanded
          // Expanded(
          //   child: OrderTable(items: ["豬肉燴飯[65]", "雞肉燴飯[65]", "里肌燴飯[70]"]),
          // ), //要用Exapanded
        ],
      ), //增加一個sizebox比較好看
    );
  }
}

class SelectBar extends StatefulWidget {
  const SelectBar({super.key});
  @override
  State<SelectBar> createState() => _SelectBarState(); //必須要宣告
}

class _SelectBarState extends State<SelectBar> {
  static int _selected = -1; // -1 = 沒選

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [_buildItem(0, "蛋餅"), _buildItem(1, "漢堡"), _buildItem(2, "吐司")],
    );
  }

  //callback 專門製造 選擇燈 跟 按鈕
  Widget _buildItem(int index, String text) {
    bool isSelected = _selected == index;
    return Column(
      children: [
        Container(
          width: 120,
          height: 30,
          color: isSelected ? Colors.green : Colors.grey, // 選中變綠
        ),
        //間隔
        const SizedBox(height: 20),
        //按鈕
        SizedBox(
          width: 120,
          height: 50,
          child: ElevatedButton(
            //按鈕造型
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.black,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // 數字越大越圓，30~40最美
                side: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
            //按下要做的事情
            onPressed: () => setState(() => _SelectBarState._selected = index),
            // onPressed: () {
            //   setState(() {
            //     _SelectBarState._selected = index;
            //   });
              
            // },
            //按鈕上面的字
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OrderTable extends StatefulWidget {
  final List<String> items; // 父層傳進來的餐點清單

  const OrderTable({super.key, required this.items});

  @override
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {
  static int _selectedId = 0;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.items.length, // <── 使用 widget.items
      itemBuilder: (context, index) {
        int id = index;
        int count = 1;

        return StatefulBuilder(
          builder: (context, setStateLocal) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Radio<int>(
                    value: id,
                    groupValue: _selectedId,
                    onChanged: (v) {
                      setState(() => _selectedId = v!);
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.items[index], // <── 拿父層傳的 items
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  DropdownButton<int>(
                    value: count,
                    items: List.generate(
                      10,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text("${i + 1}"),
                      ),
                    ),
                    onChanged: (v) => setStateLocal(() => count = v!),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
