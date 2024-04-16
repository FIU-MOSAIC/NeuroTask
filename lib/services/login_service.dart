import 'package:get/get.dart';
import 'package:neuro_task/constant/ip.dart';
import 'package:http/http.dart' as http;
import 'package:neuro_task/pages/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService{
  var ip = IP.ip;
  Future<void> login(String email,String password) async{
    if(email.isEmpty || password.isEmpty){
      Get.snackbar('Neuro Task', 'Please fill all the input box');
    }
    else{
      var url = 'http://$ip/Neuro_Task/login.php';
      try{
        var res = await http.post(Uri.parse(url),body: {
          'email' : email,
          'password' : password,
        });
        if(res.body=='login success'){
          Get.snackbar('Neuro Task', 'Login Sucessfull');
          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          sharedPreferences.setString('email', email);
          Get.to(const HomePage());
        }
        else{
          Get.snackbar('Neuro Task', 'Email or Password are incorrect');
        }
      }
      catch(e){
        // ignore: avoid_print
        print(e);
      }
    }
  }
}