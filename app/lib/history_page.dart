import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  final int userId;

  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> fichas = [];
  bool isLoading = false;
  final localhostIP = "18.188.208.241";

  @override
  void initState() {
    super.initState();
    _fetchFichas();
  }

  Future<void> _fetchFichas() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('http://$localhostIP:3000/workout/user/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() => fichas = data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao carregar fichas: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteFicha(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente deletar esta ficha?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response =
          await http.delete(Uri.parse('http://$localhostIP:3000/workout/$id'));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ficha deletada com sucesso')),
        );
        _fetchFichas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar ficha: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    }
  }

  void _editFicha(Map<String, dynamic> ficha) async {
    final groupController = TextEditingController(text: ficha['group']);
    final exerciseController =
        TextEditingController(text: ficha['exerciseName']);

    final seriesList = List<Map<String, dynamic>>.from(ficha['series']);

    final edited = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Editar Ficha'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: groupController,
                  decoration:
                      const InputDecoration(labelText: 'Grupo Muscular'),
                ),
                TextField(
                  controller: exerciseController,
                  decoration: const InputDecoration(labelText: 'Exercício'),
                ),
                const SizedBox(height: 10),
                const Text('Séries:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...seriesList.asMap().entries.map((entry) {
                  int i = entry.key;
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: entry.value['weight'].toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Peso'),
                          onChanged: (val) =>
                              seriesList[i]['weight'] = int.tryParse(val) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          initialValue: entry.value['reps'].toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Reps'),
                          onChanged: (val) =>
                              seriesList[i]['reps'] = int.tryParse(val) ?? 0,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Salvar')),
          ],
        );
      },
    );

    if (edited != true) return;

    final updatedFicha = {
      'group': groupController.text.trim(),
      'exerciseName': exerciseController.text.trim(),
      'series': seriesList
    };

    try {
      final response = await http.put(
        Uri.parse('http://$localhostIP:3000/workout/${ficha['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedFicha),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ficha atualizada com sucesso')),
        );
        _fetchFichas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao atualizar ficha: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Fichas'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchFichas),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : fichas.isEmpty
              ? const Center(child: Text('Nenhuma ficha encontrada.'))
              : ListView.builder(
                  itemCount: fichas.length,
                  itemBuilder: (context, index) {
                    final ficha = fichas[index];
                    final createdAt =
                        DateTime.tryParse(ficha['createdAt'] ?? '') ??
                            DateTime.now();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ExpansionTile(
                        title: Text(
                            '${ficha['group']} - ${ficha['exerciseName']}'),
                        subtitle: Text(
                            'Criado em: ${createdAt.day}/${createdAt.month}/${createdAt.year}'),
                        children: [
                          if (ficha['series'] != null &&
                              ficha['series'] is List)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: (ficha['series'] as List)
                                    .map<Widget>((serie) {
                                  return Text(
                                    '${serie['weight']} kg x ${serie['reps']} reps',
                                    style: const TextStyle(fontSize: 14),
                                  );
                                }).toList(),
                              ),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.only(left: 16, bottom: 12),
                              child: Text('Nenhuma série registrada.'),
                            ),
                        ],
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editFicha(ficha),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteFicha(ficha['id']),
                              tooltip: 'Excluir',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
