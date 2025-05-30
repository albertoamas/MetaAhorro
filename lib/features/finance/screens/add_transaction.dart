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
  String _currency = 'BOB'; // Moneda predeterminada
  String _category = ''; // Categoría libre
  DateTime _selectedDate = DateTime.now(); // Fecha predeterminada
  bool _isLoading = false;

  // Mapa de íconos para cada tipo de transacción
  final Map<String, IconData> _typeIcons = {
    'ingreso': Icons.trending_up_rounded,
    'gasto': Icons.trending_down_rounded,
    'ahorro': Icons.savings_rounded,
  };

  // Mapa de colores para cada tipo de transacción
  final Map<String, Color> _typeColors = {
    'ingreso': const Color(0xFF10B981),
    'gasto': const Color(0xFFEF4444),
    'ahorro': const Color(0xFF3B82F6),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Nueva Transacción',
          style: TextStyle(
            color: Colors.white, 
            fontSize: 20, 
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF3C2FCF),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Fondo con gradiente
            Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3C2FCF),
                    Color(0xFFF8FAFC),
                  ],
                  stops: [0.0, 0.3],
                ),
              ),
            ),
            
            // Formulario
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Título de la sección
                  _buildSectionTitle('Información de la Transacción'),
                  const SizedBox(height: 16),
                  
                  // Tarjeta del formulario
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selector de tipo de transacción
                            _buildFieldLabel('Tipo de Transacción'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildTypeButton('ingreso', 'Ingreso'),
                                const SizedBox(width: 8),
                                _buildTypeButton('gasto', 'Gasto'),
                                const SizedBox(width: 8),
                                _buildTypeButton('ahorro', 'Ahorro'),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Monto
                            _buildModernTextField(
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              labelText: 'Monto',
                              icon: Icons.payments_rounded,
                              iconColor: _typeColors[_type]!,
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
                            const SizedBox(height: 24),

                            // Selector de moneda
                            _buildFieldLabel('Moneda'),
                            const SizedBox(height: 12),
                            _buildCurrencySelector(),
                            const SizedBox(height: 24),
                            
                            // Categoría
                            _buildModernTextField(
                              initialValue: _category,
                              labelText: 'Categoría',
                              icon: Icons.category_rounded,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa una categoría';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _category = value!;
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // Fecha
                            _buildDatePicker(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botón para guardar
                  _buildModernButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Color(0xFF374151),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildModernTextField({
    String? initialValue,
    required String labelText,
    required IconData icon,
    Color? iconColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF374151),
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon, 
            color: iconColor ?? const Color(0xFF3C2FCF),
            size: 20,
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
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: iconColor ?? const Color(0xFF3C2FCF),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFEF4444),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildTypeButton(String type, String label) {
    final isSelected = _type == type;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(
              color: _typeColors[type]!.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : [],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _type = type;
            });
          },
          icon: Icon(_typeIcons[type], size: 18),
          label: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? _typeColors[type] : Colors.grey[100],
            foregroundColor: isSelected ? Colors.white : const Color(0xFF6B7280),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Row(
      children: [
        _buildCurrencyButton('BOB'),
        const SizedBox(width: 8),
        _buildCurrencyButton('USD'),
        const SizedBox(width: 8),
        _buildCurrencyButton('USDT'),
      ],
    );
  }

  Widget _buildCurrencyButton(String currency) {
    final isSelected = _currency == currency;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF3C2FCF).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : [],
        ),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _currency = currency;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? const Color(0xFF3C2FCF) : Colors.grey[100],
            foregroundColor: isSelected ? Colors.white : const Color(0xFF6B7280),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Text(
            currency,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
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
                  onSurface: Color(0xFF374151),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFF3C2FCF),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFormattedDate(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    Text(
                      _getRelativeDateDescription(_selectedDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3C2FCF),
            Color(0xFF4A3AFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3C2FCF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                    Icons.save_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'GUARDAR TRANSACCIÓN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _getRelativeDateDescription(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    
    final difference = selectedDay.difference(today).inDays;
    
    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Mañana';
    } else if (difference == -1) {
      return 'Ayer';
    } else if (difference > 1) {
      return 'En $difference días';
    } else {
      return 'Hace ${-difference} días';
    }
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
          description: null,
        );

        // Guardar en Firebase
        await _financeService.saveTransaction(transaction);

        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Transacción guardada correctamente'),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          // Regresar a la pantalla principal
          Navigator.pop(context);
        }
      } catch (e) {
        // Mostrar error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Error al guardar: $e')),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
