import 'package:flutter/material.dart';
import 'package:face_shield/services/api.dart' as api;

class IdentityConfirmationWidget extends StatefulWidget {
  @override
  _IdentityConfirmationWidgetState createState() =>
      _IdentityConfirmationWidgetState();
}

class _IdentityConfirmationWidgetState extends State<IdentityConfirmationWidget> {
  bool isIdentityConfirmed = false;
  bool wrongPasswordEntered = false;
  String enteredPassword = '';
  String userEmail = "";
  String picturePath = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set up a callback to handle the back button press
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = ModalRoute.of(context)!;
      currentRoute.addScopedWillPopCallback(() async {
        // If the back button is pressed, navigate to the home screen
        Navigator.pop(context);
        return Future.value(true); // Return true to allow popping the route
      });
    });
  }

  void handleConfirmation(bool confirmIdentity) {
    if (confirmIdentity) {
      setState(() {
        isIdentityConfirmed = true;
      });
    } else {
      Navigator.pushNamed(context, "/"); // Navigate to home screen
    }
  }

  void handleLogin() {
    if (userEmail.isNotEmpty) {
      api.logInWithPassword(userEmail, enteredPassword).then((result) {
        if (result) {
          Navigator.popAndPushNamed(context, "/successLogin",
              arguments: [picturePath, userEmail]);
        } else {
          setState(() {
            wrongPasswordEntered = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> arguments =
    ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    picturePath = arguments[0];
    userEmail = arguments[1];
    return AlertDialog(
      title: const Text("Confirm Identity"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Is this the correct user?"),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(userEmail),
          ),
          if (isIdentityConfirmed)
            TextField(
                obscureText: true,
                onChanged: (password) {enteredPassword = password;},
                decoration: InputDecoration(
                    labelText: 'Enter your password',
                    labelStyle: TextStyle(color: wrongPasswordEntered ? Colors.red : Colors.white),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: wrongPasswordEntered ? Colors.red : Colors.blue)))),
          Text(
            wrongPasswordEntered ? "Wrong password! Try again" : "",
            style: const TextStyle(color: Colors.red),
          )
        ],
      ),
      actions: [
        if (!isIdentityConfirmed)
          TextButton(
            onPressed: () => handleConfirmation(true),
            child: const Text("Yes"),
          ),
        if (!isIdentityConfirmed)
          TextButton(
            onPressed: () => handleConfirmation(false),
            child: const Text("No"),
          ),
        if (isIdentityConfirmed)
          TextButton(
            onPressed: handleLogin,
            child: const Text("Login"),
          ),
      ],
    );
  }
}
