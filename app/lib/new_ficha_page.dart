import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewFichaPage extends StatefulWidget {
  final int userId;

  const NewFichaPage({super.key, required this.userId});

  @override
  State<NewFichaPage> createState() => _NewFichaPageState();
}

class _NewFichaPageState extends State<NewFichaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _exerciseController = TextEditingController();

  List<Map<String, TextEditingController>> seriesControllers = [];
  bool _isLoading = false;
  late int userId;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    _addSeries();
  }

  void _addSeries() {
    setState(() {
      seriesControllers.add({
        'weight': TextEditingController(),
        'reps': TextEditingController(),
      });
    });
  }

  void _removeSeries(int index) {
    setState(() {
      seriesControllers[index]['weight']!.dispose();
      seriesControllers[index]['reps']!.dispose();
      seriesControllers.removeAt(index);
    });
  }

  Future<void> _saveFicha() async {
    final localhostIP = "18.188.208.241";
    if (_formKey.currentState!.validate()) {
      List<Map<String, dynamic>> seriesData = [];
      for (var i = 0; i < seriesControllers.length; i++) {
        final weightText = seriesControllers[i]['weight']!.text;
        final repsText = seriesControllers[i]['reps']!.text;
        seriesData.add({
          'set': i + 1,
          'weight': double.tryParse(weightText) ?? 0,
          'reps': int.tryParse(repsText) ?? 0,
        });
      }

      final ficha = {
        'group': _groupController.text,
        'exerciseName': _exerciseController.text,
        'series': seriesData,
        'userId': userId,
      };
      print(ficha);

      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://$localhostIP:3000/workout/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(ficha),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ficha salva com sucesso!')),
          );

          _formKey.currentState!.reset();
          setState(() {
            seriesControllers.clear();
            _addSeries();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar ficha: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na conexão: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _groupController.dispose();
    _exerciseController.dispose();
    for (var c in seriesControllers) {
      c['weight']!.dispose();
      c['reps']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar Nova Ficha"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _groupController,
                decoration: const InputDecoration(labelText: 'Grupo muscular'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o grupo muscular';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _exerciseController,
                decoration:
                    const InputDecoration(labelText: 'Nome do exercício'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome do exercício';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Séries',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: seriesControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: 12), // Espaço de 12 pixels abaixo de cada série
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: seriesControllers[index]['weight'],
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                                labelText: 'Peso (kg) - Série ${index + 1}'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Informe o peso';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Peso inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: seriesControllers[index]['reps'],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: 'Repetições - Série ${index + 1}'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Informe as repetições';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Repetições inválidas';
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: seriesControllers.length > 1
                              ? () => _removeSeries(index)
                              : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addSeries,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Série'),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveFicha,
                      child: const Text("Salvar Ficha"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
