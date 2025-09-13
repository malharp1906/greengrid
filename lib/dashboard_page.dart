import 'dart:async';
import 'package:flutter/material.dart';
import 'energy_reading.dart';  // Your model with meterId, consumption, carbon, timestamp
import 'api_service.dart';    // Your API fetch logic
import 'energy_chart.dart';   // Chart widget
import 'achievements_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Store all fetched readings cumulatively
  final Map<String, List<EnergyReading>> readingsByMeter = {};

  String? selectedMeter;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(const Duration(seconds: 10), (_) => fetchData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Fetch new data and merge into existing totals
  Future<void> fetchData() async {
    try {
      final data = await ApiService.fetchEnergyData();

      setState(() {
        // Add incoming readings grouped by meter_id
        for (var reading in data) {
          if (!readingsByMeter.containsKey(reading.meterId)) {
            readingsByMeter[reading.meterId] = [];
          }
          readingsByMeter[reading.meterId]!.add(reading);
        }

        // Default select first meter if none chosen yet
        selectedMeter ??= readingsByMeter.keys.isNotEmpty ? readingsByMeter.keys.first : null;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Flatten list of all meters with accumulated totals
    List<_MeterTotals> meterTotals = readingsByMeter.entries.map((e) {
      final totalConsumption = e.value.fold<double>(
          0.0, (sum, r) => sum + r.consumption);
      final totalCarbon = e.value.fold<double>(0.0, (sum, r) => sum + r.carbon);
      return _MeterTotals(e.key, totalConsumption, totalCarbon);
    }).toList();

    // Sort leaderboard by lowest consumption then by carbon
    meterTotals.sort((a, b) {
      final comp = a.totalConsumption.compareTo(b.totalConsumption);
      return (comp != 0) ? comp : a.totalCarbon.compareTo(b.totalCarbon);
    });

    // Prepare readings list for the chart (selected meter only)
    final filteredReadings = selectedMeter == null
        ? <EnergyReading>[]
        : readingsByMeter[selectedMeter!] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: readingsByMeter.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Meter selector dropdown
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DropdownButton<String>(
                    value: selectedMeter,
                    items: meterTotals
                        .map(
                          (mt) => DropdownMenuItem<String>(
                            value: mt.meterId,
                            child: Text("Meter ${mt.meterId}"),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMeter = value;
                      });
                    },
                    isExpanded: true,
                  ),
                ),

                // Consumption chart for selected meter
                SizedBox(
                  height: 280,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: EnergyChart(readings: filteredReadings),
                  ),
                ),

                const SizedBox(height: 10),

                // Leaderboard list of all meters sorted by efficiency
                Expanded(
                  child: ListView.builder(
                    itemCount: meterTotals.length,
                    itemBuilder: (context, index) {
                      final meter = meterTotals[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text("${index + 1}",
                              style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text("Meter: ${meter.meterId}"),
                        subtitle: Text(
                            "Total Carbon: ${meter.totalCarbon.toStringAsFixed(3)} kg"),
                        trailing: Text(
                            "Total Consumption: ${meter.totalConsumption.toStringAsFixed(3)} kWh"),
                      );
                    },
                  ),
                ),

                // Button to achievements page
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AchievementsPage(
      leaderboard: meterTotals
          .map((m) => MeterAchievement(m.meterId, m.totalConsumption, m.totalCarbon))
          .toList(),
      selectedMeter: selectedMeter,
    ),
  ),
);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Go to Achievements",
                          style:
                              TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// Helper class to hold totals per meter for sorting and display
class _MeterTotals {
  final String meterId;
  final double totalConsumption;
  final double totalCarbon;

  _MeterTotals(this.meterId, this.totalConsumption, this.totalCarbon);
}
