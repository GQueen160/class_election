import 'package:flutter/material.dart';

import '../election.dart';
import '../storage.dart';
import 'candidates_screen.dart';
import 'results_screen.dart';
import 'weather_strip.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  // The one Election object of the whole app. Other screens receive it.
  final election = Election();
  final nameController = TextEditingController();
  bool loading = true; // true until the saved election is read

  @override
  void initState() {
    super.initState();
    start();
  }

  // Part 2: read the saved election once when the app opens.
  Future<void> start() async {
    await loadElection(election);
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

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

  void castVote(Candidate candidate) {
    final error = election.vote(nameController.text, candidate);
    if (error != null) {
      showMessage(error);
      return; // refused: nothing changed
    }
    final voter = cleanName(nameController.text);
    setState(() {
      nameController.clear();
    });
    saveElection(election); // Part 2: save after every vote
    showMessage('$voter voted. Thank you!');
  }

  void openResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(election: election),
      ),
    );
  }

  void openCandidates() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidatesScreen(election: election),
      ),
    ).then((_) {
      // Candidates may have changed (or votes reset): redraw this screen.
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final candidates = election.candidates;

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                              child: Text(candidate.name[0]),
                            ),
                            title: Text(candidate.name),
                            trailing: FilledButton(
                              onPressed: () => castVote(candidate),
                              child: const Text('Vote'),
                            ),
                          ),
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
