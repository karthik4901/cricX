import 'package:cricx/features/match_setup/widgets/smart_roster_input.dart';
import 'package:cricx/features/scoring/models/match_state.dart';
import 'package:cricx/features/scoring/providers/match_state_provider.dart';
import 'package:cricx/features/scoring/widgets/select_opening_players_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../scoring/view/scoring_screen.dart';

class MatchSetupScreen extends ConsumerStatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  ConsumerState<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends ConsumerState<MatchSetupScreen> {
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  final _totalOversController = TextEditingController(text: '20'); // Default to 20 overs
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _teamARosterController = TextEditingController();
  final _teamBRosterController = TextEditingController();

  final _uuid = const Uuid();

  @override
  void dispose() {
    _locationController.dispose();
    _totalOversController.dispose();
    _teamAController.dispose();
    _teamBController.dispose();
    _teamARosterController.dispose();
    _teamBRosterController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup New Match'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Match Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: _selectedDate == null
                                ? 'Match Date'
                                : DateFormat.yMMMd().format(_selectedDate!),
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _totalOversController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total Overs',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team A Roster',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _teamAController,
                      decoration: const InputDecoration(
                        labelText: 'Team A Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SmartRosterInput(controller: _teamARosterController),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team B Roster',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _teamBController,
                      decoration: const InputDecoration(
                        labelText: 'Team B Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SmartRosterInput(controller: _teamBRosterController),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final location = _locationController.text;
                final matchDate = _selectedDate ?? DateTime.now();
                final totalOvers = int.tryParse(_totalOversController.text) ?? 20; // Default to 20 if invalid input

                ref
                    .read(matchStateProvider.notifier)
                    .setMatchMetadata(matchDate: matchDate, location: location, totalOvers: totalOvers);

                final teamAName = _teamAController.text.isNotEmpty
                    ? _teamAController.text
                    : 'Team A';
                final teamBName = _teamBController.text.isNotEmpty
                    ? _teamBController.text
                    : 'Team B';

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

                ref.read(matchStateProvider.notifier).addPlayers(
                      teamAPlayers: teamAPlayers,
                      teamBPlayers: teamBPlayers,
                    );

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

                if (selectedPlayers != null) {
                  ref.read(matchStateProvider.notifier).setOpeningPlayers(
                        striker: selectedPlayers['striker']!,
                        nonStriker: selectedPlayers['nonStriker']!,
                        bowler: selectedPlayers['bowler']!,
                      );

                  if (!context.mounted) return;

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ScoringScreen(
                        teamAName: teamAName,
                        teamBName: teamBName,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Start Scoring'),
            ),
          ],
        ),
      ),
    );
  }
}
