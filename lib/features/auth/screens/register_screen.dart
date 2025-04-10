import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _username = '';

  Future<void> _registerUser() async {
    try {
      // Registrar al usuario en Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      // Actualizar el perfil del usuario con el nombre de usuario
      await userCredential.user?.updateDisplayName(_username);

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );

      // Navegar a la pantalla de inicio de sesión o principal
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Manejar errores de Firebase
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'El correo ya está en uso.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es demasiado débil.';
      } else {
        errorMessage = 'Ocurrió un error: ${e.message}';
      }

      // Mostrar el mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Manejar otros errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  color: const Color(0xFF3C2FCF),
                ),
                Positioned(
                  top: -50,
                  left: -50,
                  child: Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.25,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: const Text(
                      'Registro',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Section
            Container(
              color: const Color(0xFFF5F5F5),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // Username Input
                      Material(
                        elevation: 2,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Nombre de Usuario',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu nombre de usuario';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _username = value!;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Input
                      Material(
                        elevation: 2,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Correo Electrónico',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _email = value!;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Input
                      Material(
                        elevation: 2,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: 'Contraseña',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _password = value!;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Input
                      Material(
                        elevation: 2,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Confirmar Contraseña',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor confirma tu contraseña';
                            }
                            if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _confirmPassword = value!;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Register Button
                      Material(
                        elevation: 4,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _registerUser(); // Llamar al método para registrar al usuario
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3C2FCF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Back to Login Link
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            '¿Ya tienes una cuenta? Inicia sesión',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF3C2FCF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}