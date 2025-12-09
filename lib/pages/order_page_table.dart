import 'package:flutter/material.dart';
class OrderTable extends StatefulWidget {
  const OrderTable({super.key});

  @override
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {
  int _selectedId = 0; // 目前選中的餐點

  final List<String> items = ["蛋餅", "漢堡", "吐司", "三明治", "飯糰"];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        int id = index;
        int count = 1; // 每列各自記數量

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
                      items[index],
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
