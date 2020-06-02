import 'package:alquran/ayat/ui/ayat_screen.dart';
import 'package:alquran/config/asset.dart';
import 'package:alquran/config/quran_api.dart';
import 'package:alquran/helper/database_helper.dart';
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
  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;
  bool _isEmpty = false;

  @override
  initState(){
    _initSurat();
    super.initState();
  }

  void _insert({id, name, text, translation, countAyat}) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.suratId : id,
      DatabaseHelper.suratText : text,
      DatabaseHelper.suratName : name,
      DatabaseHelper.suratTranslation : translation,
      DatabaseHelper.suratCountAyat : countAyat,
    };

    final insertId = await dbHelper.insert(row);
    //print('inserted row id: $insertId');
  }

  void _query({keyword}) async {
    setState(() {
      _list.clear();
      _isEmpty = true;
    });
    List list;
    if(keyword == null){
      list = await dbHelper.queryAllRows();
    } else {
      list = await dbHelper.queryWhereLike(keyword);
    }

    if(list.length > 0){
      setState(() {
        _isEmpty = false;
      });
    }

    list.forEach((item) {
      if(!this.mounted)return;

      setState(() {
        _list.add(
            SuraModel(
                id: item['surat_id'],
                name: item['surat_name'],
                suratText: item['surat_text'],
                translation: item['surat_terjemahan'],
                countAyat: item['count_ayat']
            )
        );
      });
    });
  }

  void _initSurat() async {
    int count = await dbHelper.queryRowCount();
    //print("COUNT DB:: $count");
    if(count > 0){
      _query();
    } else {
      _getSurat();
    }
  }


  _getSurat() async{
    try {
      NetworkUtils _netUtil = new NetworkUtils();
      _netUtil.get(QuranApi.getSurat(limit: 114))
          .then((dynamic res) {
        //print(res);
        if (res['data'] != null) {
          List data = res['data'];
          if (data.length > 0) {
            data.forEach((item) {
              _insert(
                  id: item['id'],
                  name: item['surat_name'],
                  text: item['surat_text'],
                  translation: item['surat_terjemahan'],
                  countAyat: item['count_ayat']
              );
            });
          }

          _query();
        }
      });
    } catch (ex){
      setState(() {
        _list.clear();
        _isEmpty = true;
      });
      print(ex);
    }
  }

  Widget _searchBar(){
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (value){
          if(value.length > 0) {
            _query(keyword: value);
          } else {
            _query();
          }
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
          hintText: "Cari surat ...",
          hintStyle: TextStyle(fontSize: 16),
          prefixIcon: Icon(Icons.search),
        ),
      )
    );
  }

  Widget _suraListView () {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80),
      shrinkWrap: true,
        physics: ScrollPhysics(),
        itemBuilder: (context, position){
          SuraModel item = _list[position];
          return ListTile(
            leading: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Text("${item.id}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)
                )
            ),
            title: Text("${item.name} (${item.suratText} )", style: TextStyle(fontSize: 18),),
            subtitle: Text("${item.translation}", style: TextStyle(fontSize: 14)),
            trailing: Icon(Icons.navigate_next),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return AyatScreen(title: "${item.name} (${item.suratText} )", suratId: item.id, startFrom: 0, limit: item.countAyat);
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
        title: Center(child: Text(widget.title != null ? widget.title.toUpperCase() : "Surat", textAlign: TextAlign.center)),
      ),
      body: _list.length > 0 ? _suraListView() :
      _list.length == 0 && _isEmpty == false  ? LinearProgressIndicator(
        backgroundColor: Theme.of(context).primaryColorLight,
        valueColor: AlwaysStoppedAnimation<Color>( Theme.of(context).primaryColorDark),
      ): Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(Asset.LOGO),
          Text("Surat Tidak Ditemukan", style: TextStyle(fontSize: 22),)
        ],
      ),
      floatingActionButton: _searchBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
