class GymUser {
  final String uid;
  final String name;
  final String email;
  final int age;
  final double weight; // in kg
  final double height; // in cm
  final String goal; // e.g., "Lose Weight", "Build Muscle"

  GymUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.weight,
    required this.height,
    required this.goal,
  });

  // Convert Firestore document to GymUser object
  factory GymUser.fromMap(Map<String, dynamic> data, String documentId) {
    return GymUser(
      uid: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      age: data['age'] ?? 0,
      weight: (data['weight'] ?? 0).toDouble(),
      height: (data['height'] ?? 0).toDouble(),
      goal: data['goal'] ?? '',
    );
  }

  // Convert GymUser object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'weight': weight,
      'height': height,
      'goal': goal,
    };
  }
}
