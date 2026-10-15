import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../widgets/blood_bank_card.dart';

/// The screen for managing blood bank records in the system.
/// Admins can view, add, edit, and delete blood banks and specify available blood types.
class BloodBanksScreen extends StatefulWidget {
  const BloodBanksScreen({super.key});

  @override
  State<BloodBanksScreen> createState() => _BloodBanksScreenState();
}

class _BloodBanksScreenState extends State<BloodBanksScreen> {
  // A predefined list of major cities in Iraq for the blood bank location.
  final List<String> _iraqCities = [
    "Baghdad", "Basra", "Nineveh (Mosul)", "Erbil", "Sulaymaniyah",
    "Kirkuk", "Najaf", "Karbala", "Anbar", "Duhok", "Diyala",
    "Babil (Hilla)", "Wasit (Kut)", "Maysan (Amara)", "Dhi Qar (Nasiriyah)",
    "Al-Qadisiyah (Diwaniyah)", "Muthanna (Samawah)", "Saladin (Tikrit)"
  ];
  // The standard blood types available for selection.
  final List<String> _allBloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  /// Displays a dialog for adding a new blood bank or editing an existing one.
  void _showBloodBankDialog({String? id, Map<String, dynamic>? data}) {
    final formKey = GlobalKey<FormState>();
    
    // Text controllers pre-filled with existing data if editing.
    final nameController = TextEditingController(text: data?['name'] ?? '');
    String selectedCity = data?['city'] ?? 'Baghdad';
    final addressController = TextEditingController(text: data?['address'] ?? '');
    final phoneController = TextEditingController(text: data?['phone'] ?? '');
    final latController = TextEditingController(text: data?['latitude']?.toString() ?? '');
    final lngController = TextEditingController(text: data?['longitude']?.toString() ?? '');
    
    // Stores the user's selected blood types.
    List<String> selectedBloodTypes = List<String>.from(data?['bloodTypesAvailable'] ?? []);
    
    final service = Provider.of<FirebaseService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(id == null ? 'Add Blood Bank' : 'Edit Blood Bank'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Blood Bank Name Field
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Blood Bank Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
                            if (double.tryParse(value) == null) return 'Invalid';
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
                            if (double.tryParse(value) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Selection section for available blood types using FilterChips.
                  const Text('Available Blood Types:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _allBloodTypes.map((type) {
                      final isSelected = selectedBloodTypes.contains(type);
                      return FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedBloodTypes.add(type);
                            } else {
                              selectedBloodTypes.remove(type);
                            }
                          });
                        },
                        selectedColor: Colors.red.shade100,
                        checkmarkColor: Colors.red,
                      );
                    }).toList(),
                  ),
                  // Validation warning if no blood types are selected.
                  if (selectedBloodTypes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Select at least one blood type',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
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
                if (formKey.currentState!.validate() && selectedBloodTypes.isNotEmpty) {
                  final bloodBankData = {
                    'name': nameController.text.trim(),
                    'city': selectedCity,
                    'address': addressController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'latitude': double.tryParse(latController.text) ?? 0.0,
                    'longitude': double.tryParse(lngController.text) ?? 0.0,
                    'bloodTypesAvailable': selectedBloodTypes,
                  };
                  if (id == null) {
                    await service.addBloodBank(bloodBankData);
                  } else {
                    await service.updateBloodBank(id, bloodBankData);
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
                  'Blood Banks',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showBloodBankDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('+ Add Blood Bank'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Real-time grid of blood banks.
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: service.getBloodBanks(),
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

                  final bloodBanks = snapshot.data!.docs;
                  if (bloodBanks.isEmpty) {
                    return const Center(
                      child: Text('No blood banks found'),
                    );
                  }

                  // Responsive grid for blood bank cards.
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: bloodBanks.length,
                    itemBuilder: (context, index) {
                      final doc = bloodBanks[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return BloodBankCard(
                        id: doc.id,
                        data: data,
                        onEdit: () => _showBloodBankDialog(id: doc.id, data: data),
                        onDelete: () async {
                          // Confirmation dialog before deletion.
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Blood Bank'),
                              content: const Text('Are you sure you want to delete this blood bank?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await service.deleteBloodBank(doc.id);
                          }
                        },
                        onToggleActive: (isActive) async {
                          await service.updateBloodBank(doc.id, {
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
