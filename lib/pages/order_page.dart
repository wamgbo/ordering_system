// lib/order_page.dart
import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我要點餐')),
      body: SelectBar(),

      body: SelectBar(),
    );
  }
}

class SelectBar extends StatefulWidget {
  const SelectBar({super.key});
  @override
  State<SelectBar> createState() => _SelectBarState(); //必須要宣告
}

class _SelectBarState extends State<SelectBar> {
  int _selected = -1; // -1 = 沒選

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
            onPressed: () => setState(() => _selected = index),
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
