import 'package:carapp/screens/araba_detayi.dart';
import 'package:flutter/material.dart';
import '../models/arabalar.dart';
import '../araçlar/araclar.dart';

class ArabaDuzeni extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: ScrollPhysics(),
      shrinkWrap:
          true, // GridView'ün boyutunun yalnızca içerik kadar olmasını sağlar
      itemCount: TumArabalar.Arabalar.length,
      itemBuilder: (context, i) {
        final araba = TumArabalar
            .Arabalar[i]; //uzun metni sadece araba olarak yaz !unutma!
        return _buildArabaItem(context, araba, i);
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Her satırda 2 araba olacak
      ),
    );
  }

  Widget _buildArabaItem(BuildContext context, Araba araba, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        //tıklanabilir
        //IconButtonla aynı
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ArabaDetayi(
                    isim: araba.isim,
                    marka: araba.marka,
                    yakit: araba.yakit,
                    fiyat: araba.fiyat,
                    resim: araba.resim,
                    vites: araba.vites,
                    renk: araba.renk,
                  )));
        },
        child: Container(
          margin: EdgeInsets.only(
            top: index.isEven ? 0 : 10,
            bottom: index.isEven ? 10 : 0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(187, 0, 0, 0),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Image.asset(
                araba.resim,
                width: MediaQuery.of(context).size.width *
                    0.6, // Ekranın %40'ı kadar genişlik
                height: MediaQuery.of(context).size.height *
                    0.2, // Ekranın %20'si kadar yükseklik
                //burdaki sayıyı küçülttükçe emulatörüm de küçültebilirim
                fit: BoxFit.cover,
              ),

              Text(
                araba.isim,
                style: OrtaBaslik,
              ),
              Text(
                araba.fiyat.toString(),
                style: AltBaslik,
              ),
              // sabit metin bıraktık "Küçük Metin"
            ],
          ),
        ),
      ),
    );
  }
}
