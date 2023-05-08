import 'dart:async' as async;
import 'package:flame/experimental.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Tapbutton extends PositionComponent with TapCallbacks {
  final void Function() onTap;

  Tapbutton(this.onTap) : super(anchor: Anchor.center);

  final _paint = Paint()..color = const Color.fromARGB(68,97,7,7);
  bool isLongTapDown = false;

  @override
  void render (Canvas canvas){
    canvas.drawRect(size.toRect(), _paint);
  }

  @override
  void onTapDown(TapDownEvent event){
    onTap();
  }

  @override
  void onLongTapDown(TapDownEvent event)
  {
    isLongTapDown = true;
    async.Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if(isLongTapDown){
        onTap();
      }else{
        timer.cancel();
      }
    });
  }

  @override
  void onTapUp(TapUpEvent event)
  {
    isLongTapDown = false;
  }

  void onTapCancelTapUpEvent(TapCancelEvent event)
  {
    isLongTapDown = false;
  }
}