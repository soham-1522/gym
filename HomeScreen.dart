import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';

/// ==================
/// MODEL: Workout
/// ==================
class Workout {
  final String id;
  final String name;
  final String description;
  final String difficulty;
  final int duration;
  final List<String> musclesTargeted;
  final String category;
  final List<String> equipment;
  final String? gifAsset; // 👈 added field for gif path (assets/gifs/*.gif)
  final bool completed;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.musclesTargeted,
    required this.category,
    required this.equipment,
    this.gifAsset,
    this.completed = false,
  });

  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      difficulty: data['difficulty'] ?? '',
      duration: data['duration'] ?? 0,
      musclesTargeted: List<String>.from(data['musclesTargeted'] ?? []),
      category: data['category'] ?? '',
      equipment: List<String>.from(data['equipment'] ?? []),
      gifAsset: data['gifAsset'], // store gif path like assets/gifs/pose.gif
      completed: data['completed'] ?? false,
    );
  }
}

/// ==================
/// MAIN
/// ==================
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Workout App",
      theme: ThemeData(
        fontFamily: "Roboto",
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// ==================
/// HOME SCREEN
/// ==================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String selectedCategory = "All";
  String selectedDifficulty = "All";

  final List<String> categories = ["All", "Strength", "Cardio", "Yoga"];
  final List<String> difficultyLevels = ["All", "Easy", "Medium", "Hard"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🏋️ Workouts",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          _buildChipRow(categories, selectedCategory, (cat) {
            setState(() => selectedCategory = cat);
          }),
          _buildChipRow(difficultyLevels, selectedDifficulty, (dif) {
            setState(() => selectedDifficulty = dif);
          }, showAdd: true),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('workouts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final workouts = snapshot.data!.docs
                    .map((doc) => Workout.fromFirestore(doc))
                    .where((w) =>
                (selectedCategory == "All" ||
                    w.category == selectedCategory) &&
                    (selectedDifficulty == "All" ||
                        w.difficulty == selectedDifficulty))
                    .toList();

                if (workouts.isEmpty) {
                  return const Center(
                    child: Text("No workouts found.",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return Hero(
                      tag: workout.id,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WorkoutDetailScreen(workout: workout),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.85),
                                AppColors.primary.withOpacity(0.55),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: Icon(
                                  workout.category == "Cardio"
                                      ? Icons.directions_run
                                      : workout.category == "Yoga"
                                      ? Icons.self_improvement
                                      : Icons.fitness_center,
                                  color: Colors.black,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(workout.name,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.timer,
                                            size: 16, color: Colors.white70),
                                        const SizedBox(width: 4),
                                        Text("${workout.duration} min",
                                            style: const TextStyle(
                                                color: Colors.white70)),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.star,
                                            size: 16,
                                            color: Colors.yellowAccent),
                                        const SizedBox(width: 4),
                                        Text(workout.difficulty,
                                            style: const TextStyle(
                                                color: Colors.white70)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                workout.completed
                                    ? Icons.check_circle
                                    : Icons.chevron_right,
                                color: workout.completed
                                    ? Colors.greenAccent
                                    : Colors.white,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow(List<String> items, String selected,
      Function(String) onTap, {bool showAdd = false}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ChoiceChip(
                label: Text(item),
                selected: selected == item,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                    color: selected == item ? Colors.white : Colors.black),
                onSelected: (val) => onTap(item),
              ),
            );
          }).toList(),
          if (showAdd)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddWorkoutScreen()),
                    );
                  },
                ),
              ),
            )
        ],
      ),
    );
  }
}

/// ==================
/// ADD WORKOUT (stub)
/// ==================
class AddWorkoutScreen extends StatelessWidget {
  const AddWorkoutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Workout"),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text("This is where you will add a new workout.",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

/// ==================
/// WORKOUT DETAIL + Stopwatch + GIF
/// ==================
class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  String elapsedTime = "00:00";

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startStopwatch() {
    if (!stopwatch.isRunning) {
      stopwatch.start();
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final seconds = stopwatch.elapsed.inSeconds;
        final minutes = seconds ~/ 60;
        final remainingSeconds = seconds % 60;
        setState(() {
          elapsedTime =
          "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
        });
      });
    }
  }

  void stopStopwatch() {
    stopwatch.stop();
    timer?.cancel();
  }

  void resetStopwatch() {
    stopwatch.reset();
    setState(() {
      elapsedTime = "00:00";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: widget.workout.id,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.workout.name),
                background: widget.workout.gifAsset != null
                    ? Image.asset(widget.workout.gifAsset!,
                    fit: BoxFit.cover)
                    : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.9),
                        AppColors.primary.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                      child: Icon(Icons.fitness_center,
                          size: 100, color: Colors.white30)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.workout.description,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87)),
                    const SizedBox(height: 20),

                    // ✅ Stopwatch Section
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.timer,
                                size: 40, color: Colors.blue),
                            const SizedBox(height: 10),
                            Text(elapsedTime,
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: startStopwatch,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  child: const Text("Start"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: stopStopwatch,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: const Text("Stop"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: resetStopwatch,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey),
                                  child: const Text("Reset"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    _infoCard(Icons.timer, "${widget.workout.duration} min"),
                    _infoCard(Icons.star, widget.workout.difficulty,
                        iconColor: Colors.amber),
                    _infoCard(Icons.category, widget.workout.category),
                    if (widget.workout.musclesTargeted.isNotEmpty)
                      _infoCard(Icons.accessibility_new,
                          "Muscles: ${widget.workout.musclesTargeted.join(', ')}"),
                    if (widget.workout.equipment.isNotEmpty)
                      _infoCard(Icons.fitness_center,
                          "Equipment: ${widget.workout.equipment.join(', ')}"),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String text,
      {Color iconColor = AppColors.primary}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(text),
      ),
    );
  }
}
