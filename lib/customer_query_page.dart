import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomerQueryPage extends StatefulWidget {
  final String currentUserName;
  final String currentUserPhone;

  const CustomerQueryPage({
    super.key, 
    required this.currentUserName, 
    required this.currentUserPhone
  });

  @override
  State<CustomerQueryPage> createState() => _CustomerQueryPageState();
}

class _CustomerQueryPageState extends State<CustomerQueryPage> {
  bool isTodayOnly = true;

  Future<List<String>> _fetchData() async {
    const String url = "https://orderapp-e60fb-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200 && response.body != 'null') {
      Map<String, dynamic> data = json.decode(response.body);
      
      // 取得今天日期字串 (格式: 2026-01-05)
      String todayStr = DateTime.now().toString().split(' ')[0];

      return data.values.where((v) {
        String entry = v.toString();
        // 1. 驗證是否為本人
        bool isMine = entry.contains(widget.currentUserName) || entry.contains(widget.currentUserPhone);
        if (!isMine) return false;

        // 2. 判斷是否為今日 (檢查 entry 是否包含 2026-01-05)
        if (isTodayOnly) return entry.contains(todayStr);
        return true;
      }).map((v) => v.toString()).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("客戶查詢: ${widget.currentUserName}"),
        backgroundColor: Colors.amber,
        actions: [IconButton(icon: const Icon(Icons.exit_to_app), onPressed: () => Navigator.pop(context))],
      ),
      body: Column(
        children: [
          _buildToggleButtons(),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final list = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) => Card(margin: const EdgeInsets.all(8), child: ListTile(title: Text(list[index]))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => setState(() => isTodayOnly = true),
            style: ElevatedButton.styleFrom(backgroundColor: isTodayOnly ? Colors.green : Colors.grey),
            child: const Text("今日點餐"),
          ),
          ElevatedButton(
            onPressed: () => setState(() => isTodayOnly = false),
            style: ElevatedButton.styleFrom(backgroundColor: !isTodayOnly ? Colors.green : Colors.grey),
            child: const Text("點餐紀錄"),
          ),
        ],
      ),
    );
  }
}