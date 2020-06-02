import 'package:alquran/ayat/model/ayat_model.dart';
import 'package:alquran/config/quran_api.dart';
import 'package:alquran/helper/database_helper.dart';
import 'package:alquran/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert' show utf8;

class AyatScreen extends StatefulWidget {
  AyatScreen({
    Key key,
    this.title,
    this.suratId,
    this.startFrom,
    this.limit
  }) : super(key: key);
  final String title;
  final int suratId;
  final int startFrom;
  final int limit;

  @override
  _AyatScreenState createState() => _AyatScreenState();
}

class _AyatScreenState extends State<AyatScreen> {
  List<AyatModel> _list = new List();
  final dbHelper = DatabaseHelper.instance;

  @override
  initState() {
    _initAyat();
    super.initState();
  }

  void _insert({id, number, text, suratId, juz, pageNumber, translation}) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.ayatId : id,
      DatabaseHelper.ayatNumber : number,
      DatabaseHelper.ayatText : text,
      DatabaseHelper.ayatSuratId : suratId,
      DatabaseHelper.ayatJuzId : juz,
      DatabaseHelper.ayatPageNumber : pageNumber,
      DatabaseHelper.ayatTranslation : translation,
    };

    final insertId = await dbHelper.insertAyat(row);
    //print('inserted row id: $insertId');
  }

  void _query() async {
    List list = await dbHelper.queryAllRowsAyat(widget.suratId);
    int index = 0;
    list.forEach((item) {
      if(!this.mounted)return;

      setState(() {
        if(index == 0 && item['sura_id'] != 1 && item['sura_id'] != 9){
          _list.add(
              AyatModel(
                  id: 0,
                  number: 0,
                  ayaText: " بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْم",
                  suraId: item['sura_id'],
                  juzId: item['juz_id'],
                  pageNumber: item['page_number'],
                  translation: "Dengan nama Allah Yang Maha Pengasih, Maha Penyayang."
              )
          );
        }

        _list.add(
            AyatModel(
                id: item['aya_id'],
                number: item['aya_number'],
                ayaText: item['aya_text'],
                suraId: item['sura_id'],
                juzId: item['juz_id'],
                pageNumber: item['page_number'],
                translation: item['translation_aya_text']
            )
        );

        index++;
      });
    });
  }

  void _initAyat() async {
    int count = await dbHelper.queryRowCountAyat(widget.suratId);
    //print("COUNT DB:: $count");
    if(count > 0){
      _query();
    } else {
      _getAyat();
    }
  }

   _getAyat() async{
    NetworkUtils _netUtil = new NetworkUtils();
    _netUtil.get(QuranApi.getAyat(suratId: widget.suratId, startFrom: widget.startFrom, limit: widget.limit))
        .then((dynamic res) {
     // print(res);
      if(res['data'] != null){
        List data = res['data'];
        if(data.length > 0){
          data.forEach((item){
            _insert(
                id: item['aya_id'],
                number: item['aya_number'],
                text: item['aya_text'],
                suratId: item['sura_id'],
                juz: item['juz_id'],
                pageNumber: item['page_number'],
                translation: item['translation_aya_text']
            );
          });

          _query();
        }
      }
    });
  }

  Widget _ayatListView () {
    return ListView.builder(
      shrinkWrap: true,
        physics: ScrollPhysics(),
        itemBuilder: (context, position){
          AyatModel item = _list[position];
          return  item.number != 0 ? ListTile(
            leading: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Text("${item.number}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)
                )
            ),
            title: Text("${item.ayaText}", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 24, fontFamily: 'LPQM')),
            subtitle: Html(data: "${item.translation}", defaultTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
          ) : ListTile(
            title: Text("${item.ayaText}", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            subtitle: Text("${item.translation}", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
          );
        },
        itemCount: _list.length
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _list.length > 0 ? _ayatListView() :
        LinearProgressIndicator(
          backgroundColor: Theme.of(context).primaryColorLight,
          valueColor: AlwaysStoppedAnimation<Color>( Theme.of(context).primaryColorDark),
        ),
    );
  }
}
