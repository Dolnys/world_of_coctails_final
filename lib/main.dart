import 'package:flutter/material.dart';
import 'package:world_of_coctails_final/constants/routes.dart';
import 'package:world_of_coctails_final/services/auth/auth_service.dart';
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
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        coctailsRoute: (context) => const CoctailsView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        CreateOrUptadeCoctailRoute: (context) =>
            const CreateUptadeCoctailView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const CoctailsView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
