import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:simple_permissions/simple_permissions.dart';

List<CameraDescription> cameras;

Permission permissionFromString(String value) {
  Permission permission;
  for (Permission item in Permission.values) {
    if (item.toString() == value) {
      permission = item;
      break;
    }
  }
  return permission;
}

void main() async {
  cameras = await availableCameras();

  await SimplePermissions.requestPermission(
      permissionFromString('Permission.WriteExternalStorage'));
  await SimplePermissions.requestPermission(
      permissionFromString('Permission.Camera'));

  runApp(new MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  CameraController controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Permission _permissionCamera;
  Permission _permissionStorage;

  @override
  void initState() {
    super.initState();
    controller = new CameraController(cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        //TO DO - Anything we want
      });
    });

    _permissionStorage =
        permissionFromString('Permission.WriteExternalStorage');
    _permissionCamera = permissionFromString('Permission.Camera');
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<String> saveImage() async {
    String timeStamp = new DateTime.now().millisecondsSinceEpoch.toString();
    String filePath = '/storage/emulated/0/Pictures/$timeStamp.jpg';

    if (controller.value.isTakingPicture) return null;
    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      showInSnackBar(e.toString());
    }
    return filePath;
  }

  void takePictures() async{
    bool hasCamera = await SimplePermissions.checkPermission(_permissionStorage);
    bool hasStogare= await SimplePermissions.checkPermission(_permissionStorage);

    if(!hasCamera || !hasStogare){
      showInSnackBar("No Permission to access camera !!!");
      return;
    }

    saveImage().then((String filePath){
      if(mounted && filePath != null){
        showInSnackBar("Image saved to $filePath");
      }
    });

}

  void showInSnackBar(String message){
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Camera App"),
      ),
      body: Container(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: takePictures,
                    child: Text("Click!!!"),
                  ),
                  RaisedButton(
                    onPressed: SimplePermissions.openSettings,
                    child: Text("Settings"),
                  )
                ],
              ),
              AspectRatio(
                aspectRatio: 1.0,
                child: CameraPreview(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
