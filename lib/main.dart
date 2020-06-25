import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_redux/flutter_redux.dart';

void main() {
  final store = Store<AppState>(appReducer,
      initialState: AppState.initial(), middleware: [thunkMiddleware]);
  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;
  MyApp({this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
        store: store,
        child: MaterialApp(
            title: 'Easy Flutter Redux',
            routes: {
              ViewName.id: (context) {
                return ViewName(onInit: () {
                  StoreProvider.of<AppState>(context).dispatch(getNameAction);
                });
              },
            },
            home: SaveName()));
  }
}

// Save Name
class SaveName extends StatelessWidget {
  static const String id = "SaveName";
  String name;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Name *',
            ),
            onChanged: (value) {
              name = value;
            },
          ),
          // A button thats save name
          FlatButton.icon(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString("name", name);
                Navigator.pushNamed(context, ViewName.id);
              },
              icon: Icon(Icons.save),
              label: Text("save name")),
        ],
      ),
    );
  }
}

// App State: View initialize the app state file
class AppState {
  final dynamic name;

  AppState({@required this.name});

  factory AppState.initial() {
    return AppState(name: null);
  }
}

/* Actions */
// Desc: gets data from shared preferences on request
class GetNameAction {
  final dynamic _name;

  dynamic get name => this._name;
  GetNameAction(this._name);
}

ThunkAction<AppState> getNameAction = (Store<AppState> store) async {
  final prefs = await SharedPreferences.getInstance();
  final String name = prefs.getString('name');
  store.dispatch(GetNameAction(name));
};

// Reducer
AppState appReducer(state, action) {
  return AppState(name: userReducer(state.name, action));
}

userReducer(user, action) {
  if (action is GetNameAction) {
    return action.name;
  }
}

// View Redux
class ViewName extends StatefulWidget {
  static const String id = "ViewName";
  final void Function() onInit;
  ViewName({this.onInit});

  @override
  ViewNameState createState() => ViewNameState();
}

class ViewNameState extends State<ViewName> {
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text("${state.name}")),
          );
        });
  }
}
