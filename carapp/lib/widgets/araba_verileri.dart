import 'package:carapp/araçlar/araclar.dart';
import 'package:flutter/material.dart';

class ArabaVerileri extends StatelessWidget {
  final String isim;
  final double fiyat;
  final String isim2;

  ArabaVerileri({required this.isim, this.fiyat = 0.0, required this.isim2});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5), //boşluk
      height: 80, //kutuların boyutları
      width: 90,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10)),
      child: fiyat == 0.0
          ? Column(
              children: [
                Text(
                  isim,
                  style: OrtaBaslik,
                ),
                SizedBox(
                  height: 10, //en alttaki yazı boşlukları
                ),
                Text(
                  isim2,
                  style: AltBaslik,
                ),
              ],
            )
          : Column(
              children: [
                Text(
                  isim,
                  style: OrtaBaslik,
                ),
                SizedBox(
                  height: 5, //üstteki ve ortadaki yazı arası uzaklık
                ),
                Text(
                  fiyat.toString(),
                  style: AltBaslik,
                ),
                SizedBox(
                  height: 5, // ortadaki ve alttaki yazı arası uzaklık
                ),
                Text(isim2)
              ],
            ),
    );
  }
}
