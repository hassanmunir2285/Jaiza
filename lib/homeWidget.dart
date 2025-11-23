import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class homeWidget extends StatefulWidget {
  const homeWidget({super.key});

  @override
  State<homeWidget> createState() => _homeWidgetState();
}

class _homeWidgetState extends State<homeWidget> {
  String appGroupId = "group.homeScreenApp";
  String iOSWidgetName = "MyHomeWidget";
  String androidWidgetName = "MyHomeWidget";
  String dataKey = "text_from _flutter_app";

  @override void initState() {
    // TODO: implement initState
    super.initState();
    // initilize home widget with group id
    HomeWidget.setAppGroupId(appGroupId);
  }
  @override
  Future<void> setState(VoidCallback fn) async {
    // TODO: implement setState
    super.setState(fn);
    // save widget data
    String prayerTime = "";
    await HomeWidget.saveWidgetData<String>(dataKey, prayerTime);
    // update widget after data is saved
  await HomeWidget.updateWidget(iOSName: iOSWidgetName,
      androidName: androidWidgetName);

  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
