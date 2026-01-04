import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminStorePage extends StatefulWidget {
  const AdminStorePage({super.key});

  @override
  State<AdminStorePage> createState() => _AdminStorePageState();
}

class _AdminStorePageState extends State<AdminStorePage> {
  bool isTodayOnly = true;

  Future<List<String>> _fetchAll() async {
    const String url = "https://orderapp-e60fb-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200 && response.body != 'null') {
      Map<String, dynamic> data = json.decode(response.body);
      // 關鍵：對應 Firebase 的 orderTime 格式 (例如 2026-01-05)
      String todayStr = DateTime.now().toString().split(' ')[0];

      return data.values.where((v) {
        if (isTodayOnly) return v.toString().contains(todayStr);
        return true;
      }).map((v) => v.toString()).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("店家端"),
        backgroundColor: Colors.amber,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.logout, color: Colors.black),
            label: const Text("退出", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
      body: Column(
        children: [
          // 頂部切換 Tab
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _customTab("今日點餐", isTodayOnly, () => setState(() => isTodayOnly = true)),
                _customTab("點餐紀錄", !isTodayOnly, () => setState(() => isTodayOnly = false)),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _fetchAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final list = snapshot.data ?? [];
                return Column(
                  children: [
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(10), color: Colors.amber[50],
                      child: Text("清單筆數 : ${list.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) => ListTile(title: Text(list[index])),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _customTab(String title, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(title, style: TextStyle(color: active ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}