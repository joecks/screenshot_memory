import 'package:flutter/material.dart';

class LifecycleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback doOnResume;

  const LifecycleWidget({@required this.child, this.doOnResume, Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LifecycleWidgetState();
  }
}

class LifecycleWidgetState extends State<LifecycleWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (widget.doOnResume != null) widget.doOnResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}