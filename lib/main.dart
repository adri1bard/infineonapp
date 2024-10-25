import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'dart:math' as math;
import 'dart:html' as html; // Import dart:html for web-specific elements

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 3D Model',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  three.Scene? scene;
  three.PerspectiveCamera? camera;
  three.WebGLRenderer? renderer;
  three.Object3D? object3D;
  three.Clock? clock;
  late html.DivElement _webGLContainer;  // Container for WebGL

  @override
  void initState() {
    super.initState();
    _webGLContainer = html.DivElement();  // Create the container element
    html.document.body?.append(_webGLContainer);  // Append it to the HTML document
    init3D();
  }

  void init3D() {
    // Initialize the scene
    scene = three.Scene();

    // Initialize the camera
    camera = three.PerspectiveCamera(
      75, // Field of view
      1,  // Aspect ratio (adjust later with MediaQuery)
      0.1, // Near distance
      1000, // Far distance
    );

    // Position the camera
    camera?.position.z = 5.0;

    // Initialize WebGL renderer
    renderer = three.WebGLRenderer({"alpha": true});
    renderer?.setSize(
        (html.window.innerWidth ?? 800).toDouble(),   // Use null-aware operators and default values
        (html.window.innerHeight ?? 600).toDouble()   // Use null-aware operators and default values
    );

    // Attach the renderer's DOM element to the Flutter Web DOM
    _webGLContainer.append(renderer!.domElement);

    // Load a 3D model (OBJ file)
    var loader = three.ObjectLoader(three.LoadingManager());
    loader.load('assets/model.obj', (three.Object3D object) {
      object3D = object;
      scene?.add(object3D!);
    });

    // Initialize the clock for animation
    clock = three.Clock();

    // Begin animation loop
    animate();
  }

  void animate() {
    html.window.requestAnimationFrame((num _) {  // Use html.window.requestAnimationFrame
      render();
      animate();  // Recursively call animate to continuously render the scene
    });
  }

  void render() {
    double elapsed = (clock?.getElapsedTime() ?? 0).toDouble();
    if (object3D != null) {
      object3D!.rotation.x = elapsed * math.pi / 180;
      object3D!.rotation.y = elapsed * math.pi / 180;
    }

    renderer?.render(scene!, camera!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("3D Model Viewer"),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: HtmlElementView(viewType: _webGLContainer.toString()),  // Display the WebGL content
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Description du modèle 3D',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Image.asset('assets/image.png', height: 100),
                  Text(
                    'Voici un texte qui décrit ce que représente le modèle 3D affiché au-dessus.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Infos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
