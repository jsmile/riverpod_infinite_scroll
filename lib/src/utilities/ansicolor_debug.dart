import 'package:ansicolor/ansicolor.dart';

AnsiPen info = AnsiPen()..black(bold: true);
AnsiPen success = AnsiPen()..xterm(003, bg: false); // 쑥색
AnsiPen warn = AnsiPen()..magenta(bold: true);
AnsiPen error = AnsiPen()..red(bold: true);
