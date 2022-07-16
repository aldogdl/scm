import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entity/contacts_entity.dart';
import '../entity/orden_entity.dart';
import '../providers/process_provider.dart';
import '../services/my_utils.dart';
import '../widgets/texto.dart';

class TileTargetOrden extends StatefulWidget {

  final OrdenEntity orden;
  const TileTargetOrden({
    Key? key,
    required this.orden
  }) : super(key: key);

  @override
  State<TileTargetOrden> createState() => _TileTargetOrdenState();
}

class _TileTargetOrdenState extends State<TileTargetOrden> {

  final ScrollController _ctrScrollMain = ScrollController();

  @override
  void dispose() {
    _ctrScrollMain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final f = MyUtils.getFecha(fecha: widget.orden.createdAt);

    return Scrollbar(
      controller: _ctrScrollMain,
      thumbVisibility: true,
      radius: const Radius.circular(3),
      trackVisibility: true,
      child: ListView(
        controller: _ctrScrollMain,
        children: [
          Align(
            alignment: Alignment.center,
            child: Texto(
              txt: 'Día de Solicitud:    ${f['completa']}',
            ),
          ),
          const SizedBox(height: 10),
          Texto(
            txt: 'ID de la Orden en Proceso: ${widget.orden.id}',
            txtC: Colors.white.withOpacity(0.8),
            isBold: false, isCenter: true,
            sz: 16,
          ),
          Divider(color: Colors.grey.withOpacity(0.4)),
          Container(
            padding: const EdgeInsets.all(10),
            child: _data(context.read<ProcessProvider>().enProceso.remiter),
          )
        ],
      )
    );
  }

  ///
  Widget _data(ContactEntity remit) {

    return Column(
      children: [
        _row(1, label: 'Un auto Marca:', value: widget.orden.marca),
        _row(2, label: 'Modelo:', value: widget.orden.modelo),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _row(1, label: 'Año:', value: '${widget.orden.anio}'),
            ),
            Expanded(
              flex: 2,
              child: _row(1, label: '', value: (widget.orden.isNac) ? 'NACIONAL' : 'IMPORTADO'),
            )
          ],
        ),
        _row(2, label: 'Biene de:', value: remit.nombre),
        _row(1, label: 'Celular:', value: remit.celular),
        _row(2, label: 'Cargo:', value: remit.cargo),
        _row(1, label: 'Empresa:', value: remit.empresa),
      ],
    );
  }

  ///
  Widget _row(int index, {
    required String label,
    required String value,
  }) {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(color: Colors.blueGrey)
        ),
        color: (index.isOdd)
        ? Colors.black.withOpacity(0.3)
        : Colors.transparent
      ),
      child: Row(
        children: [
          Texto(
            txt: label,
            txtC: const Color.fromARGB(255, 32, 32, 32),
            isBold: true, isCenter: true,
            sz: 16,
          ),
          const Spacer(),
          Texto(
            txt: value,
            txtC: Colors.white.withOpacity(0.8),
            isBold: false, isCenter: true,
            sz: 16,
          ),
        ],
      ),
    );
  }
}