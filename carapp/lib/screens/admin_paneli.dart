import 'package:flutter/material.dart';
import '../veritabani/veritabani.dart';
import 'giris_ekrani.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPaneli extends StatefulWidget {
  const AdminPaneli({super.key});

  @override
  State<AdminPaneli> createState() => AdminPaneliState();
}

class AdminPaneliState extends State<AdminPaneli> {
  List<Map<String, dynamic>> _kiralamalar = [];
  bool _yukleniyor = true;
  String _secilenDurum = 'tümü';

  @override
  void initState() {
    super.initState();
    _kiralamalariGetir();
  }

  Future<void> _kiralamalariGetir() async {
    setState(() => _yukleniyor = true);
    final vt = VeriTabani();
    final kiralamalar = await vt.tumKiralamalariGetir();
    setState(() {
      _kiralamalar = kiralamalar;
      _yukleniyor = false;
    });
  }

  List<Map<String, dynamic>> _filtrelenmisKiralamalar() {
    if (_secilenDurum == 'tümü') return _kiralamalar;
    return _kiralamalar.where((k) => k['durum'] == _secilenDurum).toList();
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

  double _toplamTutar() {
    return _kiralamalar
        .where((k) => k['durum'] == 'onaylandı')
        .fold(0.0, (toplam, kiralama) => toplam + (kiralama['tutar'] ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    final filtrelenmisListe = _filtrelenmisKiralamalar();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Paneli'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _kiralamalariGetir,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              final onbellek = await SharedPreferences.getInstance();
              await onbellek.clear();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const GirisEkrani()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ozet('Toplam Talep', _kiralamalar.length.toString(),
                        Icons.summarize),
                    _ozet(
                        'Bekleyen',
                        _kiralamalar
                            .where((k) => k['durum'] == 'beklemede')
                            .length
                            .toString(),
                        Icons.pending),
                    _ozet(
                        'Toplam Tutar',
                        '${_toplamTutar().toStringAsFixed(0)} ₺',
                        Icons.payments),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _durumButonu('tümü', 'Tümü', Icons.list),
                      _durumButonu(
                          'beklemede', 'Bekleyenler', Icons.pending_actions),
                      _durumButonu(
                          'onaylandı', 'Onaylananlar', Icons.check_circle),
                      _durumButonu('reddedildi', 'Reddedilenler', Icons.cancel),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _yukleniyor
                ? const Center(child: CircularProgressIndicator())
                : filtrelenmisListe.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              _secilenDurum == 'tümü'
                                  ? 'Henüz kiralama talebi yok'
                                  : 'Bu durumda kiralama talebi yok',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtrelenmisListe.length,
                        itemBuilder: (context, index) {
                          final kiralama = filtrelenmisListe[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: _durumRengi(kiralama['durum'])
                                    .withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: _durumRengi(kiralama['durum'])
                                    .withOpacity(0.2),
                                child: Icon(
                                  Icons.directions_car,
                                  color: _durumRengi(kiralama['durum']),
                                ),
                              ),
                              title: Text(
                                kiralama['araba_isim'] ?? 'Bilinmeyen Araç',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                kiralama['durum'].toUpperCase(),
                                style: TextStyle(
                                  color: _durumRengi(kiralama['durum']),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _bilgiSatiri(
                                          'Kiralayan', kiralama['ad_soyad']),
                                      _bilgiSatiri(
                                          'E-posta', kiralama['eposta']),
                                      _bilgiSatiri('Başlangıç',
                                          kiralama['baslangic_tarihi']),
                                      _bilgiSatiri(
                                          'Bitiş', kiralama['bitis_tarihi']),
                                      _bilgiSatiri('Tutar',
                                          '${kiralama['tutar']?.toStringAsFixed(0) ?? 0} ₺'),
                                      if (kiralama['durum'] == 'beklemede') ...[
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _actionButton(
                                              'Onayla',
                                              Icons.check,
                                              Colors.green,
                                              () async {
                                                final vt = VeriTabani();
                                                await vt.kiralamaDurumuGuncelle(
                                                    kiralama['id'],
                                                    'onaylandı');
                                                _kiralamalariGetir();
                                              },
                                            ),
                                            _actionButton(
                                              'Reddet',
                                              Icons.close,
                                              Colors.red,
                                              () async {
                                                final vt = VeriTabani();
                                                await vt.kiralamaDurumuGuncelle(
                                                    kiralama['id'],
                                                    'reddedildi');
                                                _kiralamalariGetir();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _ozet(String baslik, String deger, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(height: 8),
          Text(baslik, style: TextStyle(color: Colors.grey.shade600)),
          Text(
            deger,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _durumButonu(String durum, String etiket, IconData icon) {
    final secili = _secilenDurum == durum;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        selected: secili,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: secili ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Text(etiket),
          ],
        ),
        onSelected: (bool selected) {
          setState(() => _secilenDurum = durum);
        },
      ),
    );
  }

  Widget _bilgiSatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$baslik: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          Text(deger),
        ],
      ),
    );
  }

  Widget _actionButton(
      String etiket, IconData icon, Color renk, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(etiket),
      style: ElevatedButton.styleFrom(
        backgroundColor: renk,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
