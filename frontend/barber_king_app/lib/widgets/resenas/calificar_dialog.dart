import 'package:flutter/material.dart';
import '../../core/colors.dart';

class CalificarDialog extends StatefulWidget {
  const CalificarDialog({super.key});
  @override State<CalificarDialog> createState()=>_CalificarDialogState();
}
class _CalificarDialogState extends State<CalificarDialog>{
  int estrellas=5; final comentario=TextEditingController();
  @override void dispose(){comentario.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>AlertDialog(
    backgroundColor:AppColors.card,
    title:const Text('Calificar servicio',style:TextStyle(color:AppColors.white)),
    content:Column(mainAxisSize:MainAxisSize.min,children:[
      const Text('¿Cómo fue tu experiencia?',style:TextStyle(color:AppColors.subtitle)),
      const SizedBox(height:14),
      Row(mainAxisAlignment:MainAxisAlignment.center,children:List.generate(5,(i)=>IconButton(
        onPressed:()=>setState(()=>estrellas=i+1),
        icon:Icon(i<estrellas?Icons.star:Icons.star_border,color:AppColors.primary,size:32),)),),
      TextField(controller:comentario,maxLines:3,style:const TextStyle(color:AppColors.white),decoration:const InputDecoration(labelText:'Reseña (opcional)')),
    ]),
    actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancelar')),ElevatedButton(onPressed:()=>Navigator.pop(context,{'calificacion':estrellas,'comentario':comentario.text}),child:const Text('Publicar'))],
  );
}
