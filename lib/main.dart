import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ShadowBottomNavigationBar(
            items: <IconData>[
              Icons.shopping_basket,
              Icons.favorite_border,
              Icons.search,
            ],
            width: 200,
          ),
        ),
      ),
    );
  }
}

class ShadowBottomNavigationBar extends StatefulWidget {
  final double iconSize, width;
  final List<IconData> items;
  ShadowBottomNavigationBar(
      {this.iconSize = 24, this.items = const <IconData>[], this.width});

  @override
  _ShadowBottomNavigationBarState createState() =>
      _ShadowBottomNavigationBarState();
}

class _ShadowBottomNavigationBarState extends State<ShadowBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  int oldIndex = 0;
  AnimationController _controller;
  double width;

  @override
  initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
      reverseDuration: Duration(milliseconds: 400),
    );
    _controller.forward();
    width = widget.width ?? MediaQuery.of(context).size.width;
  }

  _buildNavigationTile() {
    var tiles = <Widget>[];
    for (int i = 0; i < widget.items.length; i++) {
      tiles.add(
        GestureDetector(
          onTap: () {
            if (i != selectedIndex) {
              setState(() {
                oldIndex = selectedIndex;
                selectedIndex = i;
              });
              if (_controller.isAnimating) {
              } else if (_controller.isCompleted) {
                _controller.reset();
              }
              _controller.forward();
            }
          },
          behavior: HitTestBehavior.translucent,
          child: ShadowNavigationBarTile(
            key: UniqueKey(),
            icon: widget.items[i],
            active: i == selectedIndex,
            wasActive: i == oldIndex,
            animation: _controller,
          ),
        ),
      );
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[800],
      ),
      child: Stack(
        children: <Widget>[
          AnimatedBuilder(
            animation: _controller,
            builder: (_, w) {
              return Container(
                height: 56,
                width: width,
                child: CustomPaint(
                  foregroundPainter: _SelectedTilePainter(
                      newPosition: selectedIndex,
                      oldPosition: oldIndex,
                      progress: Tween<double>(begin: 0.0, end: 1.0)
                          .animate(CurvedAnimation(
                              parent: _controller,
                              curve:
                                  Interval(0.0, 0.5, curve: Curves.easeInOut)))
                          .value,
                      count: widget.items.length),
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[..._buildNavigationTile()],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ShadowNavigationBarTile extends StatelessWidget {
  final IconData icon;
  final bool active, wasActive;
  final double iconSize;
  final Animation animation;

  ShadowNavigationBarTile({
    Key key,
    @required this.icon,
    @required this.animation,
    this.iconSize = 24,
    this.active = false,
    this.wasActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: iconSize + 24,
      child: Stack(
        children: <Widget>[
          AnimatedBuilder(
            animation: animation,
            builder: (_, w) {
              return Center(
                child: Icon(
                  icon,
                  size: iconSize,
                  color: (active && animation.value > 0.6)
                      ? Colors.white
                      : Colors.grey,
                ),
              );
            },
          ),
          FadeTransition(
            opacity: ((active)
                ? Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                        parent: animation,
                        curve: Interval(0.6, 1, curve: Curves.easeInOut)),
                  )
                : Tween<double>(begin: 1, end: 0).animate(
                    CurvedAnimation(
                        parent: animation,
                        curve: Interval(0, 0.4, curve: Curves.easeInOut)),
                  )),
            child: CustomPaint(
              foregroundPainter:
                  _LightShadowPainter(active: active || wasActive),
            ),
          )
        ],
      ),
    );
  }
}

class _SelectedTilePainter extends CustomPainter {
  _SelectedTilePainter({
    this.oldPosition,
    this.newPosition,
    this.progress,
    this.count,
    this.iconSize = 24,
    this.color = Colors.white,
  }) {
    assert(progress != null);
  }

  final int oldPosition, newPosition, count;
  final double iconSize;
  final Color color;
  final double progress;

  Offset startOffset(Size size) {
    var freeSpace = (size.width / count) - iconSize;
    assert(freeSpace >= 0);
    return Offset(
        freeSpace / 2 +
            (freeSpace + iconSize) *
                (oldPosition * (1 - progress) + newPosition * progress),
        1);
  }

  Offset endOffset(Size size) {
    var freeSpace = (size.width / count) - iconSize;
    assert(freeSpace >= 0);
    return Offset(
        freeSpace / 2 +
            (freeSpace + iconSize) *
                (oldPosition * (1 - progress) + newPosition * progress) +
            iconSize,
        1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var p = Paint()
      ..color = this.color
      ..strokeWidth = 2;
    canvas.drawLine(startOffset(size), endOffset(size), p);
  }

  @override
  bool shouldRepaint(_SelectedTilePainter oldDelegate) => true;
}

class _LightShadowPainter extends CustomPainter {
  final bool active;
  final double iconSize;
  final Color color;
  final Animation animation;

  _LightShadowPainter({
    @required this.active,
    this.animation,
    this.iconSize = 24,
    this.color = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (active) {
      var p = Paint()
        ..shader = LinearGradient(colors: <Color>[
          color.withAlpha(64),
          color.withAlpha(24),
          color.withAlpha(0)
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)
            .createShader(
          Rect.fromLTWH(0, 0, 56, 56),
        );
      var oldTrap = Path()..addPolygon(getTrap(size), true);
      canvas.drawPath(oldTrap, p);
    }
  }

  @override
  bool shouldRepaint(_LightShadowPainter oldDelegate) => true;

  List<Offset> getTrap(Size size, {Offset initial = Offset.zero}) {
    var points = <Offset>[];
    points.add(initial + Offset(14, 0));
    points.add(initial + Offset(-4, 56));
    points.add(initial + Offset(52, 56));
    points.add(initial + Offset(34, 0));
    return points;
  }
}
