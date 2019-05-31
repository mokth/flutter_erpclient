import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:erpclient/relocate/receive.dart';
import 'package:erpclient/base/customroute.dart';
import 'package:erpclient/utilities/displayutil.dart';
import 'package:erpclient/utilities/util.dart';
import 'package:erpclient/repository/inventoryrepo.dart';
import 'package:erpclient/model/relocate.dart';

enum ConfirmAction { CANCEL, ACCEPT }

class ReceiveList extends StatefulWidget {
  ReceiveList({Key key}) : super(key: key);

  _ReceiveListState createState() => _ReceiveListState();
}

class _ReceiveListState extends State<ReceiveList> {
  final InventoryRepository _repo = new InventoryRepository();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  bool _dataAvailable;

  @override
  void initState() {
    super.initState();
    _dataAvailable = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Receive List'),
      ),
      floatingActionButton: (!_dataAvailable)
          ? Text('')
          : FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  new CustomRoute(
                      builder: (context) => ReceiveEmtry()),
                );
              },
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
            ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Colors.white),
        child: FutureBuilder(
            initialData: new List<Relocate>(),
            future: _repo.getRelocates(showAll: true),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: SizedBox(
                    child: CircularProgressIndicator(),
                    height: 30.0,
                    width: 30.0,
                  ));
                default:
                  if (snapshot.hasError)
                    return new Center(child:Text('${snapshot.error}',
                    style: TextStyle(color: Colors.redAccent,fontStyle: FontStyle.italic,fontSize: 18.0),),);
                  else
                    return createListView(context, snapshot);
              }
            }),
      ),
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    // setState(() {
    //   _dataAvailable =true;
    // });
    List<Relocate> relocates = snapshot.data as List<Relocate>;
    return AnimatedList(
        key: _listKey,
        initialItemCount: relocates.length,
        itemBuilder: (BuildContext context, int index, animation) {
          return listItem(relocates[index], index, animation);
        });

    // return ListView.builder(
    //     itemCount: relocates.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       return listItem(relocates[index], index);
    //     });
  }

  Widget listItem(Relocate item, int index, Animation animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Slidable(
        delegate: new SlidableDrawerDelegate(),
        actionExtentRatio: 0.25,
        child: Container(
          padding: EdgeInsets.fromLTRB(1, 5, 1, 5),
          decoration: BoxDecoration(
              color: (index % 2 == 0)
                  ? Colors.white
                  : Color.fromRGBO(0, 0, 255, 0.1)),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 4,
                      child: DisplayUtil.listItemText(
                          Utility.dateToStringWithTime(item.trxdate),
                          fontSize: 14.0)),
                  Expanded(
                      flex: 2,
                      child: DisplayUtil.listItemText(item.qrcoderef==null?"":item.qrcoderef,
                          fontSize:14.0)),
                  Expanded(
                      flex: 2,
                      child:
                          DisplayUtil.listItemText(item.fromwh, fontSize: 13.0,textAlign: TextAlign.right)),
                  Expanded(
                      flex: 2,
                      child: DisplayUtil.listItemText(item.stdqty.toString()+" PC",
                          fontSize: 14.0,textAlign: TextAlign.right)),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 3,
                      child:
                          DisplayUtil.listItemText(item.icode, fontSize: 14.0)),
                  Expanded(
                      flex: 1,
                      child: DisplayUtil.listItemText(item.towh, fontSize: 13.0,textAlign: TextAlign.right)),
                  Expanded(
                      flex: 1,
                      child: DisplayUtil.listItemText(item.qty.toString()+" CT",
                          fontSize: 14.0,textAlign: TextAlign.right)),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                     flex: 3,
                      child:
                          DisplayUtil.listItemText(item.idesc, fontSize: 14.0)),
                   Expanded(
                      flex: 1,
                      child: DisplayUtil.listItemText(item.stdqty.toString()+" PC",
                          fontSize: 14.0,textAlign: TextAlign.right)),
                ],
              ),
              Divider(
                height: 5,
              ),
            ],
          ),
        ),
        // actions: <Widget>[
        //   new IconSlideAction(
        //       caption: 'EDIT',
        //       color: Colors.blueAccent,
        //       icon: Icons.edit,
        //       onTap: () {
        //         testReceive(item).then((msg)=>showSnackBar(msg));
        //       }),
        // ],
       
      ),
    );
  }

  Future<String> testReceive(Relocate item) async{
    String id = item.id.toString();
     var msg =await _repo.postReceive(id);
     return msg;
  }

  showSnackBar(String msg) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

}
