import 'package:flutter/material.dart';
import 'package:cricx/features/scoring/models/match_state.dart';

/// A widget that displays a bowling scorecard for a single innings.
class BowlingScorecardTable extends StatelessWidget {
  final TeamInnings innings;

  const BowlingScorecardTable({
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
                'Bowler',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            DataColumn(
              label: Text(
                'O',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'M',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              numeric: true,
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
                'W',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Econ',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              numeric: true,
            ),
          ],
          rows: innings.players
              .where((player) => player.oversBowled > 0) // Only show players who bowled
              .map((player) => _buildBowlerRow(context, player))
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildBowlerRow(BuildContext context, Player player) {
    // Format overs (already stored as a double in the format of completed overs + remaining balls/6)
    final String overs = player.oversBowled.toStringAsFixed(1);

    // Calculate economy rate (runs per over)
    final economyRate = player.oversBowled > 0
        ? (player.runsConceded / player.oversBowled).toStringAsFixed(2)
        : '-'; // Handle division by zero

    return DataRow(
      cells: [
        DataCell(Text(
          player.name,
          style: Theme.of(context).textTheme.bodyMedium,
        )),
        DataCell(Text(
          overs,
          style: Theme.of(context).textTheme.bodyMedium,
        )),
        DataCell(Text(
          player.maidens.toString(),
          style: Theme.of(context).textTheme.bodyMedium,
        )),
        DataCell(Text(
          player.runsConceded.toString(),
          style: Theme.of(context).textTheme.bodyMedium,
        )),
        DataCell(Text(
          player.wicketsTaken.toString(),
          style: Theme.of(context).textTheme.bodyMedium,
        )),
        DataCell(Text(
          economyRate,
          style: Theme.of(context).textTheme.bodyMedium,
        )),
      ],
    );
  }
}
