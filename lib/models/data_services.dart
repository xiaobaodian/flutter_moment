
import 'package:flutter_moment/models/models.dart';

class FocusDateServices {

  static List<PlaceItem> getPlaceList() {
    List<PlaceItem> list = List<PlaceItem>();
    list.add(PlaceItem(title: '循礼门小龙坎火锅', address: '这里是位置的地址'));
    list.add(PlaceItem(title: '汉街万达广场', address: '这里是位置的地址'));
    list.add(PlaceItem(title: '汉街小米之家旗舰店', address: '这里是位置的地址'));
    list.add(PlaceItem(title: '群星城', address: '这里是位置的地址'));
    list.add(PlaceItem(title: '1818广场', address: '这里是位置的地址'));
    list.add(PlaceItem(title: '迈欧中冶店', address: '这里是位置的地址'));
    list.add(PlaceItem(title: '汉街万达电影城', address: '这里是位置的地址'));
    list.add(PlaceItem(title: '徐源记烧烤', address: '这里是位置的地址'));
    list.add(PlaceItem(title: '中南商场沸腾鱼', address: '这里是位置的地址'));
    list.add(PlaceItem(title: '汉街', address: '这里是位置的地址'));
    return list;
  }

  static List<PersonItem> getPersonList() {
    List<PersonItem> list = List<PersonItem>();
    list.add(PersonItem(name: '咪娃娃'));
    list.add(PersonItem(name: '贝贝黑'));
    list.add(PersonItem(name: '雪嫘嫘'));
    list.add(PersonItem(name: '小叮当'));
    list.add(PersonItem(name: '小丸子'));
    list.add(PersonItem(name: '章飞了'));
    list.add(PersonItem(name: '花家家'));
    list.add(PersonItem(name: '大老爷'));
    return list;
  }

}