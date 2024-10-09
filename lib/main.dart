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
                  decoration: InputDecoration(
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
                child: Text(
                  'ADD',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent),
              )
            ]),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: _todoList.length,
                itemBuilder: buildItem),
          )
        ],
      ),
    );
  }

  Widget buildItem(contex, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
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
