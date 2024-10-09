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
  //list of todos
  List _todoList = [];

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
                    decoration: InputDecoration(
                      labelText: 'Nova Tarefa',
                      labelStyle: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    'ADD',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                )
              ]),
            ),
          ],
        ));
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
