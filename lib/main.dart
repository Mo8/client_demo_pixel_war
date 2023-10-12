import 'package:client/model/pixel.dart';
import 'package:client/repository/pixel_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:zoom_widget/zoom_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Pixel war'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Pixel> pixels = [];

  PixelRepository repo = PixelRepository.withClient("localhost:4040");
  int x = 0, y = 0;
  Color color = Colors.black;

  @override
  void initState() {
    loadPixels();
    repo.listenPixel().listen((event) {
      setState(() {
        pixels.add(event);
      });
    });
    super.initState();
  }

  void loadPixels() {
    repo.getPixels().then((value) {
      setState(() {
        pixels = value;
      });
    });
  }

  void sendPixel() {
    repo.sendPixel(Pixel(x, y, color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [IconButton(onPressed: loadPixels, icon: const Icon(Icons.refresh))],
      ),
      body: Center(
        child: Zoom(
          maxZoomHeight: 100000,
          maxZoomWidth: 100000,
          child: SizedBox(
            width: 10000,
            height: 7000,
            child: Stack(
              children: pixels
                  .map((e) => Positioned(
                        left: e.x * 10,
                        top: e.y * 10,
                        child: PixelContainer(e),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          Expanded(
            child: TextField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'X',
              ),
              onChanged: (value) {
                x = int.parse(value);
              },
            ),
          ),
          Expanded(
            child: TextField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Y',
              ),
              onChanged: (value) {
                y = int.parse(value);
              },
            ),
          ),
          TextButton(
            onPressed: () {
              Color chooseColor = color;
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Color"),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: chooseColor,
                          onColorChanged: (value) {
                            setState(() {
                              chooseColor = value;
                            });
                          },
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                color = chooseColor;
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text("Choose")),
                      ],
                    );
                  });
            },
            child: Text("Choose color"),
          ),
          Container(
            width: 10,
            height: 10,
            color: color,
          ),
          SizedBox(width: 20),
          FloatingActionButton(onPressed: sendPixel, child: const Icon(Icons.send)),
        ]),
      ),
    );
  }
}

class PixelContainer extends StatelessWidget {
  final Pixel pixel;

  const PixelContainer(
    this.pixel, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      color: pixel.color,
    );
  }
}
