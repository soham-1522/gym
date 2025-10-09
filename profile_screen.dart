import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail; // email passed from GymApp
  const ProfileScreen({super.key, required this.userEmail});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final email = widget.userEmail.trim().toLowerCase();
      print("🔍 Fetching profile for: $email");

      // Try fetch by document ID
      final docSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(email)
          .get();

      if (docSnap.exists) {
        setState(() {
          userData = docSnap.data();
          isLoading = false;
        });
        print("✅ Found by docId");
        return;
      }

      // Fallback: fetch by email field
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userData = snapshot.docs.first.data();
          isLoading = false;
        });
        print("✅ Found by email field");
      } else {
        setState(() {
          userData = null;
          isLoading = false;
        });
        print("❌ No user found in Firestore");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            tooltip: "Logout",
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? Center(
        child: Text(
          "❌ No user found",
          style: GoogleFonts.roboto(fontSize: 20, color: Colors.red),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              userData!['name'] ?? "N/A",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              userData!['email'] ?? "N/A",
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _profileItem("Name", userData!['name']),
                  _profileItem("Mobile No", userData!['mobile']),
                  _profileItem("Gender", userData!['gender']),
                  _profileItem("Email", userData!['email']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(String label, dynamic value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                value?.toString() ?? "N/A",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
