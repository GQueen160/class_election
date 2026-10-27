import 'package:flutter/material.dart';

import '../election.dart';
import '../storage.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key, required this.election});

  final Election election;

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
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

  void addCandidate() {
    final error = widget.election.addCandidate(nameController.text);
    if (error != null) {
      showMessage(error);
      return;
    }
    setState(() {
      nameController.clear();
    });
    saveElection(widget.election); // Part 2: save after adding
  }

  void removeCandidate(Candidate candidate) {
    final election = widget.election;
    final position = election.candidates.indexOf(candidate); // for Undo
    final error = election.removeCandidate(candidate);
    if (error != null) {
      showMessage(error);
      return;
    }
    setState(() {});
    saveElection(election); // Part 2: save after deleting
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${candidate.name} removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              election.restoreCandidate(position, candidate);
              saveElection(election); // Part 2: save after Undo
              if (mounted) {
                setState(() {});
              }
            },
          ),
        ),
      );
  }

  void confirmReset() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset all votes?'),
          content: const Text(
            'Every vote will be deleted and everyone can vote again. '
            'The candidates stay.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  widget.election.reset();
                });
                saveElection(widget.election); // Part 2: save after reset
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final candidates = widget.election.candidates;

    return Scaffold(
      appBar: AppBar(title: const Text('Candidates')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => addCandidate(),
                    decoration: const InputDecoration(
                      labelText: 'New candidate',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: addCandidate,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: candidates.isEmpty
                  ? const Center(child: Text('No candidates yet'))
                  : ListView.builder(
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        final candidate = candidates[index];
                        final word = candidate.votes == 1 ? 'vote' : 'votes';
                        return Card(
                          child: ListTile(
                            title: Text(candidate.name),
                            subtitle: Text('${candidate.votes} $word'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Remove',
                              onPressed: () => removeCandidate(candidate),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: confirmReset,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset all votes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
