// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(home: new Scaffold(body: new Home())));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home>
    with TickerProviderStateMixin {
  AnimationController _controllerMenu;
  AnimationController _controllerText;
  AnimationController _scaleController;
  AnimationController _showFuckController;
  Animation<double> _animationMenu;
  Animation<double> _animationText;
  Animation<double> _frontScale;
  Animation<double> _backScale;
  Animation<Offset> _showFuck;
  bool _menuOpened = false;
  bool _showfuck = false;
  double _height;

  @override
  void initState() {
    super.initState();
    _controllerMenu = new AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _controllerText = new AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleController = new AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _showFuckController = new AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _animationMenu = new Tween(begin: 0.3, end: 1.0).animate(
      new CurvedAnimation(
        parent: _controllerMenu,
        curve:Curves.ease,
      ),
    );
    _animationMenu.addListener((){
      setState((){});
    });
    _animationMenu.addStatusListener((status){
      if(status == AnimationStatus.completed ){
        _menuOpened = !_menuOpened;
        _controllerText.forward();
      }
      if(status == AnimationStatus.dismissed && _showfuck){
        _showFuckController.forward();
      }
    });

    _animationText = new Tween(begin: -100.0, end: 16.0).animate(
      new CurvedAnimation(
        parent: _controllerText,
        curve:Curves.ease,
      ),
    );
    _animationText.addListener((){
      setState((){});
    });

    _animationText.addStatusListener((status){
      if(status == AnimationStatus.dismissed){
      _menuOpened = !_menuOpened;
      _controllerMenu.reverse();
      }

    });
    _showFuck = new Tween(
      begin: new Offset(0.0,3.0),
      end: new Offset(0.0,0.0),
    ).animate(new CurvedAnimation(
      parent: _showFuckController,
      curve: new Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));
    _showFuck.addStatusListener((status){
      if(status == AnimationStatus.completed ){
        _scaleController.forward();
      }
      if(status == AnimationStatus.dismissed){
        _scaleController.reverse();
      }
    });

    _frontScale = new Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(new CurvedAnimation(
      parent: _scaleController,
      curve: new Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
    _backScale = new CurvedAnimation(
      parent: _scaleController,
      curve: new Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _frontScale.addListener((){
      setState((){});
    });
    _backScale.addListener((){
      setState((){});
    });

    _backScale.addStatusListener((status){
      if(status == AnimationStatus.completed){
        _showFuckController.reverse();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controllerMenu.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  new Container(
        child: new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new Align(
              child: new GestureDetector(
                child: new Container(
                  child: new ClipPath(
                    child: new Container(
                      color: Colors.black,
                      width: 250.0 * _animationMenu.value,
                    ),
                    clipper: new HillClipper(),
                  ),
                ),
                onHorizontalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dx > 0 && !_menuOpened) {
                    print("Open");
                    _controllerMenu.forward();
                  }
                  else if (details.velocity.pixelsPerSecond.dx < 0 && _menuOpened) {
                    print("Close");
                    _controllerText.reverse();
                  }
                },
              ),
              alignment: Alignment.centerLeft,
            ),
            new Align(
              child: new Transform(
                transform: new Matrix4.translationValues(
                    _animationText.value, 0.0, 0.0),
                child: new GestureDetector(
                  child: const Text("Tap Here",
                    style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                  onTap: (){
                    _controllerText.reverse();
                    _showfuck = true;
                  },
                ),
              ),
              alignment: Alignment.centerLeft,
            ),
            new SlideTransition(position: _showFuck,
              child: new Stack(
                children: <Widget>[
                  new Transform(transform:  new Matrix4.identity()
                ..scale(1.0, _backScale.value, 1.0),
                    alignment: FractionalOffset.center,
                    child: new FuckYouCard("images/too_easy.jpeg"),
                  ),
                  new Transform(transform:  new Matrix4.identity()
                    ..scale(1.0, _frontScale.value, 1.0),
                    alignment: FractionalOffset.center,
                    child: new FuckYouCard(null),
                  ),
                ],
              )
            ),
          ],
        )
    );
  }
}

class HillClipper extends CustomClipper<Path>{

  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height/5);

    var medianControlPoint = new Offset(size.width, size.height/2);
    var medianPoint = new Offset(0.0, size.height - size.height/5);
    path.quadraticBezierTo(medianControlPoint.dx, medianControlPoint.dy,
        medianPoint.dx, medianPoint.dy);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class FuckYouCard extends StatelessWidget {
  final String image;
  
  FuckYouCard(this.image);

  @override
  Widget build(BuildContext context) {
    return new Container(
        alignment: FractionalOffset.center,
        height: 250.0,
        width: 250.0,
        decoration: new BoxDecoration(
          border: new Border.all(color: new Color(0xFF9E9E9E)),
        ),
        child: image != null? new Image.asset(image): new Text(
            "Animations in flutter?",
            style: new TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
        ),
    );
  }
}

