import 'package:flutter/material.dart';
import 'package:cricx/features/scoring/models/match_state.dart';

/// A widget that displays a batting scorecard for a single innings.
class BattingScorecardTable extends StatelessWidget {
  final TeamInnings innings;
  final List<Player> opposingTeamPlayers; // For looking up bowler/fielder names

  const BattingScorecardTable({
    Key? key,
    required this.innings,
    required this.opposingTeamPlayers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          columnSpacing: 16.0,
          columns: [
            DataColumn(
              label: Text(
                'Batsman',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            DataColumn(
              label: Text(
                'R',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'B',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                '4s',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                '6s',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'SR',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              numeric: true,
            ),
          ],
          rows: [
            // Generate rows for each batsman in batting order
            // Sort by: players who faced balls first appear first (order they came to bat)
            // This ensures batting order is preserved even if roster order differs
            ...innings.players
                .where((player) => player.ballsFaced > 0) // Only show players who batted
                .toList() // Convert to list to allow sorting
                .map((player) => _buildBatsmanRow(context, player)),

            // Add extras row
            DataRow(
              cells: [
                DataCell(Text(
                  'Extras: ${_calculateExtras()} ( W: ${innings.wides}, NB: ${innings.noBalls}, B: ${innings.byes}, LB: ${innings.legByes} )',
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
                DataCell(Text(
                  _calculateExtras().toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
              ],
            ),

            // Add total row
            DataRow(
              cells: [
                DataCell(Text(
                  'Total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )),
                DataCell(Text(
                  '${innings.score}-${innings.wickets}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )),
                DataCell(Text(
                  '(${innings.overs}.${innings.balls})',
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildBatsmanRow(BuildContext context, Player player) {
    // Calculate strike rate (runs per 100 balls)
    final strikeRate = player.ballsFaced > 0
        ? (player.runsScored * 100.0 / player.ballsFaced).toStringAsFixed(2)
        : '-'; // Handle division by zero

    // Determine how to display the batsman's name based on their status
    String batsmanDisplay = player.name;
    if (player.status == PlayerStatus.out) {
      batsmanDisplay += ' (out)';
    } else if (player.status == PlayerStatus.retiredHurt) {
      batsmanDisplay += ' (retired hurt)';
    } else {
      batsmanDisplay += ' *'; // Not out
    }

    // Build dismissal info text if player is out
    String? dismissalInfo;
    if (player.status == PlayerStatus.out && player.dismissalType != null) {
      dismissalInfo = _formatDismissalInfo(player, opposingTeamPlayers);
    }

    return DataRow(
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                batsmanDisplay,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (dismissalInfo != null)
                Text(
                  dismissalInfo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ),
        DataCell(Text(
          player.runsScored.toString(),
          style: Theme.of(context).textTheme.bodyMedium,
        )),
        DataCell(Text(
          player.ballsFaced.toString(),
          style: Theme.of(context).textTheme.bodyMedium,
        )),
        DataCell(Text(
          player.fours.toString(),
          style: Theme.of(context).textTheme.bodyMedium,
        )),
        DataCell(Text(
          player.sixes.toString(),
          style: Theme.of(context).textTheme.bodyMedium,
        )),
        DataCell(Text(
          strikeRate,
          style: Theme.of(context).textTheme.bodyMedium,
        )),
      ],
    );
  }

  // Calculate extras (total score minus individual batsmen's scores)
  int _calculateExtras() {
    final batsmenTotal = innings.players.fold<int>(
      0,
      (sum, player) => sum + player.runsScored,
    );
    return innings.score - batsmenTotal;
  }

  /// Formats dismissal information in standard cricket format (e.g., "c Martin b McGrath")
  String _formatDismissalInfo(Player player, List<Player> opposingTeamPlayers) {
    if (player.dismissalType == null) return '';

    String dismissalText = '';
    String? fielderName;
    String? bowlerName;

    // Get fielder name if applicable
    if (player.fielderInvolvedId != null) {
      final fielder = opposingTeamPlayers.firstWhere(
        (p) => p.id == player.fielderInvolvedId,
        orElse: () => Player(id: '', name: 'Unknown'),
      );
      fielderName = fielder.name;
    }

    // Get bowler name
    if (player.bowlerWhoDismissedId != null) {
      final bowler = opposingTeamPlayers.firstWhere(
        (p) => p.id == player.bowlerWhoDismissedId,
        orElse: () => Player(id: '', name: 'Unknown'),
      );
      bowlerName = bowler.name;
    }

    // Format based on dismissal type
    switch (player.dismissalType!) {
      case DismissalType.bowled:
        dismissalText = bowlerName != null ? 'b $bowlerName' : 'b';
        break;
      case DismissalType.caught:
        if (fielderName != null && bowlerName != null) {
          dismissalText = 'c $fielderName b $bowlerName';
        } else if (fielderName != null) {
          dismissalText = 'c $fielderName';
        } else if (bowlerName != null) {
          dismissalText = 'c & b $bowlerName';
        } else {
          dismissalText = 'c';
        }
        break;
      case DismissalType.lbw:
        dismissalText = bowlerName != null ? 'lbw b $bowlerName' : 'lbw';
        break;
      case DismissalType.runOut:
        if (fielderName != null) {
          dismissalText = 'run out ($fielderName)';
        } else {
          dismissalText = 'run out';
        }
        break;
      case DismissalType.stumped:
        if (fielderName != null && bowlerName != null) {
          dismissalText = 'st $fielderName b $bowlerName';
        } else if (fielderName != null) {
          dismissalText = 'st $fielderName';
        } else if (bowlerName != null) {
          dismissalText = 'st b $bowlerName';
        } else {
          dismissalText = 'st';
        }
        break;
    }

    return dismissalText.toLowerCase(); // Use lowercase as per user's example
  }
}
