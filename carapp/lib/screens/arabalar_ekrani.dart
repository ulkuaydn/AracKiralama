import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../araçlar/araclar.dart';
import '../widgets/araba_duzeni.dart';
import 'giris_ekrani.dart';
import 'kiralamalarim.dart';

class ArabalarEkrani extends StatelessWidget {
  const ArabalarEkrani({super.key});

  Future<void> CikisYap(BuildContext context) async {
    final cikisOnayi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (cikisOnayi != true) return;

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final onbellek = await SharedPreferences.getInstance();
    await onbellek.clear();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const GirisEkrani()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'ARAÇ KİRALAMA',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Kiralamalarım',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Kiralamalarim()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => CikisYap(context),
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: ListView(
        children: [
          const Text(
            ' ARAÇLAR',
            style: AnaBaslik,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ArabaDuzeni(),
          )
        ],
      ),
    );
  }
}
