import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'arabalar_ekrani.dart';

class UyeOlEkrani extends StatefulWidget {
  const UyeOlEkrani({super.key});

  @override
  State<UyeOlEkrani> createState() => UyeOlEkraniDurum();
}

class UyeOlEkraniDurum extends State<UyeOlEkrani> {
  final _adKontrol = TextEditingController();
  final _epostaKontrol = TextEditingController();
  final _sifreKontrol = TextEditingController();
  final _sifreTekrarKontrol = TextEditingController();
  bool yukleniyor = false;

  Future<void> _uyeOl() async {
    if (_sifreKontrol.text != _sifreTekrarKontrol.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifreler eşleşmiyor!')),
      );
      return;
    }

    setState(() {
      yukleniyor = true;
    });

    // Burada gerçek bir API çağrısı yapılabilir
    await Future.delayed(const Duration(seconds: 2));

    final onbellek = await SharedPreferences.getInstance();
    await onbellek.setBool('girisYapildi', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ArabalarEkrani()),
      );
    }

    setState(() {
      yukleniyor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Üye Ol'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _adKontrol,
                    decoration: InputDecoration(
                      labelText: 'Ad Soyad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _epostaKontrol,
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _sifreKontrol,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _sifreTekrarKontrol,
                    decoration: InputDecoration(
                      labelText: 'Şifre Tekrar',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: yukleniyor ? null : _uyeOl,
                      child: yukleniyor
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Üye Ol',
                              style: TextStyle(fontSize: 16),
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

  @override
  void dispose() {
    _adKontrol.dispose();
    _epostaKontrol.dispose();
    _sifreKontrol.dispose();
    _sifreTekrarKontrol.dispose();
    super.dispose();
  }
}
