import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/models/club_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AddClubsScreen extends StatefulWidget {
  @override
  _AddClubsScreenState createState() => _AddClubsScreenState();
}

class _AddClubsScreenState extends State<AddClubsScreen> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController _clubNameController = TextEditingController();
  TextEditingController _imageNameController = TextEditingController();
  TextEditingController _countryCtrl = TextEditingController();
  String usernameSignupButton = 'Add Club';

  Future _checkIfUsernameExist() async {
    String uid = getRandomString(28);
    Club club = Club(
      id: uid,
      clubName: _clubNameController.text.trim(),
      lowercaseName: _clubNameController.text.trim().toLowerCase(),
      image: _imageNameController.text.trim(),
      league: ItemDropdownState.chosenValue,
    );
    await firestore.collection(_countryCtrl.text.toLowerCase()).doc(uid).set(club.toJson()).then(
      (value) {
        _clubNameController.text = '';
        _imageNameController.text = '';
        // _countryCtrl.text = '';
      },
      onError: (e) {
        print(e);
      },
    );
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    _imageNameController.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Sign up',
          style: TextStyle(
            color: ColorPalette.black,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            MdiIcons.chevronLeft,
            size: 30,
            color: ColorPalette.primary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: new EdgeInsets.only(left: 25, right: 25, bottom: 16),
          child: new Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30, bottom: 5),
                            child: TextFormField(
                              controller: _clubNameController,
                              textAlignVertical: TextAlignVertical.center,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(fontSize: 17),
                              keyboardType: TextInputType.text,
                              cursorColor: ColorPalette.primary,
                              decoration: InputDecoration(
                                contentPadding: new EdgeInsets.only(left: 16, right: 16),
                                hintText: 'Enter club name',
                                hintStyle: TextStyle(fontSize: 17),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                  borderSide: BorderSide(color: Colors.grey.shade200, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30, bottom: 5),
                            child: TextFormField(
                              controller: _imageNameController,
                              textAlignVertical: TextAlignVertical.center,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(fontSize: 17),
                              keyboardType: TextInputType.text,
                              cursorColor: ColorPalette.primary,
                              onChanged: (text) {},
                              decoration: InputDecoration(
                                contentPadding: new EdgeInsets.only(left: 16, right: 16),
                                hintText: 'Enter image name',
                                hintStyle: TextStyle(fontSize: 17),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                  borderSide: BorderSide(color: Colors.grey.shade200, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30, bottom: 5),
                            child: TextFormField(
                              controller: _countryCtrl,
                              textAlignVertical: TextAlignVertical.center,
                              // textInputAction: TextInputAction.next,
                              style: TextStyle(fontSize: 17),
                              keyboardType: TextInputType.text,
                              cursorColor: ColorPalette.primary,
                              onChanged: (text) {},
                              decoration: InputDecoration(
                                contentPadding: new EdgeInsets.only(left: 16, right: 16),
                                hintText: 'Enter country name',
                                hintStyle: TextStyle(fontSize: 17),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                  borderSide: BorderSide(color: Colors.grey.shade200, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  flex: 0,
                  child: ItemDropdown(
                    listItems: [
                      'English Premier League',
                      'French Ligue 1',
                      'German Bundesliga',
                      'Italian Seria A',
                      'Spanish La Liga',
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: ColorPalette.primary,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                      ),
                      onPressed: () => _checkIfUsernameExist(),
                      child: Text(
                        usernameSignupButton,
                        style: TextStyle(
                          fontSize: 18,
                          color: ColorPalette.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ItemDropdown extends StatefulWidget {
  final List<String> listItems;

  const ItemDropdown({Key? key, this.listItems: const []}) : super(key: key);
  @override
  ItemDropdownState createState() => ItemDropdownState();
}

class ItemDropdownState extends State<ItemDropdown> {
  static String chosenValue = '';

  @override
  void initState() {
    chosenValue = widget.listItems[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        margin: EdgeInsets.only(left: 10.0, top: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: ColorPalette.white,
          border: Border.all(color: ColorPalette.primary),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
              value: chosenValue,
              items: widget.listItems.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: ColorPalette.primary,
                      fontSize: 18,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  chosenValue = newValue!;
                });
              }),
        ),
      ),
    );
  }
}
