import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../widgets/hospital_card.dart';

/// The screen for managing hospital records in the system.
/// Admins can view, add, edit, and delete hospitals.
class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({super.key});

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  // A predefined list of major cities in Iraq for the hospital location.
  final List<String> _iraqCities = [
    "Baghdad", "Basra", "Nineveh (Mosul)", "Erbil", "Sulaymaniyah",
    "Kirkuk", "Najaf", "Karbala", "Anbar", "Duhok", "Diyala",
    "Babil (Hilla)", "Wasit (Kut)", "Maysan (Amara)", "Dhi Qar (Nasiriyah)",
    "Al-Qadisiyah (Diwaniyah)", "Muthanna (Samawah)", "Saladin (Tikrit)"
  ];

  /// Displays a dialog for adding a new hospital or editing an existing one.
  void _showHospitalDialog({String? id, Map<String, dynamic>? data}) {
    final formKey = GlobalKey<FormState>();
    
    // Text controllers pre-filled with existing data if editing.
    final nameController = TextEditingController(text: data?['name'] ?? '');
    String selectedCity = data?['city'] ?? 'Baghdad';
    final addressController = TextEditingController(text: data?['address'] ?? '');
    final phoneController = TextEditingController(text: data?['phone'] ?? '');
    final latController = TextEditingController(text: data?['latitude']?.toString() ?? '');
    final lngController = TextEditingController(text: data?['longitude']?.toString() ?? '');
    
    final service = Provider.of<FirebaseService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(id == null ? 'Add Hospital' : 'Edit Hospital'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hospital Name Field
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Hospital Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (value.trim().length < 3) return 'Name must be at least 3 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // City Selection Dropdown
                  const Text('City', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  DropdownButtonFormField<String>(
                    value: selectedCity,
                    isExpanded: true,
                    items: _iraqCities.map((city) {
                      return DropdownMenuItem(value: city, child: Text(city));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedCity = value!);
                    },
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  
                  // Address Field
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  
                  // Phone Number Field
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      // Basic regex for international or local phone numbers.
                      final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
                      if (!phoneRegex.hasMatch(value.trim())) return 'Enter a valid phone number';
                      return null;
                    },
                  ),
                  
                  // Latitude and Longitude Fields in a row.
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: latController,
                          decoration: const InputDecoration(labelText: 'Latitude'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            final lat = double.tryParse(value);
                            if (lat == null) return 'Invalid number';
                            if (lat < -90 || lat > 90) return 'Must be between -90 and 90';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: lngController,
                          decoration: const InputDecoration(labelText: 'Longitude'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            final lng = double.tryParse(value);
                            if (lng == null) return 'Invalid number';
                            if (lng < -180 || lng > 180) return 'Must be between -180 and 180';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            // Action button to save the data.
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final hospitalData = {
                    'name': nameController.text.trim(),
                    'city': selectedCity,
                    'address': addressController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'latitude': double.tryParse(latController.text) ?? 0.0,
                    'longitude': double.tryParse(lngController.text) ?? 0.0,
                  };

                  if (id == null) {
                    await service.addHospital(hospitalData);
                  } else {
                    await service.updateHospital(id, hospitalData);
                  }
                  if (mounted) Navigator.pop(context);
                }
              },
              child: Text(id == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<FirebaseService>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and "Add" button.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hospitals',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showHospitalDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('+ Add Hospital'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Real-time grid of hospitals.
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: service.getHospitals(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final hospitals = snapshot.data!.docs;
                  if (hospitals.isEmpty) {
                    return const Center(
                      child: Text('No hospitals found'),
                    );
                  }

                  // Responsive grid for hospital cards.
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: hospitals.length,
                    itemBuilder: (context, index) {
                      final doc = hospitals[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return HospitalCard(
                        id: doc.id,
                        data: data,
                        onEdit: () => _showHospitalDialog(id: doc.id, data: data),
                        onDelete: () async {
                          // Confirmation dialog before deletion.
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Hospital'),
                              content: const Text('Are you sure you want to delete this hospital?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await service.deleteHospital(doc.id);
                          }
                        },
                        onToggleActive: (isActive) async {
                          await service.updateHospital(doc.id, {
                            'isActive': isActive,
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
