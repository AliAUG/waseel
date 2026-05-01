import 'package:flutter/foundation.dart';
import 'package:waseel/features/passenger/data/user_api_service.dart';
import 'package:waseel/features/passenger/models/saved_place.dart';

class SavedPlacesProvider extends ChangeNotifier {
  SavedPlacesProvider({UserApiService? userApi})
      : _userApi = userApi ?? UserApiService();

  final UserApiService _userApi;
  final List<SavedPlace> _places = [];

  bool _loading = false;
  String? _loadError;

  bool get loading => _loading;
  String? get loadError => _loadError;

  List<SavedPlace> get places => List.unmodifiable(_places);

  static List<SavedPlace> _demoPlaces() => [
        const SavedPlace(
          id: 'local-1',
          type: SavedPlaceType.home,
          name: 'Home',
          address: 'Achrafieh, Mar Mikhael Street, Beirut',
        ),
        const SavedPlace(
          id: 'local-2',
          type: SavedPlaceType.work,
          name: 'Work',
          address: 'Downtown Beirut, Martyrs Square, Lebanon',
        ),
        const SavedPlace(
          id: 'local-3',
          type: SavedPlaceType.gym,
          name: 'Gym',
          address: 'Hamra Street, Beirut, Lebanon',
        ),
        const SavedPlace(
          id: 'local-4',
          type: SavedPlaceType.custom,
          name: "Mom's House",
          address: 'Verdun, Beirut, Lebanon',
        ),
      ];

  bool _isRealToken(String? token) =>
      token != null &&
      token.isNotEmpty &&
      token != 'local-session';

  /// Load from API when logged in; otherwise show local demo list.
  Future<void> refresh({String? token}) async {
    _loading = true;
    _loadError = null;
    notifyListeners();

    if (!_isRealToken(token)) {
      _places
        ..clear()
        ..addAll(_demoPlaces());
      _loading = false;
      notifyListeners();
      return;
    }

    try {
      final raw = await _userApi.getSavedPlaces(token!);
      _places
        ..clear()
        ..addAll(raw.map(SavedPlace.fromBackend));
      _loadError = null;
    } catch (e) {
      _loadError = e.toString();
      _places.clear();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addPlace({
    required String label,
    required String address,
    String? token,
  }) async {
    final trimmedLabel =
        label.trim().isNotEmpty ? label.trim() : 'Place';
    final trimmedAddr = address.trim();

    if (!_isRealToken(token)) {
      _places.add(SavedPlace(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        type: SavedPlace.savedPlaceTypeFromLabel(trimmedLabel),
        name: trimmedLabel,
        address: trimmedAddr,
      ));
      notifyListeners();
      return;
    }

    final raw = await _userApi.addSavedPlace(
      token!,
      label: trimmedLabel,
      address: trimmedAddr,
    );
    if (raw.isEmpty) return;
    _places.add(SavedPlace.fromBackend(raw));
    notifyListeners();
  }

  Future<void> updatePlace(
    String id, {
    required String label,
    required String address,
    String? token,
  }) async {
    final trimmedLabel = label.trim();
    final trimmedAddr = address.trim();

    if (!_isRealToken(token)) {
      final i = _places.indexWhere((p) => p.id == id);
      if (i < 0) return;
      _places[i] = SavedPlace(
        id: id,
        type: SavedPlace.savedPlaceTypeFromLabel(trimmedLabel),
        name: trimmedLabel.isEmpty ? _places[i].name : trimmedLabel,
        address: trimmedAddr,
      );
      notifyListeners();
      return;
    }

    final raw = await _userApi.updateSavedPlace(
      token!,
      id,
      label: trimmedLabel,
      address: trimmedAddr,
    );
    final i = _places.indexWhere((p) => p.id == id);
    if (i < 0) return;
    if (raw.isNotEmpty) {
      _places[i] = SavedPlace.fromBackend(raw);
    } else {
      _places[i] = SavedPlace(
        id: id,
        type: SavedPlace.savedPlaceTypeFromLabel(trimmedLabel),
        name: trimmedLabel,
        address: trimmedAddr,
      );
    }
    notifyListeners();
  }

  Future<void> removePlace(String id, {String? token}) async {
    if (_isRealToken(token)) {
      await _userApi.deleteSavedPlace(token!, id);
    }
    _places.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
