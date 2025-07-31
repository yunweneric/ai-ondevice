import 'package:flutter/material.dart';

// https://tforgione.fr/posts/ansi-escape-codes/

const kReset = '\x1b[0m';
const kBold = '\x1b[1m';
const kDim = '\x1b[2m';
const kUnderscore = '\x1b[4m';
const kBlink = '\x1b[5m';
const kReverse = '\x1b[7m';
const kHidden = '\x1b[8m';

const kBlack = '\x1b[30m';
const kRed = '\x1b[31m';
const kGreen = '\x1b[32m';
const kYellow = '\x1b[33m';
const kBlue = '\x1b[34m';
const kMagenta = '\x1b[35m';
const kCyan = '\x1b[36m';
const kWhite = '\x1b[37m';

const kBgBlack = '\x1b[40m';
const kBgRed = '\x1b[41m';
const kBgGreen = '\x1b[42m';
const kBgYellow = '\x1b[43m';
const kBgBlue = '\x1b[44m';
const kBgMagenta = '\x1b[45m';
const kBgCyan = '\x1b[46m';
const kBgWhite = '\x1b[47m';

const kAnsiTextStyle = {
  kReset: TextStyle(color: Colors.black),
  kBold: TextStyle(fontWeight: FontWeight.w700),
  kDim: TextStyle(fontWeight: FontWeight.w300),
  kUnderscore: TextStyle(decoration: TextDecoration.underline),
  kBlack: TextStyle(color: Colors.black),
  kRed: TextStyle(color: Colors.red),
  kGreen: TextStyle(color: Colors.green),
  kYellow: TextStyle(color: Color(0xFFfaaf2d)),
  kBlue: TextStyle(color: Colors.blue),
  kMagenta: TextStyle(color: Colors.purple),
  kCyan: TextStyle(color: Colors.cyan),
  kBgBlack: TextStyle(backgroundColor: Colors.black),
  kBgRed: TextStyle(backgroundColor: Colors.red),
  kBgGreen: TextStyle(backgroundColor: Colors.greenAccent),
  kBgYellow: TextStyle(backgroundColor: Colors.yellowAccent),
  kBgBlue: TextStyle(backgroundColor: Colors.blue),
  kBgMagenta: TextStyle(backgroundColor: Colors.purple),
  kBgCyan: TextStyle(backgroundColor: Colors.cyanAccent),
};

const kAnsiTextDarkStyle = {
  kReset: TextStyle(color: Colors.white),
  kBlack: TextStyle(color: Colors.white),
};
