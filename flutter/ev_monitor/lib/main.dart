import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';

Color darkGrey = Color(0xFF111111);
void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: darkGrey));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Flutter Demo',
    theme: ThemeData.dark().copyWith(
      primaryColor: Colors.green[400],
      accentColor: Colors.red[400],
      scaffoldBackgroundColor: darkGrey,
    ),
    home: DisplayPage(),
  );
}

class DisplayPage extends StatefulWidget{
  final String title;
  const DisplayPage({Key key, this.title}) : super(key: key);
  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  Timer timer;
  bool isCharging = false;
  double percentage = 0;
  @override
  void initState() {
    super.initState();
    timer = new Timer.periodic(Duration(seconds: 5), (timer) => fetchData());
  }
  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          CircularPercentIndicator(
            startAngle: 0,
            radius: 240.0,
            lineWidth: 24.0,
            percent: percentage / 100,
            center: Text('${percentage.toInt()}%', style: percentageStyle,),
            progressColor: color,
            backgroundColor: Colors.grey[900],
          ),
          Spacer(),
          Icon(icon, size: 100, color: color,),
          Text( label, style: labelStyle,),
          Spacer(),
        ],
      ),
    )
  );
  get color => isCharging ? Theme.of(context).primaryColor : Theme.of(context).accentColor;
  get label => isCharging ?  'Connected' : 'Disconnected';
  get labelStyle => Theme.of(context).textTheme.headline6.copyWith(color: color);
  get percentageStyle => Theme.of(context).textTheme.headline3;
  get icon => isCharging ? Icons.flash_on_rounded : Icons.flash_off_rounded;

  fetchData() => http.
  get(
    Uri.
    parse('https://api.thingspeak.com/channels/1365815/feeds.json?results=1',),).
  then((response) {
    List<dynamic> feeds = json.decode(response.body)['feeds'];
    if(feeds.length > 0) setState(() {
      isCharging = (feeds[0]['field1'] as String) == '1';
      percentage = double.parse(feeds[0]['field2'] as String);
    });
  });
}
