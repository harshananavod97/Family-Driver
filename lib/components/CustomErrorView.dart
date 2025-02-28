import 'package:flutter/material.dart';
import 'package:taxi_booking/main.dart';
import 'package:taxi_booking/utils/Colors.dart';

class CustomErrorView extends StatelessWidget {
  final FlutterErrorDetails details;

  const CustomErrorView(this.details, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Custom Error view",
      home: MainView(
        errorMessage: details.exception.toString(),
        trace: details.stack.toString(),
      ),
    );
  }
}

class MainView extends StatelessWidget {
  final String errorMessage;
  final String trace;

  const MainView({this.errorMessage = "",this.trace = "", super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Oops! Error Encountered"),leading: Icon(Icons.error),actions: [
        IconButton(onPressed: (){
          main();
        }, icon: Icon(Icons.restart_alt_outlined))
      ],),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white,
              // border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(color: Colors.black45,spreadRadius: 1,blurRadius: 1)
              ],
              borderRadius: BorderRadius.circular(14)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Error Title:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  // color: Colors.redAccent,
                ),
              ),
              // SizedBox(height: 8),
              Text(
                errorMessage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
              if(trace.isNotEmpty)
              SizedBox(height: 16),
              if(trace.isNotEmpty)
              Text(
                "Trace Error:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  // color: Colors.redAccent,
                ),
              ),
              // SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Text(
                        trace,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                        // overflow: TextOverflow.ellipsis,
                        // maxLines: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: MaterialButton(onPressed: () {

                },
                  color: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.withOpacity(0.8),width: 2.5,strokeAlign: BorderSide.strokeAlignInside,)
                  ),
                child: Text("Send Error Report"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}