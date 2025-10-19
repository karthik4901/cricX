import 'package:flutter/material.dart';
import '../models/match_state.dart';

class FallOfWicketDialog extends StatefulWidget {
  final List<Player> remainingBatsmen;
  final List<Player> fieldingTeam;

  const FallOfWicketDialog({
    super.key,
    required this.remainingBatsmen,
    required this.fieldingTeam,
  });

  @override
  State<FallOfWicketDialog> createState() => _FallOfWicketDialogState();
}

class _FallOfWicketDialogState extends State<FallOfWicketDialog> {
  DismissalType? _selectedDismissalType;
  Player? _selectedNextBatsman;
  Player? _selectedFielder;

  bool get _isFielderRequired =>
      _selectedDismissalType == DismissalType.caught ||
      _selectedDismissalType == DismissalType.runOut;

  bool get _canConfirm =>
      _selectedDismissalType != null &&
      _selectedNextBatsman != null &&
      (!_isFielderRequired || _selectedFielder != null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fall of Wicket'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Type of Dismissal'),
          DropdownButton<DismissalType>(
            value: _selectedDismissalType,
            hint: const Text('Select Dismissal Type'),
            isExpanded: true,
            items: DismissalType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getDismissalTypeText(type)),
              );
            }).toList(),
            onChanged: (type) {
              setState(() {
                _selectedDismissalType = type;
                if (!_isFielderRequired) {
                  _selectedFielder = null;
                }
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('Next Batsman'),
          DropdownButton<Player>(
            value: _selectedNextBatsman,
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
                _selectedNextBatsman = player;
              });
            },
          ),
          if (_isFielderRequired) ...[
            const SizedBox(height: 16),
            const Text('Fielder'),
            DropdownButton<Player>(
              value: _selectedFielder,
              hint: const Text('Select Fielder'),
              isExpanded: true,
              items: widget.fieldingTeam.map((player) {
                return DropdownMenuItem(
                  value: player,
                  child: Text(player.name),
                );
              }).toList(),
              onChanged: (player) {
                setState(() {
                  _selectedFielder = player;
                });
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canConfirm
              ? () {
                  final result = {
                    'dismissalType': _selectedDismissalType,
                    'nextBatsman': _selectedNextBatsman,
                    if (_isFielderRequired) 'fielder': _selectedFielder,
                  };

                  Future.delayed(Duration.zero, () {
                    Navigator.of(context).pop(result);
                  });
                }
              : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  String _getDismissalTypeText(DismissalType type) {
    switch (type) {
      case DismissalType.bowled:
        return 'Bowled';
      case DismissalType.caught:
        return 'Caught';
      case DismissalType.lbw:
        return 'LBW';
      case DismissalType.runOut:
        return 'Run Out';
      case DismissalType.stumped:
        return 'Stumped';
    }
  }
}
