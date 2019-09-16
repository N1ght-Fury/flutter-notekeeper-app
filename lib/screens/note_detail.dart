import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../models/note.dart';
import '../utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final String oldTitle;
  final String oldDescription;
  final int oldPriority;
  final Note note;
  NoteDetail(this.note, this.appBarTitle, {this.oldTitle, this.oldDescription, this.oldPriority});

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState();
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];

  DatabaseHelper databaseHelper = DatabaseHelper();

  String newTitle;
  String newDescription;
  int newPriority;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void _showWarningDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                'Some changes have been made. Would you like to apply changes?'),
            //content: Text('This acction cannot be undone.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.pop(context);
                  _save();
                },
              ),
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, false);
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog,
    );
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updatePriority(String value) {
    switch (value) {
      case 'High':
        widget.note.priority = 1;
        break;
      case 'Low':
        widget.note.priority = 2;
        break;
    }
  }

  void updateTitle() {
    widget.note.title = titleController.text;
  }

  void updateDescription() {
    widget.note.description = descriptionController.text;
  }

  void _save() async {

    int result;
    widget.note.date = DateFormat.yMMMd().format(DateTime.now());

    if (widget.note.id != null) {
      result = await databaseHelper.updateNote(widget.note);
    } else {
      result = await databaseHelper.insertNote(widget.note);
    }

    if (result != 0) {
      Navigator.pop(context, true);
      _showAlertDialog('Status', 'Note saved successfully');
    } else {
      Navigator.pop(context, false);
      _showAlertDialog('Status', 'Failed to save note');
    }
  }

  void _delete() async {

    if (widget.note.id == null) {
      _showAlertDialog('Status', 'Cant delete a note that is not exists');
      return;
    }

    int result = await databaseHelper.deleteNote(widget.note.id);

    if (result != 0) {
      Navigator.pop(context, true);
      _showAlertDialog('Status', 'Note deleted successfully');
    } else {
      Navigator.pop(context, false);
      _showAlertDialog('Status', 'Failed to delete note');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.subhead;

    titleController.text = widget.note.title;
    descriptionController.text = widget.note.description;

    return WillPopScope(
      onWillPop: () {
        if (widget.appBarTitle == 'Edit Note' &&
            (widget.note.title != widget.oldTitle ||
                widget.note.description != widget.oldDescription ||
                widget.note.priority != widget.oldPriority)) {
          try {
            print(widget.note.title.toString() + '  --  ' + widget.oldTitle.toString());
          } catch (e) {

          }
          _showWarningDialog(context);
          //print('hello asdsasad');
          //return Future.value(true);
        } else {
          print('nooo');
          Navigator.pop(context);
        }
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.appBarTitle),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15.0, right: 10.0, left: 10.0),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: DropdownButton(
                  items: _priorities.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(widget.note.priority),
                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      updatePriority(valueSelectedByUser);
                    });
                  },
                ),
              ),

              //Second Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (String value) {
                    newTitle = value;
                    updateTitle();
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),

              //Third Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (String value) {
                    newDescription = value;
                    updateDescription();
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),

              //Fourth element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            _save();
                          });
                        },
                      ),
                    ),
                    Container(width: 5.0),
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            _delete();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
