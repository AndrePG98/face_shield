import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helpers/Helpers.dart';
import '../services/api.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign Up"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (String ? value ){
                      if(value!.trim().isEmpty){
                        return 'O email é obrigatório!';
                      }
                      else if(!isValidEmail(value)){
                        return "Formato de email incorreto";
                      }
                      return null;
                    },
                    onChanged: (String value){
                      setState(() {
                        _formKey.currentState!.validate();
                      });
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: (String ? value ){
                      if(value!.trim().isEmpty){
                        return 'A password é obrigatória!';
                      }
                      return null;
                    },
                    onChanged: (String value){
                      setState(() {
                        _formKey.currentState!.validate();
                      });
                    },
                  ),
                   const SizedBox(
                    height: 16,
                  ),
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            if(_formKey.currentState!.validate()){
                              setState(() {
                                _loading = true;
                              });
                              signUp(_emailController.text,
                                  _passwordController.text)
                                  .then((value) => {
                                if (value)
                                  {
                                    setState(() {
                                      _loading = false;
                                    }),
                                    _emailController.clear(),
                                    _passwordController.clear(),
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                        content: Text(
                                            "Utilizador criado com sucesso!"))),
                                  }
                                else
                                  {
                                    setState((){
                                      _loading=false;
                                    }),
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                        content: Text("Erro ao criar utilizador. Email já existente!"))),
                                  }
                              });
                            }

                          },
                          child: const Text("Create Account"))
                ],
              ),
            )));
  }
}
