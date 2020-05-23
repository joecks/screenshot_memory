import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot_memory/views/strings.dart';

class FtuBloc {
  FtuBloc() {
    _permissionController.sink.add("Checking permissions...");
    check();
  }

  void check() {
    checkAccessImagesPermissions().then((hasPermission) {
      _permissionController.sink.add(hasPermission
          ? "All permissions granted"
          : "Need to grand permissions!");
    });
  }

  final _permissionController = StreamController<String>();

  Stream<String> get permissionGrantedStream => _permissionController.stream;

  static Future<bool> checkAccessImagesPermissions() async {
    final permission =
        (Platform.isIOS) ? Permission.mediaLibrary : Permission.storage;
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    } else {
      return (await permission.request()).isGranted;
    }
  }

  //TODO call
  void dispose() {
    _permissionController.close();
  }

  void onRecheckPermissionClicked() {
    check();
  }
}

class FtuPage extends StatelessWidget {
  static const routeName = "/ftu";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Consumer<FtuBloc>(
                  builder: (context, bloc, child) {
                    return StreamBuilder<String>(
                      stream: bloc.permissionGrantedStream,
                      builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) =>
                          FlatButton(
                              onPressed: () {
                                bloc.onRecheckPermissionClicked();
                              },
                              child: ThemedText(
                                  snapshot.hasData ? snapshot.data : "...")),
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
