import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/finance_service.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({Key? key}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final _formKey = GlobalKey<FormState>();
  final FinanceService _financeService = FinanceService();

  String _type = 'ingreso'; // Tipo de transacción predeterminado
  double? _amount;
  String _currency = 'USD'; // Moneda predeterminada
  String _category = 'General'; // Categoría predeterminada
  DateTime _selectedDate = DateTime.now(); // Fecha predeterminada
  String? _description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Transacción'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tipo de transacción
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                  DropdownMenuItem(value: 'gasto', child: Text('Gasto')),
                  DropdownMenuItem(value: 'ahorro', child: Text('Ahorro')),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Tipo de Transacción'),
              ),
              const SizedBox(height: 16),

              // Monto
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto'),
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

              // Moneda
              DropdownButtonFormField<String>(
                value: _currency,
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
                decoration: const InputDecoration(labelText: 'Moneda'),
              ),
              const SizedBox(height: 16),

              // Categoría
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'General', child: Text('General')),
                  DropdownMenuItem(value: 'Alimentación', child: Text('Alimentación')),
                  DropdownMenuItem(value: 'Transporte', child: Text('Transporte')),
                  DropdownMenuItem(value: 'Inversiones', child: Text('Inversiones')),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              const SizedBox(height: 16),

              // Fecha
              ListTile(
                title: const Text('Fecha'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', // Mostrar la fecha seleccionada
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked; // Actualizar la fecha seleccionada
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
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

                    // Crear la transacción
                    final transaction = Transaction(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      type: _type,
                      amount: _amount!,
                      currency: _currency,
                      category: _category,
                      date: _selectedDate,
                      profile: 'USD', // Cambia 'USD' por el perfil actual
                      description: _description,
                    );

                    // Guardar en Firebase
                    await _financeService.saveTransaction(transaction);

                    // Regresar a la pantalla principal
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar Transacción'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}