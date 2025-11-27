import 'package:characters/characters.dart';

class EscHandler {
  /// 居中打印
  static String alginCenterPrint({int? width, dynamic content}) {
    String str = content.toString();
    int strLength = strWidth(str);
    int hlafWith = ((width! - strLength) ~/ 2);
    String space = '';
    for (int i = 0; i < hlafWith; i++) {
      space += ' ';
    }
    return space + content;
  }

  /// 字符串宽度计算

  /* static int strWidth(String content) {
    return content.characters.length;
  } */
  static int strWidth(dynamic content) {
    String str = content.toString();
    return str.runes.fold(0, (length, rune) => length + (rune >= 0 && rune <= 255 ? 1 : 2));
  }

  static String fillSpace(int length) {
    return '' * length;
  }

  /// content 内容
  /// width 宽度
  /// algin 对齐方式 0左对齐 1居中 2右对齐
  static String columnMaker(String content, int width, {int algin = 0}) {
    int contentWidth = calculateWidth(content);
    int spaceWidth = width - contentWidth;
    if (algin == 0) {
      return content + (' ' * spaceWidth);
    } else if (algin == 1) {
      int halfWidth = spaceWidth ~/ 2;
      return (' ' * halfWidth) + content + (' ' * (spaceWidth - halfWidth));
    } else {
      return (' ' * spaceWidth) + content;
    }
  }

  static String fillhr({int? lenght, String? ch = '-'}) {
    String space = '';
    for (int i = 0; i < lenght!; i++) {
      space += '-';
    }
    return space;
  }

  static int calculateWidth(String text) {
    return text.characters.fold(
      0,
      (width, char) => width + (RegExp(r'[\u4E00-\u9FFF\u3000-\u303F\uFF00-\uFFEF]').hasMatch(char) ? 2 : 1),
    );
  }

  /*  static List<String> strToList(
      {required String str, required int splitLenth}) {
    String content = str.trim();
    int blankNum = splitLenth + 1;
    int strLenth = content.length;

    int m = 0;
    int j = 1;
    List<String> strList = [];
    String tail = "";
    for (int i = 0; i < strLenth; i++) {
      var newStr = content.substring(m, m + j);
      j++;
      if (strWidth(newStr) < blankNum) {
        if (m + j > strLenth) {
          m = m + j;
          tail = newStr;
          break;
        } else {
          var nextNewStr = content.substring(m, j + m);
          if (strWidth(nextNewStr) < blankNum) {
            continue;
          } else {
            m = i + 1;
            strList.add(newStr);
            j = 1;
          }
        }
      }
    }
    if (tail.isNotEmpty) {
      strList.add(tail);
    }
    return strList;
  }
 */
  ///字符串转列表，按照每行的长度进行分割
  static List<String> strToList({required String str, required int splitLength}) {
    List<String> result = [];

    // 按换行符拆分字符串
    List<String> lines = str.split('\n');
    for (var line in lines) {
      Characters chars = line.trim().characters;
      StringBuffer buffer = StringBuffer();

      int currentWidth = 0; // 当前行的宽度

      for (var char in chars) {
        int charWidth = calculateWidth(char);
        if (currentWidth + charWidth > splitLength) {
          // 超出宽度，保存当前段落
          result.add(buffer.toString());
          buffer.clear();
          currentWidth = 0;
        }
        buffer.write(char);
        currentWidth += charWidth;
      }

      // 处理剩余字符
      if (buffer.isNotEmpty) {
        result.add(buffer.toString());
      }
    }

    return result;
  }

  /// algin 对齐方式 0左对齐 1居中 2右对齐
  static String setAlgin({int? algin}) {
    switch (algin) {
      case 1:
        return "\x1B\x61\x01";
      case 2:
        return "\x1B\x61\x02";
      default:
        return "\x1B\x61\x00";
    }
  }

  /// content 内容
  /// size 默认正常大小 1:两倍高 2:两倍宽 3:两倍大小 4:三倍高 5:三倍宽 6:三倍大小 7:四倍高 8:四倍宽 9:四倍大小 10:五倍高 11:五倍宽 12:五倍大小
  static String setSize({int? size}) {
    switch (size) {
      case 1:
        return "\x1D\x21\x01";
      case 2:
        return "\x1D\x21\x10";
      case 3:
        return "\x1D\x21\x11";
      case 4:
        return "\x1D\x21\x02";
      case 5:
        return "\x1D\x21\x20";
      case 6:
        return "\x1D\x21\x22";
      case 7:
        return "\x1D\x21\x03";
      case 8:
        return "\x1D\x21\x30";
      case 9:
        return "\x1D\x21\x33";
      case 11:
        return "\x1D\x21\x04";
      case 12:
        return "\x1D\x21\x40";
      default:
        return "\x1D\x21\x00";
    }
  }

  /// 设置加粗
  static String setBold() {
    return "\x1B\x45\x01";
  }

  /// 取消加粗
  static String resetBold() {
    return "\x1B\x45\x00";
  }
}
