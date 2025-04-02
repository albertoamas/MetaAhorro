import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/goals_service.dart';

class AddGoal extends StatefulWidget {
  final Goal? goal;

  const AddGoal({Key? key, this.goal}) : super(key: key);

  @override
  State<AddGoal> createState() => _AddGoalState();
}

class _AddGoalState extends State<AddGoal> {
  final _formKey = GlobalKey<FormState>();
  final GoalsService _goalsService = GoalsService();

  late String _name;
  late double _targetAmount;
  late String _currency; // Moneda de la meta
  DateTime? _deadline;
  String? _description;

  @override
  void initState() {
    super.initState();
    _name = widget.goal?.name ?? '';
    _targetAmount = widget.goal?.targetAmount ?? 0.0;
    _currency = widget.goal?.currency ?? 'USD'; // Valor predeterminado para la moneda
    _deadline = widget.goal?.deadline;
    _description = widget.goal?.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'Nueva Meta' : 'Editar Meta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nombre de la meta
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre de la Meta'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              const SizedBox(height: 16),

              // Monto objetivo
              TextFormField(
                initialValue: _targetAmount.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto Objetivo'),
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
                  _targetAmount = double.parse(value!);
                },
              ),
              const SizedBox(height: 16),

              // Moneda
              DropdownButtonFormField<String>(
                value: _currency,
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('Dólares (USD)')),
                  DropdownMenuItem(value: 'BOB', child: Text('Bolivianos (BOB)')),
                  DropdownMenuItem(value: 'EUR', child: Text('Euros (EUR)')),
                  DropdownMenuItem(value: 'BTC', child: Text('Bitcoin (BTC)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _currency = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Moneda'),
              ),
              const SizedBox(height: 16),

              // Fecha límite
              ListTile(
                title: const Text('Fecha Límite'),
                subtitle: Text(_deadline != null
                    ? _deadline!.toLocal().toString().split(' ')[0]
                    : 'No seleccionada'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _deadline = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                onSaved: (value) {
                  _description = value;
                },
              ),
              const SizedBox(height: 16),

              // Botón para guardar
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final goal = Goal(
                      id: widget.goal?.id ?? '',
                      name: _name,
                      targetAmount: _targetAmount,
                      currentAmount: widget.goal?.currentAmount ?? 0.0,
                      currency: _currency, // Asignar la moneda seleccionada
                      deadline: _deadline,
                      description: _description,
                    );

                    if (widget.goal == null) {
                      await _goalsService.createGoal(goal);
                    } else {
                      await _goalsService.updateGoal(goal);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(widget.goal == null ? 'Crear Meta' : 'Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}