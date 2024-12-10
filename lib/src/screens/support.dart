import 'package:aps/src/constants/colors.dart';
import 'package:aps/src/constants/spacings.dart';
import 'package:aps/src/constants/texts.dart';
import 'package:flutter/material.dart';

class Support extends StatelessWidget {
  const Support({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Padding(
            padding: const EdgeInsets.all(defaultPaddingXs),
            child: Text(supportPageHeading,
                style: Theme.of(context).textTheme.displayLarge),
          ),
      ),
    );
  }
}