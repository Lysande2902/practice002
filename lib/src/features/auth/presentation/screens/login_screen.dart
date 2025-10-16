import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/login_cubit.dart';
import '../../application/login_state.dart';
import '../../data/auth_repository.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(authRepository: AuthRepository())
        ..init(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.success) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('¡Inicio de sesión exitoso!')));
            } else if (state.status == LoginStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  content: Text(
                    state.errorMessage ?? 'Error al iniciar sesión',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ));
            }
          },
          child: const LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  bool _isPasswordObscured = true;

  // Nuevas variables de estado para la validez de los campos
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en los controladores para actualizar el estado de validación
    _emailController.addListener(_updateValidationStatus);
    _passwordController.addListener(_updateValidationStatus);
  }

  // Función auxiliar para validar el email
  String? _validateEmail(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (value == null || value.isEmpty || !emailRegex.hasMatch(value)) {
      return 'Por favor, introduce un email válido';
    }
    return null;
  }

  // Función auxiliar para validar la contraseña
  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  // Actualiza el estado de validez de los campos y reconstruye el widget si es necesario
  void _updateValidationStatus() {
    setState(() {
      _isEmailValid = _validateEmail(_emailController.text) == null;
      _isPasswordValid = _validatePassword(_passwordController.text) == null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().login(
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final bool isFormValid = _isEmailValid && _isPasswordValid;
        final isLoading = state.status == LoginStatus.loading;
        // El botón de login estará habilitado si el formulario es válido Y no está cargando
        final bool isLoginButtonEnabled = isFormValid && !isLoading;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const _Logo(),
                      const SizedBox(height: 24),
                      Text(
                        'Bienvenido de nuevo',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión para continuar',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _EmailField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_passwordFocusNode);
                        },
                        validator: _validateEmail, // Usar el validador auxiliar
                        onChanged: (_) => _updateValidationStatus(), // Actualizar estado al cambiar
                      ),
                      const SizedBox(height: 16),
                      _PasswordField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        isObscured: _isPasswordObscured,
                        // El campo de contraseña se habilita si no está cargando Y el email es válido
                        enabled: !isLoading && _isEmailValid,
                        onFieldSubmitted: (_) => _onLoginPressed(),
                        onToggleObscure: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                        validator: _validatePassword, // Usar el validador auxiliar
                        onChanged: (_) => _updateValidationStatus(), // Actualizar estado al cambiar
                      ),
                      const SizedBox(height: 8),
                      const _ForgotPasswordButton(),
                      const SizedBox(height: 8),
                      const _RememberMeCheckbox(),
                      const SizedBox(height: 24),
                      _LoginButton(
                        onPressed: isLoginButtonEnabled ? _onLoginPressed : null,
                      ),
                      const SizedBox(height: 24),
                      const _SignUpPrompt(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 150,
      child: Image.asset('assets/images/logo_app.png', fit: BoxFit.contain),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({
    required this.controller,
    required this.focusNode,
    required this.onFieldSubmitted,
    this.enabled = true,
    this.validator, // Añadir parámetro para el validador
    this.onChanged, // Añadir parámetro para onChanged
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onFieldSubmitted;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged, // Pasar onChanged al TextFormField
      decoration: InputDecoration(
        labelText: 'Correo Electrónico',
        prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.primary),
      ),
      validator: validator, // Usar el validador pasado
      keyboardType: TextInputType.emailAddress,
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.isObscured,
    required this.onFieldSubmitted,
    required this.onToggleObscure,
    this.enabled = true,
    this.validator, // Añadir parámetro para el validador
    this.onChanged, // Añadir parámetro para onChanged
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldValidator<String>? validator; // Declarar el validador
  final bool isObscured;
  final ValueChanged<String> onFieldSubmitted;
  final VoidCallback onToggleObscure;
  final bool enabled;
  final ValueChanged<String>? onChanged; // Añadir el campo onChanged aquí

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged, // Pasar onChanged al TextFormField
      enabled: enabled,
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleObscure,
        ),
      ),
      validator: validator, // Usar el validador pasado
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Implementar lógica de recuperación de contraseña
        },
        child: const Text('¿Olvidaste tu contraseña?'),
      ),
    );
  }
}


class _RememberMeCheckbox extends StatelessWidget {
  const _RememberMeCheckbox();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return CheckboxListTile(
          title: const Text('Recordarme'),
          value: state.isRememberMeChecked,
          onChanged: (newValue) {
            context.read<LoginCubit>().toggleRememberMe(newValue ?? false);
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: onPressed,
            child: state.status == LoginStatus.loading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                : const Text('INICIAR SESIÓN', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('¿No tienes una cuenta?'),
        TextButton(
          onPressed: () { /* TODO: Navegar a la pantalla de registro */ },
          child: const Text('Regístrate'),
        ),
      ],
    );
  }
}
