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
  bool _isLoading = false;

  // Mapa de íconos para cada tipo de transacción
  final Map<String, IconData> _typeIcons = {
    'ingreso': Icons.arrow_downward,
    'gasto': Icons.arrow_upward,
    'ahorro': Icons.savings,
  };

  // Mapa de colores para cada tipo de transacción
  final Map<String, Color> _typeColors = {
    'ingreso': Colors.green,
    'gasto': Colors.red,
    'ahorro': Colors.blue,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Nueva Transacción',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3C2FCF),
        iconTheme: const IconThemeData(color: Colors.white), // Color blanco para la flecha de regreso
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Encabezado con color
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
            
            // Formulario
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta del formulario
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
                              // Selector de tipo de transacción
                              const Text(
                                'Tipo de Transacción',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _buildTypeButton('ingreso', 'Ingreso'),
                                  const SizedBox(width: 8),
                                  _buildTypeButton('gasto', 'Gasto'),
                                  const SizedBox(width: 8),
                                  _buildTypeButton('ahorro', 'Ahorro'),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Monto
                              TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                  labelText: 'Monto',
                                  prefixIcon: Icon(Icons.attach_money, color: _typeColors[_type]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: _typeColors[_type]!,
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
                                  _amount = double.parse(value!);
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              // Selector de moneda
                              Row(
                                children: [
                                  const Text(
                                    'Moneda:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildCurrencyButton('USD'),
                                  const SizedBox(width: 8),
                                  _buildCurrencyButton('BOB'),
                                  const SizedBox(width: 8),
                                  _buildCurrencyButton('USDT'),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              // Categoría
                              DropdownButtonFormField<String>(
                                value: _category,
                                decoration: InputDecoration(
                                  labelText: 'Categoría',
                                  prefixIcon: const Icon(Icons.category),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'General', child: Text('General')),
                                  DropdownMenuItem(value: 'Alimentación', child: Text('Alimentación')),
                                  DropdownMenuItem(value: 'Transporte', child: Text('Transporte')),
                                  DropdownMenuItem(value: 'Vivienda', child: Text('Vivienda')),
                                  DropdownMenuItem(value: 'Entretenimiento', child: Text('Entretenimiento')),
                                  DropdownMenuItem(value: 'Salud', child: Text('Salud')),
                                  DropdownMenuItem(value: 'Educación', child: Text('Educación')),
                                  DropdownMenuItem(value: 'Inversiones', child: Text('Inversiones')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _category = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              // Fecha
                              InkWell(
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
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Fecha',
                                    prefixIcon: const Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Descripción
                              TextFormField(
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
                    
                    // Botón para guardar
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C2FCF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'GUARDAR TRANSACCIÓN',
                                style: TextStyle(
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

  Widget _buildTypeButton(String type, String label) {
    final isSelected = _type == type;
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _type = type;
          });
        },
        icon: Icon(_typeIcons[type]),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? _typeColors[type] : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyButton(String currency) {
    final isSelected = _currency == currency;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _currency = currency;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF3C2FCF) : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(currency),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        _formKey.currentState!.save();

        // Crear la transacción
        final transaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: _type,
          amount: _amount!,
          currency: _currency,
          category: _category,
          date: _selectedDate,
          profile: _currency, // Usar moneda como perfil para simplificar
          description: _description,
        );

        // Guardar en Firebase
        await _financeService.saveTransaction(transaction);

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transacción guardada correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Regresar a la pantalla principal
        Navigator.pop(context);
      } catch (e) {
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
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