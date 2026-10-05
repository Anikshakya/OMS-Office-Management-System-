import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget loadingWidget([Color? color,double? size]) {
  return Center(
    child: CupertinoActivityIndicator(
      animating: true,
      color: color ?? Colors.white,
      radius: size ?? 14,
    ),
  );
}