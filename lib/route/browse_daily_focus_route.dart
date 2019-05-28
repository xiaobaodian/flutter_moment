
import 'package:flutter/material.dart';
import 'package:flutter_moment/global_store.dart';
import 'package:flutter_moment/models/models.dart';
import 'package:flutter_moment/route/details_focus_item_route.dart';
import 'package:flutter_moment/route/details_person_item_route.dart';
import 'package:flutter_moment/route/details_place_item_route.dart';
import 'package:flutter_moment/route/details_tag_item_route.dart';
import 'package:flutter_moment/route/editer_focus_item_route.dart';
import 'package:flutter_moment/route/editer_person_item_route.dart';
import 'package:flutter_moment/route/editer_place_item_route.dart';
import 'package:flutter_moment/route/editer_tage_item_route.dart';
import 'package:flutter_moment/widgets/cccat_list_tile.dart';

class BrowseDailyFocusRoute extends StatefulWidget {
  final int _initTab;

  BrowseDailyFocusRoute(int tab) : _initTab = tab;

  @override
  BrowseDailyFocusRouteState createState() => BrowseDailyFocusRouteState();
}

class BrowseDailyFocusRouteState extends State<BrowseDailyFocusRoute>
    with SingleTickerProviderStateMixin {
  GlobalStoreState _store;
  //String _localDir;
  List<FocusItem> focusList;
  List<PersonItem> personList;
  List<PlaceItem> placeList;
  List<TagItem> tagList;
  TabController _controller;

  final List<String> tabLabel = ['焦点', '人物', '位置', '标签', '图片'];

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
    focusList = _store.focusItemSet.itemList;
    personList = _store.personSet.itemList;
    placeList = _store.placeSet.itemList;
    tagList = _store.tagSet.itemList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: _controller,
          isScrollable: true,
          labelStyle: TextStyle(fontSize: 18),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: tabLabel
              .map((label) => Tab(text: label))
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
                        _store.focusItemSet.addItem(resultItem);
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
                        Future(() => _store.personSet.addItem(resultItem)).then((v){
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
                        //_store.addPlaceItem(resultItem);
                        _store.placeSet.addItem(resultItem);
                      }
                    });
                    break;
                  }
                case 3:
                  {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                          return EditerTagItemRoute(TagItem());
                        })).then((resultItem) {
                      if (resultItem is TagItem) {
                        //_store.addPlaceItem(resultItem);
                        _store.tagSet.addItem(resultItem);
                      }
                    });
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
            itemBuilder: (context, index) => buildFocusListViewItem(context, index),
            separatorBuilder: (context, index) => Divider(indent: 16, height: 8,),
            itemCount: focusList.length,
          ),
          ListView.separated(
            itemBuilder: (context, index) => getPersonListViewItem(context, index),
            separatorBuilder: (context, index) => Divider(indent: 70, height: 8,),
            itemCount: personList.length,
          ),
          ListView.separated(
            itemBuilder: (context, index) => getPlaceListViewItem(context, index),
            separatorBuilder: (context, index) => Divider(indent: 60, height: 8,),
            itemCount: placeList.length,
          ),
          ListView.separated(
            itemBuilder: (context, index) => getTagListViewItem(context, index),
            separatorBuilder: (context, index) => Divider(indent: 18, height: 8,),
            itemCount: tagList.length,
          ),
          Text('图片, 待扩充'),
        ],
      ),
    );
  }

  Widget buildFocusListViewItem(BuildContext context, int index) {
    FocusItem focusItem = focusList[index];
    var gz = focusItem.count == 0 ? '' : '${focusItem.count} ';
    return CatListTile(
      title: Text(focusItem.title,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      trailText: Text(gz),
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
            _store.focusItemSet.changeItem(focusItem);
          }
        });
      },
    );
  }

  Widget getPersonListViewItem(BuildContext context, int index) {
    var personItem = personList[index];
    var gz = personItem.count == 0 ? '' : '${personItem.count} ';
    return CatListTile(
      //contentPadding: EdgeInsets.fromLTRB(0, 12, 0, 12),
      leading: SizedBox(
        height: 36,
        width: 36,
        child: ClipOval(child: personItem.getImage()),
      ),
      title: Text(personItem.name),
      trailText: Text(gz),
      trailing: Icon(Icons.arrow_right),
      onTap: () {
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
            _store.personSet.changeItem(personItem);
          }
        });
      },
    );
  }

  Widget getPlaceListViewItem(BuildContext context, int index) {
    var placeItem = placeList[index];
    var gz = placeItem.count == 0 ? '' : '${placeItem.count} ';
    return CatListTile(
      leading: Icon(Icons.map),
      title: Text(placeItem.title),
      trailText: Text(gz),
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
            _store.placeSet.changeItem(placeItem);
          }
        });
      },
    );
  }

  Widget getTagListViewItem(BuildContext context, int index) {
    var tagItem = tagList[index];
    var gz = tagItem.count == 0 ? '' : '${tagItem.count} ';
    return CatListTile(
      title: Text(tagItem.title),
      trailText: Text(gz),
      trailing: Icon(Icons.arrow_right),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return TagItemDetailsRoute(tagItem);
        }));
      },
      onLongPress: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return EditerTagItemRoute(tagItem);
        })).then((resultItem) {
          if (resultItem is TagItem) {
            tagItem.copyWith(resultItem);
            //_store.changePlaceItem(placeItem);
            _store.tagSet.changeItem(tagItem);
          }
        });
      },
    );
  }
}
