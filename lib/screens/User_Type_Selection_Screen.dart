import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test/theme.dart';
import 'SignUpScreen.dart'; // Ensure this file exists

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0), // Add border radius
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Logo
            Image.asset("images/homie user type art.png",width: 400,height: 400,),
            const SizedBox(height: 20),

            // Welcome message
            const Text(
              "Welcome to Homie", // Removed localization
              style: TextStyle(color: AppColors.primaryColor ,fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.003),

            const Text(
              "Your one-stop solution for home services", // Removed localization
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimaryColor
              ),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            // Client Button
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.08,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(userType: 0),
                    ),);},
                child: Text("I am a Client",style: TextStyle(
                  fontSize: 18,  ),), // Removed localization
              ),),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),     // Service Provider
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.08,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(userType: 1),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryColor, width: 2.0), // Add border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Set corner radius
                  ),
                ),
                child:

                Text("I am a Service Provider"
                    ,style: TextStyle(
                      fontSize: 18,

                    )
                ), // Removed localization


              ),
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}