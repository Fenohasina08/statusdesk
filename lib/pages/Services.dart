import 'package:flutter/material.dart';

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Services", style: TextStyle(fontSize: 30)),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.refresh, color: Colors.black, size: 30),
                    ),
                  ],
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Rechercher",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 10,
                    children: [
                      TextButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {}, child: Text("Tous")),
                      TextButton(
                        onPressed: () {}, child: Text("Operationnel")),
                      TextButton(onPressed: () {}, child: Text("Degradé")),
                      TextButton(onPressed: () {}, child: Text("Indisponible")),
                      TextButton(onPressed: () {}, child: Text("Maintenance")),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle,color: Colors.green,size: 40,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Database",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                    Text("Opérationnel depuis 45 minutes",style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal),),
                  ],
                ),
                Spacer(),
                IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward_ios,color: Colors.black,size: 20,)),
              ],
            ),
           ),
           SizedBox(height:5,),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle,color: Colors.green,size: 40,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Database",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                    Text("Opérationnel depuis 45 minutes",style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal),),
                  ],
                ),
                Spacer(),
                IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward_ios,color: Colors.black,size: 20,)),
              ],
            ),
           ),
          
              ],
            ),
          ),
        ),
      ),
    );
  }
}
