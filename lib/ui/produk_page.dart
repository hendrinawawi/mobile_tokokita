import 'package:flutter/material.dart';
import 'package:toko_kita/bloc/logout_bloc.dart';
import 'package:toko_kita/bloc/produk_bloc.dart';
import 'package:toko_kita/model/produk.dart';
import 'package:toko_kita/ui/login_page.dart';
import 'package:toko_kita/ui/produk_detail.dart';
import 'package:toko_kita/ui/produk_form.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Produk'),
        backgroundColor: Colors.brown,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              child: const Icon(Icons.add, size: 26.0),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProdukForm(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(Icons.logout),
              onTap: () async {
                await LogoutBloc.logout().then((value) {
                  Navigator.pushReplacement(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Produk>>(
        future: ProdukBloc.getProduk(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // ignore: avoid_print
            print("Error: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Debug data yang diterima
          snapshot.data?.forEach((produk) {
            // ignore: avoid_print
            print("Produk di FutureBuilder: ${produk.toJson()}");
          });

          return ListProduk(list: snapshot.data!);
        },
      ),
    );
  }
}

class ListProduk extends StatelessWidget {
  final List<Produk> list;

  const ListProduk({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return ItemProduk(
            produk: list[index]); // Kirim data produk ke ItemProduk
      },
    );
  }
}

class ItemProduk extends StatelessWidget {
  final Produk produk;

  const ItemProduk({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    // Debug properti produk
    // ignore: avoid_print
    print("ItemProduk - Produk: ${produk.toJson()}");

    return GestureDetector(
      onTap: () {
        // ignore: avoid_print
        print("Navigasi ke detail produk: ${produk.namaProduk}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProdukDetail(produk: produk),
          ),
        );
      },
      child: Card(
        child: ListTile(
          title: Text(produk.namaProduk),
          subtitle:
              Text('Harga: Rp ${produk.hargaProduk}'), // Harga tetap String
        ),
      ),
    );
  }
}
