import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../veritabani/veritabani.dart';

class Kiralamalarim extends StatefulWidget {
  const Kiralamalarim({super.key});

  @override
  State<Kiralamalarim> createState() => KiralamalarimState();
}

class KiralamalarimState extends State<Kiralamalarim> {
  List<Map<String, dynamic>> _kiralamalar = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _kiralamalariGetir();
  }

  Future<void> _kiralamalariGetir() async {
    setState(() => _yukleniyor = true);
    try {
      final onbellek = await SharedPreferences.getInstance();
      final kullaniciId = onbellek.getInt('kullanici_id');
      if (kullaniciId != null) {
        final vt = VeriTabani();
        final kiralamalar = await vt.kullaniciKiralamalariniGetir(kullaniciId);
        setState(() => _kiralamalar = kiralamalar);
      }
    } finally {
      setState(() => _yukleniyor = false);
    }
  }

  Color _durumRengi(String durum) {
    switch (durum) {
      case 'beklemede':
        return Colors.orange;
      case 'onaylandı':
        return Colors.green;
      case 'reddedildi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _durumIkonu(String durum) {
    switch (durum) {
      case 'beklemede':
        return Icons.hourglass_empty;
      case 'onaylandı':
        return Icons.check_circle;
      case 'reddedildi':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Future<void> _kiralamaIptalEt(int kiralamaId) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kiralama İptali'),
        content: const Text('Bu kiralama talebini iptal etmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );

    if (onay == true) {
      final vt = VeriTabani();
      final sonuc = await vt.kiralamaIptalEt(kiralamaId);
      
      if (sonuc && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kiralama talebi iptal edildi')),
        );
        _kiralamalariGetir(); // Listeyi yenile
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Kiralamalarım',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _kiralamalariGetir,
          ),
        ],
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _kiralamalar.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.car_rental,
                          size: 80, color: Colors.grey.shade600),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz kiralama talebiniz bulunmuyor',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _kiralamalar.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final kiralama = _kiralamalar[index];
                    final durum = kiralama['durum'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _durumRengi(durum).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _durumIkonu(durum),
                                    color: _durumRengi(durum),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        kiralama['araba_isim'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tutar: ${kiralama['tutar']?.toStringAsFixed(0) ?? 0} ₺',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(15),
                              ),
                            ),
                            child: Column(
                              children: [
                                _bilgiSatiri(
                                    'Başlangıç', kiralama['baslangic_tarihi']),
                                const SizedBox(height: 8),
                                _bilgiSatiri('Bitiş', kiralama['bitis_tarihi']),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _durumRengi(durum).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _durumRengi(durum),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    durum.toUpperCase(),
                                    style: TextStyle(
                                      color: _durumRengi(durum),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (durum == 'beklemede') ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () => _kiralamaIptalEt(kiralama['id']),
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              label: const Text(
                                'İptal Et',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _bilgiSatiri(String baslik, String deger) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          baslik,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        Text(
          deger,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
