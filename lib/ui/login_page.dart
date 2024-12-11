import 'package:flutter/material.dart';
import 'package:toko_kita/bloc/login_bloc.dart';
import 'package:toko_kita/helpers/user_info.dart';
import 'package:toko_kita/ui/produk_page.dart';
import 'package:toko_kita/ui/registrasi_page.dart';
import 'package:toko_kita/widget/warning_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _emailTextboxController = TextEditingController();
  final TextEditingController _passwordTextboxController =
      TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _emailTextField(),
                _passwordTextField(),
                const SizedBox(height: 20),
                _buttonLogin(),
                const SizedBox(height: 30),
                _menuRegistrasi(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Membuat Textbox email
  Widget _emailTextField() {
    return TextFormField(
      focusNode: _emailFocusNode,
      decoration: const InputDecoration(labelText: "Email"),
      keyboardType: TextInputType.emailAddress,
      controller: _emailTextboxController,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email harus diisi';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Format email tidak valid';
        }
        return null;
      },
    );
  }

  // Membuat Textbox password
  Widget _passwordTextField() {
    return TextFormField(
      focusNode: _passwordFocusNode,
      decoration: const InputDecoration(labelText: "Password"),
      keyboardType: TextInputType.text,
      obscureText: true,
      controller: _passwordTextboxController,
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password harus diisi";
        }
        if (value.length < 6) {
          return "Password harus lebih dari 6 karakter";
        }
        return null;
      },
    );
  }

  // Membuat Tombol Login
  Widget _buttonLogin() {
    return ElevatedButton(
      // ignore: sort_child_properties_last
      child: _isLoading
          ? const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.0,
            )
          : const Text("Login"),
      onPressed: _isLoading ? null : _validateAndSubmit,
    );
  }

  void _validateAndSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      _submit();
    }
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await LoginBloc.login(
        email: _emailTextboxController.text,
        password: _passwordTextboxController.text,
      );

      // ignore: avoid_print
      print(
          "Login berhasil - Token: ${result.token}, UserID: ${result.userID}");

      await UserInfo().setToken(result.token.toString());
      await UserInfo().setUserID(int.parse(result.userID.toString()));

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const ProdukPage()),
      );
    } catch (error) {
      // ignore: avoid_print
      print("Login gagal: $error"); // Tambahkan log error untuk debugging
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const WarningDialog(
          description: "Login gagal, silahkan coba lagi",
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Membuat menu untuk membuka halaman registrasi
  Widget _menuRegistrasi() {
    return Center(
      child: InkWell(
        child: const Text(
          "Registrasi",
          style: TextStyle(color: Colors.blue),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegistrasiPage()),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailTextboxController.dispose();
    _passwordTextboxController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
