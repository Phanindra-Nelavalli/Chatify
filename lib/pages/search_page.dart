import 'package:chatify/models/contact.dart';
import 'package:chatify/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/auth_provider.dart';

class SearchPage extends StatefulWidget {
  final double _height;
  final double _width;
  SearchPage(this._height, this._width);

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  late AuthProvider _auth;
  late String _searchText;

  _SearchPageState() {
    _searchText = "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.widget._height,
      width: this.widget._width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _searchPageUI(),
      ),
    );
  }

  Widget _searchPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_searchBar(), Expanded(child: _usersListView())],
        );
      },
    );
  }

  Widget _searchBar() {
    return Container(
      height: this.widget._height * 0.08,
      width: this.widget._width,
      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 2),
      child: TextField(
        autocorrect: false,
        onSubmitted: (_input) {
          _searchText = _input;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.white),
          labelText: "Search",
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _usersListView() {
    return Container(
      height: this.widget._height * 0.75,
      width: this.widget._width,
      child: StreamBuilder<List<Contact>>(
        stream: DBService.instance.getUsersInDB(_searchText),
        builder: (_context, _snapshot) {
          var _usersData = _snapshot.data;
          if (_usersData != null) {
            _usersData.removeWhere((_contact) {
              return _contact.id == _auth.user?.uid;
            });
          }
          return _snapshot.hasData
              ? ListView.builder(
                itemCount: _usersData!.length,
                itemBuilder: (_context, _index) {
                  var _userData = _usersData![_index];
                  var _currentTime = DateTime.now();

                  var _isUserActive =
                      !_userData.lastSeen.toDate().isBefore(
                        _currentTime.subtract(Duration(hours: 1)),
                      );

                  return ListTile(
                    onTap: () {},
                    title: Text(_userData.name),
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(_userData.image),
                        ),
                      ),
                    ),
                    trailing: _trailerWidget(_isUserActive, _userData.lastSeen),
                  );
                },
              )
              : SpinKitWanderingCubes(color: Colors.blue, size: 50);
        },
      ),
    );
  }

  Widget _trailerWidget(bool _isUserActive, Timestamp _timestamp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          !_isUserActive ? "Last Seen" : "Active Now",
          style: TextStyle(fontSize: 15),
        ),
        !_isUserActive
            ? Text(
              timeago.format(_timestamp.toDate()),
              style: TextStyle(fontSize: 15),
            )
            : Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
      ],
    );
  }
}
