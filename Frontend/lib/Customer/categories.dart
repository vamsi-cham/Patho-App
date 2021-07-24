import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:test_lab/Customer/booktest.dart';
import 'package:test_lab/Customer/myorders.dart';
import 'package:test_lab/api/ApiUrl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

var categories = [];

class _CategoriesState extends State<Categories> {
  String query = '';

  Future getcategories() async{

    var response = await http.post(Uri.parse(ApiUrl.baseurl+"getcategories.php"),body:{

      "tb" : "subcategory",
      "action" : "getcategories"

    });

    var data = json.decode(response.body);
    print(data);

    if(data['status']==200){
      setState(() {
        categories = data['data'];
      });

    }
  }

  @override
  void initState() {
    getcategories();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    final controller = TextEditingController();
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height ) / 10;
    final double itemWidth = size.width / 6;

    return Scaffold(

      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Book Test',
          style: GoogleFonts.montserrat(color: Colors.black , fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.calendar_view_day),color: Colors.blue,iconSize: 24, onPressed: () {

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyOrders()),
            );

          }),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,

      ),
      body: RefreshIndicator(
        onRefresh: getcategories,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children:<Widget> [
                  Row(
                    children: [
                      Spacer(),
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage("https://image.flaticon.com/icons/png/512/2721/2721006.png") ,
                      ),
                      Spacer(),
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage("https://image.flaticon.com/icons/png/512/2037/2037992.png") ,
                      ),
                      Spacer(),
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage("https://image.flaticon.com/icons/png/512/1611/1611427.png") ,
                      ),
                      Spacer(),
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage("https://image.flaticon.com/icons/png/128/2764/2764557.png") ,
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 10,),
                  StickyHeader(
                    header: Container(
                      height: 42,
                      //margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: Colors.blue,width: 2),
                      ),
                      // padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.local_hospital,
                            color: Colors.blue,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: (){
                              if(controller.text.isNotEmpty){


                              }
                            },
                          ),
                          hintText: 'Search a test or Lab',
                          hintStyle: GoogleFonts.montserrat(),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    content: Column(
                      children:<Widget> [
                        SizedBox(height: 20,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                "Category",
                                style: GoogleFonts.montserrat(
                                  color: Colors.blueGrey,
                                  fontSize: 16.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        GridView.builder(
                          itemCount: categories.length,
                          gridDelegate:  new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: (itemWidth / itemHeight),),
                          primary: false,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return new GestureDetector(
                              child: Card(
                                color: Colors.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,

                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => BookTest(category: categories[index]['subcategory'] )),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.network(
                                        categories[index]['image'],
                                        //fit: BoxFit.fitWidth,
                                        width:70 ,
                                      ),
                                      //NetworkImage('https://image.flaticon.com/icons/png/512/1616/1616531.png');
                                      //SvgPicture.asset('assets/medical-doctor.svg',height: 100,),
                                      Text(
                                        categories[index]['subcategory'],
                                        style: GoogleFonts.montserrat(
                                            color: Colors.white,fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),

                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
