import 'package:flutter/material.dart';

final config = NetworkConfig(
  // address: '100.115.92.198',
  address: 'localhost',
  port: 8080,
);

class NetworkConfig {
  String address;
  int port;
  NetworkConfig({
    @required this.address,
    @required this.port,
  });
}
