// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Assessment{
  String assessmentTitle;
  int? assessmentPercent;
  int? markPercent;

  Assessment(this.assessmentTitle, this.assessmentPercent, this.markPercent);
}

List myAssessments = [];

// custom class to hold arguments passed from assessmentOverview route to edit/ add assessment route
class ScreenArguments{
  bool editMode;
  int assessmentIndex; 

  ScreenArguments(this.editMode, [this.assessmentIndex = -1]);
}

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
                        onPressed: () {
                          bool editMode = true;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddAssessmentRoute(),
                                settings: RouteSettings(arguments: ScreenArguments(true, index)),
                                ),
                            ).then((res) => refreshHomeRoute());
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
          bool editMode = false;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddAssessmentRoute(),
                settings: RouteSettings(arguments: ScreenArguments(false)),
                ),
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
  var assessmentIdentifierController = TextEditingController();
  final assessmentPercentController = TextEditingController();
  final markController = TextEditingController();
  

  void addAssessment(){
    myAssessments.add(Assessment(assessmentIdentifierController.text, int.parse(assessmentPercentController.text), int.parse(markController.text)));
  }
  void saveButton(bool editMode, [int index = -1]){
    if(!editMode){
      addAssessment();
    }else{
      myAssessments[index].assessmentTitle = assessmentIdentifierController.text;
      myAssessments[index].assessmentPercent = int.parse(assessmentPercentController.text);
      myAssessments[index].markPercent = int.parse(markController.text);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // setup vars which we can change depending on mode
    String modeString = "Add";

    // get contents of the arguments we passed in when generating this route
    ScreenArguments screenArgs = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    // if the route is in edit mode then we need to setup for it
    if (screenArgs.editMode){
      assessmentIdentifierController.text = myAssessments[screenArgs.assessmentIndex].assessmentTitle;
      assessmentPercentController.text = myAssessments[screenArgs.assessmentIndex].assessmentPercent.toString();
      markController.text = myAssessments[screenArgs.assessmentIndex].markPercent.toString();
      modeString = "Edit";
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$modeString Assessment'),
      ),
      body: Column(
        children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: assessmentIdentifierController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Assessment identifier',
                ),
              ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: assessmentPercentController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Assessment percent (of overall module)',
                ),
              ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: markController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Your mark (as a percent)',
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
                    // addAssessment();
                    saveButton(screenArgs.editMode, screenArgs.assessmentIndex);
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

