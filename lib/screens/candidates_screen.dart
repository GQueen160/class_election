import 'package:flutter/material.dart';

import '../election.dart';
import '../storage.dart';
import 'election_builder.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final nameController = TextEditingController();
  Candidate? editing; // the candidate in the form, null when adding a new one

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

  void startEditing(Candidate candidate) {
    setState(() {
      editing = candidate;
      nameController.text = candidate.name;
    });
  }

  void stopEditing() {
    setState(() {
      editing = null;
      nameController.clear();
    });
  }

  /// Adds a new candidate, or saves the new name of the one being edited.
  Future<void> submit(Election election) async {
    final current = editing;
    final error = election.checkCandidateName(
      nameController.text,
      editing: current,
    );
    if (error != null) {
      showMessage(error);
      return;
    }
    final name = cleanName(nameController.text);
    stopEditing();
    try {
      if (current == null) {
        await addCandidate(name);
      } else {
        await renameCandidate(current, name);
      }
    } catch (e) {
      if (mounted) showMessage('Could not save. $e');
    }
  }

  Future<void> confirmDelete(Election election, Candidate candidate) async {
    final error = election.checkRemove(candidate);
    if (error != null) {
      showMessage(error);
      return;
    }
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: Text('${candidate.name} will be removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (sure != true || !mounted) return;
    if (editing?.id == candidate.id) stopEditing();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${candidate.name} removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => restoreCandidate(candidate),
          ),
        ),
      );
    try {
      await deleteCandidate(candidate);
    } catch (e) {
      if (mounted) showMessage('Could not delete. $e');
    }
  }

  void confirmReset(Election election) {
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
                Navigator.pop(context);
                resetVotes(election).catchError((Object e) {
                  if (mounted) showMessage('Could not reset. $e');
                });
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
    return Scaffold(
      appBar: AppBar(title: const Text('Candidates')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ElectionBuilder(
          builder: (context, election) {
            final candidates = election.candidates;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => submit(election),
                        decoration: InputDecoration(
                          labelText:
                              editing == null ? 'New candidate' : 'Edit name',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => submit(election),
                      child: Text(editing == null ? 'Add' : 'Save'),
                    ),
                    if (editing != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Cancel edit',
                        onPressed: stopEditing,
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
                            final word =
                                candidate.votes == 1 ? 'vote' : 'votes';
                            return Card(
                              child: ListTile(
                                title: Text(candidate.name),
                                subtitle: Text('${candidate.votes} $word'),
                                onTap: () => startEditing(candidate),
                                onLongPress: () =>
                                    confirmDelete(election, candidate),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Remove',
                                  onPressed: () =>
                                      confirmDelete(election, candidate),
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
                    onPressed: () => confirmReset(election),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset all votes'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
