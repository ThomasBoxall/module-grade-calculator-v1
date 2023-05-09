// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Assessment{
  String assessmentTitle;
  int assessmentPercent;
  int markPercent;

  Assessment(this.assessmentTitle, this.assessmentPercent, this.markPercent);

  String getAssessmentTitle() => assessmentTitle;
  int getAssessmentPercent() => assessmentPercent;
  int getMarkPercent() => markPercent;
}

List myAssessments = [];

// custom class to hold arguments passed from assessmentOverview route to edit/ add assessment route
class ScreenArguments{
  bool editMode;
  int assessmentIndex; 

  ScreenArguments(this.editMode, [this.assessmentIndex = -1]);
}

void main() {
  runApp(MyApp());
}

// MyApp class, entry point to the app

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return  MaterialApp(
      title: 'Module Grade Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue,
      ),
      home: AssessmentOverviewRoute(),
    );
  }
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
    /// Updates view assessment route to display everything in myAssessments
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
                          color: Colors.white,
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
                          color: Colors.white,
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
  

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
    }

  int getTotalAssessmentPercent(){
    /// Returns total of assessment value percentages from myAssessments list.
    int totalAssessmentPercent = 0;
    for (Assessment assm in myAssessments){
      totalAssessmentPercent += assm.getAssessmentPercent();
    }
    return totalAssessmentPercent;
  }

  int getTotalAssessmentPercentIgnore(int ignoreIndex){
    /// Returns total of assessment value percentages from myAssessments list ignoring specified index
    /// ignoring specific index is needed for when editing an assessment
    String ignoreAssessmentIdentifer = myAssessments[ignoreIndex].getAssessmentTitle();
    int totalAssessmentPercent = 0;
    for (Assessment assm in myAssessments){
      if (assm.getAssessmentTitle() != ignoreAssessmentIdentifer){
        totalAssessmentPercent += assm.getAssessmentPercent();
      }
    }
    return totalAssessmentPercent;
  }

  bool checkAssessmentPercentValid(bool editMode, int index){
    /// checks if the total percentage of saved assessments and the new one to be added / saved assessments and the edited value is below 100 therefore valid
    /// uses `editMode` to determine if to check with ignoring an index or not
    if(editMode){
      // we can assume that index will be present
      return getTotalAssessmentPercentIgnore(index) + int.parse(assessmentPercentController.text) <= 100;
    }else{
      // we can assume that index won't have been passed
      return getTotalAssessmentPercent() + int.parse(assessmentPercentController.text) <= 100;
    }
  }

  void saveButton(bool editMode, [int index = -1]){
    /// validates input to some textboxes then updates assessment or creates new assessment
    if (isNumeric(assessmentPercentController.text) && isNumeric(markController.text)){
      if (checkAssessmentPercentValid(editMode, index)){
        if(!editMode){
          myAssessments.add(Assessment(assessmentIdentifierController.text, int.parse(assessmentPercentController.text), int.parse(markController.text)));
        }else{
          myAssessments[index].assessmentTitle = assessmentIdentifierController.text;
          myAssessments[index].assessmentPercent = int.parse(assessmentPercentController.text);
          myAssessments[index].markPercent = int.parse(markController.text);
        }
        Navigator.pop(context);
        }else{
           showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Too much assessment!'),
              content: const Text('The value you have entered into the assessment percentage textbox and those of your already added assessments exceed 100%. Try again.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }//end value check else
    }else{
      // show the user a dialogue which prompts them to re-enter them. 
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Non number detected!'),
          content: const Text('The values in the assessment percentage and mark percentage textboxes should be whole numbers. Try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      ); //end showDialogue
    } // end isNumeric else
  } // end void saveButton

  @override
  Widget build(BuildContext context) {
    // setup vars which we can change depending on mode
    // default to add mode
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
                keyboardType: TextInputType.number,
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
                keyboardType: TextInputType.number,
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

