

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_verification/screens/home.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  MobileVerificationState currentState = MobileVerificationState.SHOW_MOBILE_FORM_STATE;
  FirebaseAuth _auth = FirebaseAuth.instance;

  late String verificationId;

  bool showLoading = false;


  void signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential) async{
    setState(() {
      showLoading= true;
    });
      try {

        final authCredential = await _auth.signInWithCredential(phoneAuthCredential);

        if(authCredential.user!=null){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
        }
      } on FirebaseAuthException catch (e) {
        print(e);
        setState(() {
          showLoading= false;
        });


      }


      // ignore: deprecated_member_use
      _globalKey.currentState!.showSnackBar(SnackBar(content: Text('error')));
  }

  getMobileVerificationWidged(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
            controller: phoneController,
            decoration: InputDecoration(
              hintText: "Enter Phone Number",
            )),
        // ignore: deprecated_member_use
        FlatButton(
          onPressed: () async {
            setState(() {
              showLoading= true;
            });
            await _auth.verifyPhoneNumber(
                phoneNumber: phoneController.text,
                verificationCompleted: (phoneAuthCredential) async{
                  setState(() {
                    showLoading= false;
                  });

                },
                verificationFailed: (verificationFailed) async {
                // ignore: deprecated_member_use
                _globalKey.currentState!.showSnackBar(SnackBar(content: Text('verification fail')));
                setState(() {
                  showLoading= false;
                });

                },
                codeSent: (verificationId, resendingToken) async{
                  setState(() {
                    showLoading = false;
                    currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                    this.verificationId = verificationId;
                  });

                },
                codeAutoRetrievalTimeout: (verificationId)async{

            });
          },
          child: Text('SEND'),
          color: Colors.lightBlue,
        )
      ],
    );
  }

  getOtpWidged(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
            controller: otpController,
            decoration: InputDecoration(
              hintText: "Enter OTP",
            )),
        // ignore: deprecated_member_use
        FlatButton(
          onPressed: () {
            PhoneAuthCredential phoneAuthCredential= PhoneAuthProvider.credential(verificationId: verificationId,
                smsCode: otpController.text);
            signInWithPhoneAuthCredential(phoneAuthCredential);
          },
          child: Text('VERIFY'),
          color: Colors.lightBlue,
        )
      ],
    );
  }
   final GlobalKey<ScaffoldState> _globalKey= GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
        body: Container(
      child: showLoading ? Center(child: CircularProgressIndicator(),) : currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
          ? getMobileVerificationWidged(context)
          : getOtpWidged(context),
      padding: EdgeInsets.all(16),
    ));
  }
}

