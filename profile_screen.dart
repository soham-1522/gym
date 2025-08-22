import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalController = TextEditingController();

  bool _isSaving = false;
  bool _isEditing = false;

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'goal': _goalController.text.trim(),
      });

      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  double _calculateBMI(double weight, double height) {
    if (weight <= 0 || height <= 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  double _calculateBodyFat(double bmi, int age, String gender) {
    if (gender.toLowerCase() == "male") {
      return (1.20 * bmi) + (0.23 * age) - 16.2;
    } else {
      return (1.20 * bmi) + (0.23 * age) - 5.4;
    }
  }

  String _bmiCategory(double bmi) {
    if (bmi == 0) return "N/A";
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal weight";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  Color _bmiCategoryColor(double bmi) {
    if (bmi == 0) return Colors.grey;
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orangeAccent;
    return Colors.red;
  }

  String _bodyFatCategory(double bodyFat, String gender) {
    if (bodyFat == 0) return "N/A";
    gender = gender.toLowerCase();
    if (gender == "male") {
      if (bodyFat < 6) return "Essential Fat";
      if (bodyFat < 14) return "Athletes";
      if (bodyFat < 18) return "Fitness";
      if (bodyFat < 25) return "Average";
      return "Obese";
    } else {
      if (bodyFat < 14) return "Essential Fat";
      if (bodyFat < 21) return "Athletes";
      if (bodyFat < 25) return "Fitness";
      if (bodyFat < 32) return "Average";
      return "Obese";
    }
  }

  Color _bodyFatCategoryColor(double bodyFat, String gender) {
    if (bodyFat == 0) return Colors.grey;
    gender = gender.toLowerCase();
    if (gender == "male") {
      if (bodyFat < 6) return Colors.blueAccent;
      if (bodyFat < 14) return Colors.green;
      if (bodyFat < 18) return Colors.lightGreen;
      if (bodyFat < 25) return Colors.orange;
      return Colors.red;
    } else {
      if (bodyFat < 14) return Colors.blueAccent;
      if (bodyFat < 21) return Colors.green;
      if (bodyFat < 25) return Colors.lightGreen;
      if (bodyFat < 32) return Colors.orange;
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;
    final verticalPadding = size.height * 0.02;
    final cardMarginVertical = size.height * 0.02;
    final avatarRadius = size.width * 0.15 > 60 ? 60.0 : size.width * 0.15;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.deepPurple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: "Edit Profile",
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.deepPurple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  );
                }

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  if (!_isEditing) {
                    double bmi = _calculateBMI(
                      (data['weight'] ?? 0).toDouble(),
                      (data['height'] ?? 0).toDouble(),
                    );
                    double bodyFat = _calculateBodyFat(
                      bmi,
                      (data['age'] ?? 0),
                      data.containsKey('gender') ? data['gender'] : "male",
                    );

                    return SingleChildScrollView(
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.white.withOpacity(0.15),
                        elevation: 10,
                        margin: EdgeInsets.symmetric(vertical: cardMarginVertical),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: verticalPadding * 3,
                            horizontal: horizontalPadding * 1.2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: avatarRadius,
                                backgroundColor: Colors.deepOrange.withOpacity(0.8),
                                child: Icon(Icons.person, size: avatarRadius, color: Colors.white),
                              ),
                              SizedBox(height: verticalPadding * 2),
                              Text(
                                data['name'],
                                style: TextStyle(
                                  fontSize: size.width * 0.07,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: verticalPadding),
                              Text(
                                "${data['age']} years old",
                                style: TextStyle(fontSize: size.width * 0.05, color: Colors.grey[300]),
                              ),
                              SizedBox(height: verticalPadding * 2),
                              _infoColumn("Height", "${data['height']} cm", size, Colors.white),
                              SizedBox(height: verticalPadding),
                              _infoColumn("Weight", "${data['weight']} kg", size, Colors.white),
                              SizedBox(height: verticalPadding),
                              _infoColumn("Goal", data['goal'], size, Colors.white),
                              SizedBox(height: verticalPadding * 2),
                              const Divider(color: Colors.deepOrange, thickness: 1.5),
                              SizedBox(height: verticalPadding * 2),

                              Text(
                                "BMI: ${bmi.toStringAsFixed(1)} (${_bmiCategory(bmi)})",
                                style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: _bmiCategoryColor(bmi),
                                ),
                              ),
                              SizedBox(height: verticalPadding),

                              Text(
                                "Body Fat: ${bodyFat.toStringAsFixed(1)}% (${_bodyFatCategory(bodyFat, data['gender'] ?? "male")})",
                                style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: _bodyFatCategoryColor(bodyFat, data['gender'] ?? "male"),
                                ),
                              ),
                              SizedBox(height: verticalPadding * 2),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    _nameController.text = data['name'] ?? '';
                    _ageController.text = data['age']?.toString() ?? '';
                    _heightController.text = data['height']?.toString() ?? '';
                    _weightController.text = data['weight']?.toString() ?? '';
                    _goalController.text = data['goal'] ?? '';
                    return _buildProfileForm(size, avatarRadius);
                  }
                }
                return _buildProfileForm(size, avatarRadius);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value, Size size, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: size.width * 0.045,
            color: Colors.deepOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: size.height * 0.008),
        Text(
          value,
          style: TextStyle(fontSize: size.width * 0.05, color: textColor),
        ),
      ],
    );
  }

  Widget _buildProfileForm(Size size, double avatarRadius) {
    final horizontalPadding = size.width * 0.05;
    final verticalPadding = size.height * 0.02;

    return SingleChildScrollView(
      child: Card(
        color: Colors.white.withOpacity(0.15),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.symmetric(vertical: verticalPadding * 2),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding * 3,
            horizontal: horizontalPadding * 1.2,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: verticalPadding * 2),
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.deepOrange.withOpacity(0.8),
                  child: Icon(Icons.person, size: avatarRadius, color: Colors.white),
                ),
                SizedBox(height: verticalPadding * 2),

                _buildTextField(_nameController, "Name", "Enter your name", size),
                SizedBox(height: verticalPadding * 1.5),

                _buildTextField(_ageController, "Age", "Enter your age", size, isNumber: true),
                SizedBox(height: verticalPadding * 1.5),

                _buildTextField(_heightController, "Height (cm)", "Enter your height", size, isNumber: true),
                SizedBox(height: verticalPadding * 1.5),

                _buildTextField(_weightController, "Weight (kg)", "Enter your weight", size, isNumber: true),
                SizedBox(height: verticalPadding * 1.5),

                _buildTextField(_goalController, "Goal", "Enter your fitness goal", size),
                SizedBox(height: verticalPadding * 2),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: EdgeInsets.symmetric(vertical: verticalPadding * 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? SizedBox(
                      height: size.width * 0.06,
                      width: size.width * 0.06,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : Text(
                      "Save Profile",
                      style: TextStyle(
                        fontSize: size.width * 0.055,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: verticalPadding), // Added extra spacing under button
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String validationMessage, Size size,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepOrange, fontSize: size.width * 0.045),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepOrange.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepOrange.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: size.width * 0.03,
          vertical: size.height * 0.015,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        if (isNumber && double.tryParse(value) == null) {
          return "Enter a valid number";
        }
        return null;
      },
    );
  }
}
