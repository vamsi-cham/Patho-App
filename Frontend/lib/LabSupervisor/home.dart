import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:test_lab/LabSupervisor/customers.dart';
import 'package:test_lab/LabSupervisor/labHome.dart';
import 'package:test_lab/LabSupervisor/reports.dart';
import 'package:test_lab/main.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Spacer(),
                  IconButton(icon: Icon(Icons.help),color: Colors.blue,iconSize: 24, onPressed: () {}),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/logo.png"),
                    //fit: BoxFit.cover,
                  ),
                ),

              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Add patients to your test lab by sharing the lab ID",
                  style: GoogleFonts.montserrat(
                    color: Colors.blueGrey,
                    fontSize: 19.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Your Lab",
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Spacer(),
                  TextButton.icon(
                      onPressed: () async{

                        final box = context.findRenderObject() as RenderBox;
                        await Share.share("You have been invited by ${user[0]['name']} to join test lab ${user[0]['lab_name']}\n\nEnroll to patho using:\n$invitelink\n\nJoining ID - ${user[0]['lab_id']} ",
                            subject: user[0]['lab_id'],
                            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
                      },
                      icon: Icon(
                        Icons.add,
                        size: 19,
                        color: Colors.blue,
                      ),
                      label: Text(
                        'Invite customers',
                        style: GoogleFonts.montserrat(color: Colors.blue,fontSize: 16,),

                      )
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // if you need this
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(

                        title: Row(
                          children: [
                            Text(
                              '${user[0]['lab_name']}',
                              style: GoogleFonts.montserrat(color: Colors.black,fontSize: 18,),

                            ),
                            Spacer(),
                            IconButton(icon: Icon(Icons.arrow_forward_ios),color: Colors.blue,iconSize: 18, onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Reports()),
                              );
                            }),
                          ],
                        ),
                        subtitle: Text(
                          '${user[0]['lab_type']}',
                          style: GoogleFonts.montserrat(color: Colors.grey,fontSize: 14,),

                        ),
                      ),
                      Row(
                        children: [
                          Spacer(),
                          TextButton.icon(
                              onPressed: () async{

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Customers()),
                                );
                                //shareinvite();
                              },
                              icon: Icon(
                                Icons.notifications,
                                size: 19,
                                color: Colors.blue,
                              ),
                              label: Text(
                                'Join requests',
                                style: GoogleFonts.montserrat(color: Colors.blue,fontSize: 16,),

                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
