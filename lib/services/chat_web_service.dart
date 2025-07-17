//in this class i aim to achieve 2 methods
//1.connect->connect to the backend server(setting up the connection)
//2.chat->to perform search operation on the backend server
import 'package:web_socket_client/web_socket_client.dart';
import 'dart:convert';
import 'dart:async';
import '../config/config.dart';

class ChatWebService {
  static final _instance =
      ChatWebService._internal(); //2.creating a static instance of the class
  WebSocket? _socket; //making it a private variable.also,it can be nullable

  factory ChatWebService() =>
      _instance; //3.factory constructor is used to return the instance of the class

  ChatWebService._internal(); //1.making it a private constructor
  //now i will create a  instance of this CWS class so that we can manage the instance only within the class

//steps i done to ensure this class is singleton:-
//1.made the constructor private-(this prevents the class from being instantiated from outside(externally))
//2.created a static instance variable of the class-which ensures that only one object of ChatWebService exists
//3.created a factory constructor-which returns the instance of the class
//so whenever i create an instance of this class, it will return the same instance of the class(ensured by 3rd point)

  final _searchResultController = StreamController<
      Map<String, dynamic>>(); //this will be used to store the search results
  final _contentController = StreamController<
      Map<String,
          dynamic>>(); //keeps track of all the content that gemini is sending to us

  //i would now have 2 public getters that will expose the stream from here since stream controllers are not exposed outside since that can be dangerous
  //u don't want anyone else controlling ur stream ,only member within class can control or modify it

  Stream<Map<String, dynamic>> get searchResultStream => _searchResultController
      .stream; //fix this error by giving type to the Stream controllers above
  Stream<Map<String, dynamic>> get contentStream => _contentController
      .stream; //fix this error by giving type to the Stream controllers above

//now based on the data at type i want to add to a particular controller

  void connect() {
    //in this i will connect to the backend and start listening to the particular websocket port so that whenever the server start sending message
    //to us,we listen to them and store them with us

    _socket = WebSocket(Uri.parse(Config
        .chatWebSocketUrl)); //u can also store the data in dotenv file and the retrieve here
    //socket is connected now we need to listen to the messages
    _socket!.messages.listen((message) {
      //!->since it is no longer nullable

      final data =
          json.decode(message); //decode will convert the json string to map
      // print(data['type']); //every msg that i send has a type

      //now based on the data at type i want to add to a particular controller
      if (data['type'] == 'search_result') {
        _searchResultController
            .add(data); //passsing the entire data map that we get
      } else if (data['type'] == 'content') {
        _contentController.add(data);
      }
    });
    //since i already k that message will be in json or map so i can convert it to json format or map and then use it(we have send_json in main.py)
  }

  void chat(String query) {
    //basically tells the server that hey listen the sent button was clicked ,so send the query over to the websocket and then our connect fxn is anyways listening to all the data
    //whenever the user clicks the send(->) button,we will send the query to the server
    print(query);
    print(_socket);

    _socket!.send(json.encode({
      'query': query
    })); //socket is not null since we assume that connect is always called before chat is called
    //but still a possibility exists that chat is called before connect is called so we can use assert to check that

    //error-can't directly send a map to the server,so we need to convert it to json,i.e json.encode
  }
}
//now we can use this chatwebservice class in our home_page.dart file to connect 
//then call the chat fxn on other widget to send the query to the server
//and listen to these messages or actually get the messages on some other page