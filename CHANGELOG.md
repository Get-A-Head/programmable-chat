## 0.1.0+4

* Fixes an issue where null data would prevent events from being parsed and distributed.

## 0.1.0+3

* Makes argument to Android `EventChannel.StreamHandler::onCancel` methods nullable
* Sets `EventChannel` `StreamHandler`s to `null` on `onDetachedFromEngine`

## 0.1.0+2

* Throws an `UnsupportedError` when the `TwilioProgrammableChat.create` is called again without first shutting down the existing `ChatClient`

## 0.1.0+1

* Fix dart implementation of Message::setAttributes

## 0.1.0

* Initial iOS & Android release
