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
  bool _isLoading = false;

  final Map<String, IconData> _typeIcons = {
    'ingreso': Icons.trending_up_rounded,
    'gasto': Icons.trending_down_rounded,
    'ahorro': Icons.savings_rounded,
  };

  final Map<String, Color> _typeColors = {
    'ingreso': const Color(0xFF10B981),
    'gasto': const Color(0xFFEF4444),
    'ahorro': const Color(0xFF3B82F6),
  };

  @override
  void initState() {
    super.initState();
    _type = widget.transaction.type;
    _amount = widget.transaction.amount;
    _currency = widget.transaction.currency;
    _category = widget.transaction.category;
    _selectedDate = widget.transaction.date;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Editar Transacción',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF3C2FCF),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient header
            Container(
              height: 140,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3C2FCF), Color(0xFF4A3AFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Main form card
                    Card(
                      elevation: 12,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header icon and title
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [_typeColors[_type]!, _typeColors[_type]!.withOpacity(0.8)],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _typeColors[_type]!.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _typeIcons[_type],
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Editar Transacción',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2C3E50),
                                          ),
                                        ),
                                        Text(
                                          'Modifica tu movimiento financiero',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Transaction type selector
                              _buildTransactionTypeSelector(),
                              
                              const SizedBox(height: 24),

                              // Amount field
                              _buildModernTextField(
                                initialValue: _amount.toString(),
                                label: 'Monto',
                                icon: Icons.monetization_on_rounded,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa un monto';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Por favor ingresa un número válido';
                                  }
                                  if (double.parse(value) <= 0) {
                                    return 'El monto debe ser mayor a 0';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _amount = double.parse(value!),
                              ),
                              
                              const SizedBox(height: 24),

                              // Currency selector
                              _buildCurrencySelector(),
                              
                              const SizedBox(height: 24),

                              // Category field
                              _buildModernTextField(
                                initialValue: _category,
                                label: 'Categoría',
                                icon: Icons.category_rounded,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa una categoría';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _category = value!,
                              ),
                              
                              const SizedBox(height: 24),

                              // Date picker
                              _buildDatePicker(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Update button
                    _buildUpdateButton(),
                    
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
  Widget _buildTransactionTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Tipo de Transacción',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Row(
            children: [
              _buildTransactionTypeButton('ingreso', 'Ingreso'),
              const SizedBox(width: 12),
              _buildTransactionTypeButton('gasto', 'Gasto'),
              const SizedBox(width: 12),
              _buildTransactionTypeButton('ahorro', 'Ahorro'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeButton(String type, String name) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [_typeColors[type]!, _typeColors[type]!.withOpacity(0.8)],
                  )
                : null,
            color: isSelected ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _typeColors[type]!.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                _typeIcons[type],
                color: isSelected ? Colors.white : _typeColors[type],
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : _typeColors[type],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    String? initialValue,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3C2FCF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3C2FCF),
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF3C2FCF),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Moneda',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Row(
            children: [
              _buildCurrencyButton('BOB', 'Bolivianos'),
              const SizedBox(width: 12),
              _buildCurrencyButton('USD', 'Dólares'),
              const SizedBox(width: 12),
              _buildCurrencyButton('USDT', 'Tether'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyButton(String currency, String name) {
    final isSelected = _currency == currency;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currency = currency;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF3C2FCF), Color(0xFF4A3AFF)],
                  )
                : null,
            color: isSelected ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF3C2FCF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                currency,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF3C2FCF),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Fecha',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF3C2FCF),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3C2FCF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF3C2FCF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _getRelativeDate(_selectedDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_typeColors[_type]!, _typeColors[_type]!.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _typeColors[_type]!.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.update_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'ACTUALIZAR TRANSACCIÓN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day)).inDays;
    
    if (difference < 0) {
      return 'Hace ${-difference} días';
    } else if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Mañana';
    } else {
      return 'En $difference días';
    }
  }

  Future<void> _updateTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        _formKey.currentState!.save();
        
        final updatedTransaction = Transaction(
          id: widget.transaction.id,
          type: _type,
          amount: _amount,
          currency: _currency,
          category: _category,
          date: _selectedDate,
          profile: _currency,
          description: null,
          userId: widget.transaction.userId,
          goalId: widget.transaction.goalId,
        );

        await _financeService.updateTransaction(updatedTransaction);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transacción actualizada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
