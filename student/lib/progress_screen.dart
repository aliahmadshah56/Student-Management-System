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
        title: Text('Progress Page'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 4,
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
                child: ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    SizedBox(height: 20),
                    _buildProgressSummary(
                        context, totalTopics, completedTopics, pendingTopics),
                    SizedBox(height: 40),
                    _buildPieChart(completedTopics.length, pendingTopics.length,
                        totalTopics),
                    SizedBox(height: 60),
                    _buildTopicButtons(context, completedTopics, pendingTopics),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProgressSummary(BuildContext context, int totalTopics,
      List<Map<String, dynamic>> completedTopics, List<Map<String, dynamic>> pendingTopics) {
    return Column(
      children: [
        Text(
          'Total Topics: $totalTopics',
          style: TextStyle(
            color: Colors.teal,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Completed Topics: ${completedTopics.length}',
          style: TextStyle(color: Colors.green, fontSize: 18),
        ),
        SizedBox(height: 10),
        Text(
          'Pending Topics: ${pendingTopics.length}',
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildPieChart(int completedCount, int pendingCount, int totalCount) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            sections: _showingSections(completedCount, pendingCount, totalCount),
            borderData: FlBorderData(show: false),
            sectionsSpace: 6,
            centerSpaceRadius: 60,
          ),
        ),
      ),
    );
  }

  Widget _buildTopicButtons(BuildContext context,
      List<Map<String, dynamic>> completedTopics, List<Map<String, dynamic>> pendingTopics) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            _showTopics(context, completedTopics, 'Completed Topics');
          },
          child: Text('Completed Topics',style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _showTopics(context, pendingTopics, 'Pending Topics');
          },
          child: Text('Pending Topics',style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
      ],
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

  void _showTopics(BuildContext context, List<Map<String, dynamic>> topics,
      String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            width: double.maxFinite,
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                return ListTile(
                  title: Text(topic['name']),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
