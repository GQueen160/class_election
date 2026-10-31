// The "brain" of the app: data + rules. No widgets in this file.

import 'package:cloud_firestore/cloud_firestore.dart';

class Candidate {
  Candidate({this.id = '', required this.name, this.votes = 0, this.createdAt});

  final String id; // the Firestore document id
  final String name;
  final int votes;
  final Timestamp? createdAt;

  // ---- Saving: Candidate into a Map, and back ----

  Map<String, dynamic> toMap() {
    return {'name': name, 'votes': votes};
  }

  factory Candidate.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final votes = data['votes'];
    final createdAt = data['createdAt'];
    return Candidate(
      id: doc.id,
      name: '${data['name'] ?? ''}',
      votes: votes is num ? votes.toInt() : 0, // a console edit can't crash us
      createdAt: createdAt is Timestamp ? createdAt : null,
    );
  }
}

class Voter {
  Voter({this.id = '', required this.name});

  final String id; // the Firestore document id
  final String name;

  Map<String, dynamic> toMap() {
    return {'name': name};
  }

  factory Voter.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Voter(id: doc.id, name: '${doc.data()!['name'] ?? ''}');
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

/// Built again from the Firestore documents every time they change.
/// Nothing computed here is ever saved.
class Election {
  Election({required this.candidates, required this.voters});

  final List<Candidate> candidates;
  final List<Voter> voters;

  int get totalVotes => candidates.fold(0, (total, c) => total + c.votes);

  // ---- Rules: each returns a message if refused, or null if allowed ----

  String? checkVote(String rawName) {
    final voter = cleanName(rawName); // clean BEFORE comparing
    if (voter.isEmpty) return 'Enter your name first';
    if (voters.any((v) => v.name == voter)) return '$voter has already voted';
    return null;
  }

  /// [editing] is the candidate being renamed: their own name is allowed.
  String? checkCandidateName(String rawName, {Candidate? editing}) {
    final name = cleanName(rawName);
    if (name.isEmpty) return 'Candidate name cannot be empty';
    if (candidates.any((c) => c.name == name && c.id != editing?.id)) {
      return '$name is already a candidate';
    }
    return null;
  }

  String? checkRemove(Candidate candidate) {
    if (candidate.votes > 0) {
      return '${candidate.name} has votes and cannot be removed';
    }
    return null;
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
