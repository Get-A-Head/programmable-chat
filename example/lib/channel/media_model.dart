import 'dart:io';

import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';

class MediaModel {
  bool isLoading;
  int? bytesLoaded;
  Message message;
  File? file;

  MediaModel({this.isLoading = false, this.bytesLoaded, required this.message, this.file});

  MediaModel copyWith({bool? isLoading, int? bytesLoaded, Message? message, File? file}) {
    return MediaModel(
      isLoading: isLoading ?? this.isLoading,
      bytesLoaded: bytesLoaded ?? this.bytesLoaded,
      message: message ?? this.message,
      file: file ?? this.file,
    );
  }
}
