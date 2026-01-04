import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminStorePage extends StatelessWidget {
  const AdminStorePage({super.key});

  Future<List<Map<String, dynamic>>> _fetchAll() async {
    const String url = "https://orderapp-e60fb-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200 && response.body != 'null') {
      Map<String, dynamic> data = json.decode(response.body);
      return data.values.map((v) => Map<String, dynamic>.from(v)).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("店家端後台"), backgroundColor: Colors.amber),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data ?? [];
          return Column(
            children: [
              Container(
                color: Colors.amber, width: double.infinity, padding: const EdgeInsets.all(10),
                child: Text("清單筆數 : ${orders.length}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    int total = order['totalPrice'] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("姓名 : ${order['customerName']}"),
                          Text("總金額 : $total"),
                          Text(total >= 100 ? "優惠價 : ${(total * 0.9).toInt()}" : "優惠價 : 未達100元,無優惠!", style: const TextStyle(color: Colors.red)),
                          const Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}