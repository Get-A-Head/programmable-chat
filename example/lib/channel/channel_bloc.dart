import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';
import 'package:twilio_programmable_chat_example/channel/channel_model.dart';
import 'package:twilio_programmable_chat_example/channel/media_model.dart';

class ChannelBloc {
  late BehaviorSubject<ChannelModel> _messageSubject;
  late ValueStream<ChannelModel> messageStream;
  late BehaviorSubject<String?> _typingSubject;
  late ValueStream<String?> typingStream;
  late List<StreamSubscription> _subscriptions;
  Map<String?, BehaviorSubject<MediaModel>> mediaSubjects = <String?, BehaviorSubject<MediaModel>>{};

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  String myUsername;
  String? tempDirPath;
  ChatClient chatClient;
  ChannelDescriptor channelDescriptor;
  Channel? channel;

  ChannelBloc({required this.myUsername, required this.chatClient, required this.channelDescriptor}) {
    _messageSubject = BehaviorSubject<ChannelModel>();
    _messageSubject.add(ChannelModel());
    messageStream = _messageSubject.stream;
    _subscriptions = <StreamSubscription>[];
    _typingSubject = BehaviorSubject<String?>();
    typingStream = _typingSubject.stream;
    messageController.addListener(_onTyping);

    channelDescriptor.getChannel().then((channel) {
      this.channel = channel;
      _subscribeToChannel();
      channel?.getFriendlyName().then((friendlyName) {
        _messageSubject.add(
          _messageSubject.value.copyWith(friendlyName: friendlyName),
        );
      });
    });
  }

  Future _onTyping() async {
    await channel?.typing();
  }

  Future _subscribeToChannel() async {
    var _channel = channel;
    if (_channel == null) {
      return;
    }
    print('ChannelBloc::subscribeToChannel');
    if (_channel.hasSynchronized) {
      await _getMessages(_channel);
    }

    _subscriptions.add(_channel.onSynchronizationChanged.listen((event) async {
      if (event.synchronizationStatus == ChannelSynchronizationStatus.ALL) {
        await _getMessages(event);
      }
    }));
    _subscriptions.add(_channel.onMessageAdded.listen((Message message) {
      _messageSubject.add(_messageSubject.value.addMessage(message));
      if (message.hasMedia) {
        _getImage(message);
      }
    }));
    _subscriptions.add(_channel.onTypingStarted.listen((TypingEvent event) {
      _typingSubject.add(event.member.identity);
    }));
    _subscriptions.add(_channel.onTypingEnded.listen((TypingEvent event) {
      _typingSubject.add(null);
    }));
  }

  Future _getMessages(Channel channel) async {
    var friendlyName = await channel.getFriendlyName();
    var messageCount = await channel.getMessagesCount();
    var messages = await channel.messages.getLastMessages(messageCount);
    messages.where((message) => message.hasMedia).forEach(_getImage);
    _messageSubject.add(_messageSubject.value.copyWith(
      friendlyName: friendlyName,
      messages: messages,
    ));
    await _updateLastConsumedMessageIndex(channel, messages);
  }

  Future _updateLastConsumedMessageIndex(Channel channel, List<Message> messages) async {
    var lastConsumedMessageIndex = messages.isNotEmpty ? messages.last.messageIndex : 0;
    await channel.messages.setLastConsumedMessageIndexWithResult(lastConsumedMessageIndex ?? 0);
  }

  Future sendMessage() async {
    var message = MessageOptions()
      ..withBody(messageController.text)
      ..withAttributes({'name': myUsername});
    await channel?.messages.sendMessage(message);
  }

  Future sendImage() async {
    var image = await _imagePicker.getImage(source: ImageSource.gallery);
    if (image != null) {
      var file = File(image.path);
      var mimeType = mime(image.path);
      if (mimeType != null) {
        var message = MessageOptions()
          ..withMedia(file, mimeType)
          ..withAttributes({'name': myUsername});
        await channel?.messages.sendMessage(message);
      }
    }
  }

  Future leaveChannel() async {
    var _channel = channel;
    if (_channel == null) {
      return;
    }
    if (_channel.type == ChannelType.PUBLIC) {
      return _channel.leave();
    } else {
      await _channel.leave();
      return _channel.destroy();
    }
  }

  Future _getImage(Message message) async {
    var _messageMedia = message.media;
    if (_messageMedia == null) {
      return;
    }
    var subject = BehaviorSubject<MediaModel>();
    subject.add(MediaModel(isLoading: true, message: message));
    mediaSubjects[message.sid] = subject;

    if (tempDirPath == null) {
      var tempDir = await getTemporaryDirectory();
      tempDirPath = tempDir.path;
    }
    var _fileName = _messageMedia.fileName;
    var path = '$tempDirPath/'
        '${(_fileName != null && _fileName.isNotEmpty) ? _fileName : _messageMedia.sid}.'
        '${extensionFromMime(_messageMedia.type)}';
    var outputFile = File(path);

    await _messageMedia.download(outputFile);
    subject.add(subject.value.copyWith(isLoading: false, file: outputFile));
  }

  Future dispose() async {
    await _messageSubject.close();
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();
    messageController.removeListener(_onTyping);
  }
}
