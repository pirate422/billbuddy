import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/builders/dynamic_form_builder.dart';
import '../../data/models/biller.dart';
import '../../data/repositories/biller_repository.dart';

class AddBillerScreen extends ConsumerStatefulWidget {
  final String? billerId;

  const AddBillerScreen({super.key, this.billerId});

  @override
  ConsumerState<AddBillerScreen> createState() => _AddBillerScreenState();
}

class _AddBillerScreenState extends ConsumerState<AddBillerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final Map<String, String> _dynamicInputs = {};
  Biller? _selectedBiller;

  @override
  void initState() {
    super.initState();
    _loadBillerDetails();
  }

  void _loadBillerDetails() {
    final targetId = widget.billerId ?? 'bescom';
    final biller = BillerRepository.mockBillers.firstWhere(
      (b) => b.id == targetId,
      orElse: () => BillerRepository.mockBillers.first,
    );
    setState(() {
      _selectedBiller = biller;
      _nicknameController.text = biller.name.split('-').first.trim();
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_selectedBiller == null) return;

    if (_formKey.currentState!.validate()) {
      final validationError = DynamicFormBuilder.validateInputs(
        fields: _selectedBiller!.fields,
        userInputs: _dynamicInputs,
      );

      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedBiller!.name} linked successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final biller = _selectedBiller;
    if (biller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Link ${biller.category} Biller'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic Provider Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.deepPurple, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            biller.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${biller.category} • ${biller.state}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Biller Nickname',
                  prefixIcon: Icon(Icons.bookmark_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a nickname for this biller';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Dynamic Fields
              ...biller.fields.map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: field.label,
                      prefixIcon: const Icon(Icons.numbers),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (val) => _dynamicInputs[field.key] = val,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return '${field.label} is required';
                      }
                      return null;
                    },
                  ),
                );
              }),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Link & Save Biller',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}