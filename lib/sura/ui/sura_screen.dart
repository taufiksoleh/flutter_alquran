import 'package:alquran/ayat/ui/ayat_screen.dart';
import 'package:alquran/config/quran_api.dart';
import 'package:alquran/sura/model/sura_model.dart';
import 'package:alquran/utils/network_utils.dart';
import 'package:flutter/material.dart';

class SuraScreen extends StatefulWidget {
  SuraScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SuraScreenState createState() => _SuraScreenState();
}

class _SuraScreenState extends State<SuraScreen> {
  List<SuraModel> _list = new List();

  @override
  initState() {
    _getSurat();
    super.initState();
  }

   _getSurat() async{
    NetworkUtils _netUtil = new NetworkUtils();
    _netUtil.get(QuranApi.getSurat(limit: 114))
        .then((dynamic res) {
      print(res);
      if(res['data'] != null){
        List data = res['data'];
        if(data.length > 0){
          data.forEach((item){
            setState(() {
              _list.add(
                  SuraModel(
                      id: item['id'],
                      name: item['surat_name'],
                      suratText: item['surat_text'],
                      translation: item['surat_terjemahan'],
                      countAyat: item['count_ayat']
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
          SuraModel item = _list[position];
          return ListTile(
            leading: Text("${item.id}"),
            title: Text("${item.name} (${item.suratText})"),
            subtitle: Text("${item.translation}"),
            trailing: Icon(Icons.navigate_next),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return AyatScreen(title: "${item.name} - Surat ke ${item.id}", suratId: item.id, startFrom: 0, limit: item.countAyat);
              }));
            },
          );
        },
        itemCount: _list.length
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title != null ? widget.title : "Surat"),
      ),
      body: _suraListView()
    );
  }
}
