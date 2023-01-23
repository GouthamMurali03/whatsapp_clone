import 'package:flutter/material.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/custom_button.dart';
import 'package:whatsapp_ui/features/auth/screens/login_scren.dart';
import 'package:whatsapp_ui/resources/image_resources.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  void navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'Welcome to WhatsApp',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26),
                  ),
                ),
                SizedBox(
                  height: size.height / 9,
                ),
                Image.asset(
                  ImageResources.landingBg,
                  height: 340,
                  width: 340,
                  color: tabColor,
                ),
                SizedBox(
                  height: size.height / 9,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Servce',
                    style: TextStyle(color: greyColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: size.width * 0.75,
                  child: CustomButton(
                      text: 'Agree and Continue',
                      onPressed: () => navigateToLoginScreen(context)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
