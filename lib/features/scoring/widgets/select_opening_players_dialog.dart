import 'package:flutter/material.dart';
import '../models/match_state.dart';

class SelectOpeningPlayersDialog extends StatefulWidget {
  final List<Player> battingTeam;
  final List<Player> bowlingTeam;

  const SelectOpeningPlayersDialog({
    super.key,
    required this.battingTeam,
    required this.bowlingTeam,
  });

  @override
  State<SelectOpeningPlayersDialog> createState() =>
      _SelectOpeningPlayersDialogState();
}

class _SelectOpeningPlayersDialogState
    extends State<SelectOpeningPlayersDialog> {
  Player? _selectedStriker;
  Player? _selectedNonStriker;
  Player? _selectedBowler;

  @override
  Widget build(BuildContext context) {
    final strikerOptions = widget.battingTeam
        .where((player) => player.id != _selectedNonStriker?.id)
        .toList();
    final nonStrikerOptions = widget.battingTeam
        .where((player) => player.id != _selectedStriker?.id)
        .toList();

    return AlertDialog(
      title: const Text('Select Opening Players'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Striker'),
          DropdownButton<Player>(
            value: _selectedStriker,
            hint: const Text('Select Striker'),
            isExpanded: true,
            items: strikerOptions.map((player) {
              return DropdownMenuItem(
                value: player,
                child: Text(player.name),
              );
            }).toList(),
            onChanged: (player) {
              setState(() {
                _selectedStriker = player;
                if (_selectedStriker != null &&
                    _selectedStriker!.id == _selectedNonStriker?.id) {
                  _selectedNonStriker = null;
                }
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('Non-Striker'),
          DropdownButton<Player>(
            value: _selectedNonStriker,
            hint: const Text('Select Non-Striker'),
            isExpanded: true,
            items: nonStrikerOptions.map((player) {
              return DropdownMenuItem(
                value: player,
                child: Text(player.name),
              );
            }).toList(),
            onChanged: (player) {
              setState(() {
                _selectedNonStriker = player;
                if (_selectedNonStriker != null &&
                    _selectedNonStriker!.id == _selectedStriker?.id) {
                  _selectedStriker = null;
                }
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('Opening Bowler'),
          DropdownButton<Player>(
            value: _selectedBowler,
            hint: const Text('Select Bowler'),
            isExpanded: true,
            items: widget.bowlingTeam.map((player) {
              return DropdownMenuItem(
                value: player,
                child: Text(player.name),
              );
            }).toList(),
            onChanged: (player) {
              setState(() {
                _selectedBowler = player;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_selectedStriker != null &&
                  _selectedNonStriker != null &&
                  _selectedBowler != null)
              ? () {
                  // FIX 1: Explicitly create a map of the correct, non-nullable type.
                  final Map<String, Player> result = {
                    'striker': _selectedStriker!,
                    'nonStriker': _selectedNonStriker!,
                    'bowler': _selectedBowler!,
                  };

                  // FIX 2: Schedule the pop to run after the build cycle to prevent race conditions.
                  Future.delayed(Duration.zero, () {
                    Navigator.of(context).pop(result);
                  });
                }
              : null, // Disable button if not all players are selected
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
