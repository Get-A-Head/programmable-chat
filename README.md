# twilio_programmable_chat
Flutter plugin for [Twilio Programmable Chat](https://www.twilio.com/chat?utm_source=opensource&utm_campaign=flutter-plugin), which enables you to build a chat application. \
This Flutter plugin is a community-maintained project for [Twilio Programmable Chat](https://www.twilio.com/vidchateo?utm_source=opensource&utm_campaign=flutter-plugin) and not maintained by Twilio. If you have any issues, please file an issue instead of contacting support.

This package is currently work-in-progress and should not be used for production apps. We can't guarantee that the current API implementation will stay the same between versions, until we have reached v1.0.0.

# Example
Check out our comprehensive [example](https://gitlab.com/twilio-flutter/programmable-chat/tree/master/example) provided with this plugin.

## Join the community
If you have any question or problems, please join us on [Discord](https://discord.gg/42x46NH)

## FAQ
Read the [Frequently Asked Questions](https://gitlab.com/twilio-flutter/programmable-chat/blob/master/FAQ.md) first before creating a new issue.

## Supported platforms
* Android
* iOS
* ~~Web~~ (not yet)

# Initializing Chat Client
Call `TwilioProgrammableChat.create()` in your Flutter application to create a `ChatClient`. Once synchronized, you can start joining channels and sending messages.
```dart
ChatClient _chatClient;

void _onClientSynchronization(ChatClientSynchronizationStatus event) {
  print('ChatClient synchoronization status change: $event');
  if (ChatClientSynchronizationStatus.COMPLETED == event) {
    print('ChatClient is synchronized');
  }
  if (ChatClientSynchronizationStatus.FAILED == event) {
    print('Failed synchronization of ChatClient');
  }
}

void _onError(ErrorInfo event) {
  print('Received error: ${event.message}');
}

void init() async {
  var properties = Properties(
    region: region, // Optional region.
  );
  _chatClient = await TwilioProgrammableChat.create(token, properties);
  _chatClient.onClientSynchronization.listen(_onClientSynchronization);
  _chatClient.onError.listen(_onError);
}
```

You **must** pass the [Access Token](https://gitlab.com/twilio-flutter/programmable-video/-/tree/master/programmable_video/README.md#access-tokens) when connecting to a Room.

## Enable debug logging
Using the `TwilioProgrammableChat` class, you can enable native and dart logging of the plugin and enable the SDK logging.

```dart
var sdkEnabled = true;
var nativeEnabled = true;
var dartEnabled = true;
TwilioProgrammableVideo.debug(
  native: nativeEnabled,
  dart: dartEnabled,
  sdk: sdkEnabled,
);
```

## Access Tokens
Keep in mind, you can't generate access tokens for programmable-chat using the [TestCredentials](https://www.twilio.com/docs/iam/test-credentials#supported-resources), make use of the LIVE credentials.

You can easily generate an access token in the Twilio dashboard with the [Testing Tools](https://www.twilio.com/console/video/project/testing-tools) to start testing your code. But we recommend you setup a backend to generate these tokens for you and secure your Twilio credentials. Like we do in our [example app](https://gitlab.com/twilio-flutter/programmable-video/-/tree/master/programmable_video/example).

# Development and Contributing
Interested in contributing? We love merge requests! See the [Contribution](https://gitlab.com/twilio-flutter/programmable-chat/blob/master/CONTRIBUTING.md) guidelines.
