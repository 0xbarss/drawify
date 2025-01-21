import 'package:drawify/app_strings.dart';
import 'package:flutter/material.dart';
import 'inputs.dart';
import 'canvas.dart';
import 'file_management.dart';
import 'draw_input.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<DrawInput> _inputs = [];
  final List<Widget> _pages = [];
  int _pageNumber = 0;
  bool _isReady = false;
  bool _is3D = false;
  final String language = 'TR';

  void run() {
    setState(() {
      _pageNumber = 1;
      _pages[1] = _is3D ? Canvas3DPage(inputs: _inputs): Canvas2DPage(inputs: _inputs);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isReady) {
      _pages.addAll([
        InputsPage(inputs: _inputs, is3D: _is3D,),
        Canvas2DPage(inputs: _inputs),
        FileManagementPage(inputs: _inputs, is3D: _is3D),
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
          'Drawify',
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
                    _inputs.clear();
                    _pages[0] = InputsPage(inputs: _inputs, is3D: _is3D);
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
                _inputs.clear();
                _pages[0] = InputsPage(inputs: _inputs, is3D: _is3D);
                _pages[1] = _is3D ? Canvas3DPage(inputs: _inputs): Canvas2DPage(inputs: _inputs);
                _pages[2] = FileManagementPage(inputs: _inputs, is3D: _is3D,);
              });
            },
            child: Text(_is3D ? '3D' : '2D', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
            : null,
      ),
      body: _pages[_pageNumber],
      floatingActionButton: _pageNumber == 0 ? FloatingActionButton(onPressed: run, child: const Icon(Icons.play_arrow)): null,
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
              label: AppStrings.get('inputs', language)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.draw),
              label: AppStrings.get('canvas', language)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.file_copy_sharp),
              label: AppStrings.get('file', language)),
        ],
      ),
    );
  }
}