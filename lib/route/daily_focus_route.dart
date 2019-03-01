import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/helper_file.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/route/details_focus_item_route.dart';
import 'package:flutter_moment/route/details_person_item_route.dart';
import 'package:flutter_moment/route/details_place_item_route.dart';
import 'package:flutter_moment/route/editer_focus_item_route.dart';
import 'package:flutter_moment/route/editer_person_item_route.dart';
import 'package:flutter_moment/route/editer_place_item_route.dart';
import 'package:flutter_moment/widgets/cccat_list_tile.dart';

class DailyFocusRoute extends StatefulWidget {
  final int _initTab;

  DailyFocusRoute(int tab) : _initTab = tab;

  @override
  DailyFocusRouteState createState() => DailyFocusRouteState();
}

class DailyFocusRouteState extends State<DailyFocusRoute>
    with SingleTickerProviderStateMixin {
  GlobalStoreState _store;
  //String _localDir;
  List<FocusItem> focusList;
  List<PersonItem> personList;
  List<PlaceItem> placeList;
  TabController _controller;

  final List<String> tabLabel = ['焦点', '人物', '位置', '图片', '标签'];

  @override
  void initState() {
    super.initState();
    _controller = TabController(
        initialIndex: widget._initTab, length: tabLabel.length, vsync: this);
    debugPrint('切换到：${_controller.index}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = GlobalStore.of(context);
    focusList = GlobalStore.of(context).focusItemList;
    personList = GlobalStore.of(context).personItemList;
    placeList = GlobalStore.of(context).placeItemList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: _controller,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: tabLabel
              .map((label) => Text(label, style: TextStyle(fontSize: 17)))
              .toList(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              switch (_controller.index) {
                case 0: {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return EditerFocusItemRoute(FocusItem());
                    })).then((resultItem) {
                      if (resultItem is FocusItem) {
                        _store.addFocusItem(resultItem);
                      }
                    });
                    break;
                  }
                case 1: {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return EditerPersonItemRoute(PersonItem());
                    })).then((resultItem) {
                      if (resultItem is PersonItem) {
                        Future(() => _store.addPersonItem(resultItem)).then((v){
                          setState(() {

                          });
                        });
                        //_store.addPersonItem(resultItem);
                        Future.delayed(const Duration(milliseconds: 200), () {

                        });
                      }
                    });
                    break;
                  }
                case 2:
                  {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return EditerPlaceItemRoute(PlaceItem());
                    })).then((resultItem) {
                      if (resultItem is PlaceItem) {
                        _store.addPlaceItem(resultItem);
                      }
                    });
                    break;
                  }
                case 3:
                  {
                    break;
                  }
                case 4:
                  {
                    break;
                  }
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _controller,
        children: <Widget>[
          ListView.separated(
            itemBuilder: (context, index) {
              return buildFocusListViewItem(context, index);
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 3,
                indent: 16,
              );
            },
            itemCount: focusList.length,
          ),
          ListView.separated(
            itemBuilder: (context, index) {
              debugPrint('personList length: ${personList.length}');
              return getPersonListViewItem(context, index);
            },
            separatorBuilder: (context, index) => Divider(indent: 70,),
            itemCount: personList.length,
          ),
          ListView.separated(
            itemBuilder: (context, index) {
              return getPlaceListViewItem(
                  context, index); //buildPlaceListViewItem(context, index);
            },
            separatorBuilder: (context, index) {
              return Divider(
                indent: 60,
              );
            },
            itemCount: placeList.length,
          ),
          Text('图片，待扩充'),
          Text('标签, 待扩充'),
        ],
      ),
    );
  }

  Widget buildFocusListViewItem(BuildContext context, int index) {
    FocusItem focusItem = focusList[index];
    var subTitle =
        focusItem.references == 0 ? '未关注' : '聚焦 ${focusItem.references} 次';
    return CatListTile(
      title: Text(
        focusItem.title,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
        ),
      ),
      subtitle: Text(
        subTitle,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.black45,
          fontSize: 14,
        ),
      ),
      trailing: Icon(Icons.arrow_right),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return FocusItemDetailsRoute(focusItem);
        }));
      },
      onLongPress: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return EditerFocusItemRoute(focusItem);
        })).then((resultItem) {
          if (resultItem is FocusItem) {
            focusItem.title = resultItem.title;
            focusItem.comment = resultItem.comment;
            _store.changeFocusItem(focusItem);
          }
        });
      },
    );
  }

  Widget getPersonListViewItem(BuildContext context, int index) {

    debugPrint('person item: $index');

    var personItem = personList[index];
    var subTitle =
        personItem.references == 0 ? '未关注' : '相逢 ${personItem.references} 次';
    return CatListTile(
      leading: SizedBox(
        height: 36,
        width: 36,
        child: ClipOval(child: personItem.getImage()),
      ),
      title: Text(personItem.name),
      subtitle: Text(
        subTitle,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(Icons.arrow_right),
      onTap: () {
        //PersonDetailsRoute
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return PersonItemDetailsRoute(personItem);
        }));
      },
      onLongPress: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return EditerPersonItemRoute(personItem);
        })).then((resultItem) {
          if (resultItem is PersonItem) {
            personItem.copyWith(resultItem);
            _store.changePersonItem(personItem);
            // 从上页返回后，好像自动执行了setState，下面语句不用了
          }
        });
      },
    );
  }

  Widget getPlaceListViewItem(BuildContext context, int index) {
    var placeItem = placeList[index];
    var subTitle =
        placeItem.references == 0 ? '未关注' : '去过 ${placeItem.references} 次';
    return CatListTile(
      leading: Icon(Icons.ac_unit),
      title: Text(placeItem.title),
      subtitle: Text(subTitle),
      trailText: Text('aa'),
      trailing: Icon(Icons.arrow_right),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return PlaceItemDetailsRoute(placeItem);
        }));
      },
      onLongPress: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return EditerPlaceItemRoute(placeItem);
        })).then((resultItem) {
          if (resultItem is PlaceItem) {
            placeItem.copyWith(resultItem);
            _store.changePlaceItem(placeItem);
          }
        });
      },
    );
  }
}
