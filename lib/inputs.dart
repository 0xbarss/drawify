import 'package:drawify/app_strings.dart';
import 'package:flutter/material.dart';
import 'draw_input.dart';

class InputsPage extends StatefulWidget {
  final List<DrawInput> inputs;
  final bool is3D;

  const InputsPage({super.key, required this.inputs, required this.is3D});

  @override
  State<InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  final String language = 'TR';

  void addRow() {
    setState(() {
      widget.inputs.add(DrawInput.fromType(widget.is3D));
    });
  }

  void addBelow(int index) {
    setState(() {
      widget.inputs.insert(index+1, DrawInput.fromType(widget.is3D));
    });
  }

  void removeRow(int index) {
    setState(() {
      widget.inputs.removeAt(index);
      if (widget.inputs.isEmpty) {
        widget.inputs.add(DrawInput.fromType(widget.is3D));
      }
    });
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = widget.inputs.removeAt(oldIndex);
      widget.inputs.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ReorderableListView(
              onReorder: onReorder,
              children: [
                ...widget.inputs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Card(
                    key: ValueKey(index),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: item.lengthController,
                              decoration: InputDecoration(
                                labelText:
                                AppStrings.get('length', language),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: item.diameterController,
                              decoration: InputDecoration(
                                labelText:
                                AppStrings.get('diameter', language),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: item.angleController,
                              decoration: InputDecoration(
                                labelText: AppStrings.get('angle', language),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          if (widget.is3D) const SizedBox(width: 4),
                          if (widget.is3D) Expanded(
                            flex: 3,
                            child: TextField(
                              controller: item.crossAngleController,
                              decoration: InputDecoration(
                                labelText: AppStrings.get('crossAngle', language),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeRow(index),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                                onPressed: () => addBelow(index),
                                icon: const Icon(Icons.arrow_downward)),
                          )
                        ],
                      ),
                    ),
                  );
                }),
                // Add button at the end
                Card(
                  key: const ValueKey('addButton'),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: addRow,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.get('addRow', language),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}