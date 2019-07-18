import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../model/prschmasfg.dart';
import '../utilities/snackbarutil.dart';
import '../base/customroute.dart';
import '../utilities/displayutil.dart';
import '../utilities/util.dart';
import '../repository/inventoryrepo.dart';
import 'finished-good.dart';

enum ConfirmAction { CANCEL, ACCEPT }

class FinishedGoodList extends StatefulWidget {
  FinishedGoodList({Key key}) : super(key: key);

  _FinishedGoodListState createState() => _FinishedGoodListState();
}

class _FinishedGoodListState extends State<FinishedGoodList> {
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
        title: Text('Finished Goods List'),
      ),
      floatingActionButton: (!_dataAvailable)
          ? Text('')
          : FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  new CustomRoute(
                      builder: (context) => FinishedGood(null, "NEW")),
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
            initialData: new List<PrSchMasFG>(),
            future: _repo.getFinishedGoods(),
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
                    return new Center(
                      child: Text(
                        '${snapshot.error}',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontStyle: FontStyle.italic,
                            fontSize: 18.0),
                      ),
                    );
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
    List<PrSchMasFG> fnGood = snapshot.data as List<PrSchMasFG>;
    return AnimatedList(
        key: _listKey,
        initialItemCount: fnGood.length,
        itemBuilder: (BuildContext context, int index, animation) {
          return listItem(fnGood[index], index, animation);
        });

    // return ListView.builder(
    //     itemCount: fnGood.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       return listItem(fnGood[index], index);
    //     });
  }

  Widget listItem(PrSchMasFG item, int index, Animation animation) {
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
                          Utility.dateToString(item.trxDate),
                          fontSize: 14.0)),
                  Expanded(
                    flex: 4,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: DisplayUtil.listItemText(
                            item.scheCode + "/" + item.relNo.toString(),
                            fontSize: 14.0)),
                  ),
                  Expanded(
                      flex: 2,
                      child: DisplayUtil.listItemText(item.frWH,
                          fontSize: 13.0, textAlign: TextAlign.left)),
                  Expanded(
                      flex: 2,
                      child: DisplayUtil.listItemText(item.fgQty.toString(),
                          fontSize: 14.0,
                          textAlign: TextAlign.right,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 2,
                      child: DisplayUtil.listItemText(
                          Utility.dateToTimeString(item.trxDate),
                          fontSize: 12.0)),
                  Expanded(
                    flex: 4,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: DisplayUtil.listItemText(item.icode,
                            fontSize: 14.0,fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                      flex: 2,
                      child: DisplayUtil.listItemText(item.toWH,
                          fontSize: 13.0, textAlign: TextAlign.left)),
                  Expanded(
                      flex: 2,
                      child: DisplayUtil.listItemText(item.reject.toString(),
                          fontSize: 14.0,
                          textAlign: TextAlign.right,
                          color: Colors.red)),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 3,
                      child:
                          DisplayUtil.listItemText(item.idesc, fontSize: 13.0)),
                  Expanded(
                      flex: 1,
                      child: DisplayUtil.listItemText(item.scrap.toString(),
                          fontSize: 14.0,
                          textAlign: TextAlign.right,
                          color: Colors.red)),
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
                      builder: (context) => FinishedGood(item, "EDIT")),
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

  deleteIem(PrSchMasFG item) {
    _asyncConfirmDialog(context).then((val) {
      if (val == ConfirmAction.ACCEPT) {
        _repo.deleteFinishedGood(item.uid).then((resp) {
          setState(() {});
        }, onError: (e) {
          print(e.toString());
          SnackBarUtil.showSnackBar("Error deleting record...", _scaffoldKey);
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
