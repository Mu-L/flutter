// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';

/// Flutter code sample for custom labeled radio.

void main() => runApp(const LabeledRadioApp());

class LabeledRadioApp extends StatelessWidget {
  const LabeledRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Custom Labeled Radio Sample')),
        body: const LabeledRadioExample(),
      ),
    );
  }
}

class LinkedLabelRadio extends StatelessWidget {
  const LinkedLabelRadio({
    super.key,
    required this.label,
    required this.padding,
    required this.value,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Radio<bool>(value: value),
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  debugPrint('Label has been tapped.');
                },
            ),
          ),
        ],
      ),
    );
  }
}

class LabeledRadioExample extends StatefulWidget {
  const LabeledRadioExample({super.key});

  @override
  State<LabeledRadioExample> createState() => _LabeledRadioExampleState();
}

class _LabeledRadioExampleState extends State<LabeledRadioExample> {
  bool _isRadioSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RadioGroup<bool>(
        groupValue: _isRadioSelected,
        onChanged: (bool? newValue) {
          setState(() {
            _isRadioSelected = newValue!;
          });
        },
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LinkedLabelRadio(
              label: 'First tappable label text',
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              value: true,
            ),
            LinkedLabelRadio(
              label: 'Second tappable label text',
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              value: false,
            ),
          ],
        ),
      ),
    );
  }
}
