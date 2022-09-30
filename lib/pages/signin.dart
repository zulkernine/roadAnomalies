import 'package:flutter/material.dart';
import 'package:roadanomalies_root/colors.dart';
import 'package:roadanomalies_root/components/custom_text_field.dart';
import 'package:roadanomalies_root/constants.dart';
import 'package:roadanomalies_root/styles.dart';
import 'package:roadanomalies_root/util/auth_util.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailEditingController = TextEditingController();
  final passwordController = TextEditingController();
  bool isAuthCallAwaiting = false;
  var formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailEditingController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    setState(() {
      isAuthCallAwaiting = true;
    });
    if (formKey.currentState?.validate() ?? false) {
      try {
        await AuthUtil.signIn(
            emailEditingController.text, passwordController.text);
        Navigator.of(context).pushNamedAndRemoveUntil(
            RouteName.home, (Route<dynamic> route) => false);
      } on AuthException catch (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
        setState(() {
          isAuthCallAwaiting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            height: MediaQuery.of(context).size.height * 0.95,
            child: Center(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "JUSense",
                          style: txtStl20w300,
                        ),
                        Text(
                          Contents.appName,
                          style: txtStl50w800,
                        ),
                        Text(
                          "Road Anomaly Detection",
                          style: txtStl14w400,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),

                    CustomTextField(
                        hintText: "Email",
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                        ),
                        validator: (text) {
                          if (text?.isEmpty ?? true) {
                            return "Please write your valid email";
                          }
                          bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                              .hasMatch(text!);
                          if (!emailValid) {
                            return "Not an valid email address :(";
                          }
                          return null;
                        },
                        textController: emailEditingController),
                    const SizedBox(
                      height: 12,
                    ),
                    CustomTextField(
                        hintText: "Password",
                        obscureText: true,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.white,
                        ),
                        validator: (text) {
                          if ((text?.isEmpty ?? true) ||
                              (text?.length ?? 0) < 6) {
                            return "Password should be at least 6 characters long";
                          }
                          return null;
                        },
                        textController: passwordController),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                        onTap: isAuthCallAwaiting ? null : handleLogin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 19),
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(isAuthCallAwaiting ? 0.55 : 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text("Sign In",
                                      style: txtStl18w600Black, maxLines: 2)),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.black,
                                size: 40,
                              )
                            ],
                          ),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t have an account ?",
                          style: txtStl16w300,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, RouteName.signup);
                          },
                          child: Text(
                            "Register here",
                            style: txtStl16w300.copyWith(color: grey1),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Text(
                          "Version 2.1.0",
                          style: txtStl12w300,
                          maxLines: 2,
                          softWrap: true,
                        ),
                        Text(
                          "JUSense PotSpot",
                          style: txtStl12w300,
                          maxLines: 2,
                          softWrap: true,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
