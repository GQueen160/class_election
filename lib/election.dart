// The "brain" of the app: data + rules. No widgets in this file.

class Candidate {
  Candidate({required this.name, this.votes = 0});

  final String name;
  int votes; // not final: it goes up with every vote and back to 0 on reset

  // ---- Saving: Candidate into a Map, and back ----

  Map<String, dynamic> toJson() {
    return {'name': name, 'votes': votes};
  }

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      name: json['name'] as String,
      votes: (json['votes'] as num).toInt(),
    );
  }
}

/// Trims, removes extra spaces between words, and writes in Title Case.
/// '  keza   uwase ' -> 'Keza Uwase'
String cleanName(String raw) {
  final words = raw.trim().split(RegExp(r'\s+'));
  return words
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

class Election {
  final List<Candidate> candidates = [
    Candidate(name: 'Keza Uwase'),
    Candidate(name: 'Mutoni Aline'),
    Candidate(name: 'Eric Nshuti'),
  ];

  /// Cleaned names of everyone who has already voted.
  final List<String> voters = [];

  int get totalVotes => voters.length;

  // ---- Saving: the whole election into a Map, and back ----

  Map<String, dynamic> toJson() {
    return {
      'candidates': candidates.map((c) => c.toJson()).toList(),
      'voters': voters,
    };
  }

  /// Replaces the sample data with the saved candidates, votes and voters.
  void loadFromJson(Map<String, dynamic> json) {
    final savedCandidates = json['candidates'] as List;
    final savedVoters = json['voters'] as List;
    candidates
      ..clear()
      ..addAll(
        savedCandidates.map(
          (x) => Candidate.fromJson(x as Map<String, dynamic>),
        ),
      );
    voters
      ..clear()
      ..addAll(savedVoters.map((x) => x as String));
  }

  // ---- Rules: each returns a message if refused, or null if it worked ----

  String? vote(String rawName, Candidate candidate) {
    final voter = cleanName(rawName); // clean BEFORE comparing
    if (voter.isEmpty) return 'Enter your name first';
    if (voters.contains(voter)) return '$voter has already voted';
    voters.add(voter);
    candidate.votes++;
    return null;
  }

  String? addCandidate(String rawName) {
    final name = cleanName(rawName);
    if (name.isEmpty) return 'Candidate name cannot be empty';
    if (candidates.any((c) => c.name == name)) {
      return '$name is already a candidate';
    }
    candidates.add(Candidate(name: name));
    return null;
  }

  String? removeCandidate(Candidate candidate) {
    if (candidate.votes > 0) {
      return '${candidate.name} has votes and cannot be removed';
    }
    candidates.remove(candidate);
    return null;
  }

  /// Used by Undo: puts a removed candidate back in the same position.
  void restoreCandidate(int position, Candidate candidate) {
    candidates.insert(position, candidate);
  }

  void reset() {
    voters.clear();
    for (final c in candidates) {
      c.votes = 0;
    }
  }

  // ---- Results ----

  /// A NEW list sorted highest votes first (the real list keeps its order).
  /// Equal votes are ordered by name so the order never jumps around.
  List<Candidate> get ranked {
    final copy = List<Candidate>.of(candidates);
    copy.sort((a, b) {
      final byVotes = b.votes.compareTo(a.votes); // b first = descending
      return byVotes != 0 ? byVotes : a.name.compareTo(b.name);
    });
    return copy;
  }

  /// Percentage of all votes, 0 when nobody has voted (never NaN).
  double percentOf(Candidate candidate) {
    if (totalVotes == 0) return 0;
    return candidate.votes / totalVotes * 100;
  }

  /// 'No votes yet', 'Winner: X', or 'Tie between X and Y (4 votes each)'.
  String get banner {
    if (totalVotes == 0) return 'No votes yet';
    final topVotes = ranked.first.votes;
    final leaders = candidates.where((c) => c.votes == topVotes).toList();
    if (leaders.length == 1) return 'Winner: ${leaders.first.name}';
    final names = leaders.map((c) => c.name).toList();
    final joined = names.length == 2
        ? '${names[0]} and ${names[1]}'
        : '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
    return 'Tie between $joined ($topVotes votes each)';
  }
}
