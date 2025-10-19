import 'package:flutter/material.dart';
import 'package:cricx/features/scoring/models/match_state.dart';

/// A widget that displays a batting scorecard for a single innings.
class BattingScorecardTable extends StatelessWidget {
  final TeamInnings innings;

  const BattingScorecardTable({
    Key? key,
    required this.innings,
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
            // Generate rows for each batsman
            ...innings.players
                .where((player) => player.ballsFaced > 0) // Only show players who batted
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

    return DataRow(
      cells: [
        DataCell(Text(
          batsmanDisplay,
          style: Theme.of(context).textTheme.bodyMedium,
        )),
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
}
