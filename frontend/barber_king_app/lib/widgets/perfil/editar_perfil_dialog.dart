import 'package:flutter/material.dart';
class EditarPerfilDialog extends StatefulWidget {
  final String nombres, apellidos, telefono;
  const EditarPerfilDialog({super.key,required this.nombres,required this.apellidos,required this.telefono});
  @override State<EditarPerfilDialog> createState()=>_EditarPerfilDialogState();
}
class _EditarPerfilDialogState extends State<EditarPerfilDialog>{
  late final n=TextEditingController(text:widget.nombres),a=TextEditingController(text:widget.apellidos),t=TextEditingController(text:widget.telefono);
  @override void dispose(){n.dispose();a.dispose();t.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>AlertDialog(title:const Text('Editar perfil'),content:SingleChildScrollView(child:Column(children:[TextField(controller:n,decoration:const InputDecoration(labelText:'Nombres')),TextField(controller:a,decoration:const InputDecoration(labelText:'Apellidos')),TextField(controller:t,decoration:const InputDecoration(labelText:'Teléfono'))])),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancelar')),ElevatedButton(onPressed:()=>Navigator.pop(context,{'nombres':n.text,'apellidos':a.text,'telefono':t.text}),child:const Text('Guardar'))]);
}
