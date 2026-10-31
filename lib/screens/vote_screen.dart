import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../election.dart';
import '../storage.dart';
import 'candidates_screen.dart';
import 'election_builder.dart';
import 'results_screen.dart';
import 'weather_strip.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> castVote(Election election, Candidate candidate) async {
    final error = election.checkVote(nameController.text);
    if (error != null) {
      showMessage(error);
      return; // refused: nothing changed
    }
    final voter = cleanName(nameController.text);
    nameController.clear();
    try {
      await saveVote(voter, candidate);
      if (mounted) showMessage('$voter voted. Thank you!');
    } catch (e) {
      if (mounted) showMessage('Could not save the vote. $e');
    }
  }

  void openResults() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResultsScreen()),
    );
  }

  void openCandidates() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CandidatesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ijwi · Class Election'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Results',
            onPressed: openResults,
          ),
          IconButton(
            icon: const Icon(Icons.groups),
            tooltip: 'Candidates',
            onPressed: openCandidates,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WeatherStrip(), // live data from an API
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Your name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ElectionBuilder(
                builder: (context, election) {
                  final candidates = election.candidates;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Votes so far: ${election.totalVotes}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: candidates.isEmpty
                            ? const Center(
                                child: Text(
                                  'No candidates yet.\nAdd some on the Candidates screen.',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.builder(
                                itemCount: candidates.length,
                                itemBuilder: (context, index) {
                                  final candidate = candidates[index];
                                  return Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                          candidate.name.isEmpty
                                              ? '?'
                                              : candidate.name[0],
                                        ),
                                      ),
                                      title: Text(candidate.name),
                                      trailing: FilledButton(
                                        onPressed: () =>
                                            castVote(election, candidate),
                                        child: const Text('Vote'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
