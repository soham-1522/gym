import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionTrackingScreen extends StatefulWidget {
  const NutritionTrackingScreen({Key? key}) : super(key: key);

  @override
  State<NutritionTrackingScreen> createState() => _NutritionTrackingScreenState();
}

class _NutritionTrackingScreenState extends State<NutritionTrackingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Tracking'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('nutritionTracking').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No nutrition records found.'));
                }

                final logs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final doc = logs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.fastfood, color: Colors.deepPurple),
                        title: Text(doc['foodName'] ?? 'Unnamed Food'),
                        subtitle: Text(
                          'Calories: ${doc['calories'] ?? 0}, Protein: ${doc['protein'] ?? 0}g, Carbs: ${doc['carbs'] ?? 0}g, Fats: ${doc['fats'] ?? 0}g',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteLog(context, doc.id),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _openNutritionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }



  /// Add Nutrition Log
  void _openNutritionDialog(BuildContext parentContext) {
    final foodController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatsController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Add Nutrition Entry'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: foodController,
                  decoration: const InputDecoration(labelText: 'Food Name'),
                ),
                TextField(
                  controller: caloriesController,
                  decoration: const InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: proteinController,
                  decoration: const InputDecoration(labelText: 'Protein (g)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: carbsController,
                  decoration: const InputDecoration(labelText: 'Carbs (g)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: fatsController,
                  decoration: const InputDecoration(labelText: 'Fats (g)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext, rootNavigator: true).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.deepPurple)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () async {
                final data = {
                  'foodName': foodController.text.trim(),
                  'calories': int.tryParse(caloriesController.text) ?? 0,
                  'protein': int.tryParse(proteinController.text) ?? 0,
                  'carbs': int.tryParse(carbsController.text) ?? 0,
                  'fats': int.tryParse(fatsController.text) ?? 0,
                  'timestamp': FieldValue.serverTimestamp(),
                };

                await _firestore.collection('nutritionTracking').add(data);

                if (mounted) {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Nutrition entry added!'),
                      backgroundColor: Colors.deepPurple,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Delete Nutrition Log
  void _deleteLog(BuildContext context, String docId) {
    _firestore.collection('nutritionTracking').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nutrition entry deleted!'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
