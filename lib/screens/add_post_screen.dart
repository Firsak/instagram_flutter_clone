import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';
import '../models/user.dart' as model;
import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _descriptionController.dispose();
  }

  void postImage(
    String uid,
    String username,
    String profImage,
  ) async {
    setState(() {
      isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
      );

      setState(() {
        isLoading = false;
      });

      if (res == "success") {
        showSnackBar('Posted', context);
        _clearImage();
      } else {
        showSnackBar(res, context);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(err.toString(), context);
    }
  }

  void _clearImage() {
    setState(() {
      _file = null;
    });
  }

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Create post'),
          children: [
            SimpleDialogOption(
              padding: EdgeInsets.all(20),
              child: const Text('Take a photo'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.camera);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: EdgeInsets.all(20),
              child: const Text('Choose from gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.gallery);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: EdgeInsets.all(20),
              child: const Text('Cancel'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return _file == null
        ? Center(
            child: IconButton(
              onPressed: () => _selectImage(context),
              icon: Icon(
                Icons.upload,
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _clearImage,
              ),
              title: const Text('Post to'),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? () {}
                      : () => postImage(
                            user.uid,
                            user.username,
                            user.photoUrl,
                          ),
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                if (isLoading) LinearProgressIndicator(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Write caption',
                          border: InputBorder.none,
                        ),
                        maxLines: 8,
                        controller: _descriptionController,
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: MemoryImage(_file!),
                            fit: BoxFit.fill,
                            alignment: FractionalOffset.topCenter,
                          )),
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
