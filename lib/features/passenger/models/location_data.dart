import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationData {
  const LocationData({
    required this.lat,
    required this.lng,
    required this.address,
  });

  final double lat;
  final double lng;
  final String address;

  LatLng get latLng => LatLng(lat, lng);

  static const tripoli = LocationData(
    lat: 34.4367,
    lng: 35.8497,
    address: 'Tripoli, Lebanon',
  );

  static const halba = LocationData(
    lat: 34.5417,
    lng: 36.0758,
    address: 'Halba, Lebanon',
  );

  static const beirut = LocationData(
    lat: 33.8938,
    lng: 35.5018,
    address: 'Beirut, Lebanon',
  );

  static const sidon = LocationData(
    lat: 33.5571,
    lng: 35.3715,
    address: 'Sidon, Lebanon',
  );

  static const tyre = LocationData(
    lat: 33.2721,
    lng: 35.2034,
    address: 'Tyre, Lebanon',
  );

  static const jounieh = LocationData(
    lat: 33.9811,
    lng: 35.6178,
    address: 'Jounieh, Lebanon',
  );

  static const zahle = LocationData(
    lat: 33.8497,
    lng: 35.9042,
    address: 'Zahle, Lebanon',
  );

  static const byblos = LocationData(
    lat: 34.1211,
    lng: 35.6481,
    address: 'Byblos, Lebanon',
  );

  static const verdun = LocationData(
    lat: 33.8740,
    lng: 35.4833,
    address: 'Verdun, Beirut',
  );

  static const hamra = LocationData(
    lat: 33.8969,
    lng: 35.4833,
    address: 'Hamra, Beirut',
  );

  static const allLebanon = [
    tripoli,
    halba,
    beirut,
    sidon,
    tyre,
    jounieh,
    zahle,
    byblos,
    verdun,
    hamra,
  ];
}
