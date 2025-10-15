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
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Login Successful!')));
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ));
            } else if (state.status == LoginStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  content: Text(
                    state.errorMessage ?? 'Login Failed',
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
        final isLoading = state.status == LoginStatus.loading;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const _Logo(),
                  const SizedBox(height: 24),
                  _EmailField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    enabled: !isLoading,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                  const SizedBox(height: 16),
                  _PasswordField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    isObscured: _isPasswordObscured,
                    enabled: !isLoading,
                    onFieldSubmitted: (_) => _onLoginPressed(),
                    onToggleObscure: () {
                      setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const _RememberMeCheckbox(),
                  const SizedBox(height: 24),
                  _LoginButton(onPressed: _onLoginPressed),
                ],
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
      height: 300,
      width: 300,
      child: Image.asset('assets/images/logo_app.png'),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({
    required this.controller,
    required this.focusNode,
    required this.onFieldSubmitted,
    this.enabled = true,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onFieldSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      decoration: const InputDecoration(
        labelText: 'Email Address',
      ),
      validator: (value) {
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (value == null || !emailRegex.hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
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
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isObscured;
  final ValueChanged<String> onFieldSubmitted;
  final VoidCallback onToggleObscure;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleObscure,
        ),
      ),
      validator: (value) {
        if (value == null || value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
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
          title: const Text('Remember Me'),
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
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: state.status == LoginStatus.loading ? null : onPressed,
          child: state.status == LoginStatus.loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Login'),
        );
      },
    );
  }
}
