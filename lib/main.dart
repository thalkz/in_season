import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

List<Fruit> _fruits;

List<String> year = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre'
];

class Fruit {
  final String name;
  final Color color;
  var start, length, text, category, scientific;

  String get image => 'res/fruits2/$name.jpg';
  bool get isDark => color.computeLuminance() < 0.3;

  Fruit(this.name, this.color, this.start, this.length, this.text, this.category,
      this.scientific);

  bool inSeason(month) => (month >= start && month < start + length) || (month <= (start + length - 12));
}

Future<List<Fruit>> _parseFruits() async {
  var text = await rootBundle.loadString("res/new_fruits2.json");
  List<dynamic> json = await jsonDecode(text)['data'];
  _fruits = json
      .map((json) => Fruit(
          json['name'],
          Color(int.parse(json['color'], radix: 16)),
          json['start'] - 1,
          json['length'],
          List.from(json['text']),
          json['category'],
          json['scientific']))
      .toList();
  return _fruits;
}

main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          future: _parseFruits(),
          initialData: <Fruit>[],
          builder: (context, snap) => MainPage(fruits: snap.data),
        ),
        theme: ThemeData.light(),
      ),
    );

class MainPage extends StatefulWidget {
  final List<Fruit> fruits;

  MainPage({this.fruits});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _category = 'tout';
  GlobalKey _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 12,
      initialIndex: DateTime.now().month - 1,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade100,
          title: SvgPicture.asset("res/logo.svg"),
          centerTitle: true,
          bottom: TabBar(
            indicatorWeight: 10,
            isScrollable: true,
            tabs: List.generate(
              12,
              (month) => Tab(
                    icon: Text(
                      year[month],
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ),
            ),
            labelColor: Colors.black,
            unselectedLabelColor: Color(0xFFC5C5C5),
            indicatorColor: Colors.transparent,
          ),
        ),
        backgroundColor: Colors.white,
        body: TabBarView(
            children: _buildFruitsGrid(
                context,
                _category.isEmpty
                    ? widget.fruits
                    : widget.fruits
                        .where((f) => (f.category == _category) || (_category == 'tout'))
                        .toList())),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.filter_list),
          label: Text('${_category[0].toUpperCase()}${_category.substring(1)}'),
          backgroundColor: Colors.green,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => CategoryBottomSheet(
                  selectedCategory: _category,
                  onSelect: (String category) {
                    setState(() {
                      _category = category;
                    });
                  }),
            );
          },
        ),
      ),
    );
  }
}

class CategoryBottomSheet extends StatefulWidget {
  final String selectedCategory;
  final onSelect;

  const CategoryBottomSheet({
    Key key,
    this.selectedCategory,
    this.onSelect,
  }) : super(key: key);

  @override
  _CategoryBottomSheetState createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  String _category;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: ListView(
        children: <Widget>[
          _buildTile('tout'),
          Divider(height: 0),
          _buildTile('légume'),
          Divider(height: 0),
          _buildTile('fruit'),
          Divider(height: 0),
          _buildTile('fruit exotique'),
          Divider(height: 0),
          _buildTile('céréale'),
          Divider(height: 0),
          _buildTile('condiment'),
          Divider(height: 0),
          _buildTile('épice'),
          Divider(height: 0),
          _buildTile('aromate exotique'),
        ],
      ),
    );
  }

  _buildTile(String category) {
    bool selected = (_category == category);
    return ListTile(
      onTap: () {
        setState(() {
          _category = category;
          // Navigator.pop(context);
          widget.onSelect(category);
          Future.delayed(Duration(milliseconds: 300), () {
            Navigator.pop(context);
          });
        });
      },
      title: Text(
        '${category[0].toUpperCase()}${category.substring(1)}',
        style: selected ? TextStyle(fontWeight: FontWeight.bold) : TextStyle(),
      ),
      trailing: selected
          ? Icon(Icons.check)
          : Container(
              width: 0,
              height: 0,
            ),
    );
  }
}

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
              child: Image.asset(fruit.image),
            ),
          ),
          SizedBox(height: 8),
          Text(
            fruit.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          )
        ],
      ),
    );

_fruitPage(fruit, month, context) => Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            children: _buildPage(fruit, month),
          ),
          Positioned(
            top: 64,
            left: 24,
                      child: Container(
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color: Colors.black.withAlpha(50),
                    offset: Offset(0, 4),
                  )
                ],
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );

List<Widget> _buildPage(fruit, month) {
  List<Widget> result = [];
  result.add(FruitHeader(fruit: fruit, month: month));
  result.add(_buildCalendar(fruit));

  if (fruit.inSeason(DateTime.now().month - 1)) {
    result.add(
      Container(
        margin: EdgeInsets.symmetric(horizontal: 32),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black)),
        child: Text(
          "Actuellement en saison".toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green),
        ),
      ),
    );
  } else {
    result.add(
      Container(
        margin: EdgeInsets.symmetric(horizontal: 32),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black)),
        child: Text(
          "Actuellement Hors-saison".toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool isTitle = true;
  for (String item in fruit.text) {
    if (isTitle) {
      result.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            item,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 2),
          ),
        ),
      );
    } else {
      result.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            item,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
          ),
        ),
      );
    }
    isTitle = !isTitle;
  }
  result.add(SizedBox(height: 32));

  return result;
}

class FruitHeader extends StatefulWidget {
  final Fruit fruit;
  final int month;

  const FruitHeader({Key key, this.fruit, this.month}) : super(key: key);

  @override
  _FruitHeaderState createState() => _FruitHeaderState();
}

class _FruitHeaderState extends State<FruitHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      child: Stack(
        children: [
          Container(
            height: 250,
            color: widget.fruit.color,
          ),
          Positioned(
            right: 30,
            bottom: 10,
            child: Hero(
              tag: widget.fruit.name + '${widget.month}',
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(widget.fruit.image),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      color: Colors.black.withAlpha(50),
                      offset: Offset(0, 2),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 280,
            padding: EdgeInsets.only(top: 32, left: 24, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 80),
                Text(
                  widget.fruit.name,
                  style: TextStyle(
                    color: widget.fruit.isDark ? Colors.white : Colors.black87,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 0.8),
                ),
                Text(
                  widget.fruit.category.toString().toUpperCase(),
                  style: TextStyle(
                    color: widget.fruit.isDark ? Colors.white.withAlpha(100) : Colors.black87.withAlpha(100),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

_buildCalendar(fruit) => Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      height: 150,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 6,
        children: List.generate(
          12,
          (month) => Opacity(
                opacity: fruit.inSeason(month) ? 1 : 0.5,
                child: Container(
                  padding: EdgeInsets.all(6),
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      Text(year[month].substring(0, 3).toUpperCase()),
                      Icon(
                        fruit.inSeason(month) ? Icons.check : Icons.close,
                        color: fruit.inSeason(month) ? Colors.green : Colors.black,
                      )
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
