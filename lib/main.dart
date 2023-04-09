// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Assessment{
  String assessmentTitle;
  int? assessmentPercent;
  int? markPercent;

  Assessment(this.assessmentTitle, this.assessmentPercent, this.markPercent);
}

List myAssessments = [];

void main() {
  runApp(const MaterialApp(
    title: 'Module Grade Calculator',
    home: AssessmentOverviewRoute(),
    color: Colors.purple,
  ));

}



class AssessmentOverviewRoute extends StatefulWidget {
  const AssessmentOverviewRoute({super.key});

  @override
  State<AssessmentOverviewRoute> createState() => _HomeState();
}

class _HomeState extends State<AssessmentOverviewRoute>{
  final Map<String, String> assessmentMap = {};
  double currentTotalPercent = 0;

  void refreshHomeRoute(){
    setState(() {
      assessmentMap.clear();
      currentTotalPercent = 0;
      for (Assessment each in myAssessments){
        double eachTotalPercent = ((each.assessmentPercent!.toDouble()/100) * each.markPercent!.toDouble());
        currentTotalPercent = currentTotalPercent + eachTotalPercent; 
        assessmentMap["${each.assessmentTitle}"] = "Score: ${each.markPercent}% of ${each.assessmentPercent}% assessment ($eachTotalPercent% of overall)";
      }
    });
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Overview'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text("Total Mark: $currentTotalPercent%"),
          Expanded(
            child: ListView.builder(
              itemCount: assessmentMap.length,
              itemBuilder: (BuildContext context, int index){
                return ListTile(
                  title: Text(assessmentMap.keys.elementAt(index)),
                  subtitle: Text(assessmentMap.values.elementAt(index)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: 20.0,
                          color: Colors.black,
                        ),
                        onPressed: (){
                          myAssessments.removeAt(index);
                          refreshHomeRoute();
                        }
                        ),
                        IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 20.0,
                          color: Colors.black,
                        ),
                        onPressed: (){
                          print(index);
                        }
                        ),
                    ]
                  )
                );
              }
            )
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAssessmentRoute()),
            ).then((res) => refreshHomeRoute());
          },
        tooltip: 'Add',
        child: const Icon(Icons.add)
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class AddAssessmentRoute extends StatefulWidget {
  const AddAssessmentRoute({super.key});

  @override
  State<AddAssessmentRoute> createState() => _AddAssessmentFormState();
}

class _AddAssessmentFormState extends State<AddAssessmentRoute>{
  final assessmentIdentifierController = TextEditingController();
  final assessmentPercentController = TextEditingController();
  final markController = TextEditingController();

  void addAssessment(){
    myAssessments.add(Assessment(assessmentIdentifierController.text, int.parse(assessmentPercentController.text), int.parse(markController.text)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Assessment'),
      ),
      body: Column(
        children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: assessmentIdentifierController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter assessment identifier',
                ),
              ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: assessmentPercentController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter assessment percent',
                ),
              ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: markController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your mark (as a percent)',
                ),
              ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 10.0,
              children: <Widget>[
                ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: const Text('Back'),
                ),
                ElevatedButton( 
                  onPressed: (){
                    addAssessment();
                  },
                  child: const Text('Save'),
                )
              ],
            )
          )
        ]
      ),
    );
  }
}

