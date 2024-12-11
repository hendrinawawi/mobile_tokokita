import 'package:flutter/material.dart';
import 'package:toko_kita/bloc/produk_bloc.dart';
import 'package:toko_kita/model/produk.dart';
import 'package:toko_kita/ui/produk_form.dart';

class ProdukDetail extends StatefulWidget {
  final Produk produk;

  const ProdukDetail({super.key, required this.produk});

  @override
  State<ProdukDetail> createState() => _ProdukDetailState();
}

class _ProdukDetailState extends State<ProdukDetail> {
  bool _isDeleting = false; // Indikator untuk proses penghapusan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem("Kode Produk", widget.produk.kodeProduk),
            const SizedBox(height: 8),
            _buildDetailItem("Nama Produk", widget.produk.namaProduk),
            const SizedBox(height: 8),
            _buildDetailItem("Harga", "Rp. ${widget.produk.hargaProduk}"),
            const SizedBox(height: 16),
            _tombolHapusEdit(),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan item detail
  Widget _buildDetailItem(String label, String value) {
    return Text(
      "$label: $value",
      style: const TextStyle(fontSize: 18.0),
    );
  }

  // Tombol untuk Edit dan Hapus
  Widget _tombolHapusEdit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Tombol Edit
        OutlinedButton.icon(
          icon: const Icon(Icons.edit, color: Colors.blue),
          label: const Text("EDIT"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProdukForm(produk: widget.produk),
              ),
            ).then((value) {
              if (value == true) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Produk berhasil diperbarui")),
                );
                setState(() {}); // Perbarui UI setelah edit
              }
            });
          },
        ),
        // Tombol Hapus
        OutlinedButton.icon(
          icon: _isDeleting
              ? const CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.red)
              : const Icon(Icons.delete, color: Colors.red),
          label: const Text("DELETE"),
          onPressed: _isDeleting ? null : _confirmHapus,
        ),
      ],
    );
  }

  // Dialog Konfirmasi Hapus
  void _confirmHapus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Konfirmasi",
          style: TextStyle(color: Colors.red),
        ),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context), // Tutup dialog
          ),
          TextButton(
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              await _hapusProduk();
            },
          ),
        ],
      ),
    );
  }

  // Fungsi untuk hapus produk dari backend
  Future<void> _hapusProduk() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await ProdukBloc.deleteProduk(
          widget.produk.id!); // Pastikan ID tidak null
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk berhasil dihapus")),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context, true); // Kembali ke halaman sebelumnya
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus produk: $e")),
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }
}
