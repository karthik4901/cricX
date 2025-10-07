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
    // Filter the lists to prevent selecting the same player twice.
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
                // If the new striker is the same as the non-striker, reset the non-striker.
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
                // If the new non-striker is the same as the striker, reset the striker.
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
                  // Return the selected players
                  Navigator.of(context).pop({
                    'striker': _selectedStriker,
                    'nonStriker': _selectedNonStriker,
                    'bowler': _selectedBowler,
                  });
                }
              : null, // Disable button if not all players are selected
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
