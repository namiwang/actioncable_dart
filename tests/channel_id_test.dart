import 'package:test/test.dart';
import 'package:action_cable/channel_id.dart';

void main() {
  group("ChannelId", () {
    test("it should correctly encode channel id", () {
      final channelId = encodeChannelId("Chat", {"id": 1}).toString();
      expect('{"channel":"ChatChannel","id":1}', channelId);
    });

    test("it should correctly encode channel id", () {
      final channelId = encodeChannelId("ChatChannel", {"id": 1}).toString();
      expect('{"channel":"ChatChannel","id":1}', channelId);
    });

    test("it should correctly parse channelId", () {
      final channelIdJSON = '{"id": 1, "channel": "NotificationChannel"}';
      final channelId = parseChannelId(channelIdJSON);
      expect('{"channel":"NotificationChannel","id":1}', channelId);
    });
  });
}
