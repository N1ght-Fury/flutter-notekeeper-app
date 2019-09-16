import 'package:flutter/material.dart';

import './screens/note_detail.dart';
import './screens/note_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Keeper',
      debugShowCheckedModeBanner: false,
      home: NoteList(),
    );
  }
}