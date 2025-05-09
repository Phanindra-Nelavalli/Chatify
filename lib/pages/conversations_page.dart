import 'dart:async';
import 'package:chatify/models/converstaion.dart';
import 'package:chatify/models/message.dart';
import 'package:chatify/pages/FullScreenInageView.dart';
import 'package:chatify/services/cloud_storage_service.dart';
import 'package:chatify/services/db_service.dart';
import 'package:chatify/services/media_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import './../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shared_preferences/shared_preferences.dart';

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
  String _messageText = "";
  SharedPreferences? _prefs;
  Set<String> _pendingMessageIds = {};
  bool isImageUploading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingMessages();
  }

  Future<void> _loadPendingMessages() async {
    _prefs = await SharedPreferences.getInstance();
    final pendingMessageIds =
        _prefs!.getStringList('pending_msg_${widget.conversationID}') ?? [];

    setState(() {
      _pendingMessageIds = pendingMessageIds.toSet();
    });
  }

  ScrollController _listViewController = ScrollController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AuthProvider _auth;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.receiverImage),
              radius: 15.0,
            ),
            SizedBox(width: 8),
            Text(widget.receiverName),
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
      builder: (BuildContext context) {
        _auth = Provider.of<AuthProvider>(context);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _messagesListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _messageField(context),
            ),
          ],
        );
      },
    );
  }

  Widget _messagesListView() {
    if (_prefs == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      height: _height * 0.75,
      width: _width,
      child: StreamBuilder<Conversations>(
        stream: DBService.instance.getConversation(widget.conversationID),
        builder: (context, snapshot) {
          Timer(Duration(milliseconds: 50), () {
            if (_listViewController.hasClients) {
              _listViewController.jumpTo(
                _listViewController.position.maxScrollExtent,
              );
            }
          });

          var conversationData = snapshot.data;

          if (conversationData != null) {
            if (conversationData.messages.isNotEmpty) {
              return ListView.builder(
                controller: _listViewController,
                itemCount: conversationData.messages.length,
                itemBuilder: (context, index) {
                  var msg = conversationData.messages[index];
                  bool isOwner = msg.senderID == _auth.user?.uid;

                  String messageId =
                      "${msg.message}_${msg.timestamp.millisecondsSinceEpoch}";

                  return Padding(
                    padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment:
                          isOwner
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                      children: [
                        msg.type == MessageType.Text
                            ? _textMessageBubble(
                              isOwner,
                              msg.message,
                              msg.timestamp,
                              _pendingMessageIds.contains(messageId),
                            )
                            : _imageMessageBubble(
                              isOwner,
                              msg.message,
                              msg.timestamp,
                            ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                  "No Conversations Yet!",
                  style: TextStyle(color: Colors.white60),
                ),
              );
            }
          } else {
            return SpinKitWanderingCubes(color: Colors.blue, size: 50);
          }
        },
      ),
    );
  }

  Widget _textMessageBubble(
    bool isOwner,
    String msg,
    Timestamp time,
    bool isPending,
  ) {
    List<Color> colors =
        isOwner
            ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
            : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];

    return Container(
      padding: EdgeInsets.all(10),
      width: _width * 0.75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          stops: [0.3, 0.7],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(msg, style: TextStyle(fontSize: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                timeago.format(time.toDate()),
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(width: 5),
              Icon(
                isPending ? Icons.access_time : Icons.done_all,
                color: Colors.white70,
                size: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(bool isOwner, String url, Timestamp time) {
    List<Color> colors =
        isOwner
            ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
            : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          stops: [0.3, 0.7],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageView(imageUrl: url),
                ),
              );
            },
            child: Container(
              height: _height * 0.3,
              width: _width * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                timeago.format(time.toDate()),
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(width: 5),
              Icon(Icons.done_all, color: Colors.white70, size: 15),
            ],
          ),
        ],
      ),
    );
  }

  Widget _messageField(BuildContext context) {
    return Container(
      height: _height * 0.08,
      margin: EdgeInsets.symmetric(
        horizontal: _height * 0.01,
        vertical: _width * 0.05,
      ),
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(100),
      ),
      child:
          isImageUploading
              ? Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitThreeBounce(color: Colors.white, size: 20.0),
                    SizedBox(width: 12),
                    Text(
                      "Uploading Image...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
              : Form(
                key: _formKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _messageTextField(),
                    _sendButton(context),
                    _mediaAccessButton(),
                  ],
                ),
              ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _width * 0.55,
      child: TextFormField(
        autocorrect: false,
        validator:
            (val) =>
                val == null || val.trim().isEmpty
                    ? "Please enter a message"
                    : null,
        onChanged: (val) {
          _messageText = val;
        },
        decoration: InputDecoration(
          hintText: "Message",
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _sendButton(BuildContext context) {
    return Container(
      height: _height * 0.05,
      width: _height * 0.05,
      child: IconButton(
        icon: Icon(Icons.send),
        color: Colors.white,
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            String msg = _messageText.trim();
            _formKey.currentState!.reset();
            FocusScope.of(context).unfocus();

            // Create a unique message ID with timestamp and content
            final timestamp = Timestamp.now();
            final uniqueId = "${msg}_${timestamp.millisecondsSinceEpoch}";

            // Add to pending messages
            _pendingMessageIds.add(uniqueId);
            await _prefs!.setStringList(
              'pending_msg_${widget.conversationID}',
              _pendingMessageIds.toList(),
            );

            print("Pending messages: ${_pendingMessageIds.toList()}");

            setState(() {}); // show access_time icon immediately

            try {
              await DBService.instance.sendMessage(
                widget.conversationID,
                Message(
                  message: msg,
                  senderID: _auth.user!.uid,
                  timestamp: timestamp,
                  type: MessageType.Text,
                ),
              );

              _pendingMessageIds.remove(uniqueId);
              await _prefs!.setStringList(
                'pending_msg_${widget.conversationID}',
                _pendingMessageIds.toList(),
              );
              print(
                "Pending messages after update: ${_pendingMessageIds.toList()}",
              );

              setState(() {}); // update icon to done_all
            } catch (e) {
              // Optionally handle send error
              print("Error sending message: $e");
            }
          }
        },
      ),
    );
  }

  Widget _mediaAccessButton() {
    return Container(
      height: _height * 0.05,
      width: _height * 0.05,
      child: FloatingActionButton(
        onPressed: () async {
          setState(() {
            isImageUploading = true;
          });

          try {
            var _image = await MediaService.instance.getImageFromLibrary();

            // ignore: unnecessary_null_comparison
            if (_image == null) {
              setState(() {
                isImageUploading = false;
              });
              return;
            }

            String? _imageURL = await CloudStorageService.instance
                .uploadMediaMessage(_auth.user!.uid, _image);

            // ignore: unnecessary_null_comparison
            if (_imageURL == null) {
              setState(() {
                isImageUploading = false;
              });
              return;
            }

            await DBService.instance.sendMessage(
              this.widget.conversationID,
              Message(
                message: _imageURL,
                senderID: _auth.user!.uid,
                timestamp: Timestamp.now(),
                type: MessageType.Image,
              ),
            );
          } catch (e) {
            // Optional: print or log error
            print("Error selecting or uploading image: $e");
          } finally {
            // Always reset upload flag
            setState(() {
              isImageUploading = false;
            });
          }
        },
        shape: CircleBorder(),
        child: Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
