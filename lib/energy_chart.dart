// lib/widgets/energy_chart.dart

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'energy_reading.dart';  // Import your EnergyReading model here

class EnergyChart extends StatelessWidget {
  final List<EnergyReading> readings;
  const EnergyChart({Key? key, required this.readings}) : super(key: key);

  // Simple HH:mm formatter (no extra package required)
  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(child: Text('No data'));
    }

    // Create points
    final spots = List<FlSpot>.generate(
      readings.length,
      (i) => FlSpot(i.toDouble(), readings[i].consumption),
    );

    // Compute safe y-axis bounds with padding to avoid line going out of bounds
    final minConsumption = readings.map((r) => r.consumption).reduce(math.min);
    final maxConsumption = readings.map((r) => r.consumption).reduce(math.max);

    final padding = (maxConsumption - minConsumption).abs() * 0.25;

    final safeMinY = (minConsumption - padding) < 0 ? 0 : (minConsumption - padding);
    final safeMaxY = (maxConsumption + padding) > 0 ? (maxConsumption + padding) : 1.0;

    // How many bottom labels to show (avoids clutter)
    int step = (readings.length / 6).ceil();
    if (step < 1) step = 1;
    if (step > readings.length) step = readings.length;

    return LineChart(
      LineChartData(
        minY: safeMinY.toDouble(),
        maxY: safeMaxY.toDouble(),
        gridData: FlGridData(show: true, drawVerticalLine: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) {
                return Text(value.toStringAsFixed(3),
                    style: const TextStyle(fontSize: 10));
              },
            ),
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text('Consumption (kWh)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            axisNameSize: 16,
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= readings.length) return const SizedBox.shrink();
                // Show label only every `step` items to reduce overlap
                if (idx % step != 0) return const SizedBox.shrink();
                return Text(
                  _formatTime(readings[idx].timestamp),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(top: 0),
              child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            axisNameSize: 16,
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: spots,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData:
                BarAreaData(show: true, color: Colors.green.withOpacity(0.25)),
          ),
        ],
      ),
    );
  }
}
