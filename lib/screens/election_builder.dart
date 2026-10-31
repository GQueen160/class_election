import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../election.dart';
import '../storage.dart';

/// Listens to candidates and voters, and handles the error and loading states.
/// Each screen shows its own empty state, then its data, inside [builder].
class ElectionBuilder extends StatefulWidget {
  const ElectionBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, Election election) builder;

  @override
  State<ElectionBuilder> createState() => _ElectionBuilderState();
}

class _ElectionBuilderState extends State<ElectionBuilder> {
  // Opened once here, so a rebuild of the screen doesn't listen all over again.
  final candidates = myCandidates().orderBy('name').snapshots();
  final voters = myVoters().snapshots();

  Widget errorMessage(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Could not load the election.\n$error',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: candidates,
      builder: (context, candidateSnapshot) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: voters,
          builder: (context, voterSnapshot) {
            if (candidateSnapshot.hasError) {
              return errorMessage(candidateSnapshot.error);
            }
            if (voterSnapshot.hasError) {
              return errorMessage(voterSnapshot.error);
            }
            if (!candidateSnapshot.hasData || !voterSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final election = Election(
              candidates:
                  candidateSnapshot.data!.docs.map(Candidate.fromDoc).toList(),
              voters: voterSnapshot.data!.docs.map(Voter.fromDoc).toList(),
            );
            return widget.builder(context, election);
          },
        );
      },
    );
  }
}
