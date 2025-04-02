import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/finance_service.dart';

class EditTransaction extends StatefulWidget {
  final Transaction transaction;

  const EditTransaction({Key? key, required this.transaction}) : super(key: key);

  @override
  State<EditTransaction> createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  final _formKey = GlobalKey<FormState>();
  final FinanceService _financeService = FinanceService();

  late String _type;
  late double _amount;
  late String _currency;
  late String _category;
  late DateTime _selectedDate;
  String? _description;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction.type;
    _amount = widget.transaction.amount;
    _currency = widget.transaction.currency;
    _category = widget.transaction.category;
    _selectedDate = widget.transaction.date;
    _description = widget.transaction.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Transacción'),
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
                initialValue: _amount.toString(),
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
                  DropdownMenuItem(value: 'BOB', child: Text('Bolivianos (BOB)')),
                  DropdownMenuItem(value: 'USD', child: Text('Dólares (USD)')),
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
                title: Text('Fecha: ${_selectedDate.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
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

                    // Actualizar la transacción
                    final updatedTransaction = Transaction(
                      id: widget.transaction.id,
                      type: _type,
                      amount: _amount,
                      currency: _currency,
                      category: _category,
                      date: _selectedDate,
                      profile: widget.transaction.profile, // Mantener el perfil existente
                      description: _description,
                    );

                    await _financeService.updateTransaction(updatedTransaction);

                    // Regresar a la pantalla principal
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}