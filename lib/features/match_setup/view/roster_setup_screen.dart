import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../widgets/smart_roster_input.dart';
import '../../scoring/models/match_state.dart';
import '../../scoring/providers/match_state_provider.dart';
import '../../scoring/widgets/select_opening_players_dialog.dart';
import '../../scoring/view/scoring_screen.dart';

/// Second screen in the match setup wizard that collects player rosters.
class RosterSetupScreen extends ConsumerStatefulWidget {
  final String teamAName;
  final String teamBName;
  final int totalOvers;
  final String location;

  const RosterSetupScreen({
    super.key,
    required this.teamAName,
    required this.teamBName,
    required this.totalOvers,
    required this.location,
  });

  @override
  ConsumerState<RosterSetupScreen> createState() => _RosterSetupScreenState();
}

class _RosterSetupScreenState extends ConsumerState<RosterSetupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _teamARosterController = TextEditingController();
  final _teamBRosterController = TextEditingController();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _teamARosterController.dispose();
    _teamBRosterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Players'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: widget.teamAName),
            Tab(text: widget.teamBName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Team A Tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SmartRosterInput(controller: _teamARosterController),
                ),
                // Team B Tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SmartRosterInput(controller: _teamBRosterController),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              onPressed: () async {
                // Set match metadata
                ref.read(matchStateProvider.notifier).setMatchMetadata(
                      matchDate: DateTime.now(),
                      location: widget.location,
                      totalOvers: widget.totalOvers,
                    );

                // Parse player lists from text inputs
                final teamAPlayers = _teamARosterController.text
                    .split(',')
                    .map((name) => name.trim())
                    .where((name) => name.isNotEmpty)
                    .map((name) => Player(id: _uuid.v4(), name: name))
                    .toList();

                final teamBPlayers = _teamBRosterController.text
                    .split(',')
                    .map((name) => name.trim())
                    .where((name) => name.isNotEmpty)
                    .map((name) => Player(id: _uuid.v4(), name: name))
                    .toList();

                // Add players to the state
                ref.read(matchStateProvider.notifier).addPlayers(
                      teamAPlayers: teamAPlayers,
                      teamBPlayers: teamBPlayers,
                    );

                // Set the number of players per side based on the team with more players
                final playersPerSide = teamAPlayers.length >= teamBPlayers.length 
                    ? teamAPlayers.length 
                    : teamBPlayers.length;
                print('[DEBUG_LOG] Setting players per side to: $playersPerSide');
                ref.read(matchStateProvider.notifier).setPlayersPerSide(playersPerSide);

                // Show dialog to select opening players
                final selectedPlayers = await showDialog<Map<String, Player>>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return SelectOpeningPlayersDialog(
                      battingTeam: teamAPlayers,
                      bowlingTeam: teamBPlayers,
                    );
                  },
                );

                // If players were selected, set them and navigate to scoring screen
                if (selectedPlayers != null && context.mounted) {
                  ref.read(matchStateProvider.notifier).setOpeningPlayers(
                        striker: selectedPlayers['striker']!,
                        nonStriker: selectedPlayers['nonStriker']!,
                        bowler: selectedPlayers['bowler']!,
                      );

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => ScoringScreen(
                        teamAName: widget.teamAName,
                        teamBName: widget.teamBName,
                      ),
                    ),
                    (route) => route.isFirst, // Keep only the first route (HomeScreen)
                  );
                }
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Start Match'),
            ),
          ),
        ],
      ),
    );
  }
}
