import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remove_background/remove_background.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Visa/Passport PhotoMaker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RemoveBG(),
    );
  }
}


enum ProcessingStatus {
  notstarted,
  processing,
  done;
}

class RemoveBG extends StatefulWidget {
  const RemoveBG({super.key});

  @override
  State<RemoveBG> createState() => _RemoveBGState();
}

class _RemoveBGState extends State<RemoveBG> {
  ImgPicker imgPicker = ImgPicker();
  XFile? xFile;
  bool manualRemovalMode = false;

  ProcessingStatus processingStatus = ProcessingStatus.notstarted;
  Uint8List? imgInBytes;

  ImgRemoveBg imgRemoveBg = ImgRemoveBg();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Upload Image'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        imgPicker.getImageFromGallery().then((value) {
                          setState(() {
                            xFile = value;
                          });
                        });
                      },
                      child: const Text('Gallery'))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: xFile == null
                    ? const Placeholder()
                    : Image.file(File(xFile!.path)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: xFile == null
                          ? null
                          : () {
                        //for loading
                        setState(() {
                          processingStatus = ProcessingStatus.processing;
                          manualRemovalMode = !manualRemovalMode;
                        });

                        imgRemoveBg
                            .removeBg(context, xFile!)
                            .then((value) {
                          setState(() {
                            processingStatus = ProcessingStatus.done;
                            imgInBytes = value;
                          });
                        });
                      },
                      child: const Text('Remove Bg'))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: processingStatus == ProcessingStatus.notstarted
                    ? const Placeholder()
                    : processingStatus == ProcessingStatus.processing
                    ?
                //circular progress
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                )
                    : imgInBytes == null
                    ? Container()
                    : Image.memory(imgInBytes!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImgPicker{
  //for image uploading
  final ImagePicker picker = ImagePicker();

  //get image from gallery
  Future<XFile?> getImageFromGallery()async{
    return await picker.pickImage(source: ImageSource.gallery);
  }

  Future<XFile?> getImageFromCamera()async{
    return await picker.pickImage(source: ImageSource.camera);
  }
}


class ImgRemoveBg{
  ui.Image? image;
  ByteData? pngBytes;

//function for removing/erasing background
  Future<Uint8List> removeBg(context, XFile xFile) async{
    image = await decodeImageFromList(await xFile.readAsBytes());//1st we to convert our image file into ui.image type variable
    pngBytes = await cutImage(context: context, image: image!);//pngbytes function catch the result images
    return Uint8List.view(pngBytes!.buffer);//after pngbytes we convert it into uint8list.view function
  }
}

Future<Uint8List> manualRemoveBg(ui.Image image) async {
  // Perform your manual background removal logic here
  // Replace this placeholder code with your actual implementation

  // Example: Converting the image to grayscale
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  canvas.drawImage(image, Offset.zero, Paint());
  final picture = pictureRecorder.endRecording();
  final grayscaleImage = await picture.toImage(image.width, image.height);
  final byteData = await grayscaleImage.toByteData(format: ui.ImageByteFormat.png);

  return Uint8List.view(byteData!.buffer);
}

Future<Uint8List> removeBg(ui.Image image) async {
  // Perform automatic background removal logic here
  // Replace this placeholder code with your actual implementation

  // Example: Calling manualRemoveBg for manual removal
  return await manualRemoveBg(image);
}


/*
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 2),
        () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder:
            (BuildContext context) => const HomeScreen()),

    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50,),
          Center(
            child: Image.asset('assets/logo.jpg'),
          ),

          const SizedBox(height: 300,),
          BouncingButton(
            onPressed: () {},
          ),

        ],
      ),
    );
  }
}*/
