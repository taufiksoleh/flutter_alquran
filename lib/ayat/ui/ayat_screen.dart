import 'package:alquran/ayat/model/ayat_model.dart';
import 'package:alquran/config/quran_api.dart';
import 'package:alquran/sura/model/sura_model.dart';
import 'package:alquran/utils/network_utils.dart';
import 'package:flutter/material.dart';

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

  @override
  initState() {
    _getAyat();
    super.initState();
  }

   _getAyat() async{
    NetworkUtils _netUtil = new NetworkUtils();
    _netUtil.get(QuranApi.getAyat(suratId: widget.suratId, startFrom: widget.startFrom, limit: widget.limit))
        .then((dynamic res) {
      print(res);
      if(res['data'] != null){
        List data = res['data'];
        if(data.length > 0){
          data.forEach((item){
            setState(() {
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
            });

          });
        }
      }
    });
  }

  Widget _suraListView () {
    return ListView.builder(
      shrinkWrap: true,
        physics: ScrollPhysics(),
        itemBuilder: (context, position){
          AyatModel item = _list[position];
          return ListTile(
            leading: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Text("${item.number}")
                )
            ),
            title: Text("${item.ayaText}", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            subtitle: Text("${item.translation}", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
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
      body: _suraListView()
    );
  }
}
