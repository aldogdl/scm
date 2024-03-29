import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'views/msg_current.dart';
import 'views/config_page.dart';
import 'views/await_page.dart';
import 'views/sended_page.dart';
import 'views/papelera_page.dart';
import 'views/target_page.dart';
import '../config/sng_manager.dart';
import '../vars/globals.dart';
import '../widgets/tools_barr.dart';

final Globals _globals = getSngOf<Globals>();

class LayoutPage extends StatelessWidget {

  final Widget child;
  const LayoutPage({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: WindowBorder(
        color: _globals.borderColor,
        width: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Row(
                children: [
                  const LeftSide(),
                  RightSide(child: child)
                ]
              ),
            ),
          ],
        )
      )
    );
  }
}


class LeftSide extends StatelessWidget {

  const LeftSide({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 50,
      child: Container(
        color: _globals.sidebarColor,
        child: Column(
          children: [
            WindowTitleBarBox(
              child: MoveWindow(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'SCM ',
                      textScaleFactor: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14
                      ),
                    ),
                  ],
                ),
              )
            ),
            Expanded(
              child: ToolsBarr(
                onTap: (String view) => _verModal(context, view) 
              )
            ),
          ],
        )
      )
    );
  }

  ///
  void _verModal(BuildContext context, String view) async {

    await showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
      barrierColor: Colors.black.withOpacity(0.2),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: appWindow.size.height * 0.62,
        minWidth: appWindow.size.width
      ),
      context: context,
      builder: (context) => _showView(view)
    );
  }

  ///
  Widget _showView(String view) {
    
    late Widget child;
    switch (view) {
      case 'msg':
        child = const MsgCurrent();
        break;
      case 'targets':
        child = const TargetPage();
        break;
      case 'espera':
        child = const AwaitPage();
        break;
      case 'enviados':
        child = const SendedPage();
        break;
      case 'papelera':
        child = const PapeleraPage();
        break;
      default:
        child = const ConfigPage();
    }
    
    return GlassContainer.frostedGlass(
      height: appWindow.size.height * 0.62,
      width: appWindow.size.width,
      frostedOpacity: 0.1,
      blur: 5,
      child: child
    );
  }
}


class RightSide extends StatelessWidget {

  final Widget child;
  const RightSide({
    Key? key,
    required this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String modo = (_globals.env == 'dev')
      ? _globals.env.toUpperCase() : '';

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _globals.backgroundStartColor,
              _globals.backgroundEndColor
            ],
            stops: const [0.0, 1.0]
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            WindowTitleBarBox(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: MoveWindow(
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Text(
                          '$modo ',
                          textScaleFactor: 1,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11
                          ),
                        ),
                        Text(
                          '| Ver.: ${_globals.ver}',
                          textScaleFactor: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 11
                          ),
                        ),
                      ],
                    ),
                  )),
                  const WindowButtons()
                ]
              )
            ),
            Expanded(child: child),
          ]
        )
      )
    );
  }
}

class WindowButtons extends StatelessWidget {

  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Row(
      children: [
        MinimizeWindowButton(colors: _globals.buttonColors),
        MaximizeWindowButton(colors: _globals.buttonColors),
        CloseWindowButton(colors: _globals.buttonColors),
      ],
    );
  }
}
