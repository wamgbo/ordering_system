import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'sqlite_helper.dart';

class AdminStorePage extends StatefulWidget {
  const AdminStorePage({super.key});
  @override
  State<AdminStorePage> createState() => _AdminStorePageState();
}

class _AdminStorePageState extends State<AdminStorePage> {
  bool isTodayOnly = true;
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String dataSource = "初始化中...";

  @override
  void initState() {
    super.initState();
    _loadAndSyncData();
  }

  Future<void> _loadAndSyncData() async {
    setState(() => isLoading = true);
    final localData = await SqliteHelper.getLocalOrders();
    setState(() {
      orders = localData;
      dataSource = "來源: SQLite 本地快取";
      isLoading = false;
    });

    try {
      const String url = "https://orderapp-e60fb-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json";
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && response.body != 'null') {
        Map<String, dynamic> data = json.decode(response.body);
        for (var key in data.keys) {
          await SqliteHelper.syncOrder(key, Map<String, dynamic>.from(data[key]));
        }
        final updatedData = await SqliteHelper.getLocalOrders();
        setState(() {
          orders = updatedData;
          dataSource = "來源: SQLite (雲端已同步)";
        });
      }
    } catch (e) {
      setState(() => dataSource = "來源: SQLite (離線模式)");
    }
  }

  @override
  Widget build(BuildContext context) {
    String today = DateTime.now().toString().split(' ')[0];
    List<Map<String, dynamic>> displayList = isTodayOnly 
        ? orders.where((o) => o['orderTime'].toString().startsWith(today)).toList()
        : orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text("店家管理後台"),
        backgroundColor: Colors.amber,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(
            color: Colors.blueGrey[800],
            width: double.infinity,
            child: Text(dataSource, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAndSyncData)],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterChip(label: const Text("今日"), selected: isTodayOnly, onSelected: (v) => setState(() => isTodayOnly = true)),
              const SizedBox(width: 10),
              FilterChip(label: const Text("全部"), selected: !isTodayOnly, onSelected: (v) => setState(() => isTodayOnly = false)),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final o = displayList[index];
                int total = o['totalPrice'] ?? 0;
                int finalPrice = total >= 100 ? (total * 0.9).round() : total;
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("客戶: ${o['customerName']} (${o['customerPhone']})", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("時間: ${o['orderTime']}"),
                        const Divider(),
                        Text("餐點: ${o['items']}"),
                        Text("實收金額: \$$finalPrice", style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}