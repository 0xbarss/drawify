import 'dart:math';
import 'package:ditredi/ditredi.dart';
import 'package:drawify/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'draw_input.dart';

class Canvas2DPage extends StatefulWidget {
  final List<DrawInput> inputs;

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
  final String language = 'TR';

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
              painter: LinePainter(
                penSize,
                1,
                widget.inputs.map((entry) => entry.toDoubleMap()).toList(),
                offset: _offset,
                scale: _scale,
              )),
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final double penSize;
  final double penSpeed;
  final List<Map<String, double>> inputs;
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
  final String language = 'TR';

  LinePainter(this.penSize, this.penSpeed, this.inputs,
      {required this.offset, required this.scale});

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

    for (Map<String, double> entry in inputs) {
      final double length = entry['length']!;
      final double diameter = entry['diameter']!;
      final double angle = entry['angle']!;
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

        double oldDirection = penDirection;
        Offset oldLocation = Offset(penLocation.dx, penLocation.dy);

        penDirection = (penDirection - angle + 360) % 360;
        penLocation = center +
            Offset((cos(toRadians(penDirection + 90 * sign))) * radius,
                sin(toRadians(penDirection + 90 * sign)) * radius);


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

      String text = '${AppStrings.get('width', language)}: ${(maxX - minX).roundToDouble()}\n${AppStrings.get('height', language)}: ${(maxY - minY).roundToDouble()}\n${AppStrings.get('totalLength', language)}: ${totalLength.roundToDouble()}';
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
  final List<DrawInput> inputs;

  const Canvas3DPage({super.key, required this.inputs});

  @override
  State<Canvas3DPage> createState() => _Canvas3DPageState();
}

class _Canvas3DPageState extends State<Canvas3DPage> {
  final DiTreDiController _mainController = DiTreDiController(
      rotationX: 0,
      rotationY: 0,
      rotationZ: 0,
      minUserScale: 0.1,
      maxUserScale: 10.0,
      userScale: 5.0
  );
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

  Group3D _generateCoordinateSystem() {
    return Group3D([
      Line3D(vector.Vector3(-200, 0, 0), vector.Vector3(200, 0, 0), color: Colors.red, width: 2),
      Line3D(vector.Vector3(0, -200, 0), vector.Vector3(0, 200, 0), color: Colors.yellow, width: 2),
      Line3D(vector.Vector3(0, 0, -200), vector.Vector3(0, 0, 200), color: Colors.blue, width: 2),
    ]);
  }

  vector.Vector3 rotate(
      vector.Vector3 vector, vector.Vector3 axis, double angle) {
    axis = axis.normalized();
    double cosTheta = cos(angle);
    double sinTheta = sin(angle);

    return vector * cosTheta +
        axis.cross(vector) * sinTheta +
        axis * (axis.dot(vector) * (1 - cosTheta));
  }

  vector.Vector3 fix(vector.Vector3 point) {
    const double threshold = 1e-10;
    return vector.Vector3(
        point.x.abs() < threshold ? 0 : point.x,
        point.y.abs() < threshold ? 0 : point.y,
        point.z.abs() < threshold ? 0 : point.z);
  }

  List<Line3D> _generateLinesAndArcs() {
    int colorNumber = 0;
    List<Line3D> lines = [];
    vector.Vector3 currentPosition = vector.Vector3(0, 0, 0);
    vector.Vector3 orientation = vector.Vector3(0, 1, 0);
    vector.Vector3 planeNormal = vector.Vector3(0, 0, 1);
    final List<Map<String, double>> inputs = widget.inputs.map((entry) => entry.toDoubleMap()).toList();

    for (Map<String, double> entry in inputs) {
      final double length = entry['length']!;
      final double diameter = entry['diameter']!;
      final double angle = toRadians(entry['angle']!);
      final double crossAngle = toRadians(entry['crossAngle']!);

      if (length > 0) {
        vector.Vector3 newPosition = currentPosition + orientation * length;
        lines.add(Line3D(currentPosition, newPosition,
            color: colors[colorNumber], width: penSize));
        currentPosition = newPosition;
      }
      if (diameter > 0 && angle != 0) {
        double radius = diameter / 2;
        int segments = 360;
        double segmentAngle = angle / segments;

        planeNormal = rotate(
            planeNormal.normalized(), orientation.normalized(), crossAngle)
            .normalized();

        vector.Vector3 previousPosition = currentPosition;
        for (int i = 1; i <= segments; i++) {
          orientation = rotate(orientation, planeNormal, segmentAngle);
          vector.Vector3 nextPosition =
              previousPosition + orientation * radius * segmentAngle.abs();

          lines.add(Line3D(previousPosition, nextPosition,
              color: colors[colorNumber], width: penSize));

          previousPosition = nextPosition;
        }

        currentPosition = previousPosition;
        orientation = fix(orientation);
      }

      colorNumber = (colorNumber + 1) % colors.length;
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DiTreDiAlternativeDraggable(
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
        ],
      ),
    );
  }
}