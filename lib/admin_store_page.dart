import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'sqlite_helper.dart'; // 確保你有這個檔案

class AdminStorePage extends StatefulWidget {
  const AdminStorePage({super.key});

  @override
  State<AdminStorePage> createState() => _AdminStorePageState();
}

class _AdminStorePageState extends State<AdminStorePage> {
  bool isTodayOnly = true;
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String dataSource = "正在初始化...";

  @override
  void initState() {
    super.initState();
    _loadAndSyncData();
  }

  // 核心：先讀 SQLite，後同步 Firebase
  Future<void> _loadAndSyncData() async {
    setState(() => isLoading = true);

    // 1. 從 SQLite 讀取
    final localData = await SqliteHelper.getLocalOrders();
    setState(() {
      orders = localData;
      dataSource = "來源: SQLite 本地快取";
      isLoading = false;
    });

    // 2. 嘗試同步雲端
    try {
      const String url = "https://orderapp-e60fb-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json";
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && response.body != 'null') {
        Map<String, dynamic> data = json.decode(response.body);
        for (var key in data.keys) {
          await SqliteHelper.syncOrder(key, Map<String, dynamic>.from(data[key]));
        }
        
        // 同步完重新讀取
        final updatedData = await SqliteHelper.getLocalOrders();
        setState(() {
          orders = updatedData;
          dataSource = "來源: SQLite (已與雲端同步)";
        });
      }
    } catch (e) {
      setState(() => dataSource = "來源: SQLite (離線模式)");
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
        title: const Text("店家管理後台"),
        backgroundColor: Colors.amber,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(
            color: Colors.blueGrey[800],
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              dataSource,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAndSyncData),
        ],
      ),
      body: Column(
        children: [
          _buildToggleButtons(),
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

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilterChip(
            label: const Text("今日訂單"),
            selected: isTodayOnly,
            onSelected: (v) => setState(() => isTodayOnly = true),
          ),
          const SizedBox(width: 10),
          FilterChip(
            label: const Text("全部紀錄"),
            selected: !isTodayOnly,
            onSelected: (v) => setState(() => isTodayOnly = false),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    int total = order['totalPrice'] ?? 0;
    int finalPrice = total >= 100 ? (total * 0.9).round() : total;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("客戶: ${order['customerName']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("時間: ${order['orderTime'].toString().substring(0, 16)}"),
                const Divider(),
                Text("餐點: ${order['items']}"),
                const SizedBox(height: 10),
                Text("總金額: $total / 優惠價: $finalPrice", 
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          // 右下角 SQLite 標誌
          const Positioned(
            bottom: 8,
            right: 8,
            child: Row(
              children: [
                Text("SQLITE ", style: TextStyle(fontSize: 9, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                Icon(Icons.storage, size: 14, color: Colors.blueGrey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}