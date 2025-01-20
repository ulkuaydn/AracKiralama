import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'arabalar_ekrani.dart';
import '../veritabani/veritabani.dart';
import 'admin_paneli.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniDurum();
}

class _GirisEkraniDurum extends State<GirisEkrani> {
  final eposta = TextEditingController();
  final sifre = TextEditingController();
  final uyeAd = TextEditingController();
  final uyeEposta = TextEditingController();
  final uyeSifre = TextEditingController();
  final uyeSifreTekrar = TextEditingController();
  bool _yukleniyor = false;
  final sayfaController = PageController();
  Future<void> _girisYap() async {
    if (eposta.text.isEmpty || sifre.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-posta ve şifre boş bırakılamaz!')),
      );
      return;
    }

    setState(() {
      _yukleniyor = true;
    });

    final vt = VeriTabani();
    final kullanici = await vt.kullaniciGiris(eposta.text, sifre.text);

    if (kullanici != null) {
      final onbellek = await SharedPreferences.getInstance();
      await onbellek.setBool('girisYapildi', true);
      await onbellek.setInt('kullanici_id', kullanici['id']);
      await onbellek.setString('kullanici_rol', kullanici['rol']);

      if (mounted) {
        if (kullanici['rol'] == 'admin') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AdminPaneli()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ArabalarEkrani()),
            (route) => false,
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hatalı e-posta veya şifre!')),
        );
      }
    }

    setState(() {
      _yukleniyor = false;
    });
  }

  Future<void> _uyeOl() async {
    if (uyeAd.text.isEmpty || uyeEposta.text.isEmpty || uyeSifre.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tüm alanları doldurunuz!')),
      );
      return;
    }

    if (uyeSifre.text != uyeSifreTekrar.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifreler eşleşmiyor!')),
      );
      return;
    }

    setState(() {
      _yukleniyor = true;
    });

    final vt = VeriTabani();
    final basarili = await vt.kullaniciKaydet(
      uyeAd.text,
      uyeEposta.text,
      uyeSifre.text,
    );

    if (basarili) {
      final kullanici = await vt.kullaniciGiris(uyeEposta.text, uyeSifre.text);
      if (kullanici != null) {
        final onbellek = await SharedPreferences.getInstance();
        await onbellek.setBool('girisYapildi', true);
        await onbellek.setInt('kullanici_id', kullanici['id']);

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ArabalarEkrani()),
            (route) => false,
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bu e-posta adresi zaten kullanılıyor!')),
        );
      }
    }

    setState(() {
      _yukleniyor = false;
    });
  }

  Widget _girisFormu() {
    return Container(
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
          const Text(
            'Giriş Yap',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: eposta,
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
            controller: sifre,
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
              onPressed: _yukleniyor ? null : _girisYap,
              child: _yukleniyor
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Giriş Yap', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => sayfaController.animateToPage(
              1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
            child: const Text('Hesabın yok mu? Üye Ol'),
          ),
        ],
      ),
    );
  }

  Widget UyeOlFormu() {
    return Container(
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
          const Text(
            'Üye Ol',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: uyeAd,
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
            controller: uyeEposta,
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
            controller: uyeSifre,
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
            controller: uyeSifreTekrar,
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
              onPressed: _yukleniyor ? null : _uyeOl,
              child: _yukleniyor
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Üye Ol', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => sayfaController.animateToPage(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
            child: const Text('Zaten hesabın var mı? Giriş Yap'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(174, 0, 4, 16),
              const Color.fromARGB(255, 244, 244, 244),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
             
              child: Image.asset(
                'resimler/araba_giris.png',
                width: 500,
                opacity: const AlwaysStoppedAnimation(0.5),
              ),
            ),
            PageView(
              controller: sayfaController,
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'HOŞGELDİNİZ',
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        const SizedBox(height: 40),
                        _girisFormu(),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Yeni Üyelik Oluştur',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 40),
                        UyeOlFormu(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    eposta.dispose();
    sifre.dispose();
    uyeAd.dispose();
    uyeEposta.dispose();
    uyeSifre.dispose();
    uyeSifreTekrar.dispose();
    sayfaController.dispose();
    super.dispose();
  }
}
