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

class RecentConversationPage extends StatelessWidget {
  final double height;
  final double width;

  RecentConversationPage({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
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
        return Container(
          height: height,
          width: width,
          child: StreamBuilder<List<ConverstaionSnippet>>(
            stream: DBService.instance.getUserConversation(_auth.user!.uid),
            builder: (_context, _snapshot) {
              var _data = _snapshot.data;
              if (_data != null) {
                return _data.length != 0
                    ? ListView.builder(
                      itemCount: _data.length,
                      itemBuilder: (_context, _index) {
                        return ListTile(
                          onTap: () async {
                            await Future.delayed(Duration(milliseconds: 200));
                            await NavigationService.instance.navigateToRoute(
                              MaterialPageRoute(
                                builder: (BuildContext _context) {
                                  return ConversationsPage(
                                    _data[_index].conversationID,
                                    _data[_index].id,
                                    _data[_index].image,
                                    _data[_index].name,
                                  );
                                },
                              ),
                            );
                          },
                          title: Text(_data[_index].name),
                          subtitle: Text(_data[_index].lastMessage),
                          leading: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(_data[_index].image),
                              ),
                            ),
                          ),
                          trailing: _trailerWidget(_data[_index].timestamp),
                        );
                      },
                    )
                    : Align(
                      child: Text(
                        "No Conversations Yet!",
                        style: TextStyle(color: Colors.white30, fontSize: 15),
                      ),
                    );
              } else {
                return SpinKitWanderingCubes(color: Colors.blue, size: 50);
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
