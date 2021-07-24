import 'dart:isolate';
import 'dart:ui';

import 'package:ext_storage/ext_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:test_lab/LabSupervisor/customers.dart';
import 'dart:convert';
import 'dart:io';
import 'package:test_lab/api/ApiUrl.dart';
import 'package:test_lab/main.dart';
import 'package:test_lab/widget/loading.dart';
import "package:async/async.dart";
import 'package:path/path.dart';

class Reports extends StatefulWidget {
  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {

  int progress = 0;


  ReceivePort _receivePort = ReceivePort();

  static downloadingCallback(id, status, progress) {
    SendPort sendPort = IsolateNameServer.lookupPortByName("downloading");
    sendPort.send([id, status, progress]);
  }

  bool loading = false;

  Future getcustomers() async {
    setState(() {
      loading = true;
    });

    var response = await http.post(
        Uri.parse(ApiUrl.baseurl + "getcustomers.php"), body: {
      "lab_id": user[0]['lab_id'],
      "approval": "accepted",
      "tb": "lab_patients",
      "action": "getcustomers"
    });
    //print('addUser Response: ${response.body}');
    var data = json.decode(response.body);

    customers = data['data'];
    setState(() {
      loading = false;
    });

  }

  @override
  void initState() {
    getcustomers();
    super.initState();

    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "downloading");

    _receivePort.listen((message) {
        progress = message[2];
      print(progress);
    });
    FlutterDownloader.registerCallback(downloadingCallback);
  }

  Future uploadreport(id,file,BuildContext context) async {

    var stream= new http.ByteStream(DelegatingStream(file.openRead()));
    var length= await file.length();
    var uri = Uri.parse(ApiUrl.baseurl+"uploadreport.php");
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile("file", stream, length, filename: basename(file.path));

    request.files.add(multipartFile);
    request.fields['patient_id'] = id;
    request.fields['tb'] = "lab_patients";
    request.fields['action'] = "uploadreport";


    var respond = await request.send();
    //print(respond.headers);
    if(respond.statusCode==200){
      print("Image Uploaded");
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Reports()),
      );
      Fluttertoast.showToast(
          msg: "uploaded successfully" ,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }else{
      print("Upload Failed");
      Fluttertoast.showToast(
          msg: "uploaded failed.please try again" ,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }

  }

  Future<void> _showMyDialog(patientID,BuildContext context) async {


    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Report',
            style: GoogleFonts.montserrat(color: Colors.blue,fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                //Text('This is a demo alert dialog.'),
                Text(
                  'Are you sure to delete the lab report ?',
                  style: GoogleFonts.montserrat(color: Colors.black,fontSize: 17),

                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Yes',
                style: GoogleFonts.montserrat(color: Colors.blue),
              ),
              onPressed: () async{

                deletereport(patientID,context);
              },
            ),
            TextButton(
              child: Text(
                'No',
                style: GoogleFonts.montserrat(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future deletereport(patientID,BuildContext context) async{


    var response = await http.post( Uri.parse(ApiUrl.baseurl + "deletereport.php"), body: {
      "patient_id": patientID,
      "report": "not uploaded",
      "tb": "lab_patients",
      "action": "deletereport"
    });

    print(response.body);

    if(response.statusCode == 200){
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Reports()),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
          appBar: AppBar(
            title: Text(
              'Customers report',
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
      body: customers.length == 0 ? Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "\nEnrolled customers (${customers.length})",
                  style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 16),
                ),
              ],
            ),
          ),
          Spacer(),
          Center(
            child: Text(
              "\nNo customers enrolled..\n\nInvite your customers by sharing \nyour lab code.",
              style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
        ],
      ) : SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    "\nEnrolled customers (${customers.length})",
                    style: GoogleFonts.montserrat(color: Colors.black ,  fontSize: 16),
                  ),
                ],
              ),
            ),
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: customers.length,
                itemBuilder: (BuildContext context,int index){

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // if you need this
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    //elevation: 4,
                    margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            radius: 22,
                            child: Text(
                              customers[index]['patient_name'][0],
                              style: GoogleFonts.montserrat(fontSize: 20),
                            ),
                          ),

                          title: Text(
                            customers[index]['patient_name'],
                            style: GoogleFonts.montserrat(color: Colors.black54 ,  fontSize: 22),
                          ),
                          subtitle: Text(
                            '${customers[index]['mobile']}',
                            style: GoogleFonts.montserrat(color: Colors.blueGrey ,  fontSize: 15),
                          ),

                        ),
                        TextButton.icon(
                          icon: customers[index]['report'] == "not uploaded" ? Icon(
                            Icons.upload_sharp,
                            size: 19,
                            color: Colors.blue,
                          ):Icon(
                              Icons.download_sharp,
                              size: 19,
                              color: Colors.blue,
                              ),
                            onPressed: customers[index]['report'] == "not uploaded" ? () async{
                                print("yes");
                                FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.custom,
                                  allowedExtensions: ['jpg', 'pdf', 'doc','docx'],);

                                if(result != null) {
                                  File file = File(result.files.single.path);
                                 // print('vamsi $file');
                                  uploadreport(customers[index]['patient_id'],file,context);
                                } else {
                                  // User canceled the picker
                                }
                            } : () async{
                              final status = await Permission.storage.request();
                              //downloadreport();
                              if(status.isGranted) {
                                var path = await ExtStorage
                                    .getExternalStoragePublicDirectory(
                                    ExtStorage.DIRECTORY_DOWNLOADS);
                                print(path);
                                await FlutterDownloader.enqueue(
                                  url: 'http://app.mnds.tech/testlab_restapi/reports/${customers[index]['report']}',
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
                            label: customers[index]['report'] == "not uploaded" ? Text(
                              'Upload report',
                              style: GoogleFonts.montserrat(color: Colors.blueGrey,fontSize: 16,),
                            ) : Text(
                              customers[index]['report'],
                              style: GoogleFonts.montserrat(color: Colors.blue,fontSize: 13,),
                            ),
                        ),
                        Visibility(
                          visible: customers[index]['report'] != "not uploaded",
                          child: TextButton.icon(
                              onPressed: (){
                                _showMyDialog(customers[index]['patient_id'],context);
                              },
                              icon: Icon(
                                Icons.delete,
                                size: 19,
                                color: Colors.blue,
                              ),
                              label: Text(
                                'Delete report',
                                style: GoogleFonts.montserrat(color: Colors.blueGrey,fontSize: 16,),
                              ),
                          ),
                        ),
                      ],
                    ),

                  );
                }
            ),
            SizedBox(height: 70,),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final box = context.findRenderObject() as RenderBox;


          await Share.share("You have been invited by ${user[0]['name']} to join test lab ${user[0]['lab_name']}\n\n Joining ID - ${user[0]['lab_id']} ",
              subject: user[0]['lab_id'],
              sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
        },
        label:  Text(
          'Invite customers',
          style: GoogleFonts.montserrat(color: Colors.white,  fontSize: 16),
        ),
        icon: const Icon(Icons.share),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );
  }
}
