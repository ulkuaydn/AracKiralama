import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carapp/veritabani/veritabani.dart';

class ArabaDetayi extends StatefulWidget {
  final String isim;
  final double fiyat;
  final String renk;
  final String resim;
  final String vites;
  final String yakit;
  final String marka;

  const ArabaDetayi({
    required this.isim,
    required this.fiyat,
    required this.renk,
    required this.resim,
    required this.vites,
    required this.yakit,
    required this.marka,
    Key? key,
  }) : super(key: key);

  @override
  State<ArabaDetayi> createState() => ArabaDetayiDurumu();
}

class ArabaDetayiDurumu extends State<ArabaDetayi> {
  DateTime? baslangicTarihi;
  DateTime? bitisTarihi;
  int gunSayisi = 0;
  double toplamFiyat = 0;
  bool _yukleniyor = false;
  List<DateTimeRange> doluTarihler = [];

  @override
  void initState() {
    super.initState();
    _doluTarihleriGetir();
  }

  Future<void> _doluTarihleriGetir() async {
    final vt = VeriTabani();
    final doluTarihListesi = await vt.doluTarihleriGetir(widget.isim);
    
    setState(() {
      doluTarihler = doluTarihListesi.map((tarih) {
        return DateTimeRange(
          start: vt.tarihiAyristir(tarih['baslangic_tarihi']),
          end: vt.tarihiAyristir(tarih['bitis_tarihi']),
        );
      }).toList();
    });
  }

  // Tarih kontrolü için doğru imza
  bool Function(DateTime, DateTime?, DateTime?) get tarihMusaitMi => 
      (DateTime date, DateTime? start, DateTime? end) {
    // Geçmiş tarihleri seçilemez yap
    if (date.isBefore(DateTime.now())) return false;
    
    // Dolu tarihleri kontrol et
    for (var aralik in doluTarihler) {
      if (date.isAfter(aralik.start.subtract(const Duration(days: 1))) && 
          date.isBefore(aralik.end.add(const Duration(days: 1)))) {
        return false;
      }
    }
    return true;
  };

  Future<void> tarihAraligiSec(BuildContext context) async {
    final DateTimeRange? tarihAraligi = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color.fromARGB(255, 230, 9, 167),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
      selectableDayPredicate: tarihMusaitMi,
    );

    if (tarihAraligi != null) {
      bool aralikMusait = true;
      DateTime kontrol = tarihAraligi.start;
      
      while (kontrol.isBefore(tarihAraligi.end) || kontrol.isAtSameMomentAs(tarihAraligi.end)) {
        if (!tarihMusaitMi(kontrol, null, null)) {
          aralikMusait = false;
          break;
        }
        kontrol = kontrol.add(const Duration(days: 1));
      }

      if (aralikMusait) {
        setState(() {
          baslangicTarihi = tarihAraligi.start;
          bitisTarihi = tarihAraligi.end;
          gunSayisi = tarihAraligi.duration.inDays;
          toplamFiyat = widget.fiyat * gunSayisi;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Seçilen tarih aralığında dolu günler var!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> kiralamaOlustur() async {
    setState(() => _yukleniyor = true);

    try {
      final onbellek = await SharedPreferences.getInstance();
      final kullaniciId = onbellek.getInt('kullanici_id');

      if (kullaniciId == null) {
        throw Exception('Kullanıcı girişi bulunamadı');
      }

      final vt = VeriTabani();
      final sonuc = await vt.kiralamaOlustur(
        kullaniciId,
        widget.isim,
        "${baslangicTarihi?.day}/${baslangicTarihi?.month}/${baslangicTarihi?.year}",
        "${bitisTarihi?.day}/${bitisTarihi?.month}/${bitisTarihi?.year}",
        toplamFiyat,
      );

      if (sonuc && mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                child: Text(
                  "Kiralama Talebiniz Alındı!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text("Admin onayı bekleniyor."),
                ],
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 7, 23, 169),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Dialog'u kapat
                      Navigator.of(context).pop(); // Detay sayfasından çık
                    },
                    child: Text(
                      "Tamam",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bir hata oluştu. Lütfen tekrar deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isim),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Ortalamak için
          children: [
            // Araba bilgileri
            Center(
              child: Column(
                children: [
                  Text(widget.isim,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(widget.marka, style: TextStyle(fontSize: 18)),
                  Image.asset(widget.resim),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Özellikler kısmı

            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    115, 255, 255, 255), // kutu arka plan rengi
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(0, 9), // Gölge yönü
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "ÖZELLİKLER",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 253, 132, 39),
                        fontWeight: FontWeight.w900,
                        fontSize: 15),
                  ),
                  SizedBox(
                      height: 20), // özellikler ve alttaki yazılar arası boşluk
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OzellikKutusu("Renk", widget.renk),
                      OzellikKutusu("Vites", widget.vites),
                      OzellikKutusu("Yakıt", widget.yakit),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
            // Tarih seçimi ve toplam fiyat
            Center(
              child: Column(
                children: [
                  Text(
                    "-  Tarih Aralığı Seç  -",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 10), // tarihler arası boşluk
                  ElevatedButton(
                    onPressed: () => tarihAraligiSec(context),
                    child: Text("Seç"),
                  ),
                  SizedBox(height: 20),
                  if (baslangicTarihi != null && bitisTarihi != null) ...[
                    Text(
                      "Başlangıç: ${baslangicTarihi?.toLocal().toString().split(' ')[0]}",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      "Bitiş: ${bitisTarihi?.toLocal().toString().split(' ')[0]}",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Kiralama Süresi: $gunSayisi GÜN",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                  SizedBox(height: 20),
                  Text(
                    "Toplam Fiyat: ${toplamFiyat.toStringAsFixed(0)} ₺", // tl uzunluğu
                    style: TextStyle(
                        fontSize: 18,
                        color:
                            const Color.fromARGB(255, 7, 23, 169), //fiyat rengi
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: ElevatedButton(
                      onPressed: gunSayisi > 0
                          ? () async {
                              setState(() => _yukleniyor = true);

                              try {
                                final onbellek =
                                    await SharedPreferences.getInstance();
                                final kullaniciId =
                                    onbellek.getInt('kullanici_id');

                                if (kullaniciId == null) {
                                  throw Exception(
                                      'Kullanıcı girişi bulunamadı');
                                }

                                final vt = VeriTabani();
                                final sonuc = await vt.kiralamaOlustur(
                                  kullaniciId,
                                  widget.isim,
                                  "${baslangicTarihi?.day}/${baslangicTarihi?.month}/${baslangicTarihi?.year}",
                                  "${bitisTarihi?.day}/${bitisTarihi?.month}/${bitisTarihi?.year}",
                                  toplamFiyat,
                                );

                                if (sonuc && mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Center(
                                          child: Text(
                                            "Kiralama Talebiniz Alındı!",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 50,
                                            ),
                                            SizedBox(height: 10),
                                            Text("Admin onayı bekleniyor."),
                                          ],
                                        ),
                                        actions: [
                                          Center(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 7, 23, 169),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Dialog'u kapat
                                                Navigator.of(context)
                                                    .pop(); // Detay sayfasından çık
                                              },
                                              child: Text(
                                                "Tamam",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Bir hata oluştu. Lütfen tekrar deneyin.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                setState(() => _yukleniyor = false);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gunSayisi > 0
                            ? const Color.fromARGB(255, 255, 0, 0)
                            : Colors.grey,
                        foregroundColor:
                            gunSayisi > 0 ? Colors.white : Colors.black54,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: gunSayisi > 0 ? 5 : 0,
                      ),
                      child: _yukleniyor
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'KİRALA',
                              style: TextStyle(
                                fontSize: 15,
                                color: gunSayisi > 0
                                    ? const Color.fromARGB(255, 255, 255, 255)
                                    : Colors.black54,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget OzellikKutusu(String baslik, String deger) {
    return Column(
      children: [
        Text(
          baslik,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 5),
        Text(
          deger,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
