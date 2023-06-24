import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helpers/Helpers.dart';
import '../services/api.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  bool showPasswordRequirements = false;
  final FocusNode _focusNode = FocusNode();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  bool isValidEmail(String value){
    final RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
    return emailRegex.hasMatch(value);
  }

  void _onFocusChange() {
    if(!_focusNode.hasFocus){
      setState(() {
        showPasswordRequirements = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign Up"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        icon: FaIcon(FontAwesomeIcons.envelope),
                          labelText: "Email"
                      ),
                      validator: (String ? value ){
                        if(value!.trim().isEmpty){
                          return 'Email Required';
                        }
                        else if(!isValidEmail(value)){
                          return "Invalid email";
                        }
                        return null;
                      },
                      onChanged: (String value){
                        setState(() {
                          _formKey.currentState!.validate();
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      focusNode: _focusNode,
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        icon: const FaIcon(FontAwesomeIcons.lock),
                        labelText: "Password",
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              showPasswordRequirements = !showPasswordRequirements;
                            });
                          },
                          child: const Icon(Icons.info),
                        )
                      ),
                      validator: (String ? value ){
                        if(value!.trim().isEmpty){
                          return 'Password Required';
                        }
                        return null;
                      },
                      onChanged: (String value){
                        setState(() {
                          _formKey.currentState!.validate();
                        });
                      },
                    ),
                    showPasswordRequirements ?
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextField(
                            controller: _requirementsController,
                            decoration: const InputDecoration(
                              labelText: ""
                                  ". Longer than 6 characters",
                              labelStyle: TextStyle(fontSize: 15),
                              border: OutlineInputBorder()
                            ),
                            readOnly: true,
                            onTap: (){
                              setState(() {
                                showPasswordRequirements = false;
                              });
                            },
                          ),
                        ) : const Center(),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _repeatPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        icon: FaIcon(FontAwesomeIcons.lock),
                          labelText: "Repeat Password"
                      ),
                      validator: (String ? value ){
                        if(value!.trim().isEmpty || value.trim() != _passwordController.value.text){
                          return 'Password must match';
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
                      height: 200,
                    ),
                    _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                        onPressed: () async {
                          if(_formKey.currentState!.validate()){
                            setState(() {
                              _loading = true;
                            });
                            checkIfUserExists(_emailController.text).then((value) => {
                              if (!value)
                                {
                                  setState(() {
                                    _loading = false;
                                  }),
                                  Navigator.popAndPushNamed(context, "/faceRegister", arguments: [_emailController.text, _passwordController.text]),
                                  _emailController.clear(),
                                  _passwordController.clear(),
                                  _repeatPasswordController.clear(),
                                }
                              else
                                {
                                  setState((){
                                    _loading=false;
                                  }),
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                      content: Text("Error creating User. Email already registered!"))),
                                }
                            });
                          }
                        },
                        child: const Text("Create Account"))
                  ],
                ),
              ),
            )));
  }
}
