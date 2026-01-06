import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_list/models/nota.dart';

class NotaDialog extends StatefulWidget {
  final Nota? notaEsistente;
  final Function(Nota) onSave;

  const NotaDialog({super.key, this.notaEsistente, required this.onSave});

  @override
  State<NotaDialog> createState() => _NotaDialogState();
}

class _NotaDialogState extends State<NotaDialog> {
  final TextEditingController _controllerTitolo = TextEditingController();
  final TextEditingController _controllerContenuto = TextEditingController(); // Usato per il testo
  
  bool _isListMode = false;
  List<Map<String, dynamic>> _checklistItems = []; // Usato per la lista

  @override
  void initState() {
    super.initState();
    
    if (widget.notaEsistente != null) {
      // --- CARICAMENTO DATI ESISTENTI ---
      _controllerTitolo.text = widget.notaEsistente!.titolo;
      _isListMode = widget.notaEsistente!.isList;

      if (_isListMode) {
        // MODO LISTA: Decodifichiamo il JSON
        try {
          List<dynamic> decoded = jsonDecode(widget.notaEsistente!.contenuto);
          // Usiamo Map<String, dynamic>.from per evitare errori di tipo
          _checklistItems = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        } catch (e) {
          _checklistItems = [];
        }
      } else {
        // MODO TESTO: Carichiamo il testo semplice
        _controllerContenuto.text = widget.notaEsistente!.contenuto;
      }
    }
  }

  // --- LOGICA DI CONVERSIONE (QUANDO TOCCHI LO SWITCH) ---
  void _onSwitchChanged(bool value) {
    setState(() {
      _isListMode = value;

      if (_isListMode) {
        // DA TESTO A LISTA ⬇️
        // Proviamo a vedere se il testo è un JSON "dimenticato" (fix per il tuo bug)
        try {
            List<dynamic> decoded = jsonDecode(_controllerContenuto.text);
            _checklistItems = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        } catch (e) {
            // Se non è JSON, è testo normale: creiamo una voce per ogni riga
            final righe = _controllerContenuto.text.split('\n');
            _checklistItems = []; // Reset
            for (var riga in righe) {
              if (riga.trim().isNotEmpty) {
                _checklistItems.add({'testo': riga.trim(), 'fatto': false});
              }
            }
            // Se era vuoto, aggiungiamo almeno una riga vuota
            if (_checklistItems.isEmpty) {
               _checklistItems.add({'testo': '', 'fatto': false});
            }
        }
      } else {
        // DA LISTA A TESTO ⬆️
        // Uniamo tutti gli elementi della lista in un testo unico
        String testoUnito = "";
        for (var item in _checklistItems) {
          testoUnito += "${item['testo']}\n";
        }
        _controllerContenuto.text = testoUnito.trim();
      }
    });
  }

  void _aggiungiVoce() {
    setState(() {
      _checklistItems.add({'testo': '', 'fatto': false});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.notaEsistente == null ? 'Nuova nota' : 'Modifica'),
          // Switch Lista/Testo
          Row(
            children: [
              Icon(
                _isListMode ? Icons.check_box : Icons.text_fields, 
                size: 20, 
                color: Colors.grey
              ),
              Switch(
                value: _isListMode,
                onChanged: _onSwitchChanged, // Usiamo la nuova funzione intelligente
              ),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controllerTitolo,
              decoration: const InputDecoration(
                labelText: 'Titolo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // VISUALIZZAZIONE CONDIZIONALE
            if (!_isListMode)
              // 1. MODO TESTO
              TextField(
                controller: _controllerContenuto,
                decoration: const InputDecoration(
                  labelText: 'Contenuto',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
              )
            else
              // 2. MODO LISTA CHECKBOX
              Column(
                children: [
                  ..._checklistItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: item['fatto'],
                            onChanged: (val) {
                              setState(() {
                                item['fatto'] = val;
                              });
                            },
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: item['testo'],
                              onChanged: (val) => item['testo'] = val,
                              decoration: const InputDecoration(
                                isDense: true,
                                hintText: "Elemento...",
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _checklistItems.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }), // spread operator
                  
                  TextButton.icon(
                    onPressed: _aggiungiVoce,
                    icon: const Icon(Icons.add),
                    label: const Text("Aggiungi voce"),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
        ElevatedButton(
          onPressed: () {
            if (_controllerTitolo.text.isNotEmpty) {
              String contenutoFinale;
              
              if (_isListMode) {
                // Se salviamo come lista, codifichiamo in JSON
                // Pulizia: rimuoviamo righe vuote prima di salvare
                _checklistItems.removeWhere((item) => item['testo'].toString().trim().isEmpty);
                contenutoFinale = jsonEncode(_checklistItems);
              } else {
                // Se salviamo come testo, prendiamo il testo normale
                contenutoFinale = _controllerContenuto.text;
              }

              final nota = Nota(
                titolo: _controllerTitolo.text,
                contenuto: contenutoFinale,
                data: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                isList: _isListMode, 
              );
              
              widget.onSave(nota);
              Navigator.pop(context);
            }
          },
          child: const Text('Salva'),
        ),
      ],
    );
  }
}