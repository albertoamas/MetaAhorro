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
  late String _currency;
  DateTime? _deadline;
  String? _description;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.goal?.name ?? '';
    _targetAmount = widget.goal?.targetAmount ?? 0.0;
    _currency = widget.goal?.currency ?? 'USD';
    _deadline = widget.goal?.deadline;
    _description = widget.goal?.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.goal == null ? 'Nueva Meta' : 'Editar Meta',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3C2FCF),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF3C2FCF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                initialValue: _name,
                                decoration: InputDecoration(
                                  labelText: 'Nombre de la Meta',
                                  prefixIcon: const Icon(Icons.flag),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3C2FCF),
                                      width: 2,
                                    ),
                                  ),
                                ),
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
                              const SizedBox(height: 20),
                              TextFormField(
                                initialValue: _targetAmount > 0 ? _targetAmount.toString() : '',
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: 'Monto Objetivo',
                                  prefixIcon: const Icon(Icons.monetization_on),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3C2FCF),
                                      width: 2,
                                    ),
                                  ),
                                ),
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
                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                value: _currency,
                                decoration: InputDecoration(
                                  labelText: 'Moneda',
                                  prefixIcon: const Icon(Icons.currency_exchange),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3C2FCF),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'USD', child: Text('Dólares (USD)')),
                                  DropdownMenuItem(value: 'BOB', child: Text('Bolivianos (BOB)')),
                                  DropdownMenuItem(value: 'USDT', child: Text('Tether (USDT)')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _currency = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              InkWell(
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
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Fecha Límite',
                                    prefixIcon: const Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF3C2FCF),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _deadline != null
                                        ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                                        : 'Seleccionar fecha',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                initialValue: _description,
                                decoration: InputDecoration(
                                  labelText: 'Descripción (opcional)',
                                  prefixIcon: const Icon(Icons.description),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3C2FCF),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                maxLines: 3,
                                onSaved: (value) {
                                  _description = value;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveGoal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C2FCF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                widget.goal == null ? 'CREAR META' : 'GUARDAR CAMBIOS',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        _formKey.currentState!.save();

        final goal = Goal(
          id: widget.goal?.id ?? '',
          name: _name,
          targetAmount: _targetAmount,
          currentAmount: widget.goal?.currentAmount ?? 0.0,
          currency: _currency,
          deadline: _deadline,
          description: _description,
          progressHistory: widget.goal?.progressHistory ?? [],
        );

        if (widget.goal == null) {
          await _goalsService.createGoal(goal);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meta creada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await _goalsService.updateGoal(goal);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meta actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}