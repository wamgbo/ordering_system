import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'sqlite_helper.dart';

class CustomerQueryPage extends StatefulWidget {
  final String currentUserName;
  final String currentUserPhone;
  const CustomerQueryPage({super.key, required this.currentUserName, required this.currentUserPhone});

  @override
  State<CustomerQueryPage> createState() => _CustomerQueryPageState();
}

class _CustomerQueryPageState extends State<CustomerQueryPage> {
  List<Map<String, dynamic>> myOrders = [];

  @override
  void initState() {
    super.initState();
    _syncAndLoad();
  }

  Future<void> _syncAndLoad() async {
    final local = await SqliteHelper.getLocalOrders();
    _filterAndSet(local);

    try {
      const String url = "https://orderapp-e60fb-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200 && response.body != 'null') {
        Map<String, dynamic> data = json.decode(response.body);
        for (var key in data.keys) {
          await SqliteHelper.syncOrder(key, Map<String, dynamic>.from(data[key]));
        }
        final updated = await SqliteHelper.getLocalOrders();
        _filterAndSet(updated);
      }
    } catch (e) {
      debugPrint("離線模式");
    }
  }

  void _filterAndSet(List<Map<String, dynamic>> all) {
    setState(() {
      myOrders = all.where((o) => 
        o['customerName'] == widget.currentUserName || 
        o['customerPhone'] == widget.currentUserPhone
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("我的個人訂單紀錄"), backgroundColor: Colors.amber),
      body: myOrders.isEmpty 
        ? const Center(child: Text("尚無訂單紀錄"))
        : ListView.builder(
            itemCount: myOrders.length,
            itemBuilder: (context, index) {
              final o = myOrders[index];
              int total = o['totalPrice'] ?? 0;
              // 統一優惠邏輯：滿百九折
              int finalPrice = total >= 100 ? (total * 0.9).round() : total;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.amber),
                  title: Text("${o['orderTime']}"),
                  subtitle: Text("餐點: ${o['items']}\n應付金額: \$$finalPrice (原價: \$$total)"),
                  isThreeLine: true,
                  trailing: const Icon(Icons.cloud_done, color: Colors.green),
                ),
              );
            },
          ),
    );
  }
}