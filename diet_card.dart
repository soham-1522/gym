import 'package:flutter/material.dart';
import '../models/diet_model.dart';

class DietCard extends StatelessWidget {
  final DietPlan dietPlan;
  final VoidCallback? onTap;

  const DietCard({super.key, required this.dietPlan, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dietPlan.mealName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                dietPlan.mealType,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                dietPlan.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
