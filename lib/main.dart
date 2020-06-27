import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/item.dart';

void main() {
    runApp(App());
}

class App extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Simple List',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primarySwatch: Colors.blue,
            ), // ThemeData
            home: FirstRoute(),
        ); // MaterialApp
    }
}

/*
    Rota principal do aplicativo.
*/
class FirstRoute extends StatefulWidget {
    List<Item> items = new List<Item>();

    FirstRoute() {
        items = [];
    }

    @override
    _FirstRouteState createState() => _FirstRouteState();
}

class _FirstRouteState extends State<FirstRoute> {
    void add(String itemTitle) {
        if (itemTitle.isEmpty)
            return;

        setState(() {
            widget.items.add(
                Item(title: itemTitle,),
            );
            save();
        });
    }

    void remove(int index) {
        setState(() {
            widget.items.removeAt(index);
            save();
        });
    }

    void unchecked() {
        setState(() {
            for (Item item in widget.items) {
                item.isCompleted = false;
            }
            save();
        });
    }

    void clear() {
        setState(() {
            widget.items.clear();
            save();
        });
    }

    Future load() async {
        var prefs = await SharedPreferences.getInstance();
        var data = prefs.getString('datalist#001');

        if (data != null) {
            Iterable decoded = jsonDecode(data);
            List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
            setState(() {
                widget.items = result;
            });
        }
    }

    void save() async {
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString('datalist#001', jsonEncode(widget.items));
    }

    _FirstRouteState() {
        load();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Simple List'),
                backgroundColor: Colors.green[800],
                actions: <Widget> [
                    IconButton(
                        icon: Icon(Icons.check_box_outline_blank),
                        onPressed: () {
                            unchecked();
                        },
                    ), // IconButton
                    IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DeleteRoute(this)),
                            ); // Navigator.push
                        },
                    ), // IconButton
                    IconButton(
                        icon: Icon(Icons.bookmark_border),
                        onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => InfoRoute()),
                            ); // Navigator.push
                        },
                    ), // IconButton
                ],
            ), // AppBar
            body: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (BuildContext ctx, int index) {
                    final item = widget.items[index];
                    return Dismissible(
                        child: CheckboxListTile(
                            title: Text(item.title),
                            value: item.isCompleted,
                            onChanged: (value) {
                                setState(() {
                                    item.isCompleted = value;
                                    save();
                                });
                            },
                        ), // CheckboxListTile
                        key: Key(item.title),
                        background: Container(
                            color: Colors.grey.withOpacity(0.2),
                        ), // Container
                        onDismissed: (direction) {
                            remove(index);
                        },
                    ); // Dismissible
                }
            ), // ListView.builder
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdditionRoute(this)),
                    ); // Navigator.push
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.green,
            ), // FloatingActionButton
        ); // Scaffold
    }
}

/*
    Rota de adição de itens do aplicativo.
*/
class AdditionRoute extends StatefulWidget {
    _FirstRouteState firstRoute = null;

    AdditionRoute(_FirstRouteState firstRoute) {
        this.firstRoute = firstRoute;
    }

    @override
    _AdditionRouteState createState() => _AdditionRouteState();
}

class _AdditionRouteState extends State<AdditionRoute> {
    TextEditingController textController = TextEditingController();

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Adiconar Itens'),
                backgroundColor: Colors.green[800],
            ), // AppBar
            body: Container(
                child: Center(
                    child: Column(
                        children: <Widget> [
                            Padding(
                                padding: EdgeInsets.all(20.0),
                                child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 18,
                                    ), // TextStyle
                                    decoration: InputDecoration(
                                        icon: Icon(Icons.create),
                                        hintText: 'Escreva o nome do item',
                                        labelText: 'Novo Item',
                                        border: InputBorder.none,
                                    ), // InputDecoration
                                    controller: textController,
                                ), // TextFormField
                            ), // Padding
                            Padding(
                                padding: EdgeInsets.all(20.0),
                                child: SizedBox(
                                    width: double.infinity,
                                    child: FlatButton(
                                        color: Colors.grey[200],
                                        textColor: Colors.grey[800],
                                        disabledColor: Colors.grey,
                                        disabledTextColor: Colors.black,
                                        splashColor: Colors.grey,
                                        padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                                        onPressed: () {
                                            widget.firstRoute.add(textController.text);
                                            textController.text = '';
                                        },
                                        child: Text('Adicionar', style: TextStyle(fontSize: 18),),
                                    ), // FlatButton
                                ), // SizedBox
                            ), // Padding
                        ],
                    ), // Column
                ), // Center
            ), // Container
        ); // Scaffold
    }
}

/*
    Rota de excluir todos os itens da lista do aplicativo.
*/
class DeleteRoute extends StatelessWidget {
    _FirstRouteState firstRoute = null;

    DeleteRoute(_FirstRouteState firstRoute) {
        this.firstRoute = firstRoute;
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Excluir Lista'),
                backgroundColor: Colors.green[800],
            ), // AppBar
            body: Container(
                child: Center(
                    child: Column(
                        children: <Widget> [
                            Padding(
                                padding: EdgeInsets.only(top: 60.0, bottom: 30.0),
                                child: Text('Deseja excluir toda a lista?', style: TextStyle(fontSize: 18),), // Text
                            ), // Padding
                            Padding(
                                padding: EdgeInsets.all(20.0),
                                child: SizedBox(
                                    width: double.infinity,
                                    child: FlatButton(
                                        color: Colors.red,
                                        textColor: Colors.white,
                                        disabledColor: Colors.grey,
                                        disabledTextColor: Colors.black,
                                        splashColor: Colors.red[800],
                                        padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                                        onPressed: () {
                                            firstRoute.clear();
                                            Navigator.pop(context);
                                        },
                                        child: Text('Sim', style: TextStyle(fontSize: 18),),
                                    ), // FlatButton
                                ), // SizedBox
                            ), // Padding
                            Padding(
                                padding: EdgeInsets.only(left: 20.0, top: 0.0, right: 20.0, bottom: 0.0),
                                child: SizedBox(
                                    width: double.infinity,
                                    child: FlatButton(
                                        color: Colors.grey[200],
                                        textColor: Colors.grey[800],
                                        disabledColor: Colors.grey,
                                        disabledTextColor: Colors.black,
                                        splashColor: Colors.grey,
                                        padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                                        onPressed: () {
                                            Navigator.pop(context);
                                        },
                                        child: Text('Não', style: TextStyle(fontSize: 18),), // Text
                                    ), // FlatButton
                                ), // SizedBox
                            ), // Padding
                        ],
                    ), // Column
                ), // Center
            ), // Container
        ); // Scaffold
    }
}

/*
    Rota de informações sobre o aplicativo.
*/
class InfoRoute extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Informações'),
                backgroundColor: Colors.green[800],
            ), // AppBar
        ); // Scaffold
    }
}
