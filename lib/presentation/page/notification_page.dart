import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                height: 60,
                color: index % 2 == 0 ? Colors.grey : Colors.grey.shade300,
                child: const Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                      'Your order Number 1000AA1000213456 has been shipped'),
                )),
              );
            }),
      ),
    );
  }
}
