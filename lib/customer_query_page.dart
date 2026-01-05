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
    // 1. 先讀本地
    final local = await SqliteHelper.getLocalOrders();
    _filterAndSet(local);

    // 2. 同步雲端
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
      print("離線模式");
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
      appBar: AppBar(title: const Text("我的點餐快取"), backgroundColor: Colors.amber),
      body: ListView.builder(
        itemCount: myOrders.length,
        itemBuilder: (context, index) {
          final o = myOrders[index];
          return ListTile(
            title: Text(o['orderTime']),
            subtitle: Text("金額: ${o['totalPrice']} 元"),
            trailing: const Icon(Icons.cloud_done, color: Colors.green),
          );
        },
      ),
    );
  }
}