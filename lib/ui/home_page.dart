import 'package:flutter/material.dart';
import 'package:jeusetmatch/dto/constant.dart';
import 'package:jeusetmatch/ui/sign_in.dart';
import 'package:jeusetmatch/ui/sign_up.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  final String title = 'TrainApp';

  @override
  State<HomePage> createState() => _MainPageState();
}

class _MainPageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    var myColumn  = Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // GIF Image from assets
                      Image.asset(
                        'assets/images/home_page_img.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Constante.FOREHAND,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignIn()),
                    );
                  },
                  child: Center(
                    child: Text(
                      Constante.LOGIN_VERB,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(height: 16,),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUp()),
                    );
                  },
                  child: Center(
                    child: Text(
                      Constante.MY_ACCOUNT,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
              ],
            )
          )
        ]
    );

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(widget.title),
        ),
        body: myColumn
    );
  }
}
