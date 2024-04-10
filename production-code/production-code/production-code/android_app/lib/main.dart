import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Transaction App',
      home: TransactionForm(),
    );
  }
}

class TransactionForm extends StatefulWidget {
  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController academicYearController = TextEditingController();
  final TextEditingController branchController = TextEditingController();
  final TextEditingController studentAccountController =
      TextEditingController();
  final TextEditingController amountEtherController = TextEditingController();
  final TextEditingController privateKeyController = TextEditingController();

  String transactionResult = '';
  String availableBalance = '';

  Future<void> initiateTransaction() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/initiateTransaction'),
        body: {
          'studentName': studentNameController.text,
          'rollNumber': rollNumberController.text,
          'academicYear': academicYearController.text,
          'branch': branchController.text,
          'studentAccount': studentAccountController.text,
          'amountEther': amountEtherController.text,
          'privateKey': privateKeyController.text,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          transactionResult = response.body;
          availableBalance = '25.0'; // replace with actual available balance
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Transaction Result'),
              content: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text('Transaction Successful!',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Result: $transactionResult'),
                  SizedBox(height: 10),
                  // Text('Available Balance: $availableBalance Ether',
                  //     style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Transaction Result'),
              content: Column(
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text('Transaction Failed!',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Error: ${response.body}',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Transaction Result'),
            content: Column(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 50,
                ),
                SizedBox(height: 10),
                Text('Transaction Failed!',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Network Error: Check your connection and try again.',
                    style: TextStyle(color: Colors.red)),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: studentNameController,
              decoration: InputDecoration(labelText: 'Student Name'),
            ),
            TextField(
              controller: rollNumberController,
              decoration: InputDecoration(labelText: 'Roll Number'),
            ),
            TextField(
              controller: academicYearController,
              decoration: InputDecoration(labelText: 'Academic Year'),
            ),
            TextField(
              controller: branchController,
              decoration: InputDecoration(labelText: 'Branch'),
            ),
            TextField(
              controller: studentAccountController,
              decoration: InputDecoration(labelText: 'Student Account'),
            ),
            TextField(
              controller: amountEtherController,
              decoration: InputDecoration(labelText: 'Amount (Ether)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: privateKeyController,
              decoration: InputDecoration(labelText: 'Private Key'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: initiateTransaction,
              child: Text('Initiate Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
