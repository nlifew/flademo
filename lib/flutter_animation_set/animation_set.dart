

import 'package:flutter/material.dart';

import 'animator.dart';

export 'animation_set.dart'
    show AnimatorSet, AnimationType;

///
/// @author wangaihu
/// @date 2021.5.20
/// 这个类及其包下的类来自第三方库 [github](https://github.com/YYFlutter/flutter-animation-set/blob/master/README_CN.md)
/// 但原始版本的实现是有问题的，因此直接拷贝下来修改
///

enum AnimationType {
  repeat,
  reverse,
  onlyOnce,
  everyBuild,
}

class AnimatorSet extends StatefulWidget {
  const AnimatorSet({
    Key key,
    @required this.child,
    this.debug = false,
    @required this.animatorSet,
    this.animationType = AnimationType.everyBuild,
    this.enabled = true,
    this.alignment = Alignment.center,
  })  : assert(animatorSet != null),
        super(key: key);

  final bool enabled;
  final bool debug;
  final Widget child;
  final Alignment alignment;
  final List<Animator> animatorSet;
  final AnimationType animationType;
  // final Widget Function(BuildContext, Widget, double) builder;

  @override
  State<StatefulWidget> createState() {
    return AnimatorSetState();
  }
}

class AnimatorSetState extends State<AnimatorSet>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  int _duration;

  // @override
  // void initState() {
  //   super.initState();
  //   _initAnimation();
  // }

  void _initAnimation() {
    if (_controller == null) {
      _controller = AnimationController(vsync: this)
        // ..addListener(() {})
        ..addStatusListener((AnimationStatus status) {
          if (! widget.enabled) {
            return;
          }

          switch(widget.animationType) {
            case AnimationType.reverse:
              if (status == AnimationStatus.completed) {
                _initAnimation();
                _controller.reverse();
              }
              break;
            case AnimationType.repeat:
              if (status == AnimationStatus.completed) {
                _initAnimation();
                _controller.reset();
                _controller.forward();
              }
              break;
            case AnimationType.onlyOnce:
              break;
            case AnimationType.everyBuild:
              break;
          }

        //   if (widget.animationType == AnimationType.reverse) {
        //     if (status == AnimationStatus.completed) {
        //       _controller.reverse();
        //     }
        //   }
        //   else if (widget.animationType == AnimationType.repeat) {
        //     if (status == AnimationStatus.completed) {
        //       _controller.repeat();
        //     }
        //   }
        });
    }

    _duration = 0;
    widget.animatorSet.forEach((element) {
      _duration += element.duration ?? 0;
    });

    _controller.duration = Duration(milliseconds: _duration);

    _allocTimeSlice();
  }

  bool _isFirstPlay = true;

  void _startAnimation() {
    _controller.reset();

    if (! widget.enabled) {
      return;
    }
    if (! _isFirstPlay && widget.animationType == AnimationType.onlyOnce) {
      return;
    }
    _isFirstPlay = false;

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    _initAnimation();
    _startAnimation();

    return AnimatedBuilder(
      animation: _controller,
      builder:_buildAnimatedWidget,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  // final List<_AnimatorTimeSlice> _runningList = [];
  final List<_AnimatorTimeSlice> _waitingList = [];
  final _AnimatorOption _options = _AnimatorOption();


  void _allocTimeSlice() {
    // _runningList.clear();
    _waitingList.clear();
    _options.reset();

    double begin = 0, end = 0;
    widget.animatorSet.forEach((anim) {
      begin = end + (1.0 * anim.delay / _duration);
      end = begin + (1.0 * anim.duration - anim.delay) / _duration;

      if (widget.debug) {
        print('duration=$_duration, anim.duration=${anim.duration}, ' +
            'anim.delay=${anim.delay}, begin=$begin, end=$end');
      }
      _waitingList.add(_AnimatorTimeSlice(anim: anim, begin: begin, end: end));
    });

    // 可能我们不需要排序 ?
    // 因为在声明动画时本身就是串行的，按照顺序遍历下来就已经是时间有序的了
    // 除了 Serial，但 Serial 里面的所有子元素都认为拥有相同的 duration
    // 因此也认为是有序的
    // _waitingList.sort(_AnimatorTimeSlice.compareTo);
  }

  Widget _buildAnimatedWidget(BuildContext context, Widget _) {
    final double now = _controller.value;

    Widget child = widget.child;

    if (widget.enabled) {

      // 1. remove deprecated animations.
      // while (_runningList.isNotEmpty) {
      //   final _AnimatorTimeSlice slice = _runningList.first;
      //   if (slice.end > now) {
      //     break;
      //   }
      //   _runningList.remove(slice); // NO removeAt(0) !!!
      //   _goSleep(slice);
      // }

      // 2. append be in ordered animations.
      if (_controller.status == AnimationStatus.reverse) {
        while (_waitingList.isNotEmpty) {
          final _AnimatorTimeSlice slice = _waitingList.last;
          if (slice.end < now) {
            break;
          }
          _waitingList.remove(slice);
          _wakeUp(slice);
        }
      }
      else {
        while (_waitingList.isNotEmpty) {
          final _AnimatorTimeSlice slice = _waitingList.first;
          if (slice.begin > now) {
            break;
          }
          _waitingList.remove(slice); // NO removeAt(0) !!!
          // _runningList.add(slice);
          _wakeUp(slice);
        }
      }
    }

    // 3. real build widget
    return _options.build(context, child, widget.alignment);
  }

  void _wakeUp(_AnimatorTimeSlice slice) {
    final Animator anim = slice.anim;

    if (anim is Serial) {
      anim.serialList.forEach((it) {
        double begin = slice.begin + 1.0 * it.delay / _duration;
        _waitingList.add(_AnimatorTimeSlice(
          anim: it, begin: begin, end: slice.end,
        ));
      });
      _waitingList.sort(_AnimatorTimeSlice.compareTo);
    }
    else if (anim is Stub) {
      Animator instance = anim.builder();
      if (instance != null) {
        _waitingList.add(_AnimatorTimeSlice(
            anim: instance, begin: slice.begin, end: slice.end
        ));
        _waitingList.sort(_AnimatorTimeSlice.compareTo);
      }
    }
    else if (anim is SX) {
      // assert(_options.scaleX == null);
      _options.scaleX = Tween<double>(
        begin: anim.from,
        end: anim.to,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            slice.begin,
            slice.end,
            curve: anim.curve,
          ),
        ),
      );
    }
    else if (anim is SY) {
      // assert(_options.scaleY == null);
      _options.scaleY = Tween<double>(
        begin: anim.from,
        end: anim.to,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            slice.begin,
            slice.end,
            curve: anim.curve,
          ),
        ),
      );
    }
    else if (anim is TX) {
      // assert(_options.translateX == null);
      _options.translateX = Tween<double>(
        begin: anim.from,
        end: anim.to,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            slice.begin,
            slice.end,
            curve: anim.curve,
          ),
        ),
      );
    }
    else if (anim is TY) {
      // assert(_options.translateY == null);
      _options.translateY = Tween<double>(
        begin: anim.from,
        end: anim.to,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            slice.begin,
            slice.end,
            curve: anim.curve,
          ),
        ),
      );
    }
    else if (anim is RX) {
      // assert(_options.rotateX == null);
      _options.rotateX = Tween<double>(
        begin: anim.from,
        end: anim.to,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            slice.begin,
            slice.end,
            curve: anim.curve,
          ),
        ),
      );
    }
    else if (anim is RY) {
      // assert(_options.rotateY == null);
      _options.rotateY = Tween<double>(
        begin: anim.from,
        end: anim.to,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            slice.begin,
            slice.end,
            curve: anim.curve,
          ),
        ),
      );
    }
    else if (anim is RZ) {
      // assert(_options.rotateZ == null);
      _options.rotateZ = Tween<double>(
        begin: anim.from,
        end: anim.to,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            slice.begin,
            slice.end,
            curve: anim.curve,
          ),
        ),
      );
    }
    else if (anim is O) {
      // assert(_options.opacity == null);
      _options.opacity = Tween<double>(
        begin: anim.from,
        end: anim.to,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            slice.begin,
            slice.end,
            curve: anim.curve,
          ),
        ),
      );
    }
    else if (anim is C) {
      // assert(_options.color == null);
      _options.color = ColorTween(
        begin: anim.from,
        end: anim.to,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            slice.begin,
            slice.end,
            curve: anim.curve,
          ),
        ),
      );
    }
    else if (anim is B) {
      // assert(_options.border == null);
      _options.border = BorderRadiusTween(
        begin: anim.from,
        end: anim.to,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            slice.begin,
            slice.end,
            curve: anim.curve,
          ),
        ),
      );
    }
    else if (anim is W) {
      // assert(_options.width == null);
      _options.width = Tween<double>(
        begin: anim.from,
        end: anim.to,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            slice.begin,
            slice.end,
            curve: anim.curve,
          ),
        ),
      );
    }
    else if (anim is H) {
      // assert(_options.height == null);
      _options.height = Tween<double>(
        begin: anim.from,
        end: anim.to,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            slice.begin,
            slice.end,
            curve: anim.curve,
          ),
        ),
      );
    }
    else if (anim is P) {
      // assert(_options.padding == null);
      _options.padding = EdgeInsetsTween(
        begin: anim.from,
        end: anim.to,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            slice.begin,
            slice.end,
            curve: anim.curve,
          ),
        ),
      );
    }
    // else if (anim is Delay) {
    //  // do nothing
    // }
  }

  /*
  void _goSleep(_AnimatorTimeSlice slice) {
    final Animator anim = slice.anim;
    if (anim is SX) {
      _options.scaleX = null;
    }
    else if (anim is SY) {
      _options.scaleY = null;
    }
    else if (anim is TX) {
      _options.translateX = null;
    }
    else if (anim is TY) {
      _options.translateY = null;
    }
    else if (anim is RX) {
      _options.rotateX = null;
    }
    else if (anim is RY) {
      _options.rotateY = null;
    }
    else if (anim is RZ) {
      _options.rotateZ = null;
    }
    else if (anim is O) {
      _options.opacity = null;
    }
    else if (anim is C) {
      _options.color = null;
    }
    else if (anim is B) {
      _options.border = null;
    }
    else if (anim is W) {
      _options.width = null;
    }
    else if (anim is H) {
      _options.height = null;
    }
    else if (anim is P) {
      _options.padding = null;
    }
    // else if (anim is Stub) {
    //   // nothing to do
    // }
    // else if (anim is Serial) {
    //   // nothing to do
    // }
    // else if (anim is Delay) {
    //   // nothing to do
    // }
  }
   */
}

class _AnimatorTimeSlice {
  final Animator anim;
  final double begin;
  final double end;

  const _AnimatorTimeSlice({
    @required this.anim,
    @required this.begin,
    @required this.end,
  });

  static int compareTo(_AnimatorTimeSlice p, _AnimatorTimeSlice q) {
    double cmp = p.begin - q.begin;
    if (cmp == 0) { // difficult
      cmp = p.end - q.end;
    }
    return (cmp * 100).toInt();
  }
}

class _AnimatorOption {
  Animation<double> scaleX;
  Animation<double> scaleY;
  Animation<double> translateX;
  Animation<double> translateY;
  Animation<double> opacity;
  Animation<double> height;
  Animation<double> width;
  Animation<double> rotateX;
  Animation<double> rotateY;
  Animation<double> rotateZ;
  Animation<Color> color;
  Animation<EdgeInsets> padding;
  Animation<BorderRadius> border;

  void reset() {
    scaleX = scaleY = null;
    translateX = translateY = null;
    opacity = null;
    width = height = null;
    rotateX = rotateY = rotateZ = null;
    color = null;
    padding = null;
    border = null;
  }

  Widget build(BuildContext context, Widget child, Alignment alignment) {
    return Container(
      width: width ?.value ?? null,
      height: height ?.value ?? null,
      padding: padding ?.value ?? null,
      decoration: BoxDecoration(
        color: color ?.value ?? null,
        borderRadius: border ?.value ?? null,
      ),
      transformAlignment: alignment,
      transform: Matrix4.identity()
        ..translate(translateX ?.value ?? 0.0, translateY ?.value ?? 0.0)
        ..scale(scaleX ?.value ?? 1.0, scaleY?.value ?? 1.0)
        ..rotateX(rotateX ?.value ?? 0.0)
        ..rotateY(rotateY ?.value ?? 0.0)
        ..rotateZ(rotateZ ?.value ?? 0.0),
      child: Opacity(
        child: child,
        opacity: opacity?.value ?? 1,
      ),
    );
  }
}



class AnimatorBuilderWidget extends StatefulWidget {
  final ValueNotifier<int> index;

  final Widget child;

  final AnimatorSet Function(BuildContext, int, Widget) builder;

  const AnimatorBuilderWidget({
    Key key,
    @required this.index,
    @required this.builder,
    this.child,
  }) : super(key: key);

  @override
  _AnimatorBuilderState createState() => _AnimatorBuilderState();

  factory AnimatorBuilderWidget.of({
    @required ValueNotifier<int> index,
    @required List<List<Animator>> animList,
    Widget child,
    Alignment alignment = Alignment.center,
    AnimationType animationType = AnimationType.everyBuild,
  }) {
    return AnimatorBuilderWidget(
      index: index,
      child: child,
      builder: (context, idx, _) {
        return AnimatorSet(
          child: child,
          alignment: alignment,
          animationType: animationType,
          animatorSet: animList[idx],
        );
      },
    );
  }
}

class _AnimatorBuilderState extends State<AnimatorBuilderWidget> {

  @override
  void initState() {
    super.initState();
    widget.index.addListener(_onWidgetIndexChanged);
  }


  @override
  void didUpdateWidget(AnimatorBuilderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.index.removeListener(_onWidgetIndexChanged);
    widget.index.addListener(_onWidgetIndexChanged);
  }


  @override
  void dispose() {
    super.dispose();
    widget.index.removeListener(_onWidgetIndexChanged);
  }

  void _onWidgetIndexChanged() {
    if (mounted) {
      setState(() { });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.index.value, widget.child);
  }
}