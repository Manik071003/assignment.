import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'Model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Questionnaire App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QuestionnairePage(),
    );
  }
}

class QuestionnairePage extends StatefulWidget {
  @override
  _QuestionnairePageState createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  LoanSchema? schema;
  Map<String, String> answers = {};

  @override
  void initState() {
    loadSchema();
    super.initState();
  }

  Future<void> loadSchema() async {
    final jsonString = await rootBundle.loadString('assets/loan_schema.json');
    setState(() {
      schema = LoanSchema.fromJson(json.decode(jsonString));
    });
  }

  void answerQuestion(String questionName, String answer) {
    setState(() {
      answers[questionName] = answer;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (schema == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Questionnaire App')),
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return DefaultTabController(
        length: schema!.fields.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Questionnaire App'),
            bottom: TabBar(
              tabs: schema!.fields.map((field) {
                return Tab(text: field.schema.name);
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: schema!.fields.map((field) {
              return _buildQuestionWidget(field);
            }).toList(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => AnswerSheet(answers: answers),
              );
            },
            child: Icon(Icons.check),
          ),
        ),
      );
    }
  }

  Widget _buildQuestionWidget(Field field) {
    final fieldSchema = field.schema;
    final fieldType = field.type;

    if (fieldType == 'SingleChoiceSelector' || fieldType == 'SingleSelect') {
      final options = fieldSchema.options ?? [];
      return QuestionWidget(
        questionName: fieldSchema.name,
        questionLabel: fieldSchema.label,
        options: options,
        answerCallback: answerQuestion,
        answers: answers,
      );
    }

    if (fieldType == 'Section') {
      final sectionFields = fieldSchema.fields;
      final options = fieldSchema.options ?? [];

      return DefaultTabController(
        length: sectionFields!.length,
        child: Column(
          children: [
            TabBar(
              tabs: sectionFields.map<Tab>((sectionField) {
                return Tab(text: sectionField.schema.label);
              }).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: sectionFields.map<Widget>((sectionField) {
                  return _buildQuestionWidget(Field(schema: sectionField.schema, type: sectionField.type, version: 1));
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }

    if (fieldType == 'SingleSelect') {
      final shouldShow = fieldSchema.hidden == null || answers[fieldSchema.hidden!] == 'true';

      if (!shouldShow) {
        return SizedBox.shrink();
      }

      final options = fieldSchema.options ?? [];
      return QuestionWidget(
        questionName: fieldSchema.name,
        questionLabel: fieldSchema.label,
        options: options,
        answerCallback: answerQuestion,
        answers: answers,
      );
    }

    return SizedBox.shrink();
  }
}

class QuestionWidget extends StatefulWidget {
  final String questionName;
  final String questionLabel;
  final List<Option>? options;
  final Function(String, String) answerCallback;
  final Map<String, String> answers;

  QuestionWidget({
    required this.questionName,
    required this.questionLabel,
    this.options,
    required this.answerCallback,
    required this.answers,
  });

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  String selectedValue = '';

  @override
  void initState() {
    super.initState();
    selectedValue = widget.answers[widget.questionName] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.questionLabel,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: widget.options!.map<Widget>((option) {
              return RadioListTile(
                title: Text(option.value),
                value: option.key,
                groupValue: selectedValue,
                onChanged: (newValue) {
                  widget.answerCallback(widget.questionName, newValue!);
                  setState(() {
                    selectedValue = newValue;
                  });
                  DefaultTabController.of(context)!.animateTo(
                    DefaultTabController.of(context)!.index + 1,
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class AnswerSheet extends StatelessWidget {
  final Map<String, String> answers;

  AnswerSheet({required this.answers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chosen Answers',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 10),
          for (var entry in answers.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text('${entry.key}: ${entry.value}'),
            ),
        ],
      ),
    );
  }
}
