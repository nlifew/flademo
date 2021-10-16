

### Flutter 动画的简单实现

#### 前言

Flutter 平台的动画和 Android 平台的大同小异。如果你是经验丰富的 Android 开发人员，
一定听说过，甚至使用过 "属性动画"，"位移动画" 等相关概念或 API。某种意义上来讲，动画实际上就是一个定时器，
不断改变屏幕上某个东西的值，如 "宽度"，"高度"，"颜色"，"角度" 等值。由于人眼的视觉暂留效应，看起来就动起来了。

当然，我并不打算在这篇文档里解释那些令人头大的复杂概念，我们毕竟刚刚来到 Flutter 的世界，一切还是那么新奇 !
放轻松些，我们从简单的动画库 flutter_animation_set 开始，尝试写出一些简单的动画效果，然后再仔细推敲其源码。
到最后我敢保证你会大吃一惊：所有的动画原理都是大同小异的，它和你之前掌握的知识并没有什么不同！


#### 准备工作

在阅读到这里的时候，我相信你已经摩拳擦掌，跃跃欲试了，也相信你对 Flutter 已经充满了热情。但只有这些是不够的，您必须有 Flutter 
的基本知识，比如 Widget 的概念，dart 语言的基本语法等，否则阅读起来会非常吃力。第一步当然是使用 Android Studio 新建一个
Flutter 工程，我们接下来的所有示例代码都基于此。

然后将工程中 'lib/main.dart' 文件中的 `_MyHomePageState` 类改成下面的样子——

```dart
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: ColoredBox(
            color: Colors.green[500],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {  });
        },
        tooltip: 'Start The Animation !',
        child: Icon(Icons.send),
      ),
    );
  }
}
```

上面的逻辑其实并不复杂。我们在 `_MyHomePageState` 的 `build(BuildContext)` 函数里构造了一个
脚手架(`Scaffold`)，脚手架的主体是一个 `Center` 控件，它负责将自己的子元素居中。

对比一下就能发现，我们把官方示例代码中的 'Column' 控件改为了一个 '宽和高都为 50，颜色为浅绿色的矩形块'。
毕竟相比于文字，图案的动画效果更明显一些。还把 FloatingActionButton 的点击事件改成了 `setState() {}`。
setState 在这里的作用是通知 Flutter 框架应该重新执行 `build()` 函数。

至此，如果你的设备上成功展示出来一个绿色矩形，我们的基本准备工作就结束了。接下来就是介绍框架和使用框架的时间了 !

#### 框架介绍

正如前言中所提到的，我们首先尝试使用 flutter_animation_set 框架来学习动画搭建。flutter_animation_set 框架
来自 github，你可以在 [这里](https://github.com/YYFlutter/flutter-animation-set) 找到它的源码。但原项目
中有一些不符合我们要求的地方，因此我们使用的实际上是它的修改版。这个修改版只有两个文件，"animation_set.dart"
和 "animator.dart"，你可以直接粘贴到你的工作目录下，仅此而已！

我相信好奇的你已经打开了上面的链接了是吗？当你感叹于如此精细美妙的效果时，也不要灰心或者气馁，相信我，这并不复杂！

##### AnimatorSet 

AnimatorSet 是框架提供给我们的一个 Widget。如果你想让某个 Widget "具有动画能力"，只需要用 AnimatorSet
包装一下即可。结合上面的示例代码，既然我们想让这个浅绿色的矩形 "动起来"，第一步就是将这个矩形块用 AnimatorSet
包装起来。AnimatorSet 的构造函数提供了很多选项供开发者调用——

```dart
class AnimatorSet extends StatefulWidget {
  const AnimatorSet({
    /**
     * 这个参数负责给 Widget 一个 "独一无二的标识"，我们并不需要它
     */
    Key key,

    /**
     * 需要包裹的 widget
     */
    this.child,

    /**
     * 调试相关，我们不需要这个参数
     */
    this.debug = false,

    /**
     * 动画描述文件
     */
    @required this.animatorSet,

    /**
     * 动画播放方式，枚举类型。默认每次执行 build() 函数时自动播放动画
     */
    this.animationType = AnimationType.everyBuild,

    /**
     * 是否启用动画效果。为 false 时不会有动画效果
     */
    this.enabled = true,

    /**
     * child 在此 Widget 中的方向，类似于 android 里面的 Gravity
     */
    this.alignment = Alignment.center,
  })
  // ... 省略里面的实现 ...
}
```

正如上面文档中描述的，如果想使用 AnimatorSet 控件，一定要传进两个参数: child 和 animatorSet。
其中前者是需要被包裹的 widget; 后者是具体的动画描述文件。我们先不关心这个 "动画描述文件" 是什么，只知道它是个数组类型。
那我们就先试试看——

```dart
@override
Widget build(BuildContext context) {
  // ... 省略部分代码
    body: Center(
        child: AnimatorSet(
          child: SizedBox(
            width: 50,
            height: 50,
            child: ColoredBox(
              color: Colors.green[500],
            ),
          ),
          animatorSet: [],
        ),
    )
    // ... 省略部分代码 ...
}
```

正如您所见，我们在 `Center` 和 `SizedBox` 控件之间插入了 AnimatorSet 控件，除此之外一摸一样。既然如此，
我们先试一试效果吧，但出乎意料的是——似乎什么都没有发生 ?

似乎有什么不对? 不是说用 AnimatorSet 包装一下就能让 Widget 有动画能力吗? 怎么现在什么也没发生? 先别着急，还记得上面我们说的那个
"动画描述文件" 吗? 我们刚才仅仅是使用了一个空数组作为 "动画描述文件"，莫非这才是问题所在?

事实上确实是这样。所以接下来，我们先尝试弄懂这个 "动画描述文件" 是个什么东西 !


##### Animator

刚刚我们提到，所谓的 "动画描述文件"，其实就是个数组。那数组的类型呢? 我们看一下源码:

```dart
class AnimatorSet extends StatefulWidget {
  const AnimatorSet({
    Key key,
    @required this.child,
    this.debug = false,
    @required this.animatorSet,
    this.animationType = AnimationType.everyBuild,
    this.enabled = true,
    this.alignment = Alignment.center,
  })
  // ... 省略部分代码 ...
  final bool enabled;
  final bool debug;
  final Widget child;
  final Alignment alignment;
  final List<Animator> animatorSet; // <-- 其实是个 Animator 类型的数组 
  final AnimationType animationType;
  // ... 省略部分代码 ...
}
// Ah! There it is !
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
```
好吧，看起来 Animator 是个抽象类，还有 5 个参数。想要弄懂这些参数都是什么意思吗? 听我说，先别着急，
你现在应该出去喝一杯咖啡再回来。毕竟这么短的时间内接触了 AnimatorSet 和 Animator 两个全新的概念，如果不放松一下绝对会弄混的，
我可不想这样! 所以合上电脑盖子，来一杯香气四溢的咖啡吧。

好的欢迎回来。在继续我们的话题之前，请务必树立一个关键的意识，那就是——无论多复杂的动画，都可以分为若干个小动画片段的组合。
正如魔方一定能通过有限的步骤还原一样，复杂的动画效果一定也是由有限个小片段组合而成。这些不可再分的小片段，其实就是 Animator。
Animator 有很多种，但最最基础就是平移，旋转，缩放，透明度变化四种——是不是类似于 android 里的 translationX, scaleX 和 alpha ?
是的，动画的基础概念就是这些。事实上，只要将这些小片段按照时间顺序组合到一块，就完成了动画的编写。

#### 思维训练

上面的概念有点难懂? 我承认的确是。所以让我们来看下实例吧。放松点，这里没有任何代码，只是培养分析动画的思路而已，这很酷，
我相信你能做到的。

让我们先看一下下面这个动画效果:

1. [!先来看看这个](https://raw.githubusercontent.com/YYFlutter/flutter-animation-set/master/image/gif/12.gif)

看起来有点复杂? 并不是，这个动画实际上只包含了一种效果——"缩放"。如果你观察地够仔细，应该能发现它是先放大再缩小的。
好的，你能想到这里就已经足够了，不需要往更深处想——我说过这很简单的，对吗 ?

2. [!这个效果由两种变换组合而成](https://raw.githubusercontent.com/YYFlutter/flutter-animation-set/master/image/gif/7.gif)

这个不像刚才那个简单了对吗? 那我可以给你个提示，这个动画实际上是由两种动画组合而成的，猜猜看 ? 在看答案之前先稍微想一想总是
有帮助的。对比上面我们提到的最基础的四种变换: 旋转，平移，缩放，透明度变化，发现了吗? 没错就是这样，由缩放和透明度变化
组合而成。也就是说 "在放大的同时透明度逐渐减小"，是不是一下就豁然开朗 ?

3. [!这个由更多种方式组合而成](https://raw.githubusercontent.com/YYFlutter/flutter-animation-set/master/image/gif/18.gif)

如果你已经轻车熟路了，那么来看看这个吧；如果感到迷惑，请多花些时间消化前面的两个例子。我经常说这句话，思维因人而异，不要为了
跟上进度而跟上进度。我假设你已经把前面那两个例子完全搞懂了，那看看上面的图，你有 2 分钟的思考时间。

....

时间到! 事实上，这个动画效果是由三种变换组合而成的: 向上平移、放大，和减小透明度，你答对了吗? 接下来是另外一个重要的概念——
延时。有了延时，我们可以把多个小的动画效果组合在一起，共同构成更华丽的效果。

4. [!注意思考"延时"](https://raw.githubusercontent.com/YYFlutter/flutter-animation-set/master/image/gif/5.gif)

有想到这个例子的组合方式吗? 如果没有，可以只选择一个原点，把剩余三个先用纸遮住——然后再试试看?

如果对于单个圆点，其组合方式很简单: 就是单纯的增大了透明度而已。是的，每个原点都这样，但组合到一块呢? 每个原点的动画似乎不是同时开始
同时结束? 换句话说，每个的原点的动画似乎在时间上错开了? 是的，这就是延时的效果，后面原点的动画比前面的更晚开始，更晚结束 !

说实话我个人觉得把 "延时" 列为基础变换的其中一种是有失偏颇的，毕竟不像前面那几种那么直观易懂。但延时的确非常重要，
若干个单调动画的组合在一块，加上延时就变得出彩，这简直就是魔法!

5. [!这个示例同样使用了延时](https://raw.githubusercontent.com/YYFlutter/flutter-animation-set/master/image/gif/9.gif)

这个动画，如果单纯分析其中一个小白块，也是很简单的组合: 向上平移然后向下平移。但三个小白块之间并不是同时开始，同时结束的。
这也是 "延时" 的效果 !

6. [!试试这个](https://raw.githubusercontent.com/YYFlutter/flutter-animation-set/master/image/gif/8.gif)

对于每个小白点，是 "先放大后缩小"，准备三个小白点让它们不同时开始，就是这样 !


#### 编写动画描述文件

看起来很不容易，我们终于到了这一步! 还是那句话，如果你不能很熟练地答出上面所有题的答案，请务必再回去看看。我们接下来的代码
是和上面的示例息息相关的，只要有了上面的思考方式，代码就可以轻而易举地写出来——我保证!


##### Animator 及其子类

让我们再回顾一下 Animator 的源码——
```dart
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
```
正如同上面所提到的，对于最基础的变换效果，"平移"，"旋转"，"缩放"，"透明度变换"，它们所具有的共同属性就是上面的 5 个参数。

* `from` 和 `to` 描述了这个基础变换的起始状态和结束状态
  
* `duration` 是从 `from` 状态到 `to` 状态要经过多长时间
  
* `curve` 这个有点复杂，我们先不用管

* `dalay` 属性，这个和上面我们所说的有点区别，但好在我们现在还用不到

现在说起来还是有点抽象。以 "从现在的位置向右平移 50 个像素，花费 1000 毫秒" 为例。让我们分析下这句话，"从现在的位置"，
是初始状态，"向右平移了 50 像素" 是结束状态，"花费 1000 毫秒" 是时间。这就完成了语义向伪代码的转换。

需要注意的是，Animator 的不同子类负责完成不同的工作。如

* TX 表示沿着 x 轴 (水平方向) 平移;

* TY 表示沿着 y 轴 (竖直方向) 平移;

* RX 表示以 x 轴为轴旋转;

* RY 表示以 y 轴为轴旋转;

* RZ 表示以 z 轴 (垂直于屏幕) 为轴旋转;

* SX 表示沿着 x 轴缩放;

* SY 表示沿着 y 轴缩放;

* O 表示透明度变化;

* Delay 表示延时;

那么，上面的 "从现在的位置向右平移 50 个像素，花费 1000 毫秒" 就可以表示为:

```dart
Animator a = TX(from: 0, to: 50, duration: 1000);
```

如果多种动画需要以串行方式播放，如 "先向右平移 50 像素，再向上平移 50 像素，各花费 1000 毫秒"，就可以写在一个列表里:

```dart
List<Animator> set = [
  TX(from: 0, to: 50, duration: 1000), // 向右平移，向右为正方向，所以为 正 50
  TY(from: 0, to: -50, duration: 1000),// 向上平移，向上为负方向，所以为 负 50
];
```

在上一节里，我们提到 AnimatorSet 接受一个 Animator 类型的数组作为 "动画描述文件"。在这个数组里，所有的 Animator 按照

依次播放，一个 Animator 结束后，下一个才会开始，也就是所谓的 "串行播放"。除此之外，还有一种 "并行方式" 播放，也就是要求
几种动画效果同时发生。这就需要用到 Serial 组件了。

它同样是 Animator 的子类，并接受一个 Animator 数组，将其中的效果同时播放(Serial 这个叫法是原仓库作者的叫法，Serial 本身是 "串行" 的意思) !

比如我们需要 "向右平移 50 像素的同时再向上平移 50 像素，花费 2000 毫秒"，就可以这样写——

```dart
Animator a = Serial(
  duration: 2000, // 一共 2000 毫秒
  serialList: [
    TX(from: 0, to: 50,),
    TY(from: 0, to: -50,),
  ],
);
```

除此之外还有个很重要的组件，Delay。它和上面 Animator 里的 delay 属性可不一样，我强烈建议你使用前者，而不是后者。
Delay 也是 Animator 的子类，但只有一个属性，duration，表示持续的时间。在这段时间里没有任何动画效果。

##### 示例代码编写

那么让我们小试牛刀，开始实际写代码吧。打开之前的 'main.dart' 文件，为 AnimatorSet 编写平移动画:
```dart
// ... 省略部分代码 ...
body: Center(
        child: AnimatorSet(
          child: SizedBox(
            width: 50,
            height: 50,
            child: ColoredBox(
              color: Colors.green[500],
            ),
          ),
          animatorSet: [
            TX(from: 0, to: 100, duration: 1000),
            TY(from: 0, to: -50, duration: 1000),
          ],
        )
      ),
// ... 省略部分代码 ...
```

怎么样，开始运行的时候，是不是出现了渴望已久的效果? "先向右平移 50 像素，再向上平移 50 像素，各花费 1000 毫秒"，
然后点击右下角的悬浮按钮，动画有没有重新播放? 就是这样!

然后试试用并行的方式播放动画——

```dart
body: Center(
        child: AnimatorSet(
          child: SizedBox(
            width: 50,
            height: 50,
            child: ColoredBox(
              color: Colors.green[500],
            ),
          ),
          animatorSet: [
            Serial(
              duration: 2000,
              serialList: [
                TX(from: 0, to: 100),
                TY(from: 0, to: -50),
              ],
            ),
          ],
        )
      ),
```

有没有观察到和串行方式的区别 ?

1. [!img](https://raw.githubusercontent.com/YYFlutter/flutter-animation-set/master/image/gif/12.gif)

还记得这个吗，这个动画实际上只包含了一种效果——"缩放"。在缩小时，其 x 方向和 y 方向上缩小的程度是一样的; 同样地，在放大时，

其 x 方向和 y 方向上放大的程度也是一样的。假设其缩小的比例为 0.7，我们编写代码如下——

```dart
animatorSet: [
            Serial(
              duration: 800,
              serialList: [
                SX(from: 1, to: 0.7), // x 方向上从之前的 1 倍大小变为 0.7 倍大小
                SY(from: 1, to: 0.7), // y 方向上从之前的 1 倍大小变为 0.7 倍大小
              ],
            ),
            Serial(
              duration: 800,
              serialList: [
                SX(from: 0.7, to: 1), // x 方向上从之前的 0.7 倍大小变为 1 倍大小
                SY(from: 0.7, to: 1), // y 方向上从之前的 0.7 倍大小变为 1 倍大小
              ],
            ),
          ],
        )
```

2. [!img](https://raw.githubusercontent.com/YYFlutter/flutter-animation-set/master/image/gif/7.gif)

"在放大的同时透明度逐渐减小"，还记得透明度用哪个组件吗，对的，O!

```dart
animatorSet: [
            Serial(
              duration: 800,
              serialList: [
                SX(from: 1, to: 1.5), // x 方向上从之前的 1 倍大小变为 1.5 倍大小
                SY(from: 1, to: 1.5), // y 方向上从之前的 1 倍大小变为 1.5 倍大小
                O(from: 1, to: 0),    // 透明度从 1 (完全不透明) 到 0 (完全透明)
              ],
            ),
          ],
```

3. [!img](https://raw.githubusercontent.com/YYFlutter/flutter-animation-set/master/image/gif/18.gif)

这个动画效果是由三种变换组合而成的: 向上平移、放大，和减小透明度

```dart
animatorSet: [
            Serial(
              duration: 800,
              serialList: [
                SX(from: 1, to: 1.5),
                SY(from: 1, to: 1.5),
                TY(from: 0, to: -100), // 相比示例 2 仅仅增加了向上平移的效果
                O(from: 1, to: 0),
              ],
            ),
          ],
```

4. [!img](https://raw.githubusercontent.com/YYFlutter/flutter-animation-set/master/image/gif/5.gif)

这个例子比较复杂，因为有 4 个小圆点，每个小圆点都有自己的动画效果，因此我们要对布局做一点调整

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    // ... 省略部分代码 ...
    body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [ // children 这里做了调整，一共有两行，每行有 2 个小圆点。小圆点用 _buildDot() 构造
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [ _buildDot(), SizedBox(width: 50), _buildDot() ],
            ),
            SizedBox(height: 50),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [ _buildDot(), SizedBox(width: 50), _buildDot() ],
            ),
          ],
        )
    ),
    // ... 省略部分代码 ...
  );
}

Widget _buildDot() {
  return AnimatorSet(     // 每个小圆点都要有自己的动画效果，因此用 AnimatorSet 包装一下
    child: PhysicalModel( // 这个 widget 是宽高都为 50 的小圆点
      color: Colors.green[400],
      borderRadius: BorderRadius.circular(50),
      shape: BoxShape.circle,
      child: SizedBox(width: 50, height: 50),
    ),
    animatorSet: [
      O(from: 0, to: 1, duration: 500), // 透明度从 0 (完全透明) 变化为 1 (完全不透明)
      O(from: 1, to: 0, duration: 500), // 透明度从 1 (完全不透明) 变化为 0 (完全透明)
    ],
  );
}
```

重新运行一下，是不是先出现再消失? 但效果怎么有点不一样? 是延时，我们还没有用延时组件让小圆点各自的动画在时间上错开 !

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    // ... 省略部分代码 ...
    body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [ // children 这里做了调整，一共有两行，每行有 2 个小圆点。小圆点用 _buildDot() 构造
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [ _buildDot(0), SizedBox(width: 50), _buildDot(500) ],
            ),
            SizedBox(height: 50),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [ _buildDot(1000), SizedBox(width: 50), _buildDot(1500) ],
            ),
          ],
        )
    ),
    // ... 省略部分代码 ...
  );
}

Widget _buildDot(int delayMs) {
  return AnimatorSet(     // 每个小圆点都要有自己的动画效果，因此用 AnimatorSet 包装一下
    child: PhysicalModel( // 这个 widget 是宽高都为 50 的小圆点
      color: Colors.green[400],
      borderRadius: BorderRadius.circular(50),
      shape: BoxShape.circle,
      child: SizedBox(width: 50, height: 50),
    ),
    animatorSet: [
      O(from: 0, to: 0),                // 重要: 在延时之前先将其置为完全透明
      Delay(duration: delayMs),         // 延迟执行一段时间(也就是这段时间内什么也不做)
      O(from: 0, to: 1, duration: 500), // 透明度从 0 (完全透明) 变化为 1 (完全不透明)
      O(from: 1, to: 0, duration: 500), // 透明度从 1 (完全不透明) 变化为 0 (完全透明)
    ],
  );
}
```

5. [!img](https://raw.githubusercontent.com/YYFlutter/flutter-animation-set/master/image/gif/9.gif)

```dart
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [ _buildSquare(0), SizedBox(width: 10), _buildSquare(100), SizedBox(width: 10), _buildSquare(200) ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {  });
        },
        tooltip: 'Start The Animation !',
        child: Icon(Icons.send),
      ),
    );
  }

  Widget _buildSquare(int delayMs) {
    return AnimatorSet(
      child: SizedBox(
        width: 30,
        height: 20,
        child: ColoredBox(color: Colors.green[400]),
      ),
      animatorSet: [
        Delay(duration: delayMs),             // 延迟执行给定的时间
        TY(from: 0, to: -30, duration: 500),  // 向上平移 30 像素
        TY(from: -30, to: 0, duration: 500),  // 向下平移 30 像素
      ],
    );
  }
```

6. [!img](https://raw.githubusercontent.com/YYFlutter/flutter-animation-set/master/image/gif/8.gif)

```dart
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [ _buildDot(0), SizedBox(width: 10), _buildDot(200), SizedBox(width: 10), _buildDot(400) ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {  });
        },
        tooltip: 'Start The Animation !',
        child: Icon(Icons.send),
      ),
    );
  }

  Widget _buildDot(int delayMs) {
    return AnimatorSet(
      child: PhysicalModel(
        color: Colors.green[400],
        borderRadius: BorderRadius.circular(30),
        shape: BoxShape.circle,
        child: SizedBox(width: 30, height: 30),
      ),
      animatorSet: [
        O(from: 0, to: 0),        // 先置为透明
        Delay(duration: delayMs), // 延时指定的时间
        O(from: 1, to: 1),        // 恢复可见
        Serial(                   // 并行的动画效果，x 方向和 y 方向同时从之前的 0 倍到之前的 1 倍
          duration: 500,
          serialList: [
            SX(from: 0, to: 1),
            SY(from: 0, to: 1),
          ],
        ),
        Serial(                 // 并行的动画效果，x 方向和 y 方向同时从之前的 1 倍到之前的 0 倍
          duration: 500,
          serialList: [
            SX(from: 1, to: 0),
            SY(from: 1, to: 0),
          ]
        ),
      ],
    );
  }
```

#### AnimatorSet 的其它属性

我们上面仅仅是使用了 AnimatorSet 最基础的两个属性，child 和 animatorSet。除此之外 enabled 属性也经常用到，当这个值为
false 时，不会做任何动画处理；为 true 时才会播放。animationType 属性表示动画结束后是否重复播放，以及是否会反转等。

1. enabled 属性

如果你动手完成了所有的动画示例代码的编写，一定会发现这样一个问题: "每次进入 app，动画都会自动播放。如果我想点击右下角的悬浮按钮后
才会播放，该怎么做呢"，这就要用到 enabled 属性了。

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [ _buildSquare(0), SizedBox(width: 10), _buildSquare(100), SizedBox(width: 10), _buildSquare(200) ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() { _animationEnabled = true; }); // 点击后启用动画
        },
        tooltip: 'Start The Animation !',
        child: Icon(Icons.send),
      ),
    );
  }


  bool _animationEnabled = false;


  Widget _buildSquare(int delayMs) {
    return AnimatorSet(
      enabled: _animationEnabled, // 动画是否启用取决于 _animationEnabled 属性
      child: SizedBox(
        width: 30,
        height: 20,
        child: ColoredBox(color: Colors.green[400]),
      ),
      animatorSet: [
        Delay(duration: delayMs),
        O(from: 1, to: 1),
        TY(from: 0, to: -30, duration: 500),
        TY(from: -30, to: 0, duration: 500),
      ],
    );
  }
```

在上面的代码中，我们使用 _animationEnabled 变量控制动画是否播放。在点击悬浮按钮后，这个布尔值被修改为 true，动画才会播放 !

2. animationType 属性

AnimatorSet 的 animationType 属性是个枚举类型，有且只有以下几种:

* repeat 重复。动画播放完后会再次播放，不会停止

* reverse 反转。播放结束后会按照和之前相反的顺序播放回去

* onlyOnce 只会播放一次。

* everyBuild 每次执行 build() 函数时都会执行一次。这也是默认选项。

自己动手调整下代码，试试看 !

```dart
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [ _buildSquare(0), SizedBox(width: 10), _buildSquare(100), SizedBox(width: 10), _buildSquare(200) ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() { _animationEnabled = true; });
        },
        tooltip: 'Start The Animation !',
        child: Icon(Icons.send),
      ),
    );
  }


  bool _animationEnabled = false;


  Widget _buildSquare(int delayMs) {
    return AnimatorSet(
      animationType: AnimationType.everyBuild,
      enabled: _animationEnabled, // 动画是否启用取决于 _animationEnabled 属性
      child: SizedBox(
        width: 30,
        height: 20,
        child: ColoredBox(color: Colors.green[400]),
      ),
      animatorSet: [
        Delay(duration: delayMs),
        TY(from: 0, to: -30, duration: 500),
        TY(from: -30, to: 0, duration: 500),
        Delay(duration: 500 - delayMs),     // 保证了每个方块的动画总时间是相同的，否则在重复模式和反转模式中动画会不协调
      ],
    );
  }
```

3. Stub

Stub 不是 AnimatorSet 的属性，是 Animator 的子类，也是经常使用的一个类。Stub 的设计思路来自于 android 的 ViewStub。
它实际上是个占位符，在动画真正要执行到 Stub 时，才会调用 Builder 函数，映射为真正的 Animator。比如我们要设计这样的功能:
当悬浮按钮的按下次数是奇数次时，图案向右平移，否则向下平移。此时我们就可以使用 Stub ——

```dart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [ _buildSquare(), SizedBox(width: 10), _buildSquare(), SizedBox(width: 10), _buildSquare() ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() { _pressCount ++; });
        },
        tooltip: 'Start The Animation !',
        child: Icon(Icons.send),
      ),
    );
  }


  int _pressCount = 0;


  Widget _buildSquare() {
    return AnimatorSet(
      child: SizedBox(
        width: 30,
        height: 20,
        child: ColoredBox(color: Colors.green[400]),
      ),
      animatorSet: [
        Stub(
          duration: 500,
          builder: () {
            if ((_pressCount & 1) == 1) {
              return TX(from: 0, to: 50);
            }
            else {
              return TY(from: 0, to: 50);
            }
          },
        ),
      ],
    );
  }
```

需要注意的是，为了防止递归调用，Stub 不允许返回另一个 Stub 对象。而且映射出的 Animator 对象的 duration 属性会被 Stub
的 duration 属性覆盖掉。Stub 的 builder 函数允许返回 null，此时不会有任何动画效果，和 Delay 效果相同。

#### 原理分析

AnimatorSet 提供了 "状态式" 的动画实现方式，那它的内部实现是怎样的呢? 我们现在就来分析下。

```dart

class AnimatorSet extends StatefulWidget {
  // ... 省略部分代码 ...
  @override
  State<StatefulWidget> createState() {
    return AnimatorSetState();
  }
}
```

AnimatorSet 本质上是个 StatefulWidget，这也保证了它能够直接将子 widget 包装起来。然后找到 AnimatorSetState 类的 build() 函数——

```dart
@override
  Widget build(BuildContext context) {
    _initAnimation();
    _startAnimation();

    return AnimatedBuilder(
      animation: _controller,
      builder:_buildAnimatedWidget,
    );
  }
```

果不其然，用的是 AnimatedBuilder()。这个类接受两个参数，第一个是 AnimationController 类型，本质上是个从 0 到 1 的计时器；
builder 参数负责真正构造 widget 对象。在动画开始后的每一帧，builder 函数都会被调用。

```dart
void _initAnimation() {
    if (_controller == null) {
      _controller = AnimationController(vsync: this)
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
          }
        });
    }

    _duration = 0;
    widget.animatorSet.forEach((element) {
      _duration += element.duration ?? 0;
    });

    _controller.duration = Duration(milliseconds: _duration);

    _allocTimeSlice();
  }
```

_initAnimation() 函数的作用主要是设置必要的监听器，然后遍历了传进来的 Animator 数组，将各自的时间相加，设置给 _controller。
随后调用了 _allocTimeSlice() 函数，直译过来就是 "分配时间片"。

```dart
final List<_AnimatorTimeSlice> _waitingList = [];
final _AnimatorOption _options = _AnimatorOption();

  void _allocTimeSlice() {
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
  }
```

这个函数的作用正如其名，"分配时间片"。实际上是遍历了每个 Animator 对象，统计了其各自的开始时间，结束时间，抽象出通用的
结构 _AnimatorTimeSlice 并添加进了一个列表 _waitingList。_waitingList 保存了所有需要调度的动画片段。

我们知道 AnimationController 只会产生 0 到 1 之间的数，将每个 Animator 的 duration 除以总的 duration，得到的就是
占据时间片的比例。比如下面这个动画列表——

```dart
List<Animator> list = [
  TX(from: 0, to: 50, duration: 100),
  TY(from: 0, to: 100, duration: 200),
  TX(from: 0, to: 200, duration: 200),
];
```

其动画总时间是 `100 + 200 + 200 = 500 ms`，第一个 TX 占用 0 - 100 毫秒的时间，映射到 500 毫秒的范围上就是 
[0 / 500 = 0, 0 + 100 / 500 = 0.2]。也就是说，当 AnimationController 产生的值在 [0, 0.2] 范围上时，这个 TX
正在播放。同理，第二个是 TY，其映射后的范围是 [0.2, 0.2 + 200 / 500 = 0.6]，也就是在 [0.2, 0.6] 范围上时，
TY 正在播放，[0.6, 1.0] 时，第三个动画正在播放。由此就确定了动画播放的整条时间线。

然后我们再来看一下这些时间片是怎么被调度的。具体代码在 _buildAnimatedWidget() 里——

```dart
Widget _buildAnimatedWidget(BuildContext context, Widget _) {
    final double now = _controller.value;
    final Widget child = widget.child;

    if (widget.enabled) {
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
```
这个逻辑就很简单了，先拿到 AnimationController 当前的值，然后遍历等待队列，如果当前时间大于该时间片的开始时间，那就要
"唤醒" 该时间片，并从等待队列中移除。需要注意的是对 reverse 过程的处理，是根据结束时间而不是开始时间判断的。

```dart
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
      // ... 省略部分代码 ...
    }
  }
```

_wakeUp() 函数比较长，对 Animator 的各个子类都有处理。对于常见的 TX，TY，SX，SY，O 等，就是将时间片(_AnimatorTimeSlice)
上记录的 "开始时间"，"结束时间"，映射到 Animator 的 from 和 to 参数。还是拿上面的例子，三个时间片，分别是 [0, 0.2], 
[0.2, 0.6], [0.6, 1.0]。假如现在的 AnimationController 值为 0.3，0.3 落在第二个时间片的范围，因此执行第二个动画。
第二个动画的 from 为 0，to 为 100，那么映射后应该是 `(现在的 Controller 的值 - 时间片的左边界) / (时间片的右边界 - 
时间片的左边界) * (to - from) + from 参数`，代入后 (0.3 - 0.2) / (0.6 - 0.2) * (100 - 0) + 0 = 25，也就是此时，
平移的距离为 25。同理，在 AniamtionController 的值为 0.6 时，计算 (0.6 - 0.2) / (0.6 - 0.2) * (100 - 0) = 100，
平移的距离刚好是 to 的值，之后此动画结束，开始调度下一个时间片。

比较特殊的是 Serial 和 Stub 这两个类。这两个类有其各自的处理逻辑，并向等待队列 _waitingList 中插入了若干新的 Animator。
Serial 的每个子 Animator 都共享相同的时间片，对应 Serial 的 duration 属性。Stub 也是如此。

```dart
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
```

这个 build() 函数就是收集各个 Animator 的处理结果，并完成真正的 "平移"，"旋转"，"缩放" 等操作。但这里的 Opacity 是
一处很严重的性能缺陷。你能改进它吗?


#### 总结

至此，对于 Flutter 平台上 flutter_animation_set 框架的使用说明和原理分析就要结束了。从最后的原理部分可以看出，Flutter 
平台上的动画也没有啥特殊的，控制器产生 [0, 1] 上的值，插值器 (Curve) 确定函数曲线，然后根据这个值不断调整 Widget，
由此产生动画效果。


