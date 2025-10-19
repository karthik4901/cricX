import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/scoring/models/match_state.dart';

/// A service for persisting and retrieving match state data.
class PersistenceService {
  static const String _matchStateKey = 'in_progress_match';

  /// Saves the current match state to shared preferences.
  /// 
  /// Converts the MatchState object to JSON and stores it with the key 'in_progress_match'.
  Future<void> saveMatchState(MatchState state) async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = jsonEncode(state.toJson());
    await prefs.setString(_matchStateKey, stateJson);
  }

  /// Loads a saved match state from shared preferences.
  /// 
  /// Returns null if no saved match state is found.
  Future<MatchState?> loadMatchState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = prefs.getString(_matchStateKey);
    
    if (stateJson == null) {
      return null;
    }
    
    try {
      final Map<String, dynamic> stateMap = jsonDecode(stateJson);
      return MatchState.fromJson(stateMap);
    } catch (e) {
      // If there's an error parsing the JSON, return null
      return null;
    }
  }

  /// Clears the saved match state from shared preferences.
  Future<void> clearSavedMatch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_matchStateKey);
  }
}