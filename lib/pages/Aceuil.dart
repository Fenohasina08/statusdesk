import 'package:flutter/material.dart';

class Aceuil extends StatefulWidget {
  const Aceuil({super.key});

  @override
  State<Aceuil> createState() => _AceuilState();
}

class _AceuilState extends State<Aceuil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body:SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 50, 10, 0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  
            children: [
              Text("Status Desk",style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold),),
              IconButton(onPressed: (){}, icon: Icon(Icons.refresh)),
            ],
           ),
           SizedBox(height: 5),
           Text("Tableau de bord en temps réel",style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal),),
           SizedBox(height: 20),
           Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            height: 150,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(onPressed: (){}, icon: Icon(Icons.check_circle,color: Colors.green,size: 40,)),
                    Text("Statut des services",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                    
                  ],
                ),
                Text("Les services sont en cours de maintenance",style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal),),
                SizedBox(height: 10),
              ],
            )
            
           ),
           Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
             Container(
              width: 200,
              height: 120,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text("Operationnel",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                  SizedBox(height: 10),
                  Text("85",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white),),
                ],
              ),
             ),
             Container(
              width: 200,
              height: 120,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text("Degradé",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                  SizedBox(height: 10),
                  Text("85",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white),),
                ],
              ),
             ),
             Container(
              width: 200,
              height: 120,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text("Indisponible",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                  SizedBox(height: 10),
                  Text("85",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white),),
                ],
              ),
             ),
             Container(
              width: 200,
              height: 120,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text("Maintenance",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                  SizedBox(height: 10),
                  Text("85",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white),),
                ],
              ),
             ),
            ],
           ),
           SizedBox(height: 20),
           Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle,color: Colors.green,size: 40,),
                    Text("Historique des incidents",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  ],
                ),
                
              ],
            ),
           ),
           Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle,color: Colors.green,size: 40,),
                    Text("Historique des incidents",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  ],
                ),
                SizedBox(height: 10),
                Text("Historique des incidents",style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal),),
                
              ],
            ),
           ),
          ],
        ),
      ),
     ) ,

    );
  }
}
