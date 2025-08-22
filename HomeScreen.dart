import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Import your other screens
import 'package:soham/screens/diet_screen.dart';
import 'package:soham/screens/profile_screen.dart';
import 'package:soham/utils/colors.dart';

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
  bool completed;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.musclesTargeted,
    required this.category,
    required this.equipment,
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
      completed: data['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'duration': duration,
      'musclesTargeted': musclesTargeted,
      'category': category,
      'equipment': equipment,
      'completed': completed,
    };
  }
}

/// ==================
/// MODEL: Custom Plan
/// ==================
class CustomPlan {
  final String id;
  final String name;
  final List<String> workoutIds;

  CustomPlan({
    required this.id,
    required this.name,
    required this.workoutIds,
  });

  factory CustomPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomPlan(
      id: doc.id,
      name: data['name'] ?? '',
      workoutIds: List<String>.from(data['workoutIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'workoutIds': workoutIds,
    };
  }
}

/// ==================
/// MAIN ENTRY
/// ==================

class GymApp extends StatefulWidget {
  const GymApp({super.key});

  @override
  State<GymApp> createState() => _GymAppState();
}

class _GymAppState extends State<GymApp> {
  int _selectedIndex = 0;
  final String _testUserId = "user123"; // Replace with Firebase Auth UID

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const  NewDietScreen(),
      ProfileScreen(userId: _testUserId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        ),
      ),
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            if (!mounted) return;
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.fitness_center),
              label: 'Workouts',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu),
              label: 'Diet',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedDifficulty = 'All';
  String selectedMuscle = 'All';
  String selectedEquipment = 'All';

  final categories = ['All', 'Strength', 'Cardio', 'Yoga', 'Stretching', 'HIIT'];
  final difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];
  final muscles = ['All', 'Chest', 'Back', 'Legs', 'Arms', 'Shoulders', 'Core', 'Full Body'];
  final equipmentList = [
    'All',
    'None',
    'Dumbbells',
    'Barbell',
    'Kettlebell',
    'Machine',
    'Resistance Bands',
    'Bodyweight',
    'Stationary Bike',
    'Yoga Mat'
  ];

  @override
  void initState() {
    super.initState();
    _addDefaultWorkouts();
  }

  Future<void> _addDefaultWorkouts() async {
    final List<Map<String, dynamic>> defaultWorkouts = [
      {
        'name': 'Morning Run',
        'description': 'A light 20-minute jog to improve endurance and burn fat.',
        'difficulty': 'Beginner',
        'duration': 20,
        'musclesTargeted': ['Legs', 'Core'],
        'category': 'Cardio',
        'equipment': ['None'],
        'completed': false,
      },
      {
        'name': 'Beginner Yoga Flow',
        'description': 'A gentle 15-minute yoga routine focusing on flexibility and breathing.',
        'difficulty': 'Beginner',
        'duration': 15,
        'musclesTargeted': ['Full Body', 'Core'],
        'category': 'Yoga',
        'equipment': ['None', 'Yoga Mat'],
        'completed': false,
      },
      {
        'name': 'Beginner Stretch Routine',
        'description': 'A light 10-minute stretch focusing on all major muscle groups.',
        'difficulty': 'Beginner',
        'duration': 10,
        'musclesTargeted': ['Full Body'],
        'category': 'Stretching',
        'equipment': ['None', 'Yoga Mat'],
        'completed': false,
      },
    ];

    for (var workout in defaultWorkouts) {
      final existing = await _firestore
          .collection('workouts')
          .where('name', isEqualTo: workout['name'])
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        await _firestore.collection('workouts').add(workout);
      }
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _toggleCompleted(Workout workout) async {
    await _firestore.collection('workouts').doc(workout.id).update({
      'completed': !workout.completed,
    });
  }

  void _goToCreatePlan() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateCustomPlanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gym Pro"),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Create Custom Plan',
            onPressed: _goToCreatePlan,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search workouts...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                if (!mounted) return;
                setState(() => searchQuery = val.toLowerCase());
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _buildDropdown('Category', categories, selectedCategory,
                        (v) => setState(() => selectedCategory = v!)),
                _buildDropdown('Difficulty', difficulties, selectedDifficulty,
                        (v) => setState(() => selectedDifficulty = v!)),
                _buildDropdown('Muscle', muscles, selectedMuscle,
                        (v) => setState(() => selectedMuscle = v!)),
                _buildDropdown('Equipment', equipmentList, selectedEquipment,
                        (v) => setState(() => selectedEquipment = v!)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('workouts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var workouts = snapshot.data!.docs.map((doc) => Workout.fromFirestore(doc)).toList();

                workouts = workouts.where((w) {
                  final matchesSearch = w.name.toLowerCase().contains(searchQuery);
                  final matchesCategory = selectedCategory == 'All' || w.category == selectedCategory;
                  final matchesDifficulty = selectedDifficulty == 'All' || w.difficulty == selectedDifficulty;
                  final matchesMuscle = selectedMuscle == 'All' || w.musclesTargeted.contains(selectedMuscle);
                  final matchesEquipment = selectedEquipment == 'All' || w.equipment.contains(selectedEquipment);
                  return matchesSearch && matchesCategory && matchesDifficulty && matchesMuscle && matchesEquipment;
                }).toList();

                if (workouts.isEmpty) {
                  return const Center(child: Text("No workouts found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.fitness_center, color: Colors.white),
                        ),
                        title: Text(workout.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "${workout.duration} min • ${workout.difficulty}\nMuscles: ${workout.musclesTargeted.join(', ')}",
                        ),
                        isThreeLine: true,
                        trailing: Checkbox(
                          value: workout.completed,
                          onChanged: (_) => _toggleCompleted(workout),
                        ),
                        onTap: () => _showWorkoutDetails(workout),
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

  Widget _buildDropdown(String label, List<String> options, String selected, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: DropdownButton<String>(
        value: selected,
        underline: Container(),
        borderRadius: BorderRadius.circular(12),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showWorkoutDetails(Workout workout) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(workout.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(workout.description),
              const SizedBox(height: 8),
              Text("Category: ${workout.category}"),
              Text("Difficulty: ${workout.difficulty}"),
              Text("Duration: ${workout.duration} min"),
              Text("Muscles: ${workout.musclesTargeted.join(', ')}"),
              Text("Equipment: ${workout.equipment.join(', ')}"),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

/// ==================
/// CREATE PLAN SCREEN
/// ==================
class CreateCustomPlanScreen extends StatefulWidget {
  @override
  State<CreateCustomPlanScreen> createState() => _CreateCustomPlanScreenState();
}

class _CreateCustomPlanScreenState extends State<CreateCustomPlanScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  String planName = '';
  List<String> selectedWorkoutIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Custom Plan"),
        actions: [
          TextButton(
            onPressed: _savePlan,
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: "Plan Name",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "Enter plan name" : null,
                onSaved: (val) => planName = val ?? '',
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('workouts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final workouts = snapshot.data!.docs.map((doc) => Workout.fromFirestore(doc)).toList();

                return ListView(
                  children: workouts.map((w) {
                    return CheckboxListTile(
                      title: Text(w.name),
                      subtitle: Text("${w.duration} min • ${w.difficulty}"),
                      value: selectedWorkoutIds.contains(w.id),
                      onChanged: (val) {
                        if (!mounted) return;
                        setState(() {
                          if (val == true) {
                            selectedWorkoutIds.add(w.id);
                          } else {
                            selectedWorkoutIds.remove(w.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await _firestore.collection('custom_plans').add({
      'name': planName,
      'workoutIds': selectedWorkoutIds,
    });

    if (!mounted) return;
    Navigator.pop(context);
  }
}
