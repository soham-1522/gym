import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditWorkoutScreen extends StatefulWidget {
  final String? workoutId; // null for new workout

  const AddEditWorkoutScreen({super.key, this.workoutId});

  @override
  State<AddEditWorkoutScreen> createState() => _AddEditWorkoutScreenState();
}

class _AddEditWorkoutScreenState extends State<AddEditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Fields
  String name = '';
  String description = '';
  String category = 'Strength';
  String level = 'Beginner';
  int duration = 10;
  String imageUrl = '';
  List<String> musclesTargeted = [];
  List<String> equipment = [];

  final List<String> categories = [
    "Strength",
    "Cardio",
    "Yoga",
    "Stretching",
    "HIIT"
  ];

  final List<String> difficulties = [
    "Beginner",
    "Intermediate",
    "Advanced"
  ];

  final List<String> muscles = [
    "Chest",
    "Back",
    "Legs",
    "Arms",
    "Shoulders",
    "Core"
  ];

  final List<String> equipmentList = [
    "None",
    "Dumbbells",
    "Barbell",
    "Kettlebell",
    "Machine",
    "Resistance Bands",
    "Bodyweight",
  ];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.workoutId != null) {
      _loadWorkout();
    }
  }

  Future<void> _loadWorkout() async {
    setState(() => isLoading = true);
    final doc = await FirebaseFirestore.instance.collection('workouts').doc(widget.workoutId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        name = data['name'] ?? '';
        description = data['description'] ?? '';
        category = data['category'] ?? categories.first;
        level = data['level'] ?? difficulties.first;
        duration = data['duration'] ?? 10;
        imageUrl = data['imageUrl'] ?? '';
        musclesTargeted = List<String>.from(data['musclesTargeted'] ?? []);
        equipment = List<String>.from(data['equipment'] ?? []);
      });
    }
    setState(() => isLoading = false);
  }

  void _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final workoutData = {
      'name': name,
      'description': description,
      'category': category,
      'level': level,
      'duration': duration,
      'imageUrl': imageUrl,
      'musclesTargeted': musclesTargeted,
      'equipment': equipment,
      'completed': false,
    };

    setState(() => isLoading = true);
    final collection = FirebaseFirestore.instance.collection('workouts');
    if (widget.workoutId == null) {
      await collection.add(workoutData);
    } else {
      await collection.doc(widget.workoutId).update(workoutData);
    }
    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  Widget _buildMultiSelectChips(List<String> options, List<String> selected, void Function(List<String>) onSelectionChanged) {
    return Wrap(
      spacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selectedFlag) {
            setState(() {
              if (selectedFlag) {
                selected.add(option);
              } else {
                selected.remove(option);
              }
              onSelectionChanged(selected);
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text(widget.workoutId == null ? "Add Workout" : "Edit Workout")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: "Workout Name"),
                validator: (v) => v == null || v.isEmpty ? "Please enter a name" : null,
                onSaved: (v) => name = v ?? '',
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                onSaved: (v) => description = v ?? '',
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: "Category"),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => category = v ?? category),
                onSaved: (v) => category = v ?? category,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: level,
                decoration: const InputDecoration(labelText: "Difficulty Level"),
                items: difficulties.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => level = v ?? level),
                onSaved: (v) => level = v ?? level,
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: duration.toString(),
                decoration: const InputDecoration(labelText: "Duration (minutes)"),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter duration";
                  if (int.tryParse(v) == null) return "Enter valid number";
                  return null;
                },
                onSaved: (v) => duration = int.parse(v!),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: imageUrl,
                decoration: const InputDecoration(labelText: "Image URL (optional)"),
                onSaved: (v) => imageUrl = v ?? '',
              ),
              const SizedBox(height: 15),
              const Text("Muscles Targeted", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildMultiSelectChips(muscles, musclesTargeted, (selected) {
                musclesTargeted = selected;
              }),
              const SizedBox(height: 15),
              const Text("Equipment", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildMultiSelectChips(equipmentList, equipment, (selected) {
                equipment = selected;
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveWorkout,
                child: Text(widget.workoutId == null ? "Add Workout" : "Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
