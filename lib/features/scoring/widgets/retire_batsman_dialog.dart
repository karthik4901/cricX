import 'package:flutter/material.dart';
import '../models/match_state.dart';

class RetireBatsmanDialog extends StatefulWidget {
  final Player striker;
  final Player nonStriker;
  final List<Player> remainingBatsmen;

  const RetireBatsmanDialog({
    super.key,
    required this.striker,
    required this.nonStriker,
    required this.remainingBatsmen,
  });

  @override
  State<RetireBatsmanDialog> createState() => _RetireBatsmanDialogState();
}

class _RetireBatsmanDialogState extends State<RetireBatsmanDialog> {
  bool _isStrikerRetiring = true; // Default to striker
  Player? _selectedNewBatsman;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Retired Hurt'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Which batsman is retiring?'),
          const SizedBox(height: 16),
          ToggleButtons(
            isSelected: [_isStrikerRetiring, !_isStrikerRetiring],
            onPressed: (index) {
              setState(() {
                _isStrikerRetiring = index == 0;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(widget.striker.name),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(widget.nonStriker.name),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Next Batsman'),
          const SizedBox(height: 8),
          DropdownButton<Player>(
            value: _selectedNewBatsman,
            hint: const Text('Select Next Batsman'),
            isExpanded: true,
            items: widget.remainingBatsmen
                .where((player) => player.status == PlayerStatus.notOut)
                .map((player) {
              return DropdownMenuItem(
                value: player,
                child: Text(player.name),
              );
            }).toList(),
            onChanged: (player) {
              setState(() {
                _selectedNewBatsman = player;
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
          onPressed: _selectedNewBatsman != null
              ? () {
                  final result = {
                    'retiringBatsman': _isStrikerRetiring ? widget.striker : widget.nonStriker,
                    'newBatsman': _selectedNewBatsman,
                  };
                  Navigator.of(context).pop(result);
                }
              : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}