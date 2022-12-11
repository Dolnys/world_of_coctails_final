import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_of_coctails_final/constants/routes.dart';
import 'package:world_of_coctails_final/services/auth/auth_service.dart';
import 'package:world_of_coctails_final/services/auth/block/auth_block.dart';
import 'package:world_of_coctails_final/services/auth/block/auth_event.dart';
import 'package:world_of_coctails_final/services/auth/block/auth_state.dart';
import 'package:world_of_coctails_final/services/auth/firebase_auth_provider.dart';
import 'package:world_of_coctails_final/views/coctails/coctails_view.dart';
import 'package:world_of_coctails_final/views/coctails/create_update_coctail_view.dart';
import 'package:world_of_coctails_final/views/login_view.dart';

import 'package:world_of_coctails_final/views/register_view.dart';
import 'package:world_of_coctails_final/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        coctailsRoute: (context) => const CoctailsView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUptadeCoctailRoute: (context) =>
            const CreateUptadeCoctailView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const CoctailsView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(
              color: Colors.amber,
            )),
          );
        }
      },
    );
  }
}
