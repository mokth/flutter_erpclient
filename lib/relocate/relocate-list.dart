import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../utilities/snackbarutil.dart';
import '../base/customroute.dart';
import '../relocate/relocate.dart';
import '../utilities/displayutil.dart';
import '../utilities/util.dart';
import '../repository/inventoryrepo.dart';
import '../model/relocate.dart';

enum ConfirmAction { CANCEL, ACCEPT }

class RelocateList extends StatefulWidget {
  RelocateList({Key key}) : super(key: key);

  _RelocateListState createState() => _RelocateListState();
}

class _RelocateListState extends State<RelocateList> {
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
        title: Text('Issue List'),
      ),
      floatingActionButton: (!_dataAvailable)
          ? Text('')
          : FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  new CustomRoute(
                      builder: (context) => RelocateEntry(null, "NEW")),
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
            future: _repo.getRelocates(),
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
                      flex: 2,
                      child: DisplayUtil.listItemText(
                          Utility.dateToStringFormat(item.trxdate,"dd/MM/yy"),
                          fontSize: 14.0)),
                  Expanded(
                      flex: 4,
                      child: DisplayUtil.listItemText(item.qrcoderef==null?"":item.qrcoderef,
                          fontSize:14.0,fontWeight: FontWeight.bold)),
                  Expanded(
                      flex: 2,
                      child:
                          DisplayUtil.listItemText(item.fromwh, fontSize: 13.0,textAlign: TextAlign.left)),
                  Expanded(
                      flex: 2,
                      child: DisplayUtil.listItemText(item.stdqty.toString()+" PC",
                          fontSize: 14.0,textAlign: TextAlign.right)),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 2,
                      child: DisplayUtil.listItemText(
                          Utility.dateToStringFormat(item.trxdate,"hh:mma"),
                          fontSize: 14.0)),
                  Expanded(
                      flex: 4,
                      child:
                          DisplayUtil.listItemText(item.icode, fontSize: 14.0)),
                  Expanded(
                      flex: 2,
                      child: DisplayUtil.listItemText(item.towh, fontSize: 13.0,textAlign: TextAlign.left)),
                  Expanded(
                      flex: 2,
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
        actions: <Widget>[
          new IconSlideAction(
              caption: 'EDIT',
              color: Theme.of(context).primaryColor,
              icon: Icons.edit,
              onTap: () {
                Navigator.push(
                  context,
                  new CustomRoute(
                      builder: (context) => RelocateEntry(item, "EDIT")),
                );
              }),
        ],
        secondaryActions: <Widget>[
          new IconSlideAction(
              caption: 'DELETE',
              color: Colors.redAccent,
              icon: Icons.delete,
              onTap: () {
                deleteIem(item);
              }),
        ],
      ),
    );
  }

  deleteIem(Relocate item) {
    _asyncConfirmDialog(context).then((val) {
      if (val == ConfirmAction.ACCEPT) {
        _repo.deleteRelocate(item.id).then((resp) {
          setState(() {});
        }, onError: (e) {
          print(e.toString());
          SnackBarUtil.showSnackBar("Error deleting record...",_scaffoldKey);
        });
      }
    });
  }

  Future<ConfirmAction> _asyncConfirmDialog(BuildContext context) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: const Text('Confirm to delete this record?'),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('CONFIRM'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.ACCEPT);
              },
            )
          ],
        );
      },
    );
  }
}
