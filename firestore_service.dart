import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/diet_model.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../screens/workout_screen.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -------------------- WORKOUTS --------------------

  Future<void> addWorkout(Workout workout) async {
    await _db.collection('workouts').add(workout.toMap());
  }

  Future<List<Workout>> getWorkouts() async {
    final snapshot = await _db.collection('workouts').get();
    return snapshot.docs
        .map((doc) => Workout.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateWorkout(Workout workout) async {
    await _db.collection('workouts').doc(workout.id).update(workout.toMap());
  }

  Future<void> deleteWorkout(String id) async {
    await _db.collection('workouts').doc(id).delete();
  }

  // -------------------- DIET PLANS --------------------

  Future<void> addDietPlan(DietPlan dietPlan) async {
    await _db.collection('dietPlans').add(dietPlan.toMap());
  }

  Future<List<DietPlan>> getDietPlans() async {
    final snapshot = await _db.collection('dietPlans').get();
    return snapshot.docs
        .map((doc) => DietPlan.fromMap(doc.data()))
        .toList();
  }

  Future<void> updateDietPlan(String docId, DietPlan dietPlan) async {
    await _db.collection('dietPlans').doc(docId).update(dietPlan.toMap());
  }

  Future<void> deleteDietPlan(String docId) async {
    await _db.collection('dietPlans').doc(docId).delete();
  }


  // -------------------- USERS --------------------

  Future<void> addUser(GymUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<GymUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return GymUser.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> updateUser(GymUser user) async {
    await _db.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}
