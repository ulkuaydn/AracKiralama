import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class VeriTabani {
  static final VeriTabani _instance = VeriTabani._internal();
  static Database? _veritabani;

  factory VeriTabani() => _instance;

  VeriTabani._internal();

  Future<Database> get veritabani async {
    if (_veritabani != null) return _veritabani!;
    _veritabani = await _veritabaniniBaslat();
    return _veritabani!;
  }

  Future<Database> _veritabaniniBaslat() async {
    String yol = await getDatabasesPath();
    String veritabaniYolu = join(yol, 'arac_kiralama.db');

    return await openDatabase(
      veritabaniYolu,
      version: 1,
      onCreate: _veritabaniOlustur,
    );
  }

  Future<void> _veritabaniOlustur(Database db, int version) async {
    // Kiralama tablosu
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kiralamalar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kullanici_id INTEGER,
        araba_isim TEXT,
        baslangic_tarihi TEXT,
        bitis_tarihi TEXT,
        durum TEXT DEFAULT 'beklemede',
        tutar REAL,
        FOREIGN KEY (kullanici_id) REFERENCES kullanicilar (id)
      )
    ''');

    // Kullanıcılar tablosu
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kullanicilar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ad_soyad TEXT,
        eposta TEXT UNIQUE,
        sifre TEXT,
        rol TEXT DEFAULT 'kullanici'
      )
    ''');

    // Admin kullanıcısını kontrol et ve ekle
    final List<Map<String, dynamic>> adminKontrol = await db.query(
      'kullanicilar',
      where: 'eposta = ?',
      whereArgs: ['admin'],
    );

    if (adminKontrol.isEmpty) {
      await db.insert('kullanicilar', {
        'ad_soyad': 'Admin',
        'eposta': 'admin',
        'sifre': 'admin123',
        'rol': 'admin'
      });
    }
  }

  // Kiralama işlemleri
  Future<bool> kiralamaOlustur(int kullaniciId, String arabaIsim, String baslangicTarihi, String bitisTarihi, double tutar) async {
    try {
      final db = await veritabani;
      await db.insert('kiralamalar', {
        'kullanici_id': kullaniciId,
        'araba_isim': arabaIsim,
        'baslangic_tarihi': baslangicTarihi,
        'bitis_tarihi': bitisTarihi,
        'durum': 'beklemede',
        'tutar': tutar
      });
      return true;
    } catch (e) {
      print('Kiralama oluşturulurken hata: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> tumKiralamalariGetir() async {
    final db = await veritabani;
    return await db.rawQuery('''
      SELECT k.*, ku.ad_soyad, ku.eposta 
      FROM kiralamalar k
      JOIN kullanicilar ku ON k.kullanici_id = ku.id
      ORDER BY k.id DESC
    ''');
  }

  Future<bool> kiralamaDurumuGuncelle(int kiralamaId, String yeniDurum) async {
    try {
      final db = await veritabani;
      await db.update(
        'kiralamalar',
        {'durum': yeniDurum},
        where: 'id = ?',
        whereArgs: [kiralamaId],
      );
      return true;
    } catch (e) {
      print('Kiralama durumu güncellenirken hata: $e');
      return false;
    }
  }

  // Kullanıcı işlemleri
  Future<bool> kullaniciKaydet(String adSoyad, String eposta, String sifre) async {
    try {
      final db = await veritabani;
      await db.insert('kullanicilar', {
        'ad_soyad': adSoyad,
        'eposta': eposta,
        'sifre': sifre,
        'rol': 'kullanici'
      });
      print('Kullanıcı başarıyla kaydedildi: $eposta');
      return true;
    } catch (e) {
      print('Kullanıcı kaydedilirken hata: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> kullaniciGiris(String eposta, String sifre) async {
    try {
      final db = await veritabani;
      final List<Map<String, dynamic>> sonuc = await db.query(
        'kullanicilar',
        where: 'eposta = ? AND sifre = ?',
        whereArgs: [eposta, sifre],
      );
      print('Giriş denemesi: $eposta');
      print('Sonuç: ${sonuc.isNotEmpty ? 'Başarılı' : 'Başarısız'}');
      return sonuc.isNotEmpty ? sonuc.first : null;
    } catch (e) {
      print('Giriş yapılırken hata: $e');
      return null;
    }
  }

  // Yeni üyeleri getir
  Future<int> yeniUyeSayisiniGetir() async {
    try {
      final db = await veritabani;
      final sonuc = await db.rawQuery('''
        SELECT COUNT(*) as sayi 
        FROM kullanicilar 
        WHERE rol = 'kullanici' 
        AND id IN (
          SELECT MAX(id) 
          FROM kullanicilar 
          WHERE rol = 'kullanici'
        )
      ''');
      return Sqflite.firstIntValue(sonuc) ?? 0;
    } catch (e) {
      print('Yeni üye sayısı alınırken hata: $e');
      return 0;
    }
  }

  // Kullanıcının kiralamalarını getir
  Future<List<Map<String, dynamic>>> kullaniciKiralamalariniGetir(int kullaniciId) async {
    final db = await veritabani;
    return await db.query(
      'kiralamalar',
      where: 'kullanici_id = ?',
      whereArgs: [kullaniciId],
      orderBy: 'id DESC', // En son kiralama en üstte
    );
  }

  // Mevcut kiralamaları kontrol et
  Future<bool> tarihMusaitMi(String arabaIsim, String baslangicTarihi, String bitisTarihi) async {
    try {
      final db = await veritabani;
      final List<Map<String, dynamic>> kiralamalar = await db.query(
        'kiralamalar',
        where: 'araba_isim = ? AND (durum = ? OR durum = ?)',  // Bekleyen ve onaylanan kiralamaları kontrol et
        whereArgs: [arabaIsim, 'onaylandı', 'beklemede'],      // Her iki durumu da kontrol ediyoruz
      );

      // Tarih string'lerini DateTime'a çevir
      DateTime yeniBaslangic = tarihiAyristir(baslangicTarihi);
      DateTime yeniBitis = tarihiAyristir(bitisTarihi);

      for (var kiralama in kiralamalar) {
        DateTime mevcutBaslangic = tarihiAyristir(kiralama['baslangic_tarihi']);
        DateTime mevcutBitis = tarihiAyristir(kiralama['bitis_tarihi']);

        // Tarih çakışması kontrolü - daha detaylı kontrol
        bool tarihCakisiyor = (yeniBaslangic.isBefore(mevcutBitis) || yeniBaslangic.isAtSameMomentAs(mevcutBitis)) && 
                             (yeniBitis.isAfter(mevcutBaslangic) || yeniBitis.isAtSameMomentAs(mevcutBaslangic));
        
        if (tarihCakisiyor) {
          print('Tarih çakışması: ${kiralama['durum']} durumunda kiralama mevcut');
          return false; // Tarihler çakışıyor
        }
      }
      return true; // Tarih müsait
    } catch (e) {
      print('Tarih kontrolünde hata: $e');
      return false;
    }
  }

  // Tarih string'ini DateTime'a çeviren yardımcı metod
  DateTime tarihiAyristir(String tarih) {
    List<String> parcalar = tarih.split('/');
    return DateTime(
      int.parse(parcalar[2]), // yıl
      int.parse(parcalar[1]), // ay
      int.parse(parcalar[0]), // gün
    );
  }

  // Arabanın dolu tarihlerini getir
  Future<List<Map<String, dynamic>>> doluTarihleriGetir(String arabaIsim) async {
    try {
      final db = await veritabani;
      return await db.query(
        'kiralamalar',
        columns: ['baslangic_tarihi', 'bitis_tarihi'],
        where: 'araba_isim = ? AND (durum = ? OR durum = ?)',
        whereArgs: [arabaIsim, 'onaylandı', 'beklemede'],
      );
    } catch (e) {
      print('Dolu tarihler getirilirken hata: $e');
      return [];
    }
  }

  // Kiralama iptal etme metodu
  Future<bool> kiralamaIptalEt(int kiralamaId) async {
    try {
      final db = await veritabani;
      await db.delete(
        'kiralamalar',
        where: 'id = ? AND durum = ?',
        whereArgs: [kiralamaId, 'beklemede'],
      );
      return true;
    } catch (e) {
      print('Kiralama iptal edilirken hata: $e');
      return false;
    }
  }
}
