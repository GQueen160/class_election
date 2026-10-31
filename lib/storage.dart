// Saving the election in Firestore, under users/{uid}/...
// Only open these after the gate: currentUser! needs someone logged in.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'election.dart';

DocumentReference<Map<String, dynamic>> _me() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance.collection('users').doc(uid);
}

/// The signed-in user's candidates: users/{uid}/candidates
CollectionReference<Map<String, dynamic>> myCandidates() {
  return _me().collection('candidates');
}

/// The signed-in user's voters: users/{uid}/voters
CollectionReference<Map<String, dynamic>> myVoters() {
  return _me().collection('voters');
}

/// Sample data, written once when a new account is created.
Future<void> addSampleData() async {
  final samples = [
    Candidate(name: 'Keza Uwase'),
    Candidate(name: 'Mutoni Aline'),
    Candidate(name: 'Eric Nshuti'),
  ];
  final batch = FirebaseFirestore.instance.batch();
  for (final c in samples) {
    batch.set(myCandidates().doc(), {
      ...c.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
}

/// One vote: the voter and the candidate's count change together, or not at all.
Future<void> saveVote(String voter, Candidate candidate) async {
  final batch = FirebaseFirestore.instance.batch();
  batch.set(myVoters().doc(), {
    ...Voter(name: voter).toMap(),
    'createdAt': FieldValue.serverTimestamp(),
  });
  batch.update(myCandidates().doc(candidate.id), {
    'votes': FieldValue.increment(1),
  });
  await batch.commit();
}

Future<void> addCandidate(String name) async {
  await myCandidates().add({
    ...Candidate(name: name).toMap(),
    'createdAt': FieldValue.serverTimestamp(),
  });
}

/// Only the name changes, so a vote arriving at the same time is never lost.
Future<void> renameCandidate(Candidate candidate, String name) async {
  await myCandidates().doc(candidate.id).update({'name': name});
}

Future<void> deleteCandidate(Candidate candidate) async {
  await myCandidates().doc(candidate.id).delete();
}

/// Used by Undo: writes the same data back under the same id.
Future<void> restoreCandidate(Candidate candidate) async {
  await myCandidates().doc(candidate.id).set({
    ...candidate.toMap(),
    if (candidate.createdAt != null) 'createdAt': candidate.createdAt,
  });
}

/// Deletes every voter and puts every candidate back to 0 votes.
Future<void> resetVotes(Election election) async {
  final batch = FirebaseFirestore.instance.batch();
  for (final v in election.voters) {
    batch.delete(myVoters().doc(v.id));
  }
  for (final c in election.candidates) {
    batch.update(myCandidates().doc(c.id), {'votes': 0});
  }
  await batch.commit();
}
