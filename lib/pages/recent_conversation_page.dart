import 'package:chatify/models/converstaion.dart';
import 'package:chatify/pages/conversations_page.dart';
import 'package:chatify/services/db_service.dart';
import 'package:chatify/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentConversationPage extends StatefulWidget {
  final double height;
  final double width;

  RecentConversationPage({required this.height, required this.width});

  @override
  _RecentConversationPageState createState() => _RecentConversationPageState();
}

class _RecentConversationPageState extends State<RecentConversationPage> {
  final String _imageURL = "https://firebasestorage.googleapis.com/";
  SharedPreferences? _prefs;
  Map<String, Set<String>> _pendingMessagesByConvo = {};

  @override
  void initState() {
    super.initState();
    _loadPendingMessages();
  }

  Future<void> _loadPendingMessages() async {
    _prefs = await SharedPreferences.getInstance();

    // First load all keys from SharedPreferences
    final allKeys = _prefs!.getKeys();

    // Filter keys that start with 'pending_msg_'
    final pendingMsgKeys =
        allKeys.where((key) => key.startsWith('pending_msg_')).toList();

    // Load each conversation's pending messages
    for (var key in pendingMsgKeys) {
      final convoId = key.substring('pending_msg_'.length);
      final pendingMsgs = _prefs!.getStringList(key) ?? [];
      _pendingMessagesByConvo[convoId] = pendingMsgs.toSet();
    }

    if (mounted) {
      setState(() {});
    }
  }

  // Check if we need to refresh the pending messages periodically
  void _setupPeriodicRefresh() {
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        _loadPendingMessages();
        _setupPeriodicRefresh();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupPeriodicRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _recentConversationPageUI(),
      ),
    );
  }

  Widget _recentConversationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        final _auth = Provider.of<AuthProvider>(_context);

        if (_prefs == null) {
          return Center(
            child: SpinKitWanderingCubes(color: Colors.blue, size: 50),
          );
        }

        return Container(
          height: widget.height,
          width: widget.width,
          child: StreamBuilder<List<ConverstaionSnippet>>(
            stream: DBService.instance.getUserConversation(_auth.user!.uid),
            builder: (_context, _snapshot) {
              var _data = _snapshot.data;
              if (_data != null) {
                _data.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                return _data.length != 0
                    ? ListView.builder(
                      itemCount: _data.length,
                      itemBuilder: (_context, _index) {
                        final convo = _data[_index];
                        final convoId = convo.conversationID;

                        final hasPendingMessages =
                            _pendingMessagesByConvo.containsKey(convoId) &&
                            _pendingMessagesByConvo[convoId]!.isNotEmpty;

                        String? lastPendingMsgContent;

                        if (hasPendingMessages) {
                          final pendingMessages =
                              _pendingMessagesByConvo[convoId]!.toList();
                          pendingMessages.sort((a, b) {
                            final aTimestamp = int.tryParse(a.split('_').last);
                            final bTimestamp = int.tryParse(b.split('_').last);
                            return (bTimestamp ?? 0).compareTo(aTimestamp ?? 0);
                          });

                          if (pendingMessages.isNotEmpty) {
                            final lastPending = pendingMessages.first;

                            final lastUnderscoreIndex = lastPending.lastIndexOf(
                              '_',
                            );
                            if (lastUnderscoreIndex > 0) {
                              lastPendingMsgContent = lastPending.substring(
                                0,
                                lastUnderscoreIndex,
                              );
                            }
                          }
                        }

                        String displayMessage;
                        bool showPending = false;

                        if (hasPendingMessages &&
                            lastPendingMsgContent != null) {
                          displayMessage = lastPendingMsgContent;
                          showPending = true;
                        } else {
                          displayMessage = convo.lastMessage;
                        }

                        final isImage = displayMessage.contains(_imageURL);

                        return ListTile(
                          onTap: () async {
                            await Future.delayed(Duration(milliseconds: 200));
                            await NavigationService.instance.navigateToRoute(
                              MaterialPageRoute(
                                builder: (BuildContext _context) {
                                  return ConversationsPage(
                                    convo.conversationID,
                                    convo.id,
                                    convo.image,
                                    convo.name,
                                    _auth.user!.uid,
                                  );
                                },
                              ),
                            );

                            if (mounted) {
                              _loadPendingMessages();
                            }
                          },
                          title: Text(convo.name),
                          subtitle:
                              isImage
                                  ? Row(
                                    children: [
                                      convo.senderId != _auth.user!.uid
                                          ? Icon(
                                            Icons.done_all,
                                            size: 16,
                                            color:
                                                convo
                                                            .lastVisit
                                                            .microsecondsSinceEpoch >
                                                        convo
                                                            .timestamp
                                                            .microsecondsSinceEpoch
                                                    ? Colors.green
                                                    : Colors.white70,
                                          )
                                          : Container(),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.image_outlined,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 5),
                                      Text("Image"),
                                    ],
                                  )
                                  : Row(
                                    children: [
                                      convo.senderId == _auth.user!.uid
                                          ? showPending
                                              ? Icon(
                                                Icons.access_time,
                                                color: Colors.white70,
                                                size: 15,
                                              )
                                              : Icon(
                                                Icons.done_all,
                                                color:
                                                    convo
                                                                .lastVisit
                                                                .microsecondsSinceEpoch >
                                                            convo
                                                                .timestamp
                                                                .microsecondsSinceEpoch
                                                        ? Colors.green
                                                        : Colors.white70,
                                                size: 15,
                                              )
                                          : Container(),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          displayMessage,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          
                                        ),
                                      ),
                                    ],
                                  ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(convo.image),
                          ),
                          trailing: _trailerWidget(convo.timestamp),
                        );
                      },
                    )
                    : Center(
                      child: Text(
                        "No Conversations Yet!",
                        style: TextStyle(color: Colors.white30, fontSize: 15),
                      ),
                    );
              } else {
                return Center(
                  child: SpinKitWanderingCubes(color: Colors.blue, size: 50),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _trailerWidget(Timestamp _lastMesasageTimestamp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("Last Message", style: TextStyle(fontSize: 15)),
        Text(
          timeago.format(_lastMesasageTimestamp.toDate()),
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
