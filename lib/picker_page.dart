/*
 * Copyright (c) 2021, Nikhila (Nikki) Suneel. All Rights Reserved.
 */

import 'package:flutter/material.dart';

import 'client_apis.dart';
import 'custom_app_bar.dart';
import 'bottom_navigator.dart';
import 'application_objects.dart';

class PickerPage extends StatefulWidget {

  PickerPage({Key key}) : super(key: key);

  @override
  _PickerPageState createState() => _PickerPageState();
}

class _PickerPageState extends State<PickerPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _throughputController = TextEditingController();

  int _selectedIndex = 0;
  int _selectedType = 0;
  int _pickerId = 0;
  String _nameValue = "";
  String _throughputValue = "";

  @override
  initState() {
    super.initState();
  }

  void _onItemPressed(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onTypeSelected(int type) {
    setState(() {
      _selectedType = type;
    });
  }

  void _saveFormFields() {
    setState(() {
      _nameValue = _nameController.text;
      _throughputValue = _throughputController.text;
    });
  }

  void _resetFormFields() {
    setState(() {
      _nameValue = "";
      _throughputValue = "";
      _selectedType = 0;
    });
  }

  void _onPickerSelected(Picker picker) {
    setState(() {
      _pickerId = picker.id;
      _nameValue = picker.name;
      _throughputValue = picker.throughput.toString();
      _selectedType = picker.type == "Automatic" ? 0 : 1;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameController.dispose();
    _throughputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_formKey != null && _formKey.currentState != null) {
      _formKey.currentState.reset();
    }

    _nameController.text = "";
    _throughputController.text = "";

    // A list of widgets to hold list, add and edit picker pages
    List<WidgetOptions> _formOptions = <WidgetOptions>[
      new WidgetOptions(_listWidget(), "List of Pickers"),
      new WidgetOptions(_add(), "Add a Picker"),
      new WidgetOptions(_edit(), "Edit a Picker"),
    ];

    if (_selectedIndex == 0) {
      return SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
              _formOptions
                  .elementAt(_selectedIndex)
                  .title,
              true
          ),
          body: Form(
            key: _formKey,
            child: _formOptions
                .elementAt(_selectedIndex)
                .widget,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _onItemPressed(1);
            },
            child: Icon(Icons.add),
            tooltip: 'Add',
          ),
          bottomNavigationBar: BottomNavigator(),
        ),
      );
    } else {
        return SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: CustomAppBar(
                _formOptions
                    .elementAt(_selectedIndex)
                    .title,
                true
            ),
            body: Form(
              key: _formKey,
              child: _formOptions
                  .elementAt(_selectedIndex)
                  .widget,
            ),
            bottomNavigationBar: BottomNavigator(),
          ),
        );
    }
  }

  Widget _listWidget() {
    //List<Picker> pickers = PickerDatabase.pickers;
    return FutureBuilder<List<Picker>>(
      future: getPickers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the list of pickers.
          return _buildPickerList(snapshot.data);
        } else {
          // Otherwise, display a loading indicator.
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildPickerList(List<Picker> pickers) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            // Let the ListView know how many items it needs to build.
            itemCount: pickers.length,
            // Provide a builder function. This is where the magic happens.
            // Convert each item into a widget based on the type of item it is.
            itemBuilder: (context, index) {
              final picker = pickers[index];

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        color: Colors.green,
                      ),
                      child: ListTile(
                        title: Container(
                          child: Row(
                            children: [
                              Expanded(child: Text(picker.name, style: Theme.of(context).textTheme.headline5)),
                            ],
                          ),
                        ),
                        subtitle: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: Text(picker.type, style: Theme.of(context).textTheme.subtitle1)),
                              Expanded(child: Text(picker.throughput.toString() + " balls/min", style: Theme.of(context).textTheme.subtitle1)),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _onPickerSelected(picker);
                            _onItemPressed(2);
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _add() {
    if (_nameValue != "") {
      _nameController.text = _nameValue;
    }

    if (_throughputValue != "") {
      _throughputController.text = _throughputValue;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Container(
              child: Row(
                children: [
                  Expanded(child: Text("Name", style: Theme.of(context).textTheme.headline5)),
                ],
              ),
            ),
            subtitle: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Enter a name'
                          ),
                          cursorColor: Colors.black,
                          controller: _nameController,
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                            if (value.length > 50) {
                              return "name must be 50 characters or less";
                            }
                            return null;
                          }),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Container(
              child: Row(
                children: [
                  Expanded(child: Text("Select type", style: Theme.of(context).textTheme.headline5)),
                ],
              ),
            ),
            subtitle: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child:
                      Row(
                        children: [
                          Expanded(
                            child: Radio(
                              activeColor: Colors.black,
                              value: 0,
                              groupValue: _selectedType,
                              onChanged: (value) {
                                _saveFormFields();
                                _onTypeSelected(value);
                              },
                            ),
                          ),
                          Expanded(child: Text("Automatic", style: Theme.of(context).textTheme.bodyText1)),
                          Expanded(
                            child: Radio(
                              activeColor: Colors.black,
                              value: 1,
                              groupValue: _selectedType,
                              onChanged: (value) {
                                _saveFormFields();
                                _onTypeSelected(value);
                              },
                            ),
                          ),
                          Expanded(child: Text("Manual", style: Theme.of(context).textTheme.bodyText1)),
                        ],
                      )
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Container(
              child: Row(
                children: [
                  Expanded(child: Text("Throughput", style: Theme.of(context).textTheme.headline5)),
                ],
              ),
            ),
            subtitle: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Enter a value for # of balls picked per minute'
                        ),
                        cursorColor: Colors.black,
                        controller: _throughputController,
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter an integer value';
                          }
                          int i = int.tryParse(value);
                          if (i == null) {
                            return "throughput must be an integer between 1 and 5000";
                          }
                          // Check if throughput falls
                          if (i <= 0 || i > 5000) {
                            return "throughput must be between 1 and 5000";
                          }
                          return null;
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: "SaveBtn",
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            String type = "";
                            if (_selectedType == 0) {
                              type = "Automatic";
                            } else {
                              type = "Manual";
                            }
                            Picker addedPicker = new Picker(_nameController.text,
                                type,
                                int.parse(_throughputController.text));

                            await createPicker(addedPicker);

                            _resetFormFields();
                            _onItemPressed(0);
                          }
                        },
                        child: Icon(Icons.save_alt_outlined),
                        tooltip: 'Save',
                      ),
                      FloatingActionButton(
                        heroTag: "CancelBtn",
                        onPressed: () {
                          _resetFormFields();
                          _onItemPressed(0);
                        },
                        child: Icon(Icons.cancel),
                        tooltip: 'Cancel',
                      ),
                    ]
                )
            )
        ),
      ],
    );
  }

  Widget _edit() {
    _nameController.text = _nameValue;
    _throughputController.text = _throughputValue;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Container(
              child: Row(
                children: [
                  Expanded(child: Text("Name", style: Theme.of(context).textTheme.headline5)),
                ],
              ),
            ),
            subtitle: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                        cursorColor: Colors.black,
                        controller: _nameController,
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          if (value.length > 50) {
                            return "name must be 50 characters or less";
                          }
                          return null;
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Container(
              child: Row(
                children: [
                  Expanded(child: Text("Select type", style: Theme.of(context).textTheme.headline5)),
                ],
              ),
            ),
            subtitle: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child:
                      Row(
                        children: [
                          Expanded(
                            child: Radio(
                              value: 0,
                              groupValue: _selectedType,
                              activeColor: Colors.black,
                              onChanged: (value) {
                                _saveFormFields();
                                _onTypeSelected(value);
                              },
                            ),
                          ),
                          Expanded(child: Text("Automatic", style: Theme.of(context).textTheme.bodyText1)),
                          Expanded(
                            child: Radio(
                              value: 1,
                              groupValue: _selectedType,
                              activeColor: Colors.black,
                              onChanged: (value) {
                                _saveFormFields();
                                _onTypeSelected(value);
                              },
                            ),
                          ),
                          Expanded(child: Text("Manual", style: Theme.of(context).textTheme.bodyText1)),
                        ],
                      )
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Container(
              child: Row(
                children: [
                  Expanded(child: Text("Throughput", style: Theme.of(context).textTheme.headline5)),
                ],
              ),
            ),
            subtitle: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                        cursorColor: Colors.black,
                        controller: _throughputController,
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter an integer value';
                          }
                          // Check if throughput is an integer
                          int i = int.tryParse(value);
                          if (i == null) {
                            return "throughput must be an integer between 1 and 5000";
                          }
                          // Check if throughput falls within range
                          if (i <= 0 || i > 5000) {
                            return "throughput must be between 1 and 5000";
                          }
                          return null;
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: "SaveBtn",
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            String type = "";
                            if (_selectedType == 0) {
                              type = "Automatic";
                            } else {
                              type = "Manual";
                            }

                            Picker editedPicker = new Picker(_nameController.text,
                                type,
                                int.parse(_throughputController.text)
                            );

                            editedPicker.id = _pickerId;

                            await updatePicker(editedPicker);

                            //PickerDatabase.edit(editedPicker);

                            _resetFormFields();
                            _onItemPressed(0);
                          }
                        },
                        child: Icon(Icons.save_alt_outlined),
                        tooltip: 'Save',
                      ),
                      FloatingActionButton(
                        heroTag: "CancelBtn",
                        onPressed: () {
                          _resetFormFields();
                          _onItemPressed(0);
                        },
                        child: Icon(Icons.cancel),
                        tooltip: 'Cancel',
                      ),
                    ]
                )
            )
        ),
      ],
    );
  }
}