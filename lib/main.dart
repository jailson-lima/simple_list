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
    Rota principal da aplicação.
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
    // Adicionar um item
    void add(String itemTitle) {
        if (itemTitle.trim().isEmpty)
            return;

        setState(() {
            widget.items.add(
                Item(title: itemTitle.trim(),),
            );
            save();
        });
    }

    // Remover um item
    void remove(int index) {
        setState(() {
            widget.items.removeAt(index);
            save();
        });
    }

    // Desmarcar toda a lista
    void unchecked() {
        setState(() {
            for (Item item in widget.items) {
                item.isCompleted = false;
            }
            save();
        });
    }

    // Excluir toda a lista
    void clear() {
        setState(() {
            widget.items.clear();
            save();
        });
    }

    // Carregar a lista
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

    // Salvar a lista
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
            body: (widget.items.length != 0) ?
                ListView.builder(
                    itemCount: widget.items.length,
                    itemBuilder: (BuildContext ctx, int index) {
                        final item = widget.items[index];
                        return Dismissible(
                            child: ListTile(
                                title: item.isCompleted ?
                                    Text(item.title, style: TextStyle(color: Colors.grey[500]),) :
                                    Text(item.title),
                                leading: item.isCompleted ?
                                    Icon(Icons.check_box, color: Colors.blue) :
                                    Icon(Icons.check_box_outline_blank),
                                selected: item.isCompleted,
                                onTap: () {
                                    setState(() {
                                        item.isCompleted = !item.isCompleted;
                                        save();
                                    });
                                }
                            ), // ListTile
                            key: Key(item.title),
                            background: Container(
                                color: Colors.grey.withOpacity(0.2),
                            ), // Container
                            onDismissed: (direction) {
                                remove(index);
                            },
                        ); // Dismissible
                    },
                ) : // ListView.builder
                Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget> [
                            Row(
                                children: <Widget> [
                                    Padding(
                                        padding: EdgeInsets.only(right: 10.0, bottom: 2.0),
                                        child: Icon(Icons.content_paste, color: Colors.grey),
                                    ), // Padding
                                    Text('Lista Vazia', style: TextStyle(fontSize: 16, color: Colors.grey,),),
                                ],
                            ), // Row
                        ],
                    ), // Row
                ), // Center
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
    Rota de adição de itens a lista da aplicação.
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
                title: Text('Adicionar Itens'),
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
    Rota de excluir todos os itens da lista da aplicação.
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
    Rota de informações sobre a aplicação.
*/
class InfoRoute extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Informações'),
                backgroundColor: Colors.green[800],
            ), // AppBar
            body: Container(
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: ListView(
                        children: <Widget> [
                            ListTile(
                                title: Text('Versão do Aplicativo'),
                                subtitle: Text('1.0.0'),
                                leading: Icon(Icons.code),
                            ), // ListTile
                            ListTile(
                                title: Text('Tipo'),
                                subtitle: Text('To-do list & shopping list'),
                                leading: Icon(Icons.info_outline),
                            ), // ListTile
                            ListTile(
                                title: Text('Adicionar Item'),
                                subtitle: Text('Clique no botão verde flutuante na tela principal'),
                                leading: Icon(Icons.add),
                                isThreeLine: true,
                            ), // ListTile
                            ListTile(
                                title: Text('Remover Item'),
                                subtitle: Text('Arraste o item para a esquerda ou para a direita'),
                                leading: Icon(Icons.delete_outline),
                                isThreeLine: true,
                            ), // ListTile
                        ],
                    ), // ListView
                ), // Padding
            ), // Container
            bottomSheet: Container(
                color: Colors.grey[100],
                width: double.infinity,
                height: 80,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget> [
                        Row(
                            children: <Widget> [
                                Padding(
                                    padding: EdgeInsets.only(right: 10.0, bottom: 2.0),
                                    child: Icon(Icons.lightbulb_outline),
                                ), // Padding
                                Text('Desenvolvido por ', style: TextStyle(fontSize: 16, color: Colors.grey,),),
                                Text('Jailson Lima', style: TextStyle(fontSize: 16, color: Colors.blue,),),
                            ],
                        ), // Row
                    ],
                ), // Row
            ), // Container
        ); // Scaffold
    }
}
