import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soham/screens/workout_screen.dart';

import 'models/workout_model.dart';

class AddEditWorkoutScreen extends StatefulWidget {
  final Workout? workout; // If null → Add, else Edit

  const AddEditWorkoutScreen({super.key, this.workout});

  @override
  State<AddEditWorkoutScreen> createState() => _AddEditWorkoutScreenState();
}

class _AddEditWorkoutScreenState extends State<AddEditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController durationController;
  late TextEditingController levelController;
  late TextEditingController descriptionController;
  late TextEditingController imageUrlController;
  late TextEditingController categoryController;
  late TextEditingController musclesController;
  late TextEditingController equipmentController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.workout?.name ?? '');
    durationController =
        TextEditingController(text: widget.workout?.duration.toString() ?? '');
    levelController = TextEditingController(text: widget.workout?.level ?? '');
    descriptionController =
        TextEditingController(text: widget.workout?.description ?? '');
    imageUrlController =
        TextEditingController(text: widget.workout?.imageUrl ?? '');
    categoryController =
        TextEditingController(text: widget.workout?.category ?? '');
    musclesController = TextEditingController(
        text: widget.workout?.musclesTargeted.join(', ') ?? '');
    equipmentController = TextEditingController(
        text: widget.workout?.equipment.join(', ') ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    durationController.dispose();
    levelController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    categoryController.dispose();
    musclesController.dispose();
    equipmentController.dispose();
    super.dispose();
  }

  void _saveWorkout() async {
    if (_formKey.currentState!.validate()) {
      final newWorkout = Workout(
        id: widget.workout?.id ?? '',
        name: nameController.text.trim(),
        duration: int.parse(durationController.text.trim()),
        level: levelController.text.trim(),
        description: descriptionController.text.trim(),
        imageUrl: imageUrlController.text.trim(),
        category: categoryController.text.trim(),
        musclesTargeted:
        musclesController.text.trim().isEmpty ? [] : musclesController.text.trim().split(',').map((s) => s.trim()).toList(),
        equipment: equipmentController.text.trim().isEmpty
            ? []
            : equipmentController.text.trim().split(',').map((s) => s.trim()).toList(),
        completed: widget.workout?.completed ?? false,
      );

      if (widget.workout == null) {
        // Add
        await FirebaseFirestore.instance
            .collection('workouts')
            .add(newWorkout.toMap());
      } else {
        // Update
        await FirebaseFirestore.instance
            .collection('workouts')
            .doc(widget.workout!.id)
            .update(newWorkout.toMap());
      }

      Navigator.pop(context); // Go back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.workout != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Workout" : "Add Workout")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Workout Name'),
                validator: (value) =>
                value!.isEmpty ? 'Enter workout name' : null,
              ),
              TextFormField(
                controller: durationController,
                decoration:
                const InputDecoration(labelText: 'Duration (mins)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter duration';
                  if (int.tryParse(value) == null) return 'Enter valid number';
                  return null;
                },
              ),
              TextFormField(
                controller: levelController,
                decoration:
                const InputDecoration(labelText: 'Level (Beginner, etc.)'),
                validator: (value) =>
                value!.isEmpty ? 'Enter level' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                value!.isEmpty ? 'Enter description' : null,
              ),
              TextFormField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) =>
                value!.isEmpty ? 'Enter image URL' : null,
              ),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) =>
                value!.isEmpty ? 'Enter category' : null,
              ),
              TextFormField(
                controller: musclesController,
                decoration: const InputDecoration(
                    labelText: 'Muscles Targeted (comma separated)'),
              ),
              TextFormField(
                controller: equipmentController,
                decoration: const InputDecoration(
                    labelText: 'Equipment (comma separated)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveWorkout,
                child: Text(isEdit ? 'Update Workout' : 'Add Workout'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
