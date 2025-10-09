import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MyApp());
}

// --- MODELS ---

class Workout {
  final String id;
  final String name;
  final int duration;
  final String level;
  final String description;
  final String imageUrl;
  final String category;
  final List<String> musclesTargeted;
  final List<String> equipment;
  final bool completed;

  Workout({
    required this.id,
    required this.name,
    required this.duration,
    required this.level,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.musclesTargeted,
    required this.equipment,
    required this.completed,
  });

  factory Workout.fromMap(Map<String, dynamic> data, String id) {
    return Workout(
      id: id,
      name: data['name'] ?? '',
      duration: data['duration'] ?? 0,
      level: data['level'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      musclesTargeted: List<String>.from(data['musclesTargeted'] ?? []),
      equipment: List<String>.from(data['equipment'] ?? []),
      completed: data['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'duration': duration,
      'level': level,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'musclesTargeted': musclesTargeted,
      'equipment': equipment,
      'completed': completed,
    };
  }
}

class CustomPlan {
  final String id;
  final String name;
  final String description;
  final List<String> workoutIds;

  CustomPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.workoutIds,
  });

  factory CustomPlan.fromMap(Map<String, dynamic> data, String id) {
    return CustomPlan(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      workoutIds: List<String>.from(data['workoutIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'workoutIds': workoutIds,
    };
  }
}

// --- APP ---

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Pro',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const WorkoutsScreen(),
    );
  }
}

// --- WORKOUTS SCREEN ---

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String searchQuery = "";
  String selectedCategory = "All";
  String selectedDifficulty = "All";
  String selectedMuscle = "All";
  String selectedEquipment = "All";

  final List<String> categories = [
    "All",
    "Strength",
    "Cardio",
    "Yoga",
    "Stretching",
    "HIIT",
    "Custom Plans",
  ];

  final List<String> difficulties = [
    "All",
    "Beginner",
    "Intermediate",
    "Advanced"
  ];

  final List<String> muscles = [
    "All",
    "Chest",
    "Back",
    "Legs",
    "Arms",
    "Shoulders",
    "Core"
  ];

  final List<String> equipmentList = [
    "All",
    "None",
    "Dumbbells",
    "Barbell",
    "Kettlebell",
    "Machine",
    "Resistance Bands",
    "Bodyweight",
  ];

  // Firestore collections
  final workoutsCollection = FirebaseFirestore.instance.collection('workouts');
  final customPlansCollection =
  FirebaseFirestore.instance.collection('custom_plans');

  void _deleteCustomPlan(String id) async {
    await customPlansCollection.doc(id).delete();
  }

  void _toggleProgress(String id, bool completed) async {
    await workoutsCollection.doc(id).update({'completed': completed});
  }

  void _navigateToCreateWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
    );
  }

  void _navigateToCreateCustomPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomPlanScreen()),
    );
  }

  void _navigateToCustomPlanDetails(CustomPlan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomPlanDetailsScreen(plan: plan)),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selected,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: DropdownButton<String>(
        value: selected,
        onChanged: onChanged,
        items:
        items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gym Pro"),
        actions: [
          if (selectedCategory == "Custom Plans")
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "Create Custom Plan",
              onPressed: _navigateToCreateCustomPlan,
            )
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search workouts...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDropdown("Category", categories, selectedCategory, (value) {
                  setState(() => selectedCategory = value!);
                }),
                if (selectedCategory != "Custom Plans") ...[
                  _buildDropdown("Difficulty", difficulties, selectedDifficulty,
                          (value) {
                        setState(() => selectedDifficulty = value!);
                      }),
                  _buildDropdown("Muscle", muscles, selectedMuscle, (value) {
                    setState(() => selectedMuscle = value!);
                  }),
                  _buildDropdown("Equipment", equipmentList, selectedEquipment,
                          (value) {
                        setState(() => selectedEquipment = value!);
                      }),
                ],
              ],
            ),
          ),

          // Main list area
          Expanded(
            child: selectedCategory == "Custom Plans"
                ? StreamBuilder<QuerySnapshot>(
              stream: customPlansCollection.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final plans = snapshot.data!.docs
                    .map((doc) => CustomPlan.fromMap(
                    doc.data() as Map<String, dynamic>, doc.id))
                    .toList();
                if (plans.isEmpty) {
                  return const Center(
                      child: Text("No custom plans created."));
                }
                return ListView.builder(
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(plan.name),
                        subtitle: Text(plan.description),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () => _deleteCustomPlan(plan.id),
                        ),
                        onTap: () =>
                            _navigateToCustomPlanDetails(plan),
                      ),
                    );
                  },
                );
              },
            )
                : StreamBuilder<QuerySnapshot>(
              stream: workoutsCollection.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final workouts = snapshot.data!.docs
                    .map((doc) => Workout.fromMap(
                    doc.data() as Map<String, dynamic>, doc.id))
                    .where((workout) {
                  bool matchesSearch = workout.name
                      .toLowerCase()
                      .contains(searchQuery);
                  bool matchesCategory = selectedCategory == "All" ||
                      workout.category == selectedCategory;
                  bool matchesDifficulty = selectedDifficulty == "All" ||
                      workout.level == selectedDifficulty;
                  bool matchesMuscle = selectedMuscle == "All" ||
                      workout.musclesTargeted
                          .contains(selectedMuscle);
                  bool matchesEquipment = selectedEquipment == "All" ||
                      workout.equipment.contains(selectedEquipment);

                  return matchesSearch &&
                      matchesCategory &&
                      matchesDifficulty &&
                      matchesMuscle &&
                      matchesEquipment;
                }).toList();

                if (workouts.isEmpty) {
                  return const Center(
                      child: Text("No workouts found."));
                }

                return ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: workout.imageUrl.isNotEmpty
                            ? Image.network(
                          workout.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.fitness_center,
                            size: 50),
                        title: Text(workout.name),
                        subtitle: Text(
                            "${workout.category} • ${workout.level} • ${workout.duration} min\nMuscles: ${workout.musclesTargeted.join(', ')}\nEquipment: ${workout.equipment.join(', ')}"),
                        isThreeLine: true,
                        trailing: Checkbox(
                          value: workout.completed,
                          onChanged: (value) {
                            _toggleProgress(
                                workout.id, value ?? false);
                          },
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(workout.name),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    if (workout.imageUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        child: Image.network(
                                          workout.imageUrl,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    Text(
                                        "Description: ${workout.description}"),
                                    Text("Difficulty: ${workout.level}"),
                                    Text(
                                        "Duration: ${workout.duration} min"),
                                    Text(
                                        "Muscles Targeted: ${workout.musclesTargeted.join(', ')}"),
                                    Text(
                                        "Equipment: ${workout.equipment.join(', ')}"),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text("Close"))
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: selectedCategory == "Custom Plans"
          ? null
          : FloatingActionButton(
        onPressed: _navigateToCreateWorkout,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- ADD WORKOUT SCREEN ---

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final workoutsCollection = FirebaseFirestore.instance.collection('workouts');

  String name = "";
  int duration = 0;
  String level = "Beginner";
  String description = "";
  String imageUrl = "";
  String category = "Strength";
  List<String> musclesTargeted = [];
  List<String> equipment = [];

  final levels = ["Beginner", "Intermediate", "Advanced"];
  final categories = ["Strength", "Cardio", "Yoga", "Stretching", "HIIT"];
  final muscleOptions = ["Chest", "Back", "Legs", "Arms", "Shoulders", "Core"];
  final equipmentOptions = [
    "None",
    "Dumbbells",
    "Barbell",
    "Kettlebell",
    "Machine",
    "Resistance Bands",
    "Bodyweight"
  ];

  void _saveWorkout() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newWorkout = {
        'name': name,
        'duration': duration,
        'level': level,
        'description': description,
        'imageUrl': imageUrl,
        'category': category,
        'musclesTargeted': musclesTargeted,
        'equipment': equipment,
        'completed': false,
      };

      await workoutsCollection.add(newWorkout);
      Navigator.pop(context);
    }
  }

  Widget _buildMultiSelect(List<String> options, List<String> selected,
      Function(List<String>) onChanged) {
    return Wrap(
      spacing: 5,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return FilterChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              if (val) {
                selected.add(opt);
              } else {
                selected.remove(opt);
              }
              onChanged(selected);
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Workout"),
        actions: [
          TextButton(
              onPressed: _saveWorkout,
              child: const Text("Save",
                  style: TextStyle(color: Colors.white, fontSize: 18)))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Workout Name"),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter a name" : null,
                onSaved: (v) => name = v ?? "",
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Duration (minutes)"),
                keyboardType: TextInputType.number,
                validator: (v) =>
                v == null || v.isEmpty ? "Enter duration" : null,
                onSaved: (v) => duration = int.tryParse(v ?? "0") ?? 0,
              ),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Level"),
                value: level,
                items: levels
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => level = val!),
              ),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Category"),
                value: category,
                items: categories
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => category = val!),
              ),
              TextFormField(
                decoration:
                const InputDecoration(labelText: "Description"),
                maxLines: 2,
                onSaved: (v) => description = v ?? "",
              ),
              TextFormField(
                decoration:
                const InputDecoration(labelText: "Image/GIF URL"),
                onSaved: (v) => imageUrl = v ?? "",
              ),
              const SizedBox(height: 10),
              const Text("Muscles Targeted",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildMultiSelect(muscleOptions, musclesTargeted,
                      (val) => musclesTargeted = val),
              const SizedBox(height: 10),
              const Text("Equipment",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildMultiSelect(equipmentOptions, equipment,
                      (val) => equipment = val),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM PLAN CREATION SCREEN ---

class CustomPlanScreen extends StatefulWidget {
  const CustomPlanScreen({super.key});

  @override
  State<CustomPlanScreen> createState() => _CustomPlanScreenState();
}

class _CustomPlanScreenState extends State<CustomPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String description = "";
  List<String> selectedWorkoutIds = [];

  final workoutsCollection = FirebaseFirestore.instance.collection('workouts');

  void _savePlan() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newPlan = {
        'name': name,
        'description': description,
        'workoutIds': selectedWorkoutIds,
      };

      await FirebaseFirestore.instance.collection('custom_plans').add(newPlan);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Custom Plan"),
        actions: [
          TextButton(
              onPressed: _savePlan,
              child: const Text("Save",
                  style: TextStyle(color: Colors.white, fontSize: 18))),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: "Plan Name"),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Enter a name" : null,
                  onSaved: (value) => name = value ?? "",
                ),
                TextFormField(
                  decoration:
                  const InputDecoration(labelText: "Description (optional)"),
                  maxLines: 2,
                  onSaved: (value) => description = value ?? "",
                ),
              ]),
            ),
            const SizedBox(height: 20),
            const Text("Select Workouts",
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: workoutsCollection.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final workouts = snapshot.data!.docs
                      .map((doc) =>
                      Workout.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                      .toList();

                  return ListView(
                    children: workouts.map((workout) {
                      final selected =
                      selectedWorkoutIds.contains(workout.id);
                      return CheckboxListTile(
                        title: Text(workout.name),
                        subtitle: Text(
                            "${workout.category} • ${workout.level} • ${workout.duration} min"),
                        value: selected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedWorkoutIds.add(workout.id);
                            } else {
                              selectedWorkoutIds.remove(workout.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM PLAN DETAILS SCREEN ---

class CustomPlanDetailsScreen extends StatefulWidget {
  final CustomPlan plan;

  const CustomPlanDetailsScreen({super.key, required this.plan});

  @override
  State<CustomPlanDetailsScreen> createState() =>
      _CustomPlanDetailsScreenState();
}

class _CustomPlanDetailsScreenState extends State<CustomPlanDetailsScreen> {
  Map<String, bool> workoutCompletion = {};

  void _toggleCompletion(String workoutId, bool completed) {
    setState(() {
      workoutCompletion[workoutId] = completed;
    });
  }

  @override
  void initState() {
    super.initState();
    for (var id in widget.plan.workoutIds) {
      workoutCompletion[id] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutsCollection = FirebaseFirestore.instance.collection('workouts');

    return Scaffold(
      appBar: AppBar(title: Text(widget.plan.name)),
      body: StreamBuilder<QuerySnapshot>(
        stream: workoutsCollection.where(FieldPath.documentId,
            whereIn: widget.plan.workoutIds)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final workouts = snapshot.data!.docs
              .map((doc) =>
              Workout.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              final completed = workoutCompletion[workout.id] ?? false;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: workout.imageUrl.isNotEmpty
                      ? Image.network(workout.imageUrl,
                      width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.fitness_center, size: 50),
                  title: Text(workout.name),
                  subtitle:
                  Text("${workout.level} • ${workout.duration} min"),
                  trailing: Checkbox(
                    value: completed,
                    onChanged: (val) =>
                        _toggleCompletion(workout.id, val ?? false),
                  ),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(workout.name),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (workout.imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(workout.imageUrl,
                                  height: 200, fit: BoxFit.cover),
                            ),
                          const SizedBox(height: 10),
                          Text("Description: ${workout.description}"),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close")),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
