import 'package:flutter/material.dart';
import 'package:meu_primeiro_app/services/auth_services.dart';
import 'package:meu_primeiro_app/telas/tela_login.dart';
import 'package:meu_primeiro_app/telas/tela_principal.dart';
import 'package:provider/provider.dart';

class AuthCheck extends StatefulWidget {
  AuthCheck({super.key}); 

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    if (auth.isloading) {
      return _loading();
    } 
    else if (auth.usuario == null) {
      return LoginPage();  
    } 
    else {
      return TelaPrincipal();
    }
  }

  Widget _loading() {
    return Scaffold( 
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
