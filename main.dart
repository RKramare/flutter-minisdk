import 'dart:math';

import 'package:flutter/material.dart';
import 'lightbox_view.dart';
import 'package:provider/provider.dart';
import 'masonry_grid.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Test for mini sdk",
      color: Colors.blueGrey,
      home: MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  Future<List<Widget>> _loadImages(BuildContext context) async {
    List<Widget> items = [];
    List<String> imageUrls = [];
    List<String> thumbnailUrls = [];
    for (int i = 1; i < 13; i++) {
      imageUrls.add('images/img ($i).jpg');
      thumbnailUrls.add('images/img ($i) (Small).jpg');
    }
    LightboxView lightboxView = LightboxView(
      imageUrls: imageUrls,
      thumbnailPlacement: LightboxViewThumbnailPlacement.bottom,
      thumbnailUrls: thumbnailUrls,
    );
    for (int i = 0; i < 12; i++) {
      Image img = Image(image: AssetImage(thumbnailUrls[i]));
      items.add(
        GestureDetector(
          onTap: () {
            lightboxView.showOverlay(context, i);
          },
          child: img,
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: _loadImages(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error loading images: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No images available.');
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("MasonryGrid and LightboxView demo"),
              backgroundColor: Colors.deepPurple[800],
            ),
            body: MasonryGrid(
              mainAxisOrientation: MasonryGridOrientation.columns,
              mainAxisCount: 3,
              items: snapshot.data!,
              padding: const EdgeInsets.all(6),
            ),
          );
        }
      },
    );
  }
}

class MainApp2 extends StatelessWidget {
  const MainApp2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MasonryGridController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Masonry Grid Example"),
        ),
        body: MasonryGridWidget(
          items: rndItems(),
        ),
        floatingActionButton: const FloatingActionButtonPanel(),
      ),
    );
  }
}

class MasonryGridController with ChangeNotifier {
  bool isRow = true;
  int mainAxisCount = 3;

  void toggleAxis() {
    isRow = !isRow;
    notifyListeners();
  }

  void incrementMainAxisCount() {
    mainAxisCount++;
    notifyListeners();
  }

  void decrementMainAxisCount() {
    if (mainAxisCount > 1) {
      mainAxisCount--;
      notifyListeners();
    }
  }
}

List<Widget> rndItems() {
  double rndDouble(double min, double max) {
    final random = Random();
    return min + random.nextDouble() * (max - min);
  }

  Color rndColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  List<Widget> rectangles = [];
  for (int i = 0; i < 15; i++) {
    rectangles.add(
      Container(
        height: rndDouble(10, 40),
        width: rndDouble(30, 50),
        color: rndColor(),
      ),
    );
  }

  List<Widget> items = [];
  for (int i = 0; i < 15; i++) {
    items.add(
      Container(
        height: rndDouble(100, 400),
        width: rndDouble(300, 500),
        color: rndColor(),
      ),
    );
  }
  return items;
}

class MasonryGridWidget extends StatelessWidget {
  final List<Widget> items;
  const MasonryGridWidget({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MasonryGridController>(context);

    return MasonryGrid(
      mainAxisOrientation: controller.isRow
          ? MasonryGridOrientation.rows
          : MasonryGridOrientation.columns,
      mainAxisCount: controller.mainAxisCount,
      items: items,
      padding: const EdgeInsets.all(2),
    );
  }
}

class FloatingActionButtonPanel extends StatelessWidget {
  const FloatingActionButtonPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MasonryGridController>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => controller.toggleAxis(),
            tooltip: 'Toggle Rows/Columns',
            child: const Icon(Icons.grid_on),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => controller.decrementMainAxisCount(),
            tooltip: 'Decrease Main Axis Elements',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => controller.incrementMainAxisCount(),
            tooltip: 'Increase Main Axis Elements',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
