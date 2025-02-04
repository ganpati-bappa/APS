import 'package:aps/src/constants/colors.dart';
import 'package:aps/src/utils.dart';
import 'package:flutter/material.dart';

class GuestHome extends StatelessWidget {
  const GuestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
              backgroundColor: backgroundColor,
              leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
            ),
      body: Container(
        color: backgroundColor,
        child: homePage(context),
      ),
    );
  }
}