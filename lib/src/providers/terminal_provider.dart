import 'package:flutter/foundation.dart' show ChangeNotifier;

class TerminalProvider extends ChangeNotifier {

  final int _maxWid = 32;

  bool _terminalIsMini = true;
  bool get terminalIsMini => _terminalIsMini;
  set terminalIsMini(bool isMini) {
    _terminalIsMini = isMini;
    notifyListeners();
  }
  
  /// Usado para ver cuantas revisiones ha hecho al servidor remoto
  List<String> _taskTerminal = [];
  List<String> get taskTerminal => _taskTerminal;
  set taskTerminal(List<String> tasks){
    _taskTerminal = tasks;
    notifyListeners();
  }
  ///
  void _inT(String task) {
    var tmp = List<String>.from(_taskTerminal);
    task = task.trim();
    if(task.isNotEmpty) {
      tmp.insert(0, task);
    }
    taskTerminal = List<String>.from(tmp);
    tmp = [];
  }

  ///
  void addTask(String task)=> _inT('> $task');
  void addOk(String task)  => _inT('√ $task');
  void addErr(String task) => _inT('X $task');
  void addWar(String task) => _inT('! $task');

  ///
  void addNewReceiver(String curc) {
    int cant = _maxWid - curc.length;
    _inT(curc.padLeft(cant, '~'));
  }

  ///
  void addDiv({String s = '*'}) {
    _inT(s.padLeft(_maxWid, s));
  }

  void clean() {
    _taskTerminal  = [];
    _terminalIsMini = true;
  }

}