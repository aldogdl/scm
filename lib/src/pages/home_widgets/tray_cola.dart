import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/get_content_files.dart';
import '../../providers/process_provider.dart';
import '../../services/my_utils.dart';
import '../../vars/scroll_config.dart';
import '../../widgets/texto.dart';
import '../../widgets/my_tool_tip.dart';
import '../../widgets/sin_data.dart';

class TrayCola extends StatefulWidget {
  const TrayCola({Key? key}) : super(key: key);

  @override
  State<TrayCola> createState() => _TrayColaState();
}

class _TrayColaState extends State<TrayCola> {

  final ScrollController _ctrScrollMain = ScrollController();
  late final ProcessProvider _proc;

  bool _isInit = false;
  List<Map<String, dynamic>> _lstCamps = [];
  late Future _getTray;

  @override
  void initState() {
    _getTray = _recuperarTray();
    super.initState();
  }

  @override
  void dispose() {
    _ctrScrollMain.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _getTray,
      builder: (_, AsyncSnapshot snap) {

        if(snap.connectionState == ConnectionState.done) {
          if(_lstCamps.isNotEmpty) {
            return _buildLstCampaings();
          }
        }

        return const SinData(
          msg: '', main: 'NADA EN LA BANDEJA',
          withTit: false,
        );
      }
    );
  }

  ///
  Widget _buildLstCampaings() {

    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: Scrollbar(

        controller: _ctrScrollMain,
        thumbVisibility: true,
        radius: const Radius.circular(3),
        trackVisibility: true,
        child: Selector<ProcessProvider, bool>(
          selector: (_, provi) => provi.verColaMini,
          builder: (_, tipoLst, __) {

            return _base(
              bg: (tipoLst) ? Colors.black : Colors.grey,
              child: ListView.builder(
                padding: const EdgeInsets.only(right: 15),
                controller: _ctrScrollMain,
                itemCount: _lstCamps.length,
                itemBuilder: (_, int index) {
                  return (tipoLst)
                    ? _tipoTerminal(_lstCamps[index])
                    : _tileCampaing(_lstCamps[index]);
                }
              )
            );
          },
        )
      )
    );
  }
  
  ///
  Widget _base({required Widget child, Color bg = Colors.grey}) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(3),
      constraints: BoxConstraints.expand(
        width: appWindow.size.width
      ),
      decoration: BoxDecoration(color: bg),
      child: child
    );
  }

  ///
  Widget _tipoTerminal(Map<String, dynamic> camp) {

    final f = _extractFecha(camp['createdAt']);
    String empresa = camp['emiter']['empresa'].toUpperCase();

    if(empresa.length > 20) {
      empresa = empresa.substring(0, 20);
      empresa = '$empresa...';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: MyToolTip(
        msg: '${camp['campaing']['titulo']}  ${camp['emiter']['empresa'].toUpperCase()} ',
        child: Text(
          '> ${f['tiempo']} [${camp['sended'].length}-${camp['toSend'].length}] $empresa',
          textScaleFactor: 1,
          style: GoogleFonts.inconsolata(
            fontSize: 14,
            color: (camp['id'] == _proc.enProceso.id)
              ? Colors.amber : Colors.grey,
          ),
        ),
      )
    );
  }

  ///
  Widget _tileCampaing(Map<String, dynamic> camp) {

    return Container(
      width: appWindow.size.width,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: const Color.fromARGB(255, 92, 120, 134))
      ),
      child: Row(
        children: [
          _avatar(camp['id']),
          Expanded(
            child: _dataCamp(camp),
          ),
        ],
      ),
    );
  }

  ///
  Widget _avatar(int idCamp) {

    return Column(
      children: [
        Container(
          width: 45, height: 38,
          decoration: BoxDecoration(
            color: (idCamp != _proc.enProceso.id)
            ? const Color.fromARGB(255, 135, 136, 184)
            : const Color.fromARGB(255, 90, 91, 124),
            border: const Border(
              right: BorderSide(color: Color.fromARGB(255, 76, 99, 110))
            )
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                top: 0,
                child: Icon(
                  Icons.email, size: 30, color: Color.fromARGB(255, 150, 207, 235),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 2
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 79, 93, 133),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Texto(
                    txt: '$idCamp', txtC: Colors.white, sz: 10,
                  ),
                )
              )
            ],
          )
        )
      ],
    );
  }

  ///
  Widget _dataCamp(Map<String, dynamic> camp) {

    final f = _extractFecha(camp['createdAt']);
    String empresa = camp['emiter']['empresa'].toUpperCase();
    if(empresa.length > 25) {
      empresa = empresa.substring(0, 25);
      empresa = '$empresa...';
    }
    int cut = 15;
    if(camp['id'] > 9999) {
      cut = 10;
    }
    String campaing = camp['campaing']['titulo'];
    if(campaing.length > cut) {
      campaing = campaing.substring(0, cut);
      campaing = '$campaing...';
    }
    final sended = camp['toSend'].length - camp['noSend'].length;
    
    return Container(
      height: 38,
      padding: const EdgeInsets.only(
        left: 5, right: 5
      ),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Color.fromARGB(255, 195, 196, 207))
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Texto(
                  txt: empresa, sz: 13,
                  txtC: const Color.fromARGB(255, 60, 78, 87),
                  isBold: (camp['id'] != _proc.enProceso.id) ? false : true,
                ),
              ),
              Texto(
                txt: '$sended-${camp['toSend'].length}',
                sz: 11, txtC: const Color.fromARGB(255, 31, 40, 44),
                isBold: (camp['id'] == _proc.enProceso.id) ? true : false,
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 3),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              border: Border(
                top: BorderSide(color: Colors.black.withOpacity(0.3))
              )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Texto(
                  txt: f['tiempo'], sz: 11, isBold: true,
                  txtC: const Color.fromARGB(255, 37, 47, 53)
                ),
                const SizedBox(width: 8),
                Texto(
                  txt: campaing, sz: 13,
                  txtC: const Color.fromARGB(255, 37, 47, 53)
                ),
                const Spacer(),
                Texto(
                  txt: 'Prio.: ${camp['campaing']['priority']}', sz: 11.5,
                  txtC: const Color.fromARGB(255, 63, 67, 121)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  ///
  Map<String, dynamic> _extractFecha(dynamic fecha) {

    var date = DateTime.now();
    if(fecha.runtimeType == String) {
      date = DateTime.parse(fecha);
    }else{
      date = fecha['createdAt'];
    }
    return MyUtils.getFecha(fecha: date);
  }

  ///
  Future<void> _recuperarTray() async {

    if(!_isInit) {
      _isInit = true;
      _proc = context.read<ProcessProvider>();
    }
    if(_lstCamps.length != _proc.enTray) {
      _lstCamps = await GetContentFile.getAllCampaingsWithDataMini();
    }
  }

}