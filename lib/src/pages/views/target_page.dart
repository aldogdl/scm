import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scm/src/widgets/sin_data.dart';

import '../../entity/orden_entity.dart';
import '../../entity/proceso_entity.dart';
import '../../providers/process_provider.dart';
import '../../widgets/tile_target_orden.dart';

class TargetPage extends StatelessWidget {

  const TargetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _determinarWidget(
              context.read<ProcessProvider>().enProceso
            ),
          ),
        )
      ]
    );
  }

  ///
  Widget _determinarWidget(ProcesoEntity proc) {

    late Widget child;
    switch (proc.target) {
      case 'orden':
        child = TileTargetOrden(orden: OrdenEntity()..fromJson(proc.data));
        break;
      default:
        child = const SinData(
          msg: '', main: 'Campaña Seleccionada'
        );
    }
    return child;
  }

}