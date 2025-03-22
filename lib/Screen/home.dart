import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget{
  @override
  _HomeScreenState createState()=> _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen>{
  List<dynamic> users = [];
  ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  @override
  void initState(){
    super.initState();
    fetchUser();

    _scrollController.addListener((){
      if(_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent && !isLoading){
        fetchUser();
      }
    });
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Random User API'),
      centerTitle: true,backgroundColor: Colors.lightBlueAccent,),

      body: users.isEmpty? Center(child: CircularProgressIndicator(),):
          ListView.builder(
            controller: _scrollController,
            itemCount: users.length + (isLoading? 1:0),
            itemBuilder: (context, index){
              if(index == users.length){
                return Center(child: CircularProgressIndicator(),);
              }

              final user = users[index];
              final name = "${user['name']['title']}. "
                  "${user['name']['first']} ${user['name']['last']}";

              final email = user['email'];
              final phone = user['phone'];
              final gender = user['gender'];
              final location = "${user['location']['city']},"
                  " ${user['location']['country']}";

              final image = user ['picture']['medium'];

              return Card(margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(image),),
                  title: Text(name,style: TextStyle(
                      color: Colors.black, fontSize: 15,
                      fontWeight: FontWeight.bold),),

                  subtitle:Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(email),
                      Text(phone),
                      Text(gender),
                      Text(location,),
                  ],) ,
                ),

              );

            }

          )
    );

  }

  void fetchUser() async {
    if(isLoading)return;

    setState(() {
      isLoading =  true;
    });

    const url = 'https://randomuser.me/api/?results=5';
    final uri = Uri.parse(url);

    try {
      final response = await http.get(uri);
      if(response.statusCode == 200){
        final body = response.body;
        final json = jsonDecode(body);

        setState(() {
          users.addAll(json['results']);
        });
      }
      else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print('Failed to fetch users: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}