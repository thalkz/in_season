import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

List<Fruit> _fruits;

class Fruit {
  final name, image, color, start, length, text;
  Fruit(this.name, this.image, this.color, this.start, this.length, this.text);
  inSeason(month) => month >= start && month < start + length;
}

Future<List<Fruit>> _parseFruits() async {
  var text = await rootBundle.loadString("res/fruits.json");
  List<dynamic> json = await jsonDecode(text)['data'];
  _fruits = json
    .map((json) => Fruit(json['name'], json['icon'], Color(json['color']),
        json['start'], json['length'], List.from(json['text'])))
    .toList();
  return _fruits;
}

_randomFruitIn(month) {
  var list = _fruits.where((f) => f.inSeason(month)).toList();
  list.shuffle();
  return list[0];
}

main() => runApp(
  MaterialApp(
    home: FutureBuilder(
      future: _parseFruits(),
      initialData: <Fruit>[],
      builder: (context, snap) => _mainPage(context, snap.data),
    ),
    theme: ThemeData(primaryColor: Color(0xFFF8F8F8)),
  ),
);

_mainPage(context, List<Fruit> fruits) => DefaultTabController(
    length: 12,
    initialIndex: DateTime.now().month - 1,
    child: Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset("res/logo.svg"),
        centerTitle: true,
        bottom: TabBar(
          indicatorWeight: 10,
          isScrollable: true,
          tabs: List.generate(12, (month) => Tab(icon: Text(DateFormat().dateSymbols.MONTHS[month], style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),))),
          labelColor: Colors.black,
          unselectedLabelColor: Color(0xFFC5C5C5),
          indicatorColor: Colors.transparent,
        ),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        children: _buildFruitsGrid(context, fruits)
      ),
    ),
  );

_buildFruitsGrid(context, List<Fruit> fruits) => List.generate(
    12,
    (month) => GridView.count(
        padding: EdgeInsets.all(32),
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
        crossAxisCount: 3,
        children: fruits
            .where((fruit) => fruit.inSeason(month))
            .map((fruit) => _buildItem(context, fruit, month))
            .toList(),
      ),
  );

Widget _buildItem(context, fruit, month) => InkWell(
    onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => _fruitPage(fruit, month, context)),
      ),
    child: Column(
      children: [
        Expanded(
          child: Hero(
            tag: fruit.name + '$month',
            child: SvgPicture.asset(fruit.image),
          ),
        ),
        SizedBox(height: 8),
        Text(fruit.name)
      ],
    ),
  );

_fruitPage(fruit, month, context) => Scaffold(
    appBar: AppBar(
      title: Text('${DateFormat().dateSymbols.MONTHS[month]}'),
    ),
    body: ListView.builder(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
      itemCount: fruit.text.length + 1,
      itemBuilder: (context, i) => i == 0
          ? _buildHeader(fruit, month)
          : Text(
              fruit.text[i - 1],
              style: i.isEven
                  ? TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 2)
                  : TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
            ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      icon: Icon(Icons.shuffle),
      label: Text('Another one ?'),
      onPressed: () => Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => _fruitPage(_randomFruitIn(month), month, context)),
      ),
    ),
  );

_buildHeader(fruit, month) => Container(
    padding: EdgeInsets.all(24),
    margin: EdgeInsets.symmetric(vertical: 24),
    decoration: BoxDecoration(
      color: fruit.color,
      borderRadius: BorderRadius.all(Radius.circular(40)),
    ),
    child: Stack(
      children: [
        Hero(
          tag: fruit.name + '$month',
          child: SvgPicture.asset(fruit.image, height: 250),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 128),
            Text(
              fruit.name,
              style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)
            ),
            _buildCalendar(fruit)
          ],
        )
      ],
    ),
  );

_buildCalendar(fruit) => Wrap(
    children: List.generate(
      12,
      (month) => Container(
        padding: EdgeInsets.all(6),
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: fruit.inSeason(month) ? Colors.white : Colors.white.withAlpha(100),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            Text(DateFormat().dateSymbols.SHORTMONTHS[month]),
            Icon(fruit.inSeason(month) ? Icons.check : Icons.close, color: fruit.color)
          ],
        ),
      ),
    ),
  );