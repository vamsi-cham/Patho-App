
import 'dart:isolate';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';


class DownloadReport extends StatefulWidget {
  final String filename;
  DownloadReport({Key key, @required this.filename }) : super(key: key);
  @override
  _DownloadReportState createState() => _DownloadReportState();
}

class _DownloadReportState extends State<DownloadReport> {

  int progress = 0;


  ReceivePort _receivePort = ReceivePort();

  static downloadingCallback(id, status, progress) {
    SendPort sendPort = IsolateNameServer.lookupPortByName("downloading");
    sendPort.send([id, status, progress]);
  }


  @override
  void initState() {

    super.initState();

    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "downloading");

    _receivePort.listen((message) {
        progress = message[2];
      print(progress);
    });
    FlutterDownloader.registerCallback(downloadingCallback);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Download report',
          style: GoogleFonts.montserrat(color: Colors.black , fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            }
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
      ),
      body: widget.filename == "not uploaded" ? Center(
        child: Text(
          "\nYour lab supervisor\n didn't upload your report yet",
          style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ):Center(
        child: Column(
          children: [
            Spacer(),
            Text(widget.filename),
            ElevatedButton(
                onPressed: () async{
                  final status = await Permission.storage.request();
                  //downloadreport();
                  if(status.isGranted) {
                    var path = await ExtStorage
                        .getExternalStoragePublicDirectory(
                        ExtStorage.DIRECTORY_DOWNLOADS);
                    print(path);
                    await FlutterDownloader.enqueue(
                      url: 'http://app.mnds.tech/testlab_restapi/reports/${widget.filename}',
                      savedDir: path,
                      showNotification: true,
                      // show download progress in status bar (for Android)
                      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
                    );
                    Fluttertoast.showToast(
                        msg: "Report will be saved in $path" ,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 4,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  } else {
                    print("Permission deined");
                  }
                },
                child: Text('Download'),
            ),
            Spacer(),
          ],
        ),
      )
      //widget.filename == "not uploaded",
    );
  }
}
