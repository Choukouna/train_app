import 'package:flutter/material.dart';
import 'package:jeusetmatch/db/crud.dart';
import 'package:jeusetmatch/dto/auth_info.dart';
import 'package:jeusetmatch/dto/constant.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _pseudoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    final contextCopy = ScaffoldMessenger.of(context);

    setState(() {
      _loading = true;
      _error = null;
    });

    AuthInfo authInfo = AuthInfo(_pseudoController.text.trim(), _passwordController.text.trim());
    Crud.signIn(authInfo)
    .then((_) {
      // ✅ Successful sign-in
      if (!mounted) return;
      contextCopy.showSnackBar(
        SnackBar(content: Text(Constante.LOGIN_SUCCESS)),
      );
      setState(() {
        _loading = false;
        _error = null;
      });
    })
    .catchError((onError) {
      if (!mounted) return;
      contextCopy.showSnackBar(
        SnackBar(content: Text(onError.message ?? Constante.LOGIN_ERROR)),
      );
      setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Container(
        margin: EdgeInsets.only(top: 40),
        child: Card(
          elevation: 8, // 👈 gives floating (shadow) effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0), // inner spacing
            child: SizedBox(
              width: 420, // fixed width for card
              child: Column(
                mainAxisSize: MainAxisSize.min, // wrap content
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    Constante.LOGIN,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrangeAccent
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _pseudoController,
                    decoration: InputDecoration(
                      labelText: Constante.PSEUDO,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: Constante.PASSWORD,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.deepOrangeAccent,
                    ),
                    child: Text(
                      Constante.LOGIN_VERB,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
