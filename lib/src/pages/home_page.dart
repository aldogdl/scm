import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:scm/src/pages/home_widgets/tray_cola.dart';

import 'layout_page.dart';
import 'home_widgets/await_cola.dart';
import 'home_widgets/send_to_receiver.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return LayoutPage(
      child: Container(
        constraints: BoxConstraints.expand(
          height: appWindow.size.height - 55
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  width: appWindow.size.width,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: const Color.fromARGB(255, 47, 180, 52),
                ),
                const SizedBox(height: 10),
                const Positioned(
                  child: SendToReceiver(),
                )
              ],
            ),
            Expanded(
              child: Column(
                children: const [
                  Expanded(
                    flex: 1,
                    child: AwaitCola(),
                  ),
                  Expanded(
                    flex: 1,
                    child: TrayCola(),
                  ),
                ],
              )
            )
          ],
        )
      )
    );
  }

}
