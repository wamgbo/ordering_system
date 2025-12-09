// lib/order_page.dart
import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我要點餐')),
      body: const Center(child: Text('這裡是點餐頁面', style: TextStyle(fontSize: 30))),
    );
  }
}