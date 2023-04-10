// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../service/handcuffInfo.dart';
// import '../../handcuff.dart';
//
// class HandcuffAdd extends StatefulWidget {
//   const HandcuffAdd({Key? key}) : super(key: key);
//
//   @override
//   State<HandcuffAdd> createState() => _HandcuffAddState();
// }
//
// class _HandcuffAddState extends State<HandcuffAdd> {
//   // late int numberOfRegisteredHandcuff;
//
//   @override
//   Widget build(BuildContext context) {
//     // numberOfRegisteredHandcuff = context.watch<HandcuffInfo>().numberOfRegisteredHandcuff;
//     //
//     // debugPrint("numberOfRegisteredHandcuff : $numberOfRegisteredHandcuff");
//
//     if (context.watch<HandcuffInfo>().handcuffs.isEmpty ) {
//       return SizedBox(
//         child: GestureDetector(
//           onTap: () {
//             Navigator.push(context, MaterialPageRoute(builder: (context) {
//               return const HandcuffScreen();
//             }));
//           },
//           child: Container(
//             padding: const EdgeInsets.all(0),
//             height: 60,
//             width: 60,
//             decoration: BoxDecoration(
//               color: const Color(0xff00e693),
//               borderRadius: BorderRadius.circular(50),
//             ),
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: const Icon(
//                 Icons.add,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ),
//       );
//     } else {
//       return const SizedBox(
//         height: 1,
//       );
//     }
//   }
// }
