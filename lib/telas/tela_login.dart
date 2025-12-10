// lib/telas/tela_login.dart

import 'package:flutter/material.dart';
import 'package:meu_primeiro_app/services/auth_services.dart';
import 'package:meu_primeiro_app/telas/tela_principal.dart';
import 'package:provider/provider.dart';
import 'package:meu_primeiro_app/telas/tela_cadastro.dart';
import 'package:meu_primeiro_app/telas/tela_esqueceu_senha.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key); 

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final senha = TextEditingController();
  bool loading = false;

  login() async {
    setState(() {
      loading = true;
    });
    try {
      await context.read<AuthService>().login(email.text, senha.text);
      
      // RESETA O LOADING MESMO NO SUCESSO
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TelaPrincipal()),
        );
      }
      
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('./assets/fundo.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView( // ADICIONEI PARA EVITAR OVERFLOW
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Título
                  const Text(
                    'Login',               
                    style: TextStyle(
                      fontSize: 35,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Image.asset(
                    './assets/logo.png',
                    width: 120, 
                    height: 120,
                  ),

                  const SizedBox(height: 35),
   
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: TextFormField(
                      controller: email,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFC9D8B6),
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        labelText: 'Digite seu usuário ou e-mail',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Digite seu Email';
                        }
                        return null;
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: TextFormField(
                      controller: senha,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFC9D8B6),
                        prefixIcon: const Icon(Icons.key_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        labelText: 'Digite sua senha',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Digite sua senha';
                        } else if (value.length < 8) {
                          return 'Sua senha deve ter no mínimo 8 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Não tem uma conta? ',
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push( 
                            context,
                            MaterialPageRoute(builder: (_) => CadastroPage()),
                          );
                        },
                        child: Text(
                          'Cadastre-se aqui',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () {
                      Navigator.push( 
                        context,
                        MaterialPageRoute(builder: (_) => EsqueceuSenha()),
                      );
                    },
                    child: Text(
                      'Esqueceu sua senha?',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E8C61),
                        minimumSize: const Size(200, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: loading ? null : () { 
                        if (formKey.currentState!.validate()) {
                          login();
                        }
                      },
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Logar',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}