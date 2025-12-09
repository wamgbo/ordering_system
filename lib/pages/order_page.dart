// lib/order_page.dart
import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我要點餐')),
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
        ElevatedButton(
          // onPressed: () => setState(() => _selected = index),
          onPressed: () {
            setState(() {
              _selected = index;
            });
          },
          child: Text(text),
        ),
      ],
    );
  }
}
