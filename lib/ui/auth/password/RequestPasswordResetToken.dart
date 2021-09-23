import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';

class RequestPasswordResetToken extends StatefulWidget {
  const RequestPasswordResetToken({Key? key}) : super(key: key);

  @override
  _RequestPasswordResetTokenState createState() =>
      _RequestPasswordResetTokenState();
}

class _RequestPasswordResetTokenState extends State<RequestPasswordResetToken> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        elevation: 0.0,
      ),
      body: Form(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25, top: 16),
              child: Text(
                'Request password reset token',
                style: TextStyle(
                  color: ColorPalette.black,
                  fontSize: 24,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.next,
                  validator: null,
                  onSaved: (val) {},
                  style: TextStyle(
                    fontSize: 17,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Colors.blue,
                  decoration: InputDecoration(
                    contentPadding: new EdgeInsets.only(left: 16, right: 16),
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      fontSize: 17,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).errorColor),
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).errorColor),
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, right: 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Reset password',
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      side: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Get token',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
