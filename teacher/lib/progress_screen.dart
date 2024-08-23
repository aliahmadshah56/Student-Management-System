import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressPage extends StatefulWidget {
  final String studentId;
  final String courseId;

  ProgressPage({required this.studentId, required this.courseId});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  late Future<int> _totalTopicsFuture;
  late Future<List<Map<String, dynamic>>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData(); // Initialize data fetching
  }

  Future<void> _refreshData() async {
    // Fetch data again when pull-to-refresh is triggered
    setState(() {
      _totalTopicsFuture = _fetchTotalTopics();
      _topicsFuture = _fetchTopics();
    });
  }

  Future<int> _fetchTotalTopics() async {
    try {
      final courseDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('enrolledCourses')
          .doc(widget.courseId)
          .get();

      if (courseDoc.exists) {
        final data = courseDoc.data();
        final List<String> showTopics =
            List<String>.from(data?['showTopics'] ?? []);
        return showTopics.length;
      }
    } catch (e) {
      print("Error fetching total topics: $e");
    }
    return 0; // Return 0 if something goes wrong
  }

  Future<List<Map<String, dynamic>>> _fetchTopics() async {
    List<Map<String, dynamic>> topics = [];
    try {
      final courseDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .collection('enrolledCourses')
          .doc(widget.courseId)
          .get();

      if (courseDoc.exists) {
        final data = courseDoc.data();
        final List<String> showTopics =
            List<String>.from(data?['showTopics'] ?? []);

        for (var topicId in showTopics) {
          final statusDoc = await FirebaseFirestore.instance
              .collection('students')
              .doc(widget.studentId)
              .collection('enrolledCourses')
              .doc(widget.courseId)
              .collection('topics')
              .doc(topicId)
              .get();

          final statusData = statusDoc.data();
          String status = 'pending';
          String date = '';

          if (statusData != null) {
            if (statusData['completedAt'] != null) {
              status = 'completed';
              date = (statusData['completedAt'] as Timestamp)
                  .toDate()
                  .toLocal()
                  .toString()
                  .split(' ')[0]; // Only show the date part
            }
          }

          // Fetch topic name from /courses/{courseId}/topics/{topicId}/
          final topicDoc = await FirebaseFirestore.instance
              .collection('courses')
              .doc(widget.courseId)
              .collection('topics')
              .doc(topicId)
              .get();

          String name = topicDoc.data()?['name'] ??
              'Unnamed Topic'; // Default to 'Unnamed Topic' if null

          topics.add(
              {'name': name, 'status': status, 'date': date, 'id': topicId});
        }
      }
    } catch (e) {
      print("Error fetching topics: $e");
    }

    return topics;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Page',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<int>(
        future: _totalTopicsFuture,
        builder: (context, totalTopicsSnapshot) {
          if (totalTopicsSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!totalTopicsSnapshot.hasData) {
            return Center(child: Text('No topics available.'));
          }

          final totalTopics = totalTopicsSnapshot.data ?? 0;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _topicsFuture,
            builder: (context, topicsSnapshot) {
              if (topicsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!topicsSnapshot.hasData || topicsSnapshot.data!.isEmpty) {
                return Center(child: Text('No topics available.'));
              }

              final topics = topicsSnapshot.data!;
              final completedTopics = topics
                  .where((topic) => topic['status'] == 'completed')
                  .toList();
              final pendingTopics = topics
                  .where((topic) => topic['status'] == 'pending')
                  .toList();

              return RefreshIndicator(
                onRefresh: _refreshData,
                // Ensure this is called on pull-to-refresh
                child: ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Total Topics: $totalTopics',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Completed Topics: ${completedTopics.length}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.green, fontSize: 20),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pending Topics: ${pendingTopics.length}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.red, fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(height: 60),
                    Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: PieChart(
                          PieChartData(
                            sections: _showingSections(completedTopics.length,
                                pendingTopics.length, totalTopics),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 8,
                            centerSpaceRadius: 60,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 80),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showTopics(context, completedTopics, 'Completed');
                          },
                          child: Text(
                            'Completed Topics',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showTopics(
                              context,
                              pendingTopics,
                              'Pending ',
                            );
                          },
                          child: Text(
                            'Pending Topics',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _showingSections(
      int completedCount, int pendingCount, int totalCount) {
    return [
      PieChartSectionData(
        color: Colors.green,
        value: completedCount.toDouble(),
        title: '${(completedCount / totalCount * 100).toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: pendingCount.toDouble(),
        title: '${(pendingCount / totalCount * 100).toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  void _showTopics(
      BuildContext context, List<Map<String, dynamic>> topics, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topics[index]['name'],
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (topics[index]['status'] == 'completed')
                        Text(
                          'Completed on: ${topics[index]['date']}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.green,
                                  ),
                        ),
                      if (topics[index]['status'] == 'pending')
                        Text(
                          'Pending',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.red,
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
