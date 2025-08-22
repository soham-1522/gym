import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthyRecipesScreen extends StatefulWidget {
  const HealthyRecipesScreen({Key? key}) : super(key: key);

  @override
  State<HealthyRecipesScreen> createState() => _HealthyRecipesScreenState();
}

class _HealthyRecipesScreenState extends State<HealthyRecipesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new recipe
  Future<void> _addRecipe() async {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    final ingredientsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Recipe"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Recipe Name"),
              ),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(labelText: "Calories"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ingredientsController,
                decoration: const InputDecoration(labelText: "Ingredients"),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('healthyRecipes').add({
                'name': nameController.text,
                'calories': int.tryParse(caloriesController.text) ?? 0,
                'ingredients': ingredientsController.text,
                'createdAt': DateTime.now(),
              });
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecipe(String docId) async {
    await _firestore.collection('healthyRecipes').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Healthy Recipes"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('healthyRecipes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No recipes available."));
          }

          final recipes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.local_dining, color: Colors.green),
                  title: Text(recipe['name']),
                  subtitle: Text("Calories: ${recipe['calories']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteRecipe(recipe.id),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(recipe['name']),
                        content: Text(recipe['ingredients']),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Close"),
                          ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: _addRecipe,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
