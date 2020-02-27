![Pub](https://img.shields.io/pub/v/action_cable)

# ActionCable in Dart

ActionCable is the default realtime websocket framework and protocol in Rails.

This is a dart port of the client and protocol implementation which is available in web, dartVM and flutter.

## Usage

### Connecting to a channel 🙌

```dart
cable = ActionCable.Connect(
  "ws://10.0.2.2:3000/cable",
  headers: {
    "Authorization": "Some Token",
  },
  onConnected: (){
    print("connected");
  },
);
```

### Subscribing to channel 🎉

```dart
cable.subscribe(
  "Chat", // either "Chat" and "ChatChannel" is fine
  channelParams: { "room": "private" },
  onSubscribed: (){}, // `confirm_subscription` received
  onDisconnected: (){} // `disconnect` received
  onMessage: (Map message) {} // any other message received
);
```

### Unsubscribing from a channel 🎃

```dart
cable.unsubscribe(
  "Chat", // either "Chat" and "ChatChannel" is fine
  {"room": "private"}
);
```

### Perform an action on your ActionCable server 🎇

Requires that you have a method defined in your Rails Action Cable channel whose name matches the action property passed in.

```dart
cable.performAction(
  "Chat",
  action: "send_message",
  channelParams: { "room": "private" },
  actionParams: { "message": "Hello private peeps! 😜" }
);
```

### Disconnect from the ActionCable server

```dart
cable.disconnect();
```

## ActionCable protocol

Anycable has [a great doc](https://docs.anycable.io/#/misc/action_cable_protocol) on that topic.
