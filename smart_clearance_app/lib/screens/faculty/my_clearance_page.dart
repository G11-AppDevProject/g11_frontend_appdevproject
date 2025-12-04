import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'dashboard_page.dart';
import 'signatories_page.dart';
import 'profile_page.dart';

import 'package:smart_clearance_app/screens/faculty/faculty_request_details_page.dart';


class MyClearancePage extends StatefulWidget {
  const MyClearancePage({super.key});

  @override
  State<MyClearancePage> createState() => _MyClearancePageState();
}

class _MyClearancePageState extends State<MyClearancePage> {

  /// Remove auto refresh (lag fix)
  Future<Map<String, dynamic>>? clearanceFuture;

  String facultyId = "faculty123"; // change when login ready
  int selectedIndex = 1;

  String selectedYear = "2025–2026";
  String selectedSemester = "First Semester";

      final List<String> departments = const [
        "Registrar",
        "Accounting",
        "Dean",
        "Treasury",
        "Property Management Office",
        "Laboratory",
        "Clinic",
        "Library",
        "Human Resource Office",
        "Program Chair",
        "Office of the Vice President as Research",
        "ICT",
        "Community Extension Service Office",
      ];



  @override
  void initState() {
    super.initState();
    loadData(); // load 1 time only
  }

void loadData() async {
  final data = ApiService.getClearanceRequests(
  facultyId,
  year: selectedYear,
  semester: selectedSemester,
);


  if(!mounted) return;        // <- ensures page is still alive
  clearanceFuture = data;

  setState(() {});            // <- safe update
}



  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      bool mobile = c.maxWidth < 800;

      return Scaffold(
        drawer: mobile ? sidebar() : null,
        body: Row(
          children: [
            if (!mobile) sidebar(),
            Expanded(child: SafeArea(child: content())),
          ],
        ),
      );
    });
  }

  // ---------------- UI STRUCTURE ----------------

  Widget sidebar() {
    return Container(
      width: 260, color: const Color(0xFFF9F9F9),
      child: Column(children: [
        const SizedBox(height: 30),
        Row(mainAxisAlignment: MainAxisAlignment.center, children:[
          Image.asset("assets/sdca_logo.png",width:50),
          const SizedBox(width:10),
          const Text("Faculty\nAcademic Clearance",
            style: TextStyle(fontWeight: FontWeight.bold))
        ]),
        const SizedBox(height:30),

        menu(Icons.dashboard,"Dashboard",0,() => push(const DashboardPage())),
        menu(Icons.article,"My Clearance",1,(){ }),
        menu(Icons.account_tree,"Signatories",2,() => push(const SignatoriesPage())),
        menu(Icons.person,"Profile",3,() => push(const ProfilePage())),

        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(14),
          child: OutlinedButton.icon(
            onPressed: ()=>Navigator.pushNamedAndRemoveUntil(context,"/login",(r)=>false),
            icon:const Icon(Icons.logout), label:const Text("Logout"),
            style:OutlinedButton.styleFrom(minimumSize:const Size(double.infinity,45))
          ),
        )
      ]),
    );
  }

  Widget menu(IconData i,String t,int idx,VoidCallback go){
    bool active = selectedIndex==idx;
    return InkWell(
      onTap:(){ setState(()=>selectedIndex=idx); go(); },
      child:Container(
        padding:const EdgeInsets.symmetric(vertical:15,horizontal:20),
        color:active?const Color(0xFFEEEDED):Colors.transparent,
        child:Row(children:[
          Icon(i,color:Colors.black87), const SizedBox(width:12), Text(t)
        ]),
      ),
    );
  }

  void push(Widget p)=>Navigator.push(context,MaterialPageRoute(builder:(_)=>p));

  // ---------------- PAGE CONTENT ----------------

  Widget content(){
    return SingleChildScrollView(
      padding:const EdgeInsets.fromLTRB(30,10,30,30),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text("Clearance Requests",style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),
        const Text("Track and manage clearance requests",style:TextStyle(color:Colors.black54)),
        const SizedBox(height:30),

        counters(),
        const SizedBox(height:30),

        Row(children:[yearDrop(), const SizedBox(width:20), semDrop()]),
        const SizedBox(height:20),

        clearanceList(),
      ]),
    );
  }

  // ---------------- COUNTERS ----------------

  Widget counters(){
    return FutureBuilder(
      future: clearanceFuture,
      builder:(c,s){
        int total=0,p=0,a=0,r=0;

        if(s.hasData && s.data?["success"]==true){
          List list=s.data!["data"];
          total=list.length;
          p=list.where((x)=>x["status"]=="Pending").length;
          a=list.where((x)=>x["status"]=="Approved").length;
          r=list.where((x)=>x["status"]=="Rejected").length;
        }

        return Row(children:[
          stat("Total","$total"),
          const SizedBox(width:20),
          stat("Pending","$p",c:Colors.orange),
          const SizedBox(width:20),
          stat("Approved","$a",c:Colors.green),
          const SizedBox(width:20),
          stat("Rejected","$r",c:Colors.red),
        ]);
      });
  }

  // ---------------- LIST ----------------

  Widget clearanceList(){
    return FutureBuilder(
      future: clearanceFuture,
      builder:(c,s){
        Map<String,dynamic> latest={};

        if(s.hasData && s.data?["success"]==true){
          for(var r in s.data!["data"]) latest[r["department"]]=r;
        }

        return Column(
          children:departments.map((d){
            final data=latest[d];
            return card(
              dept:d,
              status:data?["status"]??"No Status",
              submitted:data?["submitted_on"],
              approved:data?["approved_on"],
              semester:data?["semester"],
              id:data?["_id"],
            );
          }).toList(),
        );
      });
  }

  // ---------------- CARD ----------------

  Widget card({required String dept,required String status,String? submitted,String? approved,String? semester,String? id}){

    // COLOR base
    Color c = status=="Approved"?Colors.green:
              status=="Rejected"?Colors.red:
              status=="Pending"?Colors.orange:
              Colors.blue;

    return Container(
      margin:const EdgeInsets.only(bottom:20),
      padding:const EdgeInsets.all(20),
      decoration:box(),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[
          const Icon(Icons.account_balance,color:Colors.blue),
          const SizedBox(width:10),
          Text(dept,style:const TextStyle(fontWeight:FontWeight.bold)),
          const Spacer(),
          Chip(label:Text(status),backgroundColor:c.withOpacity(.18),labelStyle:TextStyle(color:c))
        ]),

        if(submitted!=null) Text("Submitted: ${fmt(submitted)}"),
        if(approved!=null) Text("Approved: ${fmt(approved)}"),
        if(semester!=null) Text("Semester: $semester"),
        const SizedBox(height:15),

       // SEND REQUEST → hide if already sent
// SEND REQUEST BUTTON — only show if no real request exists
        if(status == "No Status" && submitted == null)
          ElevatedButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child:CircularProgressIndicator()),
              );

              final res = await ApiService.sendDepartmentRequest(
                facultyId: facultyId,
                department: dept,
                year: selectedYear,
                semester: selectedSemester,
              );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res["message"] ?? "Request Sent"))
              );

              loadData();   // ⬅ refresh from DB (admin still controls Pending)
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Send Request"),
          ),


        // WHEN PENDING → Buttons show instead ✔
        if(status=="Pending") Row(children:[
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FacultyRequestDetailsPage(requestId: id!), // 👈 Pass DB _id
                ),
              );
            },
            child: const Text("View Details"),
          ),

          const SizedBox(width:10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FacultyRequestDetailsPage(requestId: id!),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4FA3FF)),
            child: const Text("Submit Requirements"),
          ),
        ]),

        if(status=="Rejected" && id!=null)
          ElevatedButton(
            onPressed:()async{
              await ApiService.resubmitClearanceRequest(id);
              loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content:Text("Re-Submitted")));
            },
            style:ElevatedButton.styleFrom(backgroundColor:Colors.orange),
            child:const Text("Resubmit")
          ),
          
            if (status == "Approved")
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FacultyRequestDetailsPage(requestId: id!), 
                    ),
                  );
                },
                child: const Text("View Details"),
              ),
      ]),
    );
  }

  // ---------------- HELPERS ----------------

  String fmt(d){ try{return DateFormat("MMM dd yyyy").format(DateTime.parse(d));}catch(_){return "-";}}
  BoxDecoration box()=>BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12),boxShadow:[BoxShadow(color:Colors.black12,blurRadius:8)]);
  Widget stat(String t,String n,{Color c=Colors.black})=>Expanded(child:
    Container(padding:const EdgeInsets.all(20),decoration:box(),child:
      Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(t,style:const TextStyle(color:Colors.black54)),
        Text(n,style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:c))
      ])));
// ================= DROPDOWNS =================

Widget yearDrop()=>drop(
  selectedYear,
  ["2023–2024","2024–2025","2025–2026"],
  (v){
    setState(()=>selectedYear=v);
    loadData();          // 🔥 reload requests with new year filter
  }
);

      Widget semDrop()=>drop(
        selectedSemester,
        ["First Semester","Second Semester"],
        (v){
          setState(()=>selectedSemester=v);
          loadData();          // 🔥 reload requests with new sem filter
        }
      );

      Widget drop(v,List list,Function pick)=>Container(
        padding:const EdgeInsets.symmetric(horizontal:16),
        decoration:box(),
        child:DropdownButtonHideUnderline(
          child:DropdownButton(
            value:v,
            items:list.map((e)=>DropdownMenuItem(
              value:e,
              child:Text(e),
            )).toList(),
            onChanged:(x)=>pick(x),    // ⬅ now both dropdowns update
          )
        )
      );

}
