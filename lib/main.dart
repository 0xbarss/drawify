import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0XFF398CAF)),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String language = "TR";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEE2DA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                language == "TR" ? "Drawify'a Hoşgeldin" : "Welcome to Drawify",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: const Image(
                  image: AssetImage("assets/images/logo.jpeg"),
                  width: 300,
                  height: 300,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                language == "TR"
                    ? "Sezgisel çizim araçlarımızla yaratıcılığınızı serbest bırakın. Hemen çizmeye başlayın!"
                    : "Unleash your creativity with our intuitive drawing tools. Start sketching now!",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFF398CAF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Homepage()),
                      );
                    },
                    child: Text(
                      language == "TR" ? "Hemen Başla" : "Get Started",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<Map<String, TextEditingController>> _inputs2D = [];
  final List<Map<String, TextEditingController>> _inputs3D = [];
  List<Map<String, String>> _drawInputs = [];
  final List<Widget> _pages = [];
  int _pageNumber = 0;
  bool _isReady = false;
  bool _is3D = false;
  String language = "TR";

  void run() {
    setState(() {
      _pageNumber = 1;
      if (_is3D) {
        _drawInputs = _inputs3D.map((entry) {
          return {
            'Length':
                entry['Length']?.text == null || entry['Length']!.text.isEmpty
                    ? '0'
                    : entry['Length']!.text,
            'Diameter': entry['Diameter']?.text == null ||
                    entry['Diameter']!.text.isEmpty
                ? '0'
                : entry['Diameter']!.text,
            'Angle':
                entry['Angle']?.text == null || entry['Angle']!.text.isEmpty
                    ? '0'
                    : entry['Angle']!.text,
            'zAngle':
                entry['zAngle']?.text == null || entry['zAngle']!.text.isEmpty
                    ? '0'
                    : entry['zAngle']!.text,
          };
        }).toList();
        _pages[1] = Canvas3DPage(inputs: _drawInputs);
      } else {
        _drawInputs = _inputs2D.map((entry) {
          return {
            'Length':
                entry['Length']?.text == null || entry['Length']!.text.isEmpty
                    ? '0'
                    : entry['Length']!.text,
            'Diameter': entry['Diameter']?.text == null ||
                    entry['Diameter']!.text.isEmpty
                ? '0'
                : entry['Diameter']!.text,
            'Angle':
                entry['Angle']?.text == null || entry['Angle']!.text.isEmpty
                    ? '0'
                    : entry['Angle']!.text,
          };
        }).toList();
        _pages[1] = Canvas2DPage(inputs: _drawInputs);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isReady) {
      _pages.addAll([
        Inputs2DPage(inputs: _inputs2D),
        Canvas2DPage(inputs: _drawInputs),
        FileManagementPage(inputs: _inputs2D),
      ]);
      _isReady = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Drawify",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color(0XFF398CAF),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          if (_pageNumber == 0)
            IconButton(
                onPressed: () {
                  setState(() {
                    if (_is3D) {
                      _inputs3D.clear();
                      _pages[0] = Inputs3DPage(inputs: _inputs3D);
                    } else {
                      _inputs2D.clear();
                      _pages[0] = Inputs2DPage(inputs: _inputs2D);
                    }
                  });
                },
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.black,
                )),
        ],
        leading: _pageNumber == 0
            ? TextButton(
                onPressed: () {
                  setState(() {
                    _is3D = !_is3D;
                    _pages[0] = _is3D
                        ? Inputs3DPage(
                            inputs: _inputs3D,
                          )
                        : Inputs2DPage(inputs: _inputs2D);
                    _pages[1] = _is3D
                        ? Canvas3DPage(
                            inputs: _drawInputs,
                          )
                        : Canvas2DPage(inputs: _drawInputs);
                    _pages[2] = _is3D ? FileManagementPage(inputs: _inputs3D): FileManagementPage(inputs: _inputs2D);
                  });
                },
                child: Text(
                  _is3D ? "3D" : "2D",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ))
            : null,
      ),
      body: _pages[_pageNumber],
      floatingActionButton: _pageNumber == 0
          ? FloatingActionButton(
              onPressed: run,
              child: const Icon(Icons.play_arrow),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          setState(() {
            _pageNumber = index;
          });
        },
        currentIndex: _pageNumber,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.input),
              label: language == "TR" ? "Girdiler" : "Inputs"),
          BottomNavigationBarItem(
              icon: const Icon(Icons.draw),
              label: language == "TR" ? "Çizim" : "Canvas"),
          BottomNavigationBarItem(
              icon: const Icon(Icons.file_copy_sharp),
              label: language == "TR" ? "Dosya" : "File"),
        ],
      ),
    );
  }
}

class Inputs2DPage extends StatefulWidget {
  final List<Map<String, TextEditingController>> inputs;

  const Inputs2DPage({super.key, required this.inputs});

  @override
  State<Inputs2DPage> createState() => _Inputs2DPageState();
}

class _Inputs2DPageState extends State<Inputs2DPage> {
  String language = "TR";

  void addRow() {
    setState(() {
      widget.inputs.add({
        'Length': TextEditingController(),
        'Diameter': TextEditingController(),
        'Angle': TextEditingController(),
      });
    });
  }

  void removeRow(int index) {
    setState(() {
      widget.inputs.removeAt(index);
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
                            child: TextField(
                              controller: item['Length'],
                              decoration: InputDecoration(
                                labelText:
                                    language == "TR" ? 'Uzunluk' : 'Length',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: item['Diameter'],
                              decoration: InputDecoration(
                                labelText:
                                    language == "TR" ? 'Çap' : 'Diameter',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: item['Angle'],
                              decoration: InputDecoration(
                                labelText: language == "TR"
                                    ? 'Açı (XY)'
                                    : 'Angle (XY)',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeRow(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                // Add button at the end
                Card(
                  key: const ValueKey("addButton"),
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
                            language == "TR" ? "Satır Ekle" : "Add Row",
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

class Inputs3DPage extends StatefulWidget {
  final List<Map<String, TextEditingController>> inputs;

  const Inputs3DPage({super.key, required this.inputs});

  @override
  State<Inputs3DPage> createState() => _Inputs3DPageState();
}

class _Inputs3DPageState extends State<Inputs3DPage> {
  String language = "TR";

  void addRow() {
    setState(() {
      widget.inputs.add({
        'Length': TextEditingController(),
        'Diameter': TextEditingController(),
        'Angle': TextEditingController(),
        'zAngle': TextEditingController()
      });
    });
  }

  void removeRow(int index) {
    setState(() {
      widget.inputs.removeAt(index);
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
                            child: TextField(
                              controller: item['Length'],
                              decoration: InputDecoration(
                                labelText:
                                    language == "TR" ? 'Uzunluk' : 'Length',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: item['Diameter'],
                              decoration: InputDecoration(
                                labelText:
                                    language == "TR" ? 'Çap' : 'Diameter',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: item['Angle'],
                              decoration: InputDecoration(
                                labelText: language == "TR"
                                    ? 'Açı (XY)'
                                    : 'Angle (XY)',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: item['zAngle'],
                              decoration: InputDecoration(
                                labelText:
                                    language == "TR" ? 'Açı (Z)' : 'Angle (Z)',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeRow(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                // Add button at the end
                Card(
                  key: const ValueKey("addButton"),
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
                            language == "TR" ? "Satır Ekle" : "Add Row",
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

class Canvas2DPage extends StatefulWidget {
  final List<Map<String, String>> inputs;

  const Canvas2DPage({super.key, required this.inputs});

  @override
  State<Canvas2DPage> createState() => _Canvas2DPageState();
}

class _Canvas2DPageState extends State<Canvas2DPage> {
  Offset _offset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;
  Offset _lastOffset = Offset.zero;
  double _scale = 1.0;
  double _initialScale = 1.0;
  double penSize = 2.0;
  bool _isSliderActive = false;
  String language = "TR";

  void resetCanvas() {
    setState(() {
      _scale = 1.0;
      _offset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isSliderActive)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: SizedBox(
                      child: Slider(
                          min: 2.0,
                          max: 10.0,
                          value: penSize,
                          onChanged: (value) {
                            setState(() {
                              penSize = value;
                            });
                          }),
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isSliderActive = !_isSliderActive;
                });
              },
              child: Icon(_isSliderActive
                  ? Icons.keyboard_arrow_up
                  : Icons.line_weight),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: resetCanvas,
              child: const Icon(Icons.restart_alt_rounded),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onScaleStart: (details) {
            _initialFocalPoint = details.focalPoint;
            _lastOffset = _offset;
            _initialScale = _scale;
          },
          onScaleUpdate: (details) {
            setState(() {
              _scale = (_initialScale * details.scale).clamp(0.5, 10.0);
              final delta = details.focalPoint - _initialFocalPoint;
              _offset = _lastOffset + delta * _scale;
            });
          },
          child: CustomPaint(
              size: MediaQuery.of(context).size,
              painter: LinePainter(penSize, 1, widget.inputs,
                  offset: _offset,
                  scale: _scale,)),
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final double penSize;
  final double penSpeed;
  final List<Map<String, String>> inputs;
  final List<MaterialColor> colors = [
    Colors.red,
    Colors.orange,
    Colors.teal,
    Colors.green,
    Colors.indigo,
    Colors.deepPurple,
  ];

  final Offset offset;
  final double scale;
  final String language = "TR";

  LinePainter(this.penSize, this.penSpeed, this.inputs,
      {required this.offset,
      required this.scale});

  double toRadians(double degree) {
    return degree * (pi / 180);
  }

  void drawGrid(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const double squareSize = 25.0;
    double extendedWidth = 5 * size.width;
    double extendedHeight = 5 * size.height;

    for (double x = -extendedWidth; x <= extendedWidth; x += squareSize) {
      canvas.drawLine(
          Offset(x, -extendedHeight), Offset(x, extendedHeight), gridPaint);
    }

    for (double y = -extendedHeight; y <= extendedHeight; y += squareSize) {
      canvas.drawLine(
          Offset(-extendedWidth, y), Offset(extendedWidth, y), gridPaint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    drawGrid(canvas, size);

    Offset penLocation = Offset(size.width / 2, size.height / 2);
    int colorNumber = 0;
    double penDirection = 270;
    double minX = size.width / 2,
        minY = size.height / 2,
        maxX = size.width / 2,
        maxY = size.height / 2;
    double totalLength = 0;

    for (Map<String, String> entry in inputs) {
      final double length = double.parse(entry["Length"]!);
      final double diameter = double.parse(entry["Diameter"]!);
      final double angle = double.parse(entry["Angle"]!);
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = penSize
        ..color = colors[colorNumber++];
      colorNumber = colorNumber % colors.length;

      if (length > 0) {
        Offset d = Offset(length * cos(toRadians(penDirection)),
            length * sin(toRadians(penDirection)));
        Offset p1 = penLocation;
        Offset p2 = penLocation + d;
        canvas.drawLine(p1, p2, paint);
        penLocation += d;

        totalLength += length;
        minX = min(minX, min(p1.dx, p2.dx));
        minY = min(minY, min(p1.dy, p2.dy));
        maxX = max(maxX, max(p1.dx, p2.dx));
        maxY = max(maxY, max(p1.dy, p2.dy));
      }
      if (diameter > 0 && angle != 0) {
        double radius = diameter / 2;
        int sign = angle < 0 ? -1 : 1;

        Offset d = Offset(cos(toRadians(penDirection - 90)) * radius * sign,
            sin(toRadians(penDirection - 90)) * radius * sign);
        Offset center = penLocation + d;
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            toRadians(penDirection + 90 * sign),
            toRadians(-angle),
            false,
            paint);

        // canvas.drawCircle(center, 5, paint);
        double oldDirection = penDirection;
        Offset oldLocation = Offset(penLocation.dx, penLocation.dy);

        penDirection = (penDirection - angle + 360) % 360;
        penLocation = center +
            Offset((cos(toRadians(penDirection + 90 * sign))) * radius,
                sin(toRadians(penDirection + 90 * sign)) * radius);

        // canvas.drawCircle(penLocation, 1, paint);

        totalLength += toRadians(angle) * radius;
        if (angle < 0) {
          for (int i = 0; i >= angle; i--) {
            minX = min(minX, oldLocation.dx);
            minY = min(minY, oldLocation.dy);
            maxX = max(maxX, oldLocation.dx);
            maxY = max(maxY, oldLocation.dy);
            oldDirection = (oldDirection - 1 + 360) % 360;
            oldLocation = center +
                Offset((cos(toRadians(oldDirection + 90 * sign))) * radius,
                    sin(toRadians(oldDirection + 90 * sign)) * radius);
          }
        } else {
          for (int i = 0; i < angle; i++) {
            minX = min(minX, oldLocation.dx);
            minY = min(minY, oldLocation.dy);
            maxX = max(maxX, oldLocation.dx);
            maxY = max(maxY, oldLocation.dy);
            oldDirection = (oldDirection - 1 + 360) % 360;
            oldLocation = center +
                Offset((cos(toRadians(oldDirection + 90 * sign))) * radius,
                    sin(toRadians(oldDirection + 90 * sign)) * radius);
          }
        }
      }
    }

    if (totalLength > 0) {
      double padding = 50;
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black;

      canvas.drawLine(Offset(maxX + padding, maxY + padding),
          Offset(maxX + padding, minY - padding), paint);
      canvas.drawLine(Offset(minX - padding, maxY + padding),
          Offset(minX - padding, minY - padding), paint);
      canvas.drawLine(Offset(maxX + padding, maxY + padding),
          Offset(minX - padding, maxY + padding), paint);
      canvas.drawLine(Offset(maxX + padding, minY - padding),
          Offset(minX - padding, minY - padding), paint);

      String text = language == "TR"
          ? 'Genişlik: ${(maxX - minX).roundToDouble()}\nYükseklik: ${(maxY - minY).roundToDouble()}\nToplam Uzunluk: ${totalLength.roundToDouble()}'
          : 'Width: ${(maxX - minX).roundToDouble()}\nHeight: ${(maxY - minY).roundToDouble()}\nTotal Length: ${totalLength.roundToDouble()}';
      final textSpan = TextSpan(
        text: text,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 10),
      );
      final TextPainter textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(maxX - padding * 2, minY - padding * 2));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Canvas3DPage extends StatefulWidget {
  final List<Map<String, String>> inputs;

  const Canvas3DPage({super.key, required this.inputs});

  @override
  State<Canvas3DPage> createState() => _Canvas3DPageState();
}

class _Canvas3DPageState extends State<Canvas3DPage> {
  final DiTreDiController _mainController = DiTreDiController(rotationX: 0, rotationY: 0, userScale: 5);
  double _zoom = 5.0;
  int colorNumber = 0;
  final List<MaterialColor> colors = [
    Colors.red,
    Colors.orange,
    Colors.teal,
    Colors.green,
    Colors.indigo,
    Colors.deepPurple,
  ];

  bool _isSliderActive = false;
  double penSize = 2.0;

  double toRadians(double degree) {
    return degree * (pi / 180);
  }

  vector.Vector3 rotateX(vector.Vector3 arg, double angle) {
    vector.Matrix3 xRotation = vector.Matrix3.rotationX(toRadians(angle));
    return xRotation.transform(arg);
  }

  vector.Vector3 rotateY(vector.Vector3 arg, double angle) {
    vector.Matrix3 yRotation = vector.Matrix3.rotationY(toRadians(angle));
    return yRotation.transform(arg);
  }

  vector.Vector3 rotateZ(vector.Vector3 arg, double angle) {
    vector.Matrix3 zRotation = vector.Matrix3.rotationZ(toRadians(angle));
    return zRotation.transform(arg);
  }

  void reset() {
    setState(() {
      colorNumber = 0;
      _zoom = 5.0;
      _mainController.update(rotationX: -45, rotationY: 45, rotationZ: 0, userScale: _zoom);
    });
  }

  Group3D _generateCoordinateSystem() {
    return Group3D([
      // X-axis (red)
      Line3D(vector.Vector3(-200, 0, 0), vector.Vector3(200, 0, 0),
          color: Colors.red, width: 2),
      // Y-axis (green)
      Line3D(vector.Vector3(0, -200, 0), vector.Vector3(0, 200, 0),
          color: Colors.yellow, width: 2),
      // Z-axis (blue)
      Line3D(vector.Vector3(0, 0, -200), vector.Vector3(0, 0, 200),
          color: Colors.blue, width: 2),
    ]);
  }

  List<Line3D> _generateLinesAndArcs() {
    List<Line3D> lines = [];
    vector.Vector3 currentPosition = vector.Vector3(0, 0, 0);
    double currentDirection = 90;
    double currentZDirection = 0;
    int colorNumber = 0;

    for (Map<String, String> entry in widget.inputs) {
      final double length = double.parse(entry["Length"] ?? "0");
      final double diameter = double.parse(entry["Diameter"] ?? "0");
      final double angle = double.parse(entry["Angle"] ?? "0");
      final double zAngle = double.parse(entry["zAngle"] ?? "0");
      currentZDirection = (currentZDirection + zAngle) % 360;

      if (length > 0) {
        vector.Vector3 newPosition = currentPosition +
            vector.Vector3(
                length *
                    cos(toRadians(currentDirection)) *
                    cos(toRadians(currentZDirection)),
                length *
                    sin(toRadians(currentDirection)) *
                    cos(toRadians(currentZDirection)),
                length * sin(toRadians(currentZDirection)));
        lines.add(Line3D(currentPosition, newPosition,
            color: colors[colorNumber], width: penSize));
        currentPosition = newPosition;
      }

      if (diameter > 0 && angle != 0) {
        double radius = diameter / 2;
        int segments = 360;
        double segmentAngle = angle / segments;
        int sign = angle < 0 ? -1: 1;

        vector.Vector3 center = currentPosition +
            vector.Vector3(
              radius * sin(toRadians(currentDirection)) * sign,
              radius * cos(toRadians(currentDirection)) * sign,
              radius * sin(toRadians(currentZDirection)),
            );

        vector.Vector3 previousPoint = currentPosition;

        for (int i = 1; i <= segments; i++) {
          double segmentDirection = currentDirection + i * segmentAngle;
          vector.Vector3 nextPoint = center -
              vector.Vector3(
                radius * sin(toRadians(segmentDirection)) * sin(toRadians(currentZDirection)) * sign,
                radius * cos(toRadians(segmentDirection)) * sin(toRadians(currentZDirection)) * sign,
                radius * sin(toRadians(currentZDirection)),
              );

          lines.add(Line3D(previousPoint, nextPoint,
              color: colors[colorNumber], width: penSize));
          previousPoint = nextPoint;
        }

        currentDirection = (currentDirection + angle) % 360;
        currentPosition = previousPoint;
      }

      colorNumber = (colorNumber + 1) % colors.length;
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _zoom *= details.scale;
            _zoom = _zoom.clamp(0.5, 10.0);
            _mainController.userScale = _zoom;
          });
        },
        child: DiTreDiAlternativeDraggable(
          controller: _mainController,
          child: Stack(
            children: [
              DiTreDi(
                figures: [
                  ..._generateLinesAndArcs(),
                ],
                controller: _mainController,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: SizedBox(
                    width: 100,
                    height: 100,
                    child: DiTreDiAlternativeDraggable(
                        controller: _mainController,
                        child: DiTreDi(
                          figures: [_generateCoordinateSystem()],
                          controller: _mainController,
                        ))),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isSliderActive)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: SizedBox(
                      child: Slider(
                          min: 2.0,
                          max: 10.0,
                          value: penSize,
                          onChanged: (value) {
                            setState(() {
                              penSize = value;
                            });
                          }),
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isSliderActive = !_isSliderActive;
                });
              },
              child: Icon(_isSliderActive
                  ? Icons.keyboard_arrow_up
                  : Icons.line_weight),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: reset,
              child: const Icon(Icons.restart_alt_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class FileManagementPage extends StatefulWidget {
  final List<Map<String, TextEditingController>> inputs;

  const FileManagementPage({super.key, required this.inputs});

  @override
  State<FileManagementPage> createState() => _FileManagementPageState();
}

class _FileManagementPageState extends State<FileManagementPage> {
  List<Map<String, dynamic>> files = [];
  String language = "TR";

  Future<String> getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  Future<void> saveFile(
      String fileName, List<Map<String, String>> fileContent) async {
    if (!fileName.endsWith('.json')) {
      fileName += '.json';
    }

    final filePath = await getFilePath(fileName);
    final file = File(filePath);

    await file.writeAsString(jsonEncode(fileContent));

    setState(() {
      files.add({'name': fileName, 'path': filePath, 'content': fileContent});
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(language == "TR"
              ? 'Dosya $fileName başarıyla kaydedildi!'
              : 'File $fileName saved successfully!')),
    );
  }

  Future<void> loadFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final filesInDir = Directory(directory.path).listSync();

    setState(() {
      files = filesInDir
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .map((file) {
        final content = jsonDecode(file.readAsStringSync());
        return {
          'name': file.uri.pathSegments.last,
          'path': file.path,
          'content': content
        };
      }).toList();
    });
  }

  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }

    setState(() {
      files.removeWhere((file) => file['path'] == filePath);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(language == "TR"
              ? 'Dosya başarıyla silindi!'
              : 'File deleted successfully!')),
    );
  }

  Future<void> uploadFile(Map<String, dynamic> file) async {
    setState(() {
      widget.inputs.clear();
      widget.inputs.addAll((file['content'] as List).map((input) {
        if (input.containsKey('zAngle')) {
          return {
            'Length': TextEditingController(text: input['Length'].toString()),
            'Diameter': TextEditingController(text: input['Diameter'].toString()),
            'Angle': TextEditingController(text: input['Angle'].toString()),
            'zAngle': TextEditingController(text: input['zAngle'].toString())
          };
        }
        return {
          'Length': TextEditingController(text: input['Length'].toString()),
          'Diameter': TextEditingController(text: input['Diameter'].toString()),
          'Angle': TextEditingController(text: input['Angle'].toString()),
        };
      }).toList());
    });
  }

  Future<void> promptForFilenameAndSave() async {
    TextEditingController filenameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(language == "TR" ? 'Dosya İsmi' : 'Enter Filename'),
        content: TextField(
          controller: filenameController,
          decoration: InputDecoration(
            hintText: language == "TR"
                ? 'Dosya ismi girin'
                : 'Enter filename (e.g., my_file)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(language == "TR" ? 'İptal' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (filenameController.text.isNotEmpty) {
                saveFile(
                    filenameController.text,
                    widget.inputs.map((entry) {
                      if (entry.containsKey('zAngle')) {
                        return {
                          'Length': entry['Length']?.text ?? '0',
                          'Diameter': entry['Diameter']?.text ?? '0',
                          'Angle': entry['Angle']?.text ?? '0',
                          'zAngle': entry['zAngle']?.text ?? '0'
                        };
                      }
                      return {
                        'Length': entry['Length']?.text ?? '0',
                        'Diameter': entry['Diameter']?.text ?? '0',
                        'Angle': entry['Angle']?.text ?? '0',
                      };
                    }).toList());
              }
            },
            child: Text(language == "TR" ? 'Kaydet' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: files.isEmpty
                ? Center(
                    child: Text(language == "TR"
                        ? 'Görüntülenecek dosya yok'
                        : 'No files available.'))
                : ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(file['name']),
                          subtitle: Text(file['path']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.upload),
                                onPressed: () => uploadFile(file),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteFile(file['path']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          ElevatedButton.icon(
            onPressed: promptForFilenameAndSave,
            icon: const Icon(Icons.save),
            label: Text(
                language == "TR" ? 'JSON Dosyası Kaydet' : 'Save JSON File'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50)),
          ),
        ],
      ),
    );
  }
}
