import 'dart:io';
import 'dart:math';
import 'dart:convert';

main(List<String> args) async {
  var systemTempDir = Directory("./fruits/");

  List<dynamic> list = [];

  systemTempDir
      .list(recursive: false, followLinks: false)
      .listen((FileSystemEntity entity) {
    String lowercase = entity.path.substring(9).split(".")[0];
    if (lowercase.isEmpty) return;

    String name = '${lowercase[0].toUpperCase()}${lowercase.substring(1)}';

    var file = new File(entity.path);
    String content = file.readAsStringSync();
    final colorRegex = RegExp(r'fill:#[A-Z0-9]{6}', multiLine: true);
    final matches = colorRegex.allMatches(content);

    var color;
    if (matches.length > 0) {
      color = 'AA' + matches.last.group(0).substring(6);
    } else {
      color = 'AACCCCCC';
    }

    list.add({
      "name": name,
      "icon": "res/fruits/" + name.toLowerCase() + ".svg",
      "color": int.parse(color, radix: 16),
      "start": Random().nextInt(11),
      "length": Random().nextInt(11),
      "text": [
        "There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable",
        "How to choose ?",
        "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source.",
        "How to cook ?",
        "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English",
        "Nutitional benefits",
        "It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc."
      ]
    });
  }).onDone(() {
    var map = {"data": list};

    var json = jsonEncode(map);

    var outputFile = new File('fruits8.json');
    outputFile.writeAsStringSync(json);
  });
}
