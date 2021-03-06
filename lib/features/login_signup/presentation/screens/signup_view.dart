import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puvts/app/locator_injection.dart';
import 'package:puvts/core/constants/puvts_colors.dart';
import 'package:puvts/core/widgets/keyboard_dismisser.dart';
import 'package:puvts/core/widgets/puvts_button.dart';
import 'package:puvts/core/widgets/puvts_textfield.dart';
import 'package:puvts/features/login_signup/domain/bloc/login_signup_bloc.dart';
import 'package:puvts/features/login_signup/domain/bloc/login_signup_state.dart';
import 'package:puvts/features/login_signup/presentation/screens/login_view.dart';
import 'package:puvts/generated/assets.gen.dart';

class SignupView extends StatefulWidget {
  const SignupView({Key? key}) : super(key: key);

  @override
  _SignupViewState createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginSignupBloc>(
      create: (_) => locator<LoginSignupBloc>(),
      child: BlocConsumer<LoginSignupBloc, LoginSignupState>(
        listener: (BuildContext context, LoginSignupState state) async {
          if (state.finished) {
            showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => AlertDialog(
                contentPadding: EdgeInsets.symmetric(horizontal: 24)
                    .copyWith(top: 25, bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Success',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        child: PuvtsButton(
                          height: 40,
                          buttonColor: puvtsBlue,
                          onPressed: () =>
                              Navigator.of(context).pushAndRemoveUntil(
                            CupertinoPageRoute(
                              builder: (BuildContext context) {
                                return LoginView();
                              },
                            ),
                            (_) => false,
                          ),
                          text: 'Back to Login',
                          textSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state.hasError) {
            showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => AlertDialog(
                contentPadding: EdgeInsets.symmetric(horizontal: 24)
                    .copyWith(top: 25, bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Something Went Wrong',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        child: PuvtsButton(
                          height: 40,
                          buttonColor: puvtsBlue,
                          onPressed: () => Navigator.pop(context),
                          text: 'Try Again',
                          textSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
        builder: (BuildContext context, LoginSignupState state) {
          return KeyboardDismisser(
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: puvtsBlue,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              backgroundColor: puvtsBlue,
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: EdgeInsets.all(30),
                        child: Image.asset(
                          Assets.images.logoPin.path,
                          height: 30,
                          width: 30,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'E-Jeep Android-Based Tracking System',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: puvtsWhite,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Text(
                        'Signup',
                        style: TextStyle(
                          color: puvtsWhite,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 30),
                      PuvtsTextfield(
                        labelText: 'First name',
                        textStyle: TextStyle(
                            color: puvtsWhite.withOpacity(0.8), fontSize: 20),
                        controller: firstNameController,
                      ),
                      const SizedBox(height: 10),
                      PuvtsTextfield(
                        labelText: 'Last name',
                        textStyle: TextStyle(
                            color: puvtsWhite.withOpacity(0.8), fontSize: 20),
                        controller: lastNameController,
                      ),
                      const SizedBox(height: 10),
                      PuvtsTextfield(
                        labelText: 'Email',
                        textStyle: TextStyle(
                            color: puvtsWhite.withOpacity(0.8), fontSize: 20),
                        controller: emailController,
                      ),
                      const SizedBox(height: 10),
                      PuvtsTextfield(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () => context
                              .read<LoginSignupBloc>()
                              .showHidePassword(),
                          color: puvtsWhite,
                          icon: Icon(
                            state.obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                          ),
                        ),
                        textStyle: TextStyle(
                            color: puvtsWhite.withOpacity(0.8), fontSize: 20),
                        controller: passwordController,
                        obscureText: state.obscurePassword,
                      ),
                      const SizedBox(height: 150),
                      state.isLoading
                          ? CircularProgressIndicator(color: puvtsWhite)
                          : PuvtsButton(
                              width: 200,
                              height: 60,
                              buttonColor: puvtsBlue,
                              onPressed: () =>
                                  context.read<LoginSignupBloc>().signup(
                                        firstname: firstNameController.text,
                                        lastname: lastNameController.text,
                                        email: emailController.text,
                                        password: passwordController.text,
                                      ),
                              text: 'Signup',
                              textSize: 20,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
