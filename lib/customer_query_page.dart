import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomerQueryPage extends StatelessWidget {
  final String currentUserName;
  const CustomerQueryPage({super.key, required this.currentUserName});

  Future<List<Map<String, dynamic>>> _fetchMyOrders() async {
    const String url = "https://orderapp-e60fb-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200 && response.body != 'null') {
      Map<String, dynamic> data = json.decode(response.body);
      // 篩選姓名相符的訂單
      return data.values
          .where((item) => item['customerName'] == currentUserName)
          .map((v) => Map<String, dynamic>.from(v))
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("個人點餐紀錄"), backgroundColor: Colors.amber),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMyOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data ?? [];
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                color: Colors.grey[900],
                child: Text(item.toString(), style: const TextStyle(color: Colors.white)),
              );
            },
          );
        },
      ),
    );
  }
}