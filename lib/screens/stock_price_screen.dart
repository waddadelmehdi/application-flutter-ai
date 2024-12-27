import 'package:flutter/material.dart';

class StockPriceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Price Prediction'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          'Stock Price Prediction Logic Goes Here',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }
}
