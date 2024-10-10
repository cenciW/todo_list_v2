import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _todoController = TextEditingController();

  //list of todos
  List _todoList = [];

  Map<String, dynamic> _lastRemoved = Map();
  int _lastRemovedPos = 0;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _todoList = json.decode(data);
      });
    });
  }

  void _addTodo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _todoController.text;
      _todoController.text = "";
      newTodo["ok"] = false;
      _todoList.add(newTodo);
      _saveData();
      // _getFile();
    });
  }

  void _removeTodo(int index) {
    setState(() {
      _todoList.removeAt(index);
      _saveData();
    });
  }

  //função para esperar 1 segundo
  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _todoList.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });
      _saveData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _todoController,
                  decoration: const InputDecoration(
                    labelText: 'Nova Tarefa',
                    labelStyle: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _addTodo();
                  print("Adicionado");
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent),
                child: const Text(
                  'ADD',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ]),
          ),
          Expanded(
            child: RefreshIndicator(
                child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: _todoList.length,
                    itemBuilder: buildItem),
                onRefresh: _refresh),
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext contex, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: const Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(Icons.delete, color: Colors.white)),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_todoList[index]["title"]),
        value: _todoList[index]["ok"],
        secondary: IconButton(
          icon: Icon(_todoList[index]["ok"] ? Icons.check_circle : Icons.error),
          onPressed: () {
            setState(() {
              _todoList.removeAt(index);
              _saveData();
            });
          },
        ),
        onChanged: (bool? value) {
          setState(() {
            _todoList[index]["ok"] = value;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        _lastRemoved = Map.from(_todoList[index]);
        _lastRemovedPos = index;
        _todoList.removeAt(index);

        _saveData();

        final snack = SnackBar(
          duration: const Duration(seconds: 2),
          content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                _todoList.insert(_lastRemovedPos, _lastRemoved);
                _saveData();
              });
            },
          ),
        );
        ScaffoldMessenger.of(contex).showSnackBar(snack);
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    //local do arquivo vou salvar
    return File('${directory.path}/data.json');
  }

  Future<File> _saveData() async {
    //pegamos o arquivo e convertemos para json
    String data = json.encode(_todoList);

    //esperar para obter o arquivo
    final file = await _getFile();

    //escrever no arquivo
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      //como ja estao salvos como string, basta ler como str
      return file.readAsString();
    } catch (e) {
      throw Exception('Erro ao ler os dados ' + e.toString());
    }
  }
}
