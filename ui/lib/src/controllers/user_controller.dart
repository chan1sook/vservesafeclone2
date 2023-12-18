import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vservesafe/src/models/site_data.dart';
import 'package:vservesafe/src/models/user_data.dart';
import 'package:vservesafe/src/services/api_service.dart';

class UserController with ChangeNotifier {
  UserController();

  VserveUserData? _userData;
  VserveUserData? get userData => _userData;
  String? _selectedSiteId;
  String? get selectedSiteId => _selectedSiteId;

  List<VserveSiteData> _avalaibleSites = [];
  List<VserveSiteData> get avalaibleSites => _avalaibleSites;

  VserveSiteData? _selectedSite;
  VserveSiteData? get selectedSite => _selectedSite;

  final ApiService _apiService = ApiService();

  Future<void> updateUserData(VserveUserData? userData) async {
    _userData = userData;

    notifyListeners();
  }

  Future<VserveUserData?> getUserServer() => _apiService.getUserServer();

  Future<void> updateAvaliableSitesData(List<VserveSiteData> sites) async {
    _avalaibleSites = sites;

    notifyListeners();
  }

  Future<List<VserveSiteData>> getAvaliableSitesServer() =>
      _apiService.getAvaliableSitesServer();

  Future<void> updateSelectedSite(VserveSiteData? siteData) async {
    if (_userData == null) {
      return;
    }

    await _apiService.updateSelectedSiteId(_userData!.id, siteData?.id);
    _selectedSiteId = await _apiService.selectedSiteId(_userData!.id);
    _selectedSite = siteData;

    notifyListeners();
  }

  Future<String?> getSelectedSiteId() async {
    if (_userData == null) {
      return null;
    }
    return await _apiService.selectedSiteId(_userData!.id);
  }

  Future<VserveSiteData?> loadFirstSiteByPref() async {
    if (_userData == null) {
      return null;
    }

    final id = await _apiService.selectedSiteId(_userData!.id);
    final loadSite = _avalaibleSites.firstWhereOrNull((site) => site.id == id);
    if (loadSite == null && _avalaibleSites.isNotEmpty) {
      return _avalaibleSites[0];
    }
    return loadSite;
  }
}
