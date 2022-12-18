import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_of_coctails_final/services/auth/auth_exceptions.dart';
import 'package:world_of_coctails_final/services/auth/block/auth_block.dart';
import 'package:world_of_coctails_final/services/auth/block/auth_event.dart';
import 'package:world_of_coctails_final/services/auth/block/auth_state.dart';
import 'package:world_of_coctails_final/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              'Cannot find a user with the entered credentials!',
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
      child: Expanded(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('Login'),
            backgroundColor: Color.fromARGB(255, 141, 207, 186),
          ),
          backgroundColor: Colors.amber,
          body: AnimateGradient(
            duration: const Duration(seconds: 5),
            primaryBegin: Alignment.topCenter,
            primaryEnd: Alignment.bottomRight,
            secondaryBegin: Alignment.bottomLeft,
            secondaryEnd: Alignment.bottomLeft,
            primaryColors: const [
              Color.fromRGBO(234, 244, 244, 1),
              Color.fromARGB(255, 129, 231, 175),
            ],
            secondaryColors: const [
              Color.fromARGB(255, 130, 219, 149),
              Color.fromRGBO(204, 227, 222, 1),
            ],
            child: Center(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Image(
                            image: AssetImage('assets/images/logo.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email here',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'Enter your password here',
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 2),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(90)),
                    child: ElevatedButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        context.read<AuthBloc>().add(
                              AuthEventLogIn(
                                email,
                                password,
                              ),
                            );
                      },
                      child: Text(
                        'Login',
                        style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.black26;
                            }
                            return Colors.white;
                          }),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30)))),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventForgotPassword(),
                          );
                    },
                    child: const Text('Forgot password?'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventShouldRegister(),
                          );
                    },
                    child: const Text('Not registered yet? Register here!'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
