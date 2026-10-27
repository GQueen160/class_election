import 'dart:convert';

import 'package:class_election/election.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cleanName trims, collapses spaces and uses Title Case', () {
    expect(cleanName('  keza   uwase '), 'Keza Uwase');
    expect(cleanName('aLINE'), 'Aline');
    expect(cleanName('    '), '');
  });

  test('a voter can vote only once, even written differently', () {
    final e = Election();
    expect(e.vote(' aLINE ', e.candidates[0]), isNull);
    expect(e.vote('Aline', e.candidates[1]), 'Aline has already voted');
    expect(e.vote('   ', e.candidates[1]), 'Enter your name first');
    expect(e.totalVotes, 1);
  });

  test('4, 4 and 1 votes give 44.4%, 44.4%, 11.1% and a tie', () {
    final e = Election();
    for (var i = 0; i < 4; i++) {
      e.vote('a$i', e.candidates[0]);
      e.vote('b$i', e.candidates[1]);
    }
    e.vote('c0', e.candidates[2]);
    expect(e.percentOf(e.candidates[0]).toStringAsFixed(1), '44.4');
    expect(e.percentOf(e.candidates[2]).toStringAsFixed(1), '11.1');
    expect(e.banner, 'Tie between Keza Uwase and Mutoni Aline (4 votes each)');
    expect(e.ranked.last.name, 'Eric Nshuti');
  });

  test('a single leader is the winner', () {
    final e = Election();
    e.vote('x', e.candidates[1]);
    expect(e.banner, 'Winner: Mutoni Aline');
  });

  test('before any vote the banner says No votes yet, never NaN', () {
    final e = Election();
    expect(e.banner, 'No votes yet');
    expect(e.percentOf(e.candidates[0]), 0);
  });

  test('candidate rules', () {
    final e = Election();
    expect(e.addCandidate('  '), 'Candidate name cannot be empty');
    expect(e.addCandidate(' keza uwase '), 'Keza Uwase is already a candidate');
    expect(e.addCandidate('  new   person '), isNull);
    expect(e.candidates.last.name, 'New Person');
    e.vote('v', e.candidates[0]);
    expect(e.removeCandidate(e.candidates[0]),
        'Keza Uwase has votes and cannot be removed');
    expect(e.removeCandidate(e.candidates[1]), isNull);
  });

  test('reset clears votes and voters but keeps candidates', () {
    final e = Election();
    e.vote('v', e.candidates[0]);
    e.reset();
    expect(e.banner, 'No votes yet');
    expect(e.candidates.length, 3);
    expect(e.vote('v', e.candidates[0]), isNull);
  });

  test('saving: votes and voters survive toJson and loadFromJson', () {
    final e = Election();
    e.addCandidate('new person');
    e.vote('aline', e.candidates[0]);
    e.vote('eric', e.candidates[3]);

    final copy = Election();
    copy.loadFromJson(jsonDecode(jsonEncode(e.toJson())) as Map<String, dynamic>);

    expect(copy.candidates.length, 4);
    expect(copy.candidates[3].name, 'New Person');
    expect(copy.candidates[0].votes, 1);
    expect(copy.totalVotes, 2);
    // A voter who voted yesterday still cannot vote again today.
    expect(copy.vote('ALINE', copy.candidates[1]), 'Aline has already voted');
  });
}
