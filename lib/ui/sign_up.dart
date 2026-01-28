import 'package:flutter/material.dart';
import 'package:jeusetmatch/db/crud.dart';
import 'package:jeusetmatch/dto/auth_info.dart';
import 'package:jeusetmatch/dto/constant.dart';
import 'package:jeusetmatch/dto/player.dart';
import 'package:jeusetmatch/utils/utils_functions.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  final _pseudoController = TextEditingController();
  final _nameController = TextEditingController();
  final _pnomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _rankController = TextEditingController();
  final _cityController = TextEditingController();
  bool _creationOnGoing = false;

  /// Form submission handler
  void _signUp() {
    final contextCopy = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return;
    setState(() => _creationOnGoing = true);
    Player user = Player(
        _pseudoController.text.trim(),
        _nameController.text.trim(),
        _pnomController.text.trim(),
        _cityController.text.trim(),
        Utils.extractRankFromString(_rankController.text.trim()), 0, 0
    );

    AuthInfo authInfo = AuthInfo(_emailController.text.trim(), _passwordController.text.trim());

    /// Call DB to perform account creation
    Crud.signUp(player: user, authInfo: authInfo)
      .then((_) {
        contextCopy.showSnackBar(
          SnackBar(content: Text(Constante.ACCOUNT_CREATED)),
        );
        if (!mounted) return;
        setState(() => _creationOnGoing = false);
      })
      .catchError((error) {
        contextCopy.showSnackBar(
          SnackBar(content: Text(error.message ?? Constante.ACCOUNT_ERROR)),
        );
        if (!mounted) return;
        setState(() => _creationOnGoing = false);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creation de compte')),
      body: Container(
        margin: EdgeInsets.only(top: 20, bottom: 20),
        child: Card(
          elevation: 8, // 👈 gives floating (shadow) effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(24), // inner spacing
            child: ListView(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // wrap content
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        Constante.ACCOUNT_CREATION,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _pseudoController,
                        decoration: InputDecoration(
                          labelText: Constante.PSEUDO_LABEL,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) =>
                        v != null && v.length > 5 ? null : Constante.PSEUDO_ERROR,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: Constante.EMAIL_LABEL,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) =>
                        v != null && v.contains('@') ? null : Constante.EMAIL_ERROR,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: Constante.LASTNAME_LABEL,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pnomController,
                        decoration: InputDecoration(
                          labelText: Constante.FIRSTNAME_LABEL,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: Constante.CITY,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) =>
                        v != null && v.length > 2 ? null : Constante.CITY_ERROR,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: Constante.PASSWORD_LABEL,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) => v != null && v.length >= 6
                            ? null
                            : Constante.PASSWORD_ERROR,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: Constante.PASSWORD_CONFIRMATION,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) =>
                        v == _passwordController.text ? null : Constante.PASSWORD_IDENTICAL,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _rankController,
                        decoration: InputDecoration(
                          labelText: Constante.RANKING_TEXT,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) =>
                        Utils.isValidRank(v) ? null : Constante.RANKING_ERROR,
                      ),
                      const SizedBox(height: 24),
                      _creationOnGoing
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.deepOrangeAccent,
                        ),
                        child: Text(
                          Constante.MY_ACCOUNT,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ),
      )
    );
  }
}
