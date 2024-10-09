import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
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
        title: const Text('Lista de Tarefas'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            'Conteúdo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
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
