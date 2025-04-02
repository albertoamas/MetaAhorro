import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/progress.dart';
import '../services/goals_service.dart';

class AddProgressForm extends StatefulWidget {
  final Goal goal;

  const AddProgressForm({Key? key, required this.goal}) : super(key: key);

  @override
  State<AddProgressForm> createState() => _AddProgressFormState();
}

class _AddProgressFormState extends State<AddProgressForm> {
  final _formKey = GlobalKey<FormState>();
  final GoalsService _goalsService = GoalsService();

  late double _amount;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Agregar Progreso a "${widget.goal.name}"',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monto a agregar'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa un monto';
              }
              if (double.tryParse(value) == null) {
                return 'Por favor ingresa un número válido';
              }
              return null;
            },
            onSaved: (value) {
              _amount = double.parse(value!);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                final progress = Progress(
                  amount: _amount,
                  date: DateTime.now(),
                  description: null,
                );

                await _goalsService.addProgressToGoal(widget.goal.id, progress);

                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}