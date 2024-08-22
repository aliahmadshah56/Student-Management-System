import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressPage extends StatelessWidget {
  final int totalTopics;
  final int completedTopics;
  final int pendingTopics;
  final List<String> completedTopicList;

  ProgressPage({
    required this.totalTopics,
    required this.completedTopics,
    required this.pendingTopics,
    required this.completedTopicList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Topics: $totalTopics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Completed Topics: $completedTopics',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Pending Topics: $pendingTopics',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: showingSections(),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 50,
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showCompletedTopics(context);
              },
              child: Text('Show Completed Topics'),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    double total = completedTopics.toDouble() + pendingTopics.toDouble();

    if (total == 0) {
      return []; // No data to show
    }

    return [
      PieChartSectionData(
        color: Colors.blue,
        value: (completedTopics.toDouble() / total) * 100,
        title: '${completedTopics.toString()} (${(completedTopics.toDouble() /
            total * 100).toStringAsFixed(1)}%)',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: (pendingTopics.toDouble() / total) * 100,
        title: '${pendingTopics.toString()} (${(pendingTopics.toDouble() /
            total * 100).toStringAsFixed(1)}%)',
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  void _showCompletedTopics(BuildContext context) {
    if (completedTopicList.isEmpty) {
      // Handle case when the list is empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Completed Topics',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'No completed topics available.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Completed Topics',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemCount: completedTopicList.length,
              itemBuilder: (context, index) {
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '• ',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: completedTopicList[index],  // Display the topic name
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

}