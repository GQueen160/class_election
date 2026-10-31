import 'package:class_election/election.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds an Election the same way the app does from Firestore documents.
Election electionWith(List<int> votes, {List<String> voters = const []}) {
  const names = ['Keza Uwase', 'Mutoni Aline', 'Eric Nshuti'];
  return Election(
    candidates: [
      for (var i = 0; i < votes.length; i++)
        Candidate(id: 'c$i', name: names[i], votes: votes[i]),
    ],
    voters: voters.map((name) => Voter(name: name)).toList(),
  );
}

void main() {
  test('cleanName trims, collapses spaces and uses Title Case', () {
    expect(cleanName('  keza   uwase '), 'Keza Uwase');
    expect(cleanName('aLINE'), 'Aline');
    expect(cleanName('    '), '');
  });

  test('a voter can vote only once, even written differently', () {
    final e = electionWith([1, 0, 0], voters: ['Aline']);
    expect(e.checkVote(' aLINE '), 'Aline has already voted');
    expect(e.checkVote('   '), 'Enter your name first');
    expect(e.checkVote('Eric'), isNull);
    expect(e.totalVotes, 1);
  });

  test('4, 4 and 1 votes give 44.4%, 44.4%, 11.1% and a tie', () {
    final e = electionWith([4, 4, 1]);
    expect(e.percentOf(e.candidates[0]).toStringAsFixed(1), '44.4');
    expect(e.percentOf(e.candidates[2]).toStringAsFixed(1), '11.1');
    expect(e.banner, 'Tie between Keza Uwase and Mutoni Aline (4 votes each)');
    expect(e.ranked.last.name, 'Eric Nshuti');
  });

  test('a single leader is the winner', () {
    expect(electionWith([0, 1, 0]).banner, 'Winner: Mutoni Aline');
  });

  test('before any vote the banner says No votes yet, never NaN', () {
    final e = electionWith([0, 0, 0]);
    expect(e.banner, 'No votes yet');
    expect(e.percentOf(e.candidates[0]), 0);
  });

  test('candidate rules', () {
    final e = electionWith([1, 0, 0]);
    expect(e.checkCandidateName('  '), 'Candidate name cannot be empty');
    expect(e.checkCandidateName(' keza uwase '),
        'Keza Uwase is already a candidate');
    expect(e.checkCandidateName('  new   person '), isNull);
    expect(e.checkRemove(e.candidates[0]),
        'Keza Uwase has votes and cannot be removed');
    expect(e.checkRemove(e.candidates[1]), isNull);
  });

  test('editing a candidate may keep their name but not take another', () {
    final e = electionWith([0, 0, 0]);
    final keza = e.candidates[0];
    expect(e.checkCandidateName('keza uwase', editing: keza), isNull);
    expect(e.checkCandidateName('eric nshuti', editing: keza),
        'Eric Nshuti is already a candidate');
  });

  test('a votes change made in the console keeps the results right', () {
    final e = electionWith([5, 0, 0], voters: ['Aline']);
    expect(e.totalVotes, 5);
    expect(e.percentOf(e.candidates[0]), 100);
  });
}
