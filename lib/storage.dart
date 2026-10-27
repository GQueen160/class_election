// Saving the election on the phone with shared_preferences.
// Same idea as Kigali Weather steps 7 and 8, for the whole election.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'election.dart';

const _key = 'election';

/// Saves the candidates, every vote and who already voted.
Future<void> saveElection(Election election) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_key, jsonEncode(election.toJson()));
}

/// Loads the saved election. The very first time nothing is saved,
/// so the sample candidates stay.
Future<void> loadElection(Election election) async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_key);
  if (saved != null) {
    election.loadFromJson(jsonDecode(saved) as Map<String, dynamic>);
  }
}
