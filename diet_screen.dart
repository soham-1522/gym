import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DietTipsScreen.dart';
import 'HealthyRecipesScreen.dart';
import 'WaterIntakeScreen.dart';
import 'NutritionTrackingScreen.dart'; // <-- Added

class NewDietScreen extends StatefulWidget {
  const NewDietScreen({Key? key}) : super(key: key);

  @override
  State<NewDietScreen> createState() => _NewDietScreenState();
}

class _NewDietScreenState extends State<NewDietScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Section'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          _buildFeatureButtons(context),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('dietPlans').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No diet plans found.'));
                }

                final plans = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final doc = plans[index];
                    final int calories = (doc['calories'] is int)
                        ? doc['calories']
                        : (doc['calories'] as num?)?.toInt() ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.restaurant_menu, color: Colors.deepPurple),
                        title: Text(doc['mealName'] ?? 'Unnamed Meal'),
                        subtitle: Text('${doc['mealType'] ?? ''} - $calories cal'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.deepPurple),
                              onPressed: () => _openMealDialog(context, doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, doc.id),
                            ),
                          ],
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
        onPressed: () => _openMealDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFeatureButtons(BuildContext context) {
    final features = [
      {'title': 'Meal Plans', 'icon': Icons.restaurant_menu},
      {'title': 'Nutrition Tracking', 'icon': Icons.bar_chart},
      {'title': 'Healthy Recipes', 'icon': Icons.local_dining},
      {'title': 'Water Intake', 'icon': Icons.water_drop},
      {'title': 'Diet Tips', 'icon': Icons.tips_and_updates},
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return GestureDetector(
              onTap: () {
                switch (feature['title']) {
                  case 'Healthy Recipes':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HealthyRecipesScreen()),
                    );
                    break;
                  case 'Water Intake':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WaterIntakeScreen()),
                    );
                    break;
                  case 'Diet Tips':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DietTipsScreen()),
                    );
                    break;
                  case 'Nutrition Tracking':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NutritionTrackingScreen()),
                    );
                    break;
                  default:
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${feature['title']} clicked')),
                    );
                }
              },
              child: Container(
                width: 120,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(feature['icon'] as IconData, color: Colors.deepPurple),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openMealDialog(BuildContext parentContext, DocumentSnapshot? doc) {
    final nameController = TextEditingController(
        text: doc != null ? doc['mealName'] : '');
    final typeController = TextEditingController(
        text: doc != null ? doc['mealType'] : '');
    final caloriesController = TextEditingController(
        text: doc != null ? (doc['calories'] ?? '').toString() : '');
    final descriptionController = TextEditingController(
        text: doc != null ? doc['description'] : '');

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(doc == null ? 'Add Meal Plan' : 'Edit Meal Plan'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Meal Name'),
                ),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Meal Type'),
                ),
                TextField(
                  controller: caloriesController,
                  decoration: const InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
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
                  'mealName': nameController.text.trim(),
                  'mealType': typeController.text.trim(),
                  'calories':
                  int.tryParse(caloriesController.text.trim()) ?? 0,
                  'description': descriptionController.text.trim(),
                };

                if (doc == null) {
                  await _firestore.collection('dietPlans').add(data);
                } else {
                  await _firestore.collection('dietPlans').doc(doc.id).update(data);
                }

                if (mounted) {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(doc == null
                          ? 'Meal plan added successfully!'
                          : 'Meal plan updated successfully!'),
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

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Meal Plan'),
          content: const Text('Are you sure you want to delete this meal plan?'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext, rootNavigator: true).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.deepPurple)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await _firestore.collection('dietPlans').doc(docId).delete();
                if (mounted) {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Meal plan deleted successfully!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
