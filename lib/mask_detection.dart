import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_detection/object%20detection.dart';
import 'package:tflite/tflite.dart';

class MaskDetection extends StatefulWidget {
  const MaskDetection({Key? key}) : super(key: key);

  @override
  _MaskDetectionState createState() => _MaskDetectionState();
}

class _MaskDetectionState extends State<MaskDetection> {

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
    res=(await Tflite.loadModel(model: "assets/model_unquant.tflite",labels: "assets/labelsM.txt"))!;
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
          "Face Mask Detection",
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
          const ListTile(
            leading: Icon(
              Icons.masks,
              color: Colors.red,
            ),
            title: Text(
              'Mask Detection', style: TextStyle(  color: Colors.grey),

            ),

          ),
          const Divider(
            color: Colors.blue,
          ),
          ListTile(
            leading: const Icon(
              Icons.add,
              color: Colors.red,
            ),
            title: const Text(
              'Object Detection',
            ),
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context)=>ObjectDetection()));
            },
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
