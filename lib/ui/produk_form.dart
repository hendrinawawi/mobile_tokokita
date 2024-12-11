import 'package:flutter/material.dart';
import 'package:toko_kita/bloc/produk_bloc.dart';
import 'package:toko_kita/model/produk.dart';
// ignore: unused_import
import 'package:toko_kita/ui/produk_page.dart';
import 'package:toko_kita/widget/warning_dialog.dart';

class ProdukForm extends StatefulWidget {
  final Produk? produk;

  const ProdukForm({super.key, this.produk});

  @override
  // ignore: library_private_types_in_public_api
  _ProdukFormState createState() => _ProdukFormState();
}

class _ProdukFormState extends State<ProdukForm> {
  final _formKey = GlobalKey<FormState>();
  final _kodeProdukController = TextEditingController();
  final _namaProdukController = TextEditingController();
  final _hargaProdukController = TextEditingController();

  bool _isLoading = false;
  late String _judul;
  late String _tombolSubmit;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.produk != null) {
      _judul = "UBAH PRODUK";
      _tombolSubmit = "UBAH";
      _kodeProdukController.text = widget.produk?.kodeProduk ?? '';
      _namaProdukController.text = widget.produk?.namaProduk ?? '';
      _hargaProdukController.text = widget.produk?.hargaProduk ?? '';
    } else {
      _judul = "TAMBAH PRODUK";
      _tombolSubmit = "SIMPAN";
    }
  }

  @override
  void dispose() {
    _kodeProdukController.dispose();
    _namaProdukController.dispose();
    _hargaProdukController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul)),
      //backgroundColor: Colors.brown,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _kodeProdukController,
                  labelText: "Kode Produk",
                  validator: (value) => value == null || value.isEmpty
                      ? "Kode Produk harus diisi"
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _namaProdukController,
                  labelText: "Nama Produk",
                  validator: (value) => value == null || value.isEmpty
                      ? "Nama Produk harus diisi"
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _hargaProdukController,
                  labelText: "Harga Produk",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Harga harus diisi";
                    }
                    if (double.tryParse(value) == null) {
                      // Validasi angka
                      return "Harga harus berupa angka";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    if (widget.produk != null) {
                      await _submitForm(isUpdate: true);
                    } else {
                      await _submitForm(isUpdate: false);
                    }

                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => const WarningDialog(
                          description: "Proses gagal, silahkan coba lagi",
                        ),
                      );
                    }
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(_tombolSubmit),
      ),
    );
  }

  Future<void> _submitForm({required bool isUpdate}) async {
    final produk = Produk(
      id: isUpdate ? widget.produk?.id : null,
      kodeProduk: _kodeProdukController.text,
      namaProduk: _namaProdukController.text,
      hargaProduk: _hargaProdukController.text, // Tetap String di model
    );
    final Map<String, dynamic> produkData = produk.toJson();
// Konversi harga ke integer sebelum mengirim
    produkData['harga'] = int.parse(produk.hargaProduk);

    // Debugging: Lihat data produk yang akan dikirim
    // ignore: avoid_print
    print("Produk yang akan dikirim: ${produk.toJson()}");

    if (isUpdate) {
      await ProdukBloc.updateProduk(produk: produk);
    } else {
      await ProdukBloc.addProduk(produk: produk);
    }
  }
}
