import 'package:flutter/material.dart';

export 'animator.dart';

/// [github](https://github.com/YYFlutter/flutter-animation-set/blob/master/README_CN.md)

abstract class Animator<T> {
  final T from;
  final T to;
  final int duration;
  final int delay;
  final Curve curve;

  const Animator({
    this.from,
    this.to,
    this.duration = 0,
    this.delay = 0,
    this.curve = Curves.linear,
  });
}

class Serial extends Animator<int> {
  const Serial({
    // int from,
    // int to,
    int duration = 0,
    // Curve curve,

    /// 无效，用Delay组件替代
    // int delay,
    @required this.serialList,
  }) : super(
    // from: from,
    // to: to,
    duration: duration,
    // curve: curve,
    // delay: delay,
  );

  // int duration;
  // int delay;
  final List<Animator> serialList;
}

class W extends Animator<double> {
  const W({
    @required double from,
    @required double to,
    int duration = 0,
    int delay = 0,
    Curve curve = Curves.linear,
  }) : super(
    from: from,
    to: to,
    duration: duration,
    delay: delay,
    curve: curve,
  );

  // double from;
  // double to;
  // int duration;
  // int delay;
  // Curve curve;
}

class H extends Animator<double> {
  // H({
  //   this.from,
  //   this.to,
  //   this.duration = 0,
  //   this.delay = 0,
  //   this.curve = Curves.linear,
  // });
  //
  // double from;
  // double to;
  // int duration;
  // int delay;
  // Curve curve;
  const H({
    @required double from,
    @required double to,
    int duration = 0,
    int delay = 0,
    Curve curve = Curves.linear,
  }) : super(
    from: from,
    to: to,
    duration: duration,
    delay: delay,
    curve: curve,
  );
}

class P extends Animator<EdgeInsets> {
  // P({
  //   this.from,
  //   this.to,
  //   this.duration = 0,
  //   this.delay = 0,
  //   this.curve = Curves.linear,
  // });
  //
  // EdgeInsets from;
  // EdgeInsets to;
  // int duration;
  // int delay;
  // Curve curve;
  const P({
    @required EdgeInsets from,
    @required EdgeInsets to,
    int duration = 0,
    int delay = 0,
    Curve curve = Curves.linear,
  }) : super(
    from: from,
    to: to,
    duration: duration,
    delay: delay,
    curve: curve,
  );
}

class O extends Animator<double> {
  // O({
  //   this.from,
  //   this.to,
  //   this.duration = 0,
  //   this.delay = 0,
  //   this.curve = Curves.linear,
  // });
  //
  // double from;
  // double to;
  // int duration;
  // int delay;
  // Curve curve;
  const O({
    @required double from,
    @required double to,
    int duration = 0,
    int delay = 0,
    Curve curve = Curves.linear,
  }) : super(
    from: from,
    to: to,
    duration: duration,
    delay: delay,
    curve: curve,
  );
}

class SX extends Animator<double> {
  // SX({
  //   this.from,
  //   this.to,
  //   this.duration = 0,
  //   this.delay = 0,
  //   this.curve = Curves.linear,
  // });
  //
  // double from;
  // double to;
  // int duration;
  // int delay;
  // Curve curve;
  const SX({
    @required double from,
    @required double to,
    int duration = 0,
    int delay = 0,
    Curve curve = Curves.linear,
  }) : super(
    from: from,
    to: to,
    duration: duration,
    delay: delay,
    curve: curve,
  );
}

class SY extends Animator<double> {
  // SY({
  //   this.from,
  //   this.to,
  //   this.duration = 0,
  //   this.delay = 0,
  //   this.curve = Curves.linear,
  // });
  //
  // double from;
  // double to;
  // int duration;
  // int delay;
  // Curve curve;
  const SY({
    @required double from,
    @required double to,
    int duration = 0,
    int delay = 0,
    Curve curve = Curves.linear,
  }) : super(
    from: from,
    to: to,
    duration: duration,
    delay: delay,
    curve: curve,
  );
}

class RX extends Animator<double> {
  // RX({
  //   this.from,
  //   this.to,
  //   this.duration = 0,
  //   this.delay = 0,
  //   this.curve = Curves.linear,
  // });
  //
  // double from;
  // double to;
  // int duration;
  // int delay;
  // Curve curve;
  const RX({
    @required double from,
    @required double to,
    int duration = 0,
    int delay = 0,
    Curve curve = Curves.linear,
  }) : super(
    from: from,
    to: to,
    duration: duration,
    delay: delay,
    curve: curve,
  );
}

class RY extends Animator<double> {
  // RY({
  //   this.from,
  //   this.to,
  //   this.duration = 0,
  //   this.delay = 0,
  //   this.curve = Curves.linear,
  // });
  //
  // double from;
  // double to;
  // int duration;
  // int delay;
  // Curve curve;
  const RY({
    @required double from,
    @required double to,
    int duration = 0,
    int delay = 0,
    Curve curve = Curves.linear,
  }) : super(
    from: from,
    to: to,
    duration: duration,
    delay: delay,
    curve: curve,
  );
}

class RZ extends Animator<double> {
  // RZ({
  //   this.from,
  //   this.to,
  //   this.duration = 0,
  //   this.delay = 0,
  //   this.curve = Curves.linear,
  // });
  //
  // double from;
  // double to;
  // int duration;
  // int delay;
  // Curve curve;
  const RZ({
    @required double from,
    @required double to,
    int duration = 0,
    int delay = 0,
    Curve curve = Curves.linear,
  }) : super(
    from: from,
    to: to,
    duration: duration,
    delay: delay,
    curve: curve,
  );
}

class TX extends Animator<double> {
  // TX({
  //   this.from,
  //   this.to,
  //   this.duration = 0,
  //   this.delay = 0,
  //   this.curve = Curves.linear,
  // });
  //
  // double from;
  // double to;
  // int duration;
  // int delay;
  // Curve curve;
  const TX({
    @required double from,
    @required double to,
    int duration = 0,
    int delay = 0,
    Curve curve = Curves.linear,
  }) : super(
    from: from,
    to: to,
    duration: duration,
    delay: delay,
    curve: curve,
  );
}

class TY extends Animator<double> {
  // TY({
  //   this.from,
  //   this.to,
  //   this.duration = 0,
  //   this.delay = 0,
  //   this.curve = Curves.linear,
  // });
  //
  // double from;
  // double to;
  // int duration;
  // int delay;
  // Curve curve;
  const TY({
    @required double from,
    @required double to,
    int duration = 0,
    int delay = 0,
    Curve curve = Curves.linear,
  }) : super(
    from: from,
    to: to,
    duration: duration,
    delay: delay,
    curve: curve,
  );
}

class C extends Animator<Color> {
  // C({
  //   this.from,
  //   this.to,
  //   this.duration = 0,
  //   this.delay = 0,
  //   this.curve = Curves.linear,
  // });
  //
  // Color from;
  // Color to;
  // int duration;
  // int delay;
  // Curve curve;
  const C({
    @required Color from,
    @required Color to,
    int duration = 0,
    int delay = 0,
    Curve curve = Curves.linear,
  }) : super(
    from: from,
    to: to,
    duration: duration,
    delay: delay,
    curve: curve,
  );
}

class B extends Animator<BorderRadius> {
  // B({
  //   this.from,
  //   this.to,
  //   this.duration = 0,
  //   this.delay = 0,
  //   this.curve = Curves.linear,
  // });
  //
  // BorderRadius from;
  // BorderRadius to;
  // int duration;
  // int delay;
  // Curve curve;
  const B({
    @required BorderRadius from,
    @required BorderRadius to,
    int duration = 0,
    int delay = 0,
    Curve curve = Curves.linear,
  }) : super(
    from: from,
    to: to,
    duration: duration,
    delay: delay,
    curve: curve,
  );
}

class Delay extends Animator<int> {
  // Delay({
  //   this.duration = 0,
  //
  //   /// 无效
  //   this.delay = 0,
  // });
  //
  // int duration;
  // int delay;
  const Delay({
    // int from,
    // int to,
    @required int duration,
    /// 无效
    // int delay,
    // Curve curve,
  }) : super(
    // from: from,
    // to: to,
    duration: duration,
    // delay: duration,
    // curve: curve,
  );
}


class Stub extends Animator<int> {
  final Animator<dynamic> Function() builder;

  const Stub({
    @required this.builder,
    int delay = 0,
    int duration = 0,
  }) : super(
    delay: delay,
    duration: duration
  );
}
