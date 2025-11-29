import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import '../dashboard_page.dart';
import '../profile_page.dart';

import '../admin_request_details_page.dart';

String formatDate(dynamic d) {
  if (d == null) return "-";
  try {
    return DateFormat("MMM dd, yyyy").format(DateTime.parse(d.toString()));
  } catch (e) {
    return "-";
  }
}

class RegistrarApprovalsPage extends StatefulWidget {
  const RegistrarApprovalsPage({super.key});

  @override
  State<RegistrarApprovalsPage> createState() => _RegistrarApprovalsPageState();
}

class _RegistrarApprovalsPageState extends State<RegistrarApprovalsPage> {
  int selectedIndex = 1;
  final department = "Registrar";

  String selectedYear = "2025–2026";
  String selectedSemester = "First Semester";

  Future<Map<String, dynamic>>? requestsFuture;

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  void loadRequests() {
    requestsFuture = ApiService.getDepartmentRequests(department);
    setState(() {});
  }

  Future<void> updateStatus(String id, String status) async {
    final res = await ApiService.updateClearanceStatus(id, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Status updated → $status"))
    );
    loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    bool mobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      drawer: mobile ? sidebar() : null,
      body: Row(children: [
        if (!mobile) sidebar(),
        Expanded(child: SafeArea(child: buildContent())),
      ]),
    );
  }

  // ============================= SIDEBAR =============================
  Widget sidebar(){
    return Container(
      width:260, color:const Color(0xFFF9F9F9),
      child:Column(children:[
        const SizedBox(height:30),
        Image.asset("assets/sdca_logo.png",width:50),
        const SizedBox(height:10),
        const Text("Admin\nAcademic Clearance",
            style:TextStyle(fontWeight:FontWeight.bold,fontSize:15),
            textAlign:TextAlign.center),
        const SizedBox(height:30),

        menu(Icons.dashboard,"Dashboard",0),
        menu(Icons.fact_check,"Approvals",1),
        menu(Icons.person,"Profile",2),

        const Spacer(),
        Padding(
          padding:const EdgeInsets.all(12),
          child:OutlinedButton.icon(
            onPressed:()=>Navigator.pushNamedAndRemoveUntil(context,"/login",(r)=>false),
            icon:const Icon(Icons.logout),
            label:const Text("Logout"),
          ),
        )
      ]),
    );
  }

  Widget menu(IconData i,String t,int index){
    final active=index==selectedIndex;
    return InkWell(
      onTap:(){
        setState(()=>selectedIndex=index);
        if(index==0) Navigator.push(context,MaterialPageRoute(builder:(_)=>const AdminDashboardPage()));
        if(index==2) Navigator.push(context,MaterialPageRoute(builder:(_)=>const AdminProfilePage()));
      },
      child:Container(
        padding:const EdgeInsets.symmetric(vertical:14,horizontal:20),
        color:active?Colors.grey.shade200:null,
        child:Row(children:[Icon(i),SizedBox(width:10),Text(t)])
      ),
    );
  }

  // ============================= CONTENT =============================
  Widget buildContent(){
    return SingleChildScrollView(
      padding:const EdgeInsets.all(30),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text("Approvals",style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),
        const Text("Registrar Review Clearance Requests",style:TextStyle(color:Colors.black54)),
        const SizedBox(height:30),

        counters(),
        const SizedBox(height:30),

        Row(children:[yearDrop(),const SizedBox(width:20),semDrop()]),
        const SizedBox(height:25),

        requestList()
      ]),
    );
  }

  // ============================= COUNTERS =============================
  Widget counters(){
    return FutureBuilder(
      future:requestsFuture,
      builder:(c,s){
        final List all = s.hasData && s.data?["data"] is List ? s.data!["data"] : [];

        final filtered = all.where((e)=>
          e["academic_year"]==selectedYear && e["semester"]==selectedSemester
        ).toList();

        return Row(children:[
          stat("Total","${filtered.length}"),
          const SizedBox(width:20),
          stat("Pending","${filtered.where((e)=>e["status"]=="Pending").length}",color:Colors.orange),
          const SizedBox(width:20),
          stat("Approved","${filtered.where((e)=>e["status"]=="Approved").length}",color:Colors.green),
          const SizedBox(width:20),
          stat("Rejected","${filtered.where((e)=>e["status"]=="Rejected").length}",color:Colors.red),
        ]);
      },
    );
  }

  // ============================= REQUEST LIST =============================
  Widget requestList(){
    return FutureBuilder(
      future:requestsFuture,
      builder:(c,s){
        final List all=s.hasData&&s.data?["data"] is List?s.data!["data"]:[];
        final filtered=all.where((e)=>
          e["academic_year"]==selectedYear && e["semester"]==selectedSemester).toList();

        if(filtered.isEmpty) return Padding(
          padding:const EdgeInsets.all(30),
          child:Text("No Requests Found",style:TextStyle(color:Colors.black54)),
        );

        return Column(
          children:filtered.map((e)=>card(e)).toList()
        );
      },
    );
  }

  // ============================= CARD VIEW =============================
  Widget card(r){
    return Container(
      padding:const EdgeInsets.all(20),
      margin:const EdgeInsets.only(bottom:20),
      decoration:box(),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[

        Row(children:[
          const Icon(Icons.person),SizedBox(width:8),
          Text("Faculty: ${r["faculty_id"]}",style:TextStyle(fontWeight:FontWeight.bold)),
          Spacer(),
          Chip(label:Text(r["status"]),backgroundColor:status(r).withOpacity(.2),labelStyle:TextStyle(color:status(r)))
        ]),

        Text("Year: ${r["academic_year"]}"),
        Text("Semester: ${r["semester"]}"),
        Text("Submitted: ${formatDate(r["submitted_on"])}"),
        const SizedBox(height:15),

        Row(children:[

          if(r["status"]=="No Status")
            ElevatedButton(
              onPressed:()=>updateStatus(r["_id"],"Pending"),
              child:const Text("Pend"),style:btn(Colors.orange)
            ),

          if(r["status"]=="Pending")...[

            ElevatedButton(onPressed:()=>updateStatus(r["_id"],"Approved"),
              child:const Text("Approve"),style:btn(Colors.green)),
            const SizedBox(width:10),

            ElevatedButton(onPressed:()=>updateStatus(r["_id"],"Rejected"),
              child:const Text("Reject"),style:btn(Colors.red)),
            const SizedBox(width:10),

            OutlinedButton(
              onPressed:(){
                Navigator.push(
                  context,MaterialPageRoute(
                    builder:(_)=>AdminRequestDetailsPage(requestId:r["_id"])
                  )
                );
              },
              child:const Text("View Details"),
            ),
          ],

          if(r["status"]=="Approved"||r["status"]=="Rejected")
            OutlinedButton(
              onPressed:(){
                Navigator.push(
                  context,MaterialPageRoute(
                    builder:(_)=>AdminRequestDetailsPage(requestId:r["_id"])
                  )
                );
              },
              child:const Text("View Details"),
            ),
        ])
      ]),
    );
  }



  // ============================= UI HELPERS =============================
  Widget stat(String t,String n,{Color color=Colors.black})=>
    Expanded(child:Container(
      padding:const EdgeInsets.all(20), decoration:box(),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(t,style:const TextStyle(color:Colors.black54)),
        Text(n,style:TextStyle(fontWeight:FontWeight.bold,fontSize:22,color:color))
      ]),
    ));

  Widget yearDrop()=>dropdown(selectedYear,["2023–2024", "2024–2025", "2025–2026"],(v)=>setState(()=>selectedYear=v));
  Widget semDrop()=>dropdown(selectedSemester,["First Semester","Second Semester"],(v)=>setState(()=>selectedSemester=v));

  Widget dropdown(String value,List items,Function pick)=>Container(
    padding:const EdgeInsets.symmetric(horizontal:16),
    decoration:box(),
    child:DropdownButtonHideUnderline(
      child:DropdownButton(
        value:value,
        items:items.map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),
        onChanged:(v)=>pick(v),
      ),
    ),
  );

  BoxDecoration box()=>BoxDecoration(
    color:Colors.white,borderRadius:BorderRadius.circular(12),
    boxShadow:[BoxShadow(color:Colors.black12,blurRadius:8,offset:Offset(0,2))]
  );

  ButtonStyle btn(Color c)=>ElevatedButton.styleFrom(backgroundColor:c);

  Color status(r)=> r["status"]=="Approved"?Colors.green:
                    r["status"]=="Rejected"?Colors.red:
                    r["status"]=="Pending"?Colors.orange:Colors.blue;
}
