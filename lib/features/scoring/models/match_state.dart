enum ExtraType { wide, noBall, bye, legBye }

enum DismissalType {
  bowled,
  caught,
  lbw,
  runOut,
  stumped,
}

enum PlayerStatus { notOut, out, retiredHurt }

class Player {
  final String id;
  final String name;
  final PlayerStatus status;

  // Batting Stats
  final int runsScored;
  final int ballsFaced;
  final int fours;
  final int sixes;

  // Bowling Stats
  final int wicketsTaken;
  final double oversBowled;
  final int runsConceded;
  final int maidens;

  Player({
    required this.id,
    required this.name,
    this.status = PlayerStatus.notOut,
    this.runsScored = 0,
    this.ballsFaced = 0,
    this.fours = 0,
    this.sixes = 0,
    this.wicketsTaken = 0,
    this.oversBowled = 0.0,
    this.runsConceded = 0,
    this.maidens = 0,
  });

  Player copyWith({
    String? id,
    String? name,
    PlayerStatus? status,
    int? runsScored,
    int? ballsFaced,
    int? fours,
    int? sixes,
    int? wicketsTaken,
    double? oversBowled,
    int? runsConceded,
    int? maidens,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      runsScored: runsScored ?? this.runsScored,
      ballsFaced: ballsFaced ?? this.ballsFaced,
      fours: fours ?? this.fours,
      sixes: sixes ?? this.sixes,
      wicketsTaken: wicketsTaken ?? this.wicketsTaken,
      oversBowled: oversBowled ?? this.oversBowled,
      runsConceded: runsConceded ?? this.runsConceded,
      maidens: maidens ?? this.maidens,
    );
  }

  /// Converts a Player object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.index,
      'runsScored': runsScored,
      'ballsFaced': ballsFaced,
      'fours': fours,
      'sixes': sixes,
      'wicketsTaken': wicketsTaken,
      'oversBowled': oversBowled,
      'runsConceded': runsConceded,
      'maidens': maidens,
    };
  }

  /// Creates a Player object from a JSON map.
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json.containsKey('status') 
          ? PlayerStatus.values[json['status'] as int] 
          : PlayerStatus.notOut,
      runsScored: json['runsScored'] as int,
      ballsFaced: json['ballsFaced'] as int,
      fours: json['fours'] as int,
      sixes: json['sixes'] as int,
      wicketsTaken: json['wicketsTaken'] as int,
      // Handle the case where oversBowled might be decoded as an int
      oversBowled: json['oversBowled'] is int 
          ? (json['oversBowled'] as int).toDouble() 
          : json['oversBowled'] as double,
      runsConceded: json['runsConceded'] as int,
      maidens: json['maidens'] as int,
    );
  }
}

class TeamInnings {
  final int score;
  final int wickets;
  final int overs;
  final int balls;
  final List<Player> players;

  const TeamInnings({
    required this.score,
    required this.wickets,
    required this.overs,
    required this.balls,
    required this.players,
  });

  /// Converts a TeamInnings object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'wickets': wickets,
      'overs': overs,
      'balls': balls,
      'players': players.map((player) => player.toJson()).toList(),
    };
  }

  /// Creates a TeamInnings object from a JSON map.
  factory TeamInnings.fromJson(Map<String, dynamic> json) {
    // Safely extract and convert the players list
    List<Player> extractPlayers() {
      if (!json.containsKey('players') || json['players'] == null) return [];

      try {
        final playersList = json['players'] as List;
        return playersList
            .map((playerJson) {
              try {
                return Player.fromJson(playerJson as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing player: $e');
                // Return a default player if there's an error
                return Player(id: 'error', name: 'Error');
              }
            })
            .toList();
      } catch (e) {
        print('Error parsing players list: $e');
        return [];
      }
    }

    return TeamInnings(
      score: json['score'] as int,
      wickets: json['wickets'] as int,
      overs: json['overs'] as int,
      balls: json['balls'] as int,
      players: extractPlayers(),
    );
  }
}

class MatchState {
  final TeamInnings teamAInnings;
  final TeamInnings teamBInnings;
  final int currentInnings;
  final Player? striker;
  final Player? nonStriker;
  final Player? bowler;
  final DateTime matchDate;
  final String location;
  final int totalOvers;
  final bool isFirstInningsComplete;
  final bool isMatchComplete;

  const MatchState({
    required this.teamAInnings,
    required this.teamBInnings,
    required this.currentInnings,
    this.striker,
    this.nonStriker,
    this.bowler,
    required this.matchDate,
    required this.location,
    this.totalOvers = 20, // Default to 20 overs
    this.isFirstInningsComplete = false, // Default to false
    this.isMatchComplete = false, // Default to false
  });

  /// Converts a MatchState object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'teamAInnings': teamAInnings.toJson(),
      'teamBInnings': teamBInnings.toJson(),
      'currentInnings': currentInnings,
      'striker': striker?.toJson(),
      'nonStriker': nonStriker?.toJson(),
      'bowler': bowler?.toJson(),
      'matchDate': matchDate.toIso8601String(),
      'location': location,
      'totalOvers': totalOvers,
      'isFirstInningsComplete': isFirstInningsComplete,
      'isMatchComplete': isMatchComplete,
    };
  }

  /// Creates a MatchState object from a JSON map.
  factory MatchState.fromJson(Map<String, dynamic> json) {
    // Safely extract and convert the nullable Player objects
    Player? extractPlayer(String key) {
      if (json[key] == null) return null;
      try {
        return Player.fromJson(json[key] as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing $key: $e');
        return null;
      }
    }

    return MatchState(
      teamAInnings: TeamInnings.fromJson(json['teamAInnings'] as Map<String, dynamic>),
      teamBInnings: TeamInnings.fromJson(json['teamBInnings'] as Map<String, dynamic>),
      currentInnings: json['currentInnings'] as int,
      striker: extractPlayer('striker'),
      nonStriker: extractPlayer('nonStriker'),
      bowler: extractPlayer('bowler'),
      matchDate: DateTime.parse(json['matchDate'] as String),
      location: json['location'] as String,
      totalOvers: json.containsKey('totalOvers') ? json['totalOvers'] as int : 20, // Default to 20 overs if not specified
      isFirstInningsComplete: json.containsKey('isFirstInningsComplete') ? json['isFirstInningsComplete'] as bool : false, // Default to false if not specified
      isMatchComplete: json.containsKey('isMatchComplete') ? json['isMatchComplete'] as bool : false, // Default to false if not specified
    );
  }
}
