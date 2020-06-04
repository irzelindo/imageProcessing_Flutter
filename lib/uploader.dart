import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Uploader extends StatefulWidget {
  final File file;

  Uploader({Key key, this.file}) : super(key: key);

  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://imageprocessing-4ad23.appspot.com');

  StorageUploadTask _uploadTask;

  void _starUpload() {
    String filePath = 'images/${DateTime.now()}.png';

    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
        stream: _uploadTask.events,
        builder: (context, snapshot) {
          var event = snapshot?.data?.snapshot;

          double progressPercent =
              event != null ? event.bytesTransferred / event.totalByteCount : 0;

          return Column(
            children: <Widget>[
              if (_uploadTask.isComplete) Text('Upload Completed'),
              if (_uploadTask.isPaused)
                FlatButton(
                  child: Icon(Icons.play_arrow),
                  onPressed: _uploadTask.resume,
                ),
              if (_uploadTask.isInProgress)
                FlatButton(
                  child: Icon(Icons.pause),
                  onPressed: _uploadTask.pause,
                ),
              LinearProgressIndicator(
                value: progressPercent,
              ),
              Text(
                '${(progressPercent * 100).toStringAsFixed(2)} %'
              ),
            ],
          );
        },
      );
    } else {
      return FlatButton.icon(
          onPressed: _starUpload,
          icon: Icon(Icons.cloud_upload),
          label: Text('Upload to Firebase'));
    }
  }
}
