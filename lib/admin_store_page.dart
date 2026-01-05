import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'sqlite_helper.dart'; // 引入剛寫的 Helper

class AdminStorePage extends StatefulWidget {
  const AdminStorePage({super.key});

  @override
  State<AdminStorePage> createState() => _AdminStorePageState();
}

class _AdminStorePageState extends State<AdminStorePage> {
  bool isTodayOnly = true;
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAndSyncData();
  }

  // 核心邏輯：先載入本地緩存，再嘗試同步 Firebase
  Future<void> _loadAndSyncData() async {
    // 1. 先顯示本地現有的 SQLite 資料
    final localData = await SqliteHelper.getLocalOrders();
    setState(() {
      orders = localData;
      isLoading = false;
    });

    // 2. 嘗試從 Firebase 同步最新資料
    try {
      const String url = "https://orderapp-e60fb-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json";
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && response.body != 'null') {
        Map<String, dynamic> data = json.decode(response.body);
        
        // 逐筆存入 SQLite
        for (var key in data.keys) {
          await SqliteHelper.syncOrder(key, Map<String, dynamic>.from(data[key]));
        }

        // 3. 同步完畢，重新讀取本地資料更新 UI
        final updatedData = await SqliteHelper.getLocalOrders();
        setState(() {
          orders = updatedData;
        });
      }
    } catch (e) {
      debugPrint("網路同步失敗，目前顯示離線資料: $e");
    }
  }

  List<Map<String, dynamic>> get filteredOrders {
    String todayStr = DateTime.now().toString().split(' ')[0];
    if (isTodayOnly) {
      return orders.where((o) => o['orderTime'].toString().startsWith(todayStr)).toList();
    }
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("店家後台 (SQLite 同步版)"),
        backgroundColor: Colors.amber,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAndSyncData)],
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) => _orderCard(filteredOrders[index]),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(onPressed: () => setState(() => isTodayOnly = true), child: Text("今日", style: TextStyle(color: isTodayOnly ? Colors.blue : Colors.grey))),
        TextButton(onPressed: () => setState(() => isTodayOnly = false), child: Text("全部", style: TextStyle(color: !isTodayOnly ? Colors.blue : Colors.grey))),
      ],
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    int total = order['totalPrice'] ?? 0;
    int finalPrice = total >= 100 ? (total * 0.9).round() : total;

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("客戶: ${order['customerName']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("時間: ${order['orderTime']}"),
            Text("內容: ${order['items']}"),
            const Divider(),
            Text("總計: $total / 優惠: $finalPrice", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}