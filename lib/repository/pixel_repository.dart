import 'dart:convert';

import 'package:client/model/pixel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

class PixelRepository {
  String hostname;
  IOWebSocketChannel channel;

  PixelRepository.withClient(this.hostname) : channel = IOWebSocketChannel.connect('ws://$hostname/ws');

  Stream<Pixel> listenPixel() {
    return channel.stream.map((event) {
      print(event);
      return Pixel.fromJson(jsonDecode(event));
    });
  }

  void sendPixel(Pixel pixel) {
    channel.sink.add(jsonEncode(pixel.toJson()));
  }

  Future<List<Pixel>> getPixels() async {
    final response = await http.get(Uri.parse("http://$hostname/pixels"));
    try {
      final json = response.body;
      final pixels = jsonDecode(json) as List<dynamic>;
      return pixels.map((e) => Pixel.fromJson(e)).toList();
    } catch (e) {
      print(e);
      return [];
    }

  }
}
