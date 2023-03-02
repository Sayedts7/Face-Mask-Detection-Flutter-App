import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_detection/mask_detection.dart';
import 'package:tflite/tflite.dart';

class ObjectDetection extends StatefulWidget {
  const ObjectDetection({Key? key}) : super(key: key);

  @override
  _ObjectDetectionState createState() => _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection> {

  late File _image;
  late List _results;
  bool imageSelect=false;
  @override
  void initState()
  {
    super.initState();
    loadModel();
  }
  Future loadModel()
  async {
    Tflite.close();
    String res;
    res=(await Tflite.loadModel(model: "assets/model.tflite",labels: "assets/labels.txt"))!;
    print("Models loading status: $res");
  }

  Future imageClassification(File image)
  async {
    final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results=recognitions!;
      _image=image;
      imageSelect=true;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(

          decoration: const BoxDecoration(

            gradient: LinearGradient(
              colors: [Colors.red, Colors.blue],
            ),
          ),
        ),

        title: const Text(
          "Object Detection",
          style: TextStyle(fontSize: 25),
        ),

        // automaticallyImplyLeading: false,
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          const UserAccountsDrawerHeader(

              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red, Colors.blue]),
              ),


              accountName: Text(
                'Machine Learning',
              ),
              accountEmail: null),

          ListTile(
            leading: const Icon(
              Icons.masks,
              color: Colors.red,
            ),
            title: const Text(
              'Mask Detection',
            ),

            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>MaskDetection()));
            },

          ),
          const Divider(
            color: Colors.blue,
          ),
          const ListTile(
            leading: Icon(
              Icons.add,
              color: Colors.red,
            ),
            title: Text(
              'Object Detection',   style: TextStyle(  color: Colors.grey),

            ),

          ),
          const Divider(
            color: Colors.blue,
          ),
        ]),
      ),
      body: ListView(
        children: [
          (imageSelect)?Container(
            margin: const EdgeInsets.all(10),
            child: Image.file(_image),
          ):Container(
            margin: const EdgeInsets.only(top: 200),
            child: Center(
              child: Text("No image selected", style: TextStyle(fontSize: 25),),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: (imageSelect)?_results.map((result) {
                return Card(
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.red, Colors.blue]),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child:  Center(
                      child: Text(
                        "${result['label']} - ${result['confidence'].toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white,
                            fontSize: 20),
                      ),
                    ),
                  ),
                );
              }).toList():[],

            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        tooltip: "Pick Image",
        child:  Container(
          width: 60,
          height: 60,
          child: Icon(Icons.image),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.red, Colors.blue])),
        ),
      ),
    );
  }
  Future pickImage()
  async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    File image=File(pickedFile!.path);
    imageClassification(image);
  }
}




class GradientIcon extends StatelessWidget {
  GradientIcon(
      this.icon,
      this.size,
      this.gradient,
      );

  final IconData icon;
  final double size;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      child: SizedBox(
        width: size * 1.2,
        height: size * 1.2,
        child: Icon(
          icon,
          size: size,
          color: Colors.white,
        ),
      ),
      shaderCallback: (Rect bounds) {
        final Rect rect = Rect.fromLTRB(0, 0, size, size);
        return gradient.createShader(rect);
      },
    );
  }
}
