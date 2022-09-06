import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'views/check_status.dart';
import 'views/open_browser.dart';
import 'views/open_whastapp.dart';
import 'views/scm_title.dart';
import '../layout_page.dart';
import '../../vars/scroll_config.dart';

class ConnectView extends StatefulWidget {

  final int page;
  final ValueChanged<void> onClose;

  const ConnectView({
    Key? key,
    required this.page,
    required this.onClose
  }) : super(key: key);

  @override
  State<ConnectView> createState() => _ConnectViewState();
}

class _ConnectViewState extends State<ConnectView> {
  
  final _ctrPage = PageController();

  bool _isInit = false;

  @override
  void dispose() {
    _ctrPage.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_initWidget);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    if (!_isInit) {
      _isInit = true;
    }

    return LayoutPage(
      child: Container(
        width: appWindow.size.width,
        height: appWindow.size.height,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ScmTitle(onClose: (_) => widget.onClose(null)),
            Expanded(
              child: _pagesViewer(),
            ),
          ],
        )
      ),
    );
  }

  ///
  Widget _pagesViewer() {

    return Container(
      constraints: BoxConstraints.expand(
        height: appWindow.size.height * 0.73
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withOpacity(0.1),
        border: Border.all(
          color: Colors.grey.withOpacity(0.4)
        )
      ),
      child: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: PageView(
          controller: _ctrPage,
          children: [
            OpenBrowser(
              onNext: (_) {
                _ctrPage.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn
                );
              }
            ),
            OpenWhastapp(
              onNext: (_) {
                _ctrPage.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn
                );
              }
            ),
            CheckStatus(
              onNext: (_){}
            )
          ],
        ),
      ),
    );
  }

  ///
  Future<void> _initWidget(_) async {
    
    if(widget.page != 0) {
      _ctrPage.jumpToPage(widget.page);
    }
  }

}