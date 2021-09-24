import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/ui/widgets/custom_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget displayCircleImage(String picUrl, double size, hasBorder) => CachedNetworkImage(
      height: size,
      width: size,
      imageBuilder: (context, imageProvider) => _getCircularImageProvider(imageProvider, size, false),
      imageUrl: picUrl,
      placeholder: (context, url) => _getPlaceholderOrErrorImage(size, hasBorder),
      errorWidget: (context, url, error) => _getPlaceholderOrErrorImage(size, hasBorder),
    );

Widget _getPlaceholderOrErrorImage(double size, hasBorder) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xff7c94b6),
        borderRadius: new BorderRadius.all(new Radius.circular(size / 2)),
        border: new Border.all(
          color: Colors.white,
          style: hasBorder ? BorderStyle.solid : BorderStyle.none,
          width: 2.0,
        ),
      ),
      child: ClipOval(
          child: Image.asset(
        'assets/images/placeholder.jpg',
        fit: BoxFit.cover,
        height: size,
        width: size,
      )),
    );

Widget _getCircularImageProvider(ImageProvider provider, double size, bool hasBorder) {
  return ClipOval(
      child: Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
        borderRadius: new BorderRadius.all(new Radius.circular(size / 2)),
        border: new Border.all(
          color: Colors.white,
          style: hasBorder ? BorderStyle.solid : BorderStyle.none,
          width: 2.0,
        ),
        image: DecorationImage(
          image: provider,
          fit: BoxFit.cover,
        )),
  ));
}

// not used yet
skipNulls<Widget>(List<Widget> items) {
  return items..removeWhere((item) => item == null);
}

Widget showEmptyState(
  String title,
  String description, {
  String? buttonTitle,
  bool? isDarkMode,
  VoidCallback? action,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(height: 30),
      Text(title, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      SizedBox(height: 15),
      Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 17),
      ),
      SizedBox(height: 25),
      if (action != null)
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  primary: Colors.blue,
                ),
                child: Text(
                  buttonTitle!,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: action),
          ),
        )
    ],
  );
}

String truncateString(String data, int length) {
  return (data.length >= length) ? '${data.substring(0, length)}...' : data;
}

pushReplacement(BuildContext context, Widget destination) {
  Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => destination));
}

push(BuildContext context, Widget destination) async {
  final result = await Navigator.of(context).push(
    new MaterialPageRoute(builder: (context) => destination),
  );
  return Future.value(result);
}

pushAndRemoveUntil(BuildContext context, Widget destination, bool predict, bool showDialog,
    [String message = '']) async {
  if (showDialog) {
    showProgressDialog(
      context,
      SimpleFontelicoProgressDialogType.normal,
      message,
      false,
      0,
    );
    await Future.delayed(Duration(seconds: 1));
  }
  Navigator.of(context)
      .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => destination), (Route<dynamic> route) => predict);
}

bool validateEmail(String value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return false;
  else
    return true;
}

bool validatePassword(String value) {
  String pattern = r'^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%^&*(),.?:{}|<>]).*';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return false;
  else
    return true;
}

String capitalizeFirstLetter(String word) {
  return word[0].toUpperCase() + word.substring(1);
}

Future<void> showProgressDialog(
  BuildContext context,
  SimpleFontelicoProgressDialogType type,
  String text,
  bool hide,
  int duration,
) async {
  SimpleFontelicoProgressDialog _dialog = SimpleFontelicoProgressDialog(
    context: context,
    barrierDimisable: false,
    duration: Duration(seconds: 1000),
  );
  _dialog.show(
    message: text,
    type: type,
    horizontal: true,
    width: 300.0,
    height: 75.0,
    hideText: false,
    indicatorColor: Colors.blue,
  );
  if (hide) {
    await Future.delayed(Duration(seconds: duration));
    _dialog.hide();
  }
}

Future<void> progressDialog(
  BuildContext context,
  SimpleFontelicoProgressDialog _dialog,
  SimpleFontelicoProgressDialogType type,
  String text,
) async {
  _dialog.show(
    message: text,
    type: type,
    horizontal: true,
    width: 300.0,
    height: 75.0,
    hideText: false,
    indicatorColor: Colors.blue,
  );
  // if (hide) {
  //   await Future.delayed(Duration(seconds: duration));
  //   _dialog.hide();
  // }
}

void hideProgressDialog(
  BuildContext context,
  SimpleFontelicoProgressDialogType type,
) {
  SimpleFontelicoProgressDialog _dialog = SimpleFontelicoProgressDialog(
    context: context,
    barrierDimisable: false,
    duration: Duration(seconds: 100),
  );
  _dialog.hide();
}

String dateTimeAgo(dateTime) {
  final date = DateTime.parse(dateTime.toDate().toString());
  return timeago.format(date);
}

String timeFromDate(dateTime) {
  final date = DateTime.parse(dateTime.toDate().toString());
  return DateFormat.jm().format(date);
}

Widget displayImage(String picUrl, double size) => CachedNetworkImage(
      imageBuilder: (context, imageProvider) => _getFlatImageProvider(imageProvider, size),
      imageUrl: picUrl,
      placeholder: (context, url) => _getFlatPlaceholderOrErrorImage(size, true),
      errorWidget: (context, url, error) => _getFlatPlaceholderOrErrorImage(size, false),
    );

Widget _getFlatImageProvider(ImageProvider provider, double size) {
  return Container(
    width: size - 50,
    height: size - 50,
    child: FadeInImage(
        fit: BoxFit.cover,
        placeholder: Image.asset(
          'assets/images/img_placeholder.png',
          fit: BoxFit.cover,
          height: size,
          width: size,
        ).image,
        image: provider),
  );
}

Widget _getFlatPlaceholderOrErrorImage(double size, bool placeholder) => Container(
      width: placeholder ? 35 : size,
      height: placeholder ? 35 : size,
      child: placeholder
          ? Center()
          : Image.asset(
              'assets/images/error_image.png',
              fit: BoxFit.cover,
              height: size,
              width: size,
            ),
    );

Color hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}

String getRandomString(int length) {
  String chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(_rnd.nextInt(chars.length)),
    ),
  );
}

int getRandomInt(int length) {
  String chars = '1234567890';
  Random _rnd = Random();
  var res = String.fromCharCodes(
    Iterable.generate(
      10,
      (_) => chars.codeUnitAt(_rnd.nextInt(chars.length)),
    ),
  );
  return int.parse(res);
}

Future<bool> saveImageToGallery(Uint8List imageBytes) async {
  await [Permission.storage].request();
  final time = DateTime.now().toIso8601String().replaceAll('.', '-').replaceAll(':', '-');
  final name = 'screenshot_$time';
  final result = await ImageGallerySaver.saveImage(imageBytes, name: name);
  return result['isSuccess'];
}

Future shareScreenshot(BuildContext context, Uint8List bytes, String text) async {
  final box = context.findRenderObject() as RenderBox?;
  final directory = await getApplicationDocumentsDirectory();
  final image = File('${directory.path}/flutter.png');
  image.writeAsBytesSync(bytes);

  final subject = 'Shared from KickChat';
  await Share.shareFiles(
    [image.path],
    text: text,
    subject: subject,
    sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  );
}

Future shareText(BuildContext context, String text) async {
  final box = context.findRenderObject() as RenderBox?;

  final subject = 'Shared from KickChat';
  await Share.share(
    text,
    subject: subject,
    sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  );
}

Future shareImage(BuildContext context, String text, String urlString) async {
  try {
    final box = context.findRenderObject() as RenderBox?;
    var url = Uri.parse(urlString);
    var response = await get(url);
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/flutter.png');
    image.writeAsBytesSync(response.bodyBytes);

    final subject = 'Shared from KickChat';
    await Share.shareFiles(
      [image.path],
      text: text,
      subject: subject,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
    return true;
  } on Exception catch (e) {
    throw (e);
  }
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String avatarColor() {
  List<String> colors = [
    '#f44336',
    '#e91e63',
    '#2196f3',
    '#9c27b0',
    '#3f51b5',
    '#00bcd4',
    '#4caf50',
    '#ff9800',
    '#8bc34a',
    '#009688',
    '#03a9f4',
    '#cddc39',
    '#2962ff',
    '#448aff',
    '#84ffff',
    '#00e676',
    '#43a047',
    '#d32f2f',
    '#ff1744',
    '#ad1457',
    '#6a1b9a',
    '#1a237e',
    '#1de9b6',
    '#d84315'
  ];
  final _random = new Random();

  // generate a random index based on the list length
  // and use it to retrieve the element
  return colors[_random.nextInt(colors.length)];
}

// For Android, this will be changed from cupertino to something else
// Cupertino widgets are for IOS
Future showCupertinoAlert(
  BuildContext context,
  String title,
  String description,
  String text,
  String cancel,
  bool showCancel,
) {
  return showCupertinoDialog(
    context: context,
    builder: (context) {
      return CustomDialogBox(
        title: title,
        descriptions: description,
        okay: text,
        cancel: cancel,
        showCancel: showCancel,
      );
    },
  );
}

Future showAlertDialog(BuildContext context, String title, String content, bool hideCancel) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('$title'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[Text('$content')],
          ),
        ),
        actions: <Widget>[
          !hideCancel
              ? TextButton(
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                )
              : Text(''),
          TextButton(
            child: const Text(
              'OK',
              style: TextStyle(fontSize: 18),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

Future<ByteData?> createProfileAvatar(Color color, Size size, String text) async {
  ui.PictureRecorder recorder = new ui.PictureRecorder();
  Canvas canvas = new Canvas(
    recorder,
    new Rect.fromPoints(
      new Offset(0.0, 0.0),
      new Offset(size.width, size.height),
    ),
  );
  final stroke = new Paint()
    ..color = Colors.grey
    ..style = PaintingStyle.stroke;

  canvas.drawRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height), stroke);

  final paint = new Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  canvas.drawPaint(paint);
  if (text != '') {
    TextSpan span = new TextSpan(
        style: new TextStyle(
          color: ColorPalette.white,
          fontWeight: FontWeight.bold,
          fontSize: 100,
        ),
        text: text[0]);
    TextPainter textPainter = new TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    final xCenter = (size.width - textPainter.width) / 2;
    final yCenter = (size.height - textPainter.height) / 2;
    final offset = Offset(xCenter, yCenter);
    textPainter.paint(canvas, offset);
  }

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  ByteData? pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
  return pngBytes;
}

Future writeBufferToFile(ByteData data) async {
  final buffer = data.buffer;
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  var filePath = tempPath + '/file_01.tmp'; // file_01.tmp is dump file, can be anything
  return new File(filePath).writeAsBytes(
    buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
}

Future convertSocialProfileUrlToImage(String urlString) async {
  var url = Uri.parse(urlString);
  var response = await get(url);
  final directory = await getApplicationDocumentsDirectory();
  final image = File('${directory.path}/flutter.png');
  image.writeAsBytesSync(response.bodyBytes);
  return image;
}

matchStatus(status, elapsed, timestamp) {
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var format = new DateFormat('hh:mm a');
  switch (status.toString()) {
    case 'NS':
      return format.format(date);
    case 'FT':
      return 'FT';
    case 'HT':
      return 'HT';
    case 'PST':
      return 'POS';
    case 'CANC':
      return 'CANC';
    case 'P':
      return 'PEN';
    case 'PEN':
      return 'PEN';
    case 'TBD':
      return 'TBD';
    case 'AET':
      return 'AET';
    case 'BT':
      return 'BT';
    case 'SUSP':
      return 'SUSP';
    case 'INT':
      return 'INT';
    case 'ABD':
      return 'ABD';
    case 'AWD':
      return 'TC';
    case 'WO':
      return 'WO';
    default:
      if (status == '1H' || status == '2H' || status == 'ET') {
        return "$elapsed'";
      }
      return elapsed;
  }
}
