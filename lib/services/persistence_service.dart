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
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert the MatchState object to a JSON map
      final stateMap = state.toJson();

      // Log information about the nullable Player fields
      print('Saving match state:');
      print('- striker: ${state.striker != null ? 'present' : 'null'}');
      print('- nonStriker: ${state.nonStriker != null ? 'present' : 'null'}');
      print('- bowler: ${state.bowler != null ? 'present' : 'null'}');

      // Verify that the nullable Player fields are properly serialized
      if (state.striker != null && !stateMap.containsKey('striker')) {
        print('Warning: striker field was not properly serialized');
      }
      if (state.nonStriker != null && !stateMap.containsKey('nonStriker')) {
        print('Warning: nonStriker field was not properly serialized');
      }
      if (state.bowler != null && !stateMap.containsKey('bowler')) {
        print('Warning: bowler field was not properly serialized');
      }

      // Encode the JSON map to a string
      final stateJson = jsonEncode(stateMap);

      // Save the JSON string to shared preferences
      await prefs.setString(_matchStateKey, stateJson);

      print('Match state saved successfully');
    } catch (e) {
      print('Error saving match state: $e');
    }
  }

  /// Loads a saved match state from shared preferences.
  /// 
  /// Returns null if no saved match state is found or if there's an error parsing the JSON.
  Future<MatchState?> loadMatchState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = prefs.getString(_matchStateKey);

    if (stateJson == null) {
      print('No saved match state found');
      return null;
    }

    try {
      final Map<String, dynamic> stateMap = jsonDecode(stateJson);

      // Validate that the required fields are present in the JSON
      if (!stateMap.containsKey('teamAInnings') || 
          !stateMap.containsKey('teamBInnings') || 
          !stateMap.containsKey('currentInnings') ||
          !stateMap.containsKey('matchDate') ||
          !stateMap.containsKey('location')) {
        print('Invalid match state JSON: missing required fields');
        return null;
      }

      // Create the MatchState object from the JSON
      final matchState = MatchState.fromJson(stateMap);

      // Verify that the striker, nonStriker, and bowler fields were properly deserialized
      if (stateMap.containsKey('striker') && stateMap['striker'] != null && matchState.striker == null) {
        print('Warning: striker field was not properly deserialized');
      }
      if (stateMap.containsKey('nonStriker') && stateMap['nonStriker'] != null && matchState.nonStriker == null) {
        print('Warning: nonStriker field was not properly deserialized');
      }
      if (stateMap.containsKey('bowler') && stateMap['bowler'] != null && matchState.bowler == null) {
        print('Warning: bowler field was not properly deserialized');
      }

      return matchState;
    } catch (e) {
      // If there's an error parsing the JSON, log the error and return null
      print('Error loading match state: $e');
      return null;
    }
  }

  /// Clears the saved match state from shared preferences.
  Future<void> clearSavedMatch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_matchStateKey);
  }
}
