import 'package:flutter/material.dart';

import 'election_builder.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ElectionBuilder(
          builder: (context, election) {
            final ranked = election.ranked;
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    election.banner,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ranked.isEmpty
                      ? const Center(child: Text('No candidates yet'))
                      : ListView.builder(
                          itemCount: ranked.length,
                          itemBuilder: (context, index) {
                            final candidate = ranked[index];
                            final percent = election.percentOf(candidate);
                            final word =
                                candidate.votes == 1 ? 'vote' : 'votes';
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${index + 1}. ${candidate.name}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ),
                                        Text(
                                          '${candidate.votes} $word · '
                                          '${percent.toStringAsFixed(1)}%',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: percent / 100,
                                      minHeight: 12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
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
    );
  }
}
