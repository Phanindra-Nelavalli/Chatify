import 'package:chatify/models/converstaion.dart';
import 'package:chatify/services/db_service.dart';
import 'package:chatify/services/media_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import './../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationsPage extends StatefulWidget {
  final String conversationID;
  final String receiverID;
  final String receiverName;
  final String receiverImage;

  ConversationsPage(
    this.conversationID,
    this.receiverID,
    this.receiverImage,
    this.receiverName,
  );

  @override
  State<StatefulWidget> createState() {
    return _ConversationPageState();
  }
}

class _ConversationPageState extends State<ConversationsPage> {
  late double _height;
  late double _width;

  late AuthProvider _auth;
  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(this.widget.receiverImage),
              radius: 15.0,
            ),
            SizedBox(width: 8),
            Text(this.widget.receiverName),
          ],
        ),
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationUI(),
      ),
    );
  }

  Widget _conversationUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _messagesListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _messageField(_context),
            ),
          ],
        );
      },
    );
  }

  Widget _messagesListView() {
    return Container(
      height: _height * 0.75,
      width: _width,
      child: StreamBuilder<Conversations>(
        stream: DBService.instance.getConversation(this.widget.conversationID),
        builder: (BuildContext _context, _snapshot) {
          var _conversationData = _snapshot.data;
          if (_conversationData != null) {
            return ListView.builder(
              itemCount: _conversationData.messages.length,
              itemBuilder: (BuildContext _context, int _index) {
                var _messages = _conversationData.messages[_index];
                bool _isOwnerMessage = _messages.senderID == _auth.user?.uid;
                return Padding(
                  padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment:
                        _isOwnerMessage
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _textMessageBubble(
                        _isOwnerMessage,
                        _messages.message,
                        _messages.timestamp,
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return SpinKitWanderingCubes(color: Colors.blue, size: 50);
          }
        },
      ),
    );
  }

  Widget _textMessageBubble(
    bool _isOwnerMessage,
    String _message,
    Timestamp _timestamp,
  ) {
    List<Color> _colorScheme =
        _isOwnerMessage
            ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
            : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    return Container(
      height: _height * 0.07,
      width: _width * 0.75,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_message, style: TextStyle(fontSize: 16)),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              timeago.format(_timestamp.toDate()),
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageField(BuildContext _context) {
    return Container(
      height: _height * 0.08,
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _height * 0.01,
        vertical: _width * 0.05,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _messageTextField(),
          _sendButton(_context),
          _mediaAccessButton(),
        ],
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _width * 0.55,
      child: TextFormField(
        autocorrect: false,
        validator: (_input) {
          if (_input == 0) {
            return "Please Enter a Message";
          }
          return null;
        },
        onSaved: (_input) {},
        decoration: InputDecoration(
          hintText: "Message",
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _sendButton(BuildContext _context) {
    return Container(
      height: _height * 0.05,
      width: _height * 0.05,
      child: IconButton(
        icon: Icon(Icons.send),
        color: Colors.white,
        onPressed: () {},
      ),
    );
  }

  Widget _mediaAccessButton() {
    return Container(
      height: _height * 0.05,
      width: _height * 0.05,
      child: FloatingActionButton(
        onPressed: () {
          MediaService.instance.getImageFromLibrary();
        },
        shape: CircleBorder(),
        child: Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
