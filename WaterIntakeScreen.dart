import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({Key? key}) : super(key: key);

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double dailyTarget = 3000; // in ml
  double consumed = 0;

  void addWater(double amount) {
    setState(() {
      consumed += amount;
    });
  }

  void resetWater() {
    setState(() {
      consumed = 0;
    });
  }

  Future<void> saveWaterIntake() async {
    try {
      await _firestore.collection('waterIntake').add({
        'date': DateTime.now(),
        'dailyTarget': dailyTarget,
        'consumed': consumed,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Water intake saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteWaterIntake(String docId) async {
    try {
      await _firestore.collection('waterIntake').doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Record deleted!"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = consumed / dailyTarget;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Intake"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset",
            onPressed: resetWater,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: "Save",
            onPressed: saveWaterIntake,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text("Daily Target: ${dailyTarget.toInt()} ml",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              color: Colors.blue,
              backgroundColor: Colors.grey[300],
              minHeight: 15,
            ),
            const SizedBox(height: 20),
            Text("Consumed: ${consumed.toInt()} ml",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () => addWater(250),
                  child: const Text("+250ml"),
                ),
                ElevatedButton(
                  onPressed: () => addWater(500),
                  child: const Text("+500ml"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: saveWaterIntake,
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Save",
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: resetWater,
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Reset",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(),
            const Text("Saved History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Firestore Stream with Delete Option
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('waterIntake')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No records found.");
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    DateTime date = (data['date'] as Timestamp).toDate();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      child: ListTile(
                        leading: const Icon(Icons.local_drink,
                            color: Colors.blueAccent),
                        title: Text(
                            "Consumed: ${data['consumed'].toInt()} ml / ${data['dailyTarget'].toInt()} ml"),
                        subtitle: Text(
                            "Date: ${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              deleteWaterIntake(doc.id), // Delete action
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
