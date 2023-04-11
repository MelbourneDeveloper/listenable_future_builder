# listenable_future_builder

![badge](https://github.com/MelbourneDeveloper/listenable_future_builder/actions/workflows/build_and_test.yml/badge.svg)

<a href="https://codecov.io/gh/melbournedeveloper/listenable_future_builder"><img src="https://codecov.io/gh/melbournedeveloper/listenable_future_builder/branch/main/graph/badge.svg" alt="codecov"></a>

## Introduction

We often use [`ChangeNotifier`](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) and [`ValueNotifier<>`](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) as controllers behind [`StatelessWidget`](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html)s. However, there are two issues:

- A vanilla `StatelessWidget` cannot hold onto the controller because it could rebuild and lose the state at any time.
- We sometimes need to do async work before we can use the controller.

`ListenableFutureBuilder` solves these issues by acting like a hybrid of [`AnimatedBuilder`](https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html) and [`FutureBuilder`](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html). 

Do this:

[Live Sample](https://dartpad.dev/?id=8ea8e0e52e26be59d4cb8c056de53617)

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

`ListenableFutureBuilder` works with any [`Listenable`](https://api.flutter.dev/flutter/foundation/Listenable-class.html), such as a `ChangeNotifier` or `ValueNotifier`. To use `ListenableFutureBuilder`, provide a `listenable` function that returns a `Future` of your `Listenable` controller and a `builder` function that defines how to build the widget depending on the state of the `AsyncSnapshot`. 

Here's an example of how to use `ListenableFutureBuilder` with a `ValueNotifier`. The `builder` function should check the state of the `AsyncSnapshot` to determine if the data is ready, an error occurred, or if it's still loading. We display a [`CircularProgressIndicator`](https://api.flutter.dev/flutter/material/CircularProgressIndicator-class.html) while waiting, show an error message if an error occurs, and display the value once it's available. 

Clicking the floating action button will pop up an input dialog, and if you enter a value, it will create a new list with the new item. The `ListView` will display all the items in the current list. 

[Live Sample](https://dartpad.dev/?id=8bb84e817cf5f1245eb25d1c52c7c217)

```dart
import 'package:flutter/material.dart';
import 'package:listenable_future_builder/listenable_future_builder.dart';

void main() => runApp(
      MaterialApp(
        theme: ThemeData(
            useMaterial3: true,
            primarySwatch: Colors.purple,
        ),
        debugShowCheckedModeBanner: false,
        home: ListenableFutureBuilder<ValueNotifier<List<String>>>(
          listenable: () => Future<ValueNotifier<List<String>>>.delayed(
              const Duration(seconds: 2),
              () => ValueNotifier<List<String>>([])),
          builder: (context, child, snapshot) => Scaffold(
            appBar: AppBar(title: const Text('To-do List')),
            body: snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data!.value.length,
                    itemBuilder: (context, index) =>
                        ListTile(title: Text(snapshot.data!.value[index])),
                  )
                : snapshot.hasError
                    ? const Text('Error')
                    : const CircularProgressIndicator.adaptive(),
            floatingActionButton: FloatingActionButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add a new to-do item'),
                  content: TextField(
                    onSubmitted: (value) {
                      Navigator.of(context).pop();
                      List<String> updatedList =
                          List<String>.from(snapshot.data!.value);
                      updatedList.add(value);
                      snapshot.data!.value = updatedList;
                    },
                  ),
                ),
              ),
              tooltip: 'Add a new item',
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
```

## Disposal

In some cases, you may need to perform cleanup operations when the `ListenableFutureBuilder` is disposed. This is necessary when listeners hold resources that need to be released when the widget is no longer in use. To handle disposal, provide a `disposeListenable` function. This function will be called with the `Listenable` instance when the `ListenableFutureBuilder` is disposed.

In this example, we create a custom `ChangeNotifier` class that manages a timer, and we use `ListenableFutureBuilder` to display the timer's current value. We also provide a `disposeListenable` function to stop the timer and clean up resources when the widget is no longer in use. The `disposeListenable` function stops the timer and releases the resources held by the `TimerNotifier` when the `ListenableFutureBuilder` is disposed. This helps to prevent resource leaks and ensure proper cleanup of the `Listenable`. This example is stateful so we can toggle the `_showListenableFutureBuilder` with the floating action button. Clicking this removes the `ListenableFutureBuilder` from the tree, which triggers the `disposeListenable` function.

[Live Sample](https://dartpad.dev/?id=bf318c5a7e87e0fa1ace796247d96620)

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
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.orange,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
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

## Custom Listenable

You may want to implement your own version of the `Listenable` class. This example displays random colors when you click the floating action button. We create a `ColorController` class that extends `Listenable`. This controller allows you to change the color of the `ColoredBox` widget by calling the `changeColor` method. The `ListenableFutureBuilder` is used to build the widget tree with the `ColorController`, and a `FloatingActionButton` is provided to change the color randomly. The `disposeListenable` function is called when the `ListenableFutureBuilder` is removed from the widget tree, and it disposes of the `ColorController`.

[Live Sample](https://dartpad.dev/?id=a98cd6da42144ea581b9ef45704dcbf2)

```dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:listenable_future_builder/listenable_future_builder.dart';

class ColorController extends Listenable {
  final List<VoidCallback> _listeners = [];

  Color _color = Colors.red;

  Color get color => _color;

  void changeColor(Color newColor) {
    _color = newColor;
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void dispose() {
    _listeners.clear();
  }
}

void main() => runApp(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.green,
        ),
        debugShowCheckedModeBanner: false,
        home: ListenableFutureBuilder<ColorController>(
          listenable: () => Future.delayed(
              const Duration(seconds: 2), () => ColorController()),
          builder: (context, child, snapshot) => Scaffold(
            body: Center(
              child: snapshot.hasData
                  ? ColoredBox(
                      color: snapshot.data!.color,
                      child: const SizedBox(width: 100, height: 100),
                    )
                  : snapshot.hasError
                      ? const Text('Error')
                      : const CircularProgressIndicator.adaptive(),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => snapshot.data?.changeColor(
                  Colors.primaries[Random().nextInt(Colors.primaries.length)]),
              tooltip: 'Change color',
              child: const Icon(Icons.color_lens),
            ),
          ),
          disposeListenable: (colorController) async =>
              colorController.dispose(),
        ),
      ),
    );
```

## Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue on GitHub. If you'd like to contribute code, feel free to fork the repository and submit a pull request.