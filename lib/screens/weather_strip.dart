import 'package:flutter/material.dart';

import '../weather.dart';

/// Election-day weather in Kigali, with the three states:
/// loading (spinner), error (message + Retry) and data.
class WeatherStrip extends StatefulWidget {
  const WeatherStrip({super.key});

  @override
  State<WeatherStrip> createState() => _WeatherStripState();
}

class _WeatherStripState extends State<WeatherStrip> {
  Weather? weather;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await fetchWeather();
      if (!mounted) return;
      setState(() {
        weather = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not load the weather.';
      });
    }
  }

  void retry() {
    setState(() {
      loading = true;
      error = null;
    });
    load();
  }

  IconData iconFor(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.cloud;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 95) return Icons.thunderstorm;
    if (code >= 51) return Icons.water_drop;
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (loading) {
      child = const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading election-day weather...'),
        ],
      );
    } else if (error != null) {
      child = Row(
        children: [
          const Icon(Icons.wifi_off),
          const SizedBox(width: 12),
          Expanded(child: Text(error!)),
          TextButton(onPressed: retry, child: const Text('Retry')),
        ],
      );
    } else {
      child = Row(
        children: [
          Icon(iconFor(weather!.code)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Election day in Kigali: ${weather!.temperature.round()}°C, '
              '${describe(weather!.code)}',
            ),
          ),
        ],
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: child,
      ),
    );
  }
}
