class Araba {
  final String isim;
  final double fiyat;
  final String renk;
  final String resim;
  final String vites;
  final String yakit;
  final String marka;

  Araba(
      {required this.isim,
      required this.fiyat,
      required this.renk,
      required this.resim,
      required this.vites,
      required this.yakit,
      required this.marka});
}

ArabaListesi TumArabalar = ArabaListesi(Arabalar: [
  Araba(
      isim: 'Peugeot 2008',
      fiyat: 8000,
      renk: 'Turuncu',
      vites: 'Otomatik',
      yakit: 'Dizel',
      marka: 'SUV',
      resim: 'resimler/araba_1.jpeg'),
  Araba(
      isim: 'Range Rover Sport',
      fiyat: 4500,
      renk: 'Siyah',
      vites: 'Otomatik',
      yakit: 'Dizel',
      marka: 'LAND ROVER',
      resim: 'resimler/araba_2.jpg'),
  Araba(
      isim: 'Chery Tiggo 8 Pro ',
      fiyat: 3000,
      renk: 'Beyaz',
      vites: 'Otomatik',
      yakit: 'Benzin',
      marka: 'SUV',
      resim: 'resimler/araba_3.jpg'),
  Araba(
      isim: 'BMW 5 Serisi',
      fiyat: 6500,
      renk: 'Bordo',
      vites: 'Otomatik',
      yakit: 'Dizel',
      marka: 'BMW',
      resim: 'resimler/araba_4.jpeg'),
  Araba(
      isim: 'Togg T10x ',
      fiyat: 7000,
      renk: 'Mavi',
      vites: 'Otomatik',
      yakit: 'Elektirikli',
      marka: 'TOGG',
      resim: 'resimler/araba_5.jpeg'),
  Araba(
      isim: 'Maserati Mc20',
      fiyat: 9000,
      renk: 'Sarı',
      vites: 'Otomatik',
      yakit: 'Dizel',
      marka: 'STELLANTİS',
      resim: 'resimler/araba_6.jpeg'),
  Araba(
      isim: 'Aston Martin',
      fiyat: 7500,
      renk: 'Pembe',
      vites: 'Otomatik',
      yakit: 'Elektirikli',
      marka: 'PREMİER AUTOMOTİVE GROUP',
      resim: 'resimler/araba_8.jpeg'),
  Araba(
      isim: 'Dacia Duster',
      fiyat: 5000,
      renk: 'Beton Gri',
      vites: 'Otomatik',
      yakit: 'Benzin',
      marka: 'SUV',
      resim: 'resimler/araba_7.webp'),
  Araba(
      isim: 'Jeep Wrangler',
      fiyat: 10000,
      renk: 'Gemlik Yeşili',
      vites: 'Otomatik',
      yakit: 'Dizel',
      marka: 'FCA',
      resim: 'resimler/araba_9.jpeg'),
  Araba(
      isim: 'Mini Cooper ',
      fiyat: 6000,
      renk: 'Kırmızı',
      vites: 'Otomatik',
      yakit: 'Benzin',
      marka: 'BMW',
      resim: 'resimler/araba_10.jpg'),
]);

class ArabaListesi {
  List<Araba> Arabalar;

  ArabaListesi({required this.Arabalar});
}
