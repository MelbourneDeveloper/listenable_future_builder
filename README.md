# listenable_future_builder

![badge](https://github.com/MelbourneDeveloper/listenable_future_builder/actions/workflows/build_and_test.yml/badge.svg)

<a href="https://codecov.io/gh/melbournedeveloper/listenable_future_builder"><img src="https://codecov.io/gh/melbournedeveloper/listenable_future_builder/branch/main/graph/badge.svg" alt="codecov"></a>

## Introduction

We often use [`ChangeNotifier`](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) and [`ValueNotifier<>`](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) as controllers behind `StatelessWidget`s. However, there are two issues:

- A vanilla `StatelessWidget` cannot hold onto the controller because it could rebuild and lose the state at any time.
- We sometimes need to do async work before we can use the controller.

`ListenableFutureBuilder` solves these issues by acting like a hybrid of [`AnimatedBuilder`](https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html) and [`FutureBuilder`](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html). 

Do this:

```dart
import 'package:flutter/material.dart';
import 'package:listenable_future_builder/listenable_future_builder.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: ListenableFutureBuilder<ValueNotifier<int>>(
        listenable: getController,
        builder: (context, child, snapshot) => Scaffold(
          appBar: AppBar(),
          body: Center(
              child: snapshot.hasData
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'You have pushed the button this many times:',
                        ),
                        Text(
                          '${snapshot.data!.value}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    )
                  : snapshot.hasError
                      ? const Text('Error')
                      : const CircularProgressIndicator.adaptive()),
          floatingActionButton: FloatingActionButton(
            onPressed: () => snapshot.data?.value++,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

Future<ValueNotifier<int>> getController() async =>
    Future.delayed(const Duration(seconds: 2), () => ValueNotifier<int>(0));
```

Instead of this:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ValueNotifier<int>? _controller;

  @override
  void initState() {
    super.initState();
    _getController();
  }

  Future<void> _getController() async {
    final controller = await getController();
    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _controller!.value++,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          body: _controller != null
              ? AnimatedBuilder(
                  animation: _controller!,
                  builder: (context, child) => Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'You have pushed the button this many times:',
                          ),
                          Text(
                            '${_controller!.value}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      )))
              : const CircularProgressIndicator.adaptive(),
        ),
        debugShowCheckedModeBanner: false,
      );
}

Future<ValueNotifier<int>> getController() async =>
    Future.delayed(const Duration(seconds: 2), () => ValueNotifier<int>(0));
```

Notice that the second version is far more verbose than the version with `ListenableFutureBuilder`. This is because `ListenableFutureBuilder` creates your controller for you on the first call and hangs onto the controller for the lifespan of the widget. That means you don't need to create a `StatefulWidget` / `State` pair to hold onto the controller.

## Getting Started

Add listenable_future_builder to your pubspec.yaml dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  listenable_future_builder: ^[CURRENT-VERSION]
```

Import the package in your Dart file:

```dart
import 'package:listenable_future_builder/listenable_future_builder.dart';
```

### Usage

`ListenableFutureBuilder` works with any [`Listenable'](https://api.flutter.dev/flutter/foundation/Listenable-class.html), such as a `ChangeNotifier` or `ValueNotifier`. To use `ListenableFutureBuilder`, provide a `listenable` function that returns a `Future` of your `Listenable` controller and a `builder` function that defines how to build the widget depending on the state of the `AsyncSnapshot`. Here's an example of how to use `ListenableFutureBuilder` with a `ValueNotifier`:

```dart
ListenableFutureBuilder<ValueNotifier<int>>(
  listenable: getController,
  builder: (context, child, snapshot) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: snapshot.hasData
        ? Text('${snapshot.data!.value}')
        : snapshot.hasError
            ? const Text('Error')
            : const CircularProgressIndicator.adaptive(),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => snapshot.data?.value++,
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    ),
  ),
)

Future<ValueNotifier<int>> getController() async =>
    Future.delayed(const Duration(seconds: 2), () => ValueNotifier<int>(0));
```

The `builder` function should check the state of the `AsyncSnapshot` to determine if the data is ready, an error occurred, or if it's still loading. In this example, we display a [`CircularProgressIndicator`](https://api.flutter.dev/flutter/material/CircularProgressIndicator-class.html) while waiting, show an error message if an error occurs, and display the value once it's available.

### Disposal

In some cases, you may need to perform cleanup operations when the `ListenableFutureBuilder` is disposed. This is necessary when listeners hold resources that need to be released when the widget is no longer in use. To handle disposal, provide a `disposeListenable` function. This function will be called with the `Listenable` instance when the `ListenableFutureBuilder` is disposed.

In this example, we create a custom `ChangeNotifier` class that manages a timer, and we use `ListenableFutureBuilder` to display the timer's current value. We also provide a `disposeListenable` function to stop the timer and clean up resources when the widget is no longer in use. The `disposeListenable` function stops the timer and releases the resources held by the `TimerNotifier` when the `ListenableFutureBuilder` is disposed. This helps to prevent resource leaks and ensure proper cleanup of the `Listenable`. This example is stateful so we can toggle the `_showListenableFutureBuilder` with the floating action button. Clicking this removes the `ListenableFutureBuilder` from the tree, which triggers the `disposeListenable` function.


``` dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:listenable_future_builder/listenable_future_builder.dart';

class TimerNotifier extends ChangeNotifier {
  Timer? _timer;
  int _seconds = 0;

  TimerNotifier() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      notifyListeners();
    });
  }

  int get seconds => _seconds;

  void disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showListenableFutureBuilder = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: _showListenableFutureBuilder
            ? ListenableFutureBuilder<TimerNotifier>(
                listenable: getTimerNotifier,
                builder: (context, child, snapshot) => snapshot.hasData
                    ? Text('Elapsed seconds: ${snapshot.data!.seconds}')
                    : snapshot.hasError
                        ? const Text('Error')
                        : const CircularProgressIndicator.adaptive(),
                disposeListenable: (timerNotifier) async =>
                    timerNotifier.disposeTimer(),
              )
            : const Text('ListenableFutureBuilder removed.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(
          () => _showListenableFutureBuilder = !_showListenableFutureBuilder,
        ),
        tooltip: 'Toggle ListenableFutureBuilder',
        child: const Icon(Icons.toggle_on),
      ),
    );
  }
}

Future<TimerNotifier> getTimerNotifier() async {
  await Future.delayed(const Duration(seconds: 2));
  return TimerNotifier();
}
```



Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue on GitHub. If you'd like to contribute code, feel free to fork the repository and submit a pull request.