import 'package:flutter/material.dart';

class AchievementsPage extends StatelessWidget {
  final List<MeterAchievement> leaderboard;
  final String? selectedMeter;

  const AchievementsPage({Key? key, required this.leaderboard, required this.selectedMeter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safely find the leader (first item in sorted leaderboard)
    final leader = leaderboard.isNotEmpty ? leaderboard.first : null;

    // Safely find selected meter entry or null if not present
    final selected = leaderboard.where((m) => m.meterId == selectedMeter).isNotEmpty
        ? leaderboard.firstWhere((m) => m.meterId == selectedMeter)
        : null;

    final double gapKWh = (selected != null && leader != null)
        ? (selected.totalConsumption - leader.totalConsumption)
        : 0.0;

    final int selectedPosition = selected != null ? leaderboard.indexOf(selected) + 1 : -1;

    // Build dynamic achievements list with descriptions about leader and gap
    final achievements = [
      Achievement(
        title: "Saved 10 kWh",
        points: 50,
        description: (gapKWh > 0)
            ? "Your meter is ${gapKWh.toStringAsFixed(3)} kWh behind the leader."
            : "Great! You are the leader!",
      ),
      Achievement(
        title: "Top 3 in leaderboard",
        points: 100,
        description: (selectedPosition > 0 && selectedPosition <= 3)
            ? "You are in the top 3 on the leaderboard!"
            : "Keep going, reach the top 3!",
      ),
      Achievement(
        title: "Weekly Challenge Winner",
        points: 200,
        description: (leader != null &&
                selected != null &&
                selected.meterId == leader.meterId)
            ? "Congratulations! You won this week's challenge!"
            : "Try harder to win the next challenge.",
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Achievements")),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: achievements.map((achievement) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(achievement.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: achievement.description != null
                  ? Text(achievement.description!)
                  : null,
              trailing: Text("${achievement.points} pts"),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Simple Achievement data class
class Achievement {
  final String title;
  final int points;
  final String? description;

  Achievement({
    required this.title,
    required this.points,
    this.description,
  });
}

// MeterAchievement model expected to be passed from DashboardPage (or rename to your class)
class MeterAchievement {
  final String meterId;
  final double totalConsumption;
  final double totalCarbon;

  MeterAchievement(this.meterId, this.totalConsumption, this.totalCarbon);
}
