// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Orders`
  String get orders {
    return Intl.message(
      'Orders',
      name: 'orders',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signIn {
    return Intl.message(
      'Sign In',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get select_language {
    return Intl.message(
      'Select Language',
      name: 'select_language',
      desc: '',
      args: [],
    );
  }

  /// `Client`
  String get client {
    return Intl.message(
      'Client',
      name: 'client',
      desc: '',
      args: [],
    );
  }

  /// `I am a Service Provider`
  String get service_provider {
    return Intl.message(
      'I am a Service Provider',
      name: 'service_provider',
      desc: '',
      args: [],
    );
  }

  /// `Top Rated`
  String get top_rated {
    return Intl.message(
      'Top Rated',
      name: 'top_rated',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  /// `Teaching`
  String get teaching {
    return Intl.message(
      'Teaching',
      name: 'teaching',
      desc: '',
      args: [],
    );
  }

  /// `Cleaning`
  String get cleaning {
    return Intl.message(
      'Cleaning',
      name: 'cleaning',
      desc: '',
      args: [],
    );
  }

  /// `Plumbing`
  String get plumbing {
    return Intl.message(
      'Plumbing',
      name: 'plumbing',
      desc: '',
      args: [],
    );
  }

  /// `Electrician`
  String get electrician {
    return Intl.message(
      'Electrician',
      name: 'electrician',
      desc: '',
      args: [],
    );
  }

  /// `Upload Image`
  String get uploadImage {
    return Intl.message(
      'Upload Image',
      name: 'uploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Delete Image`
  String get deleteImage {
    return Intl.message(
      'Delete Image',
      name: 'deleteImage',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get change_password {
    return Intl.message(
      'Change Password',
      name: 'change_password',
      desc: '',
      args: [],
    );
  }

  /// `Old password`
  String get old_password {
    return Intl.message(
      'Old password',
      name: 'old_password',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirm_password {
    return Intl.message(
      'Confirm Password',
      name: 'confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `Enter your name`
  String get username_placeholder {
    return Intl.message(
      'Enter your name',
      name: 'username_placeholder',
      desc: '',
      args: [],
    );
  }

  /// `Edit Username`
  String get edit_username {
    return Intl.message(
      'Edit Username',
      name: 'edit_username',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Age`
  String get age {
    return Intl.message(
      'Age',
      name: 'age',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message(
      'Location',
      name: 'location',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get save_changes {
    return Intl.message(
      'Save Changes',
      name: 'save_changes',
      desc: '',
      args: [],
    );
  }

  /// `Changes saved successfully!`
  String get save_changes_success {
    return Intl.message(
      'Changes saved successfully!',
      name: 'save_changes_success',
      desc: '',
      args: [],
    );
  }

  /// `Change Picture`
  String get change_picture {
    return Intl.message(
      'Change Picture',
      name: 'change_picture',
      desc: '',
      args: [],
    );
  }

  /// `Delete Picture`
  String get delete_picture {
    return Intl.message(
      'Delete Picture',
      name: 'delete_picture',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signUp {
    return Intl.message(
      'Sign Up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get welcome {
    return Intl.message(
      'Welcome',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `to Homie`
  String get toHomie {
    return Intl.message(
      'to Homie',
      name: 'toHomie',
      desc: '',
      args: [],
    );
  }

  /// `Welcome To Homie`
  String get welcomeToHomie {
    return Intl.message(
      'Welcome To Homie',
      name: 'welcomeToHomie',
      desc: '',
      args: [],
    );
  }

  /// `Not a member?`
  String get notAMember {
    return Intl.message(
      'Not a member?',
      name: 'notAMember',
      desc: '',
      args: [],
    );
  }

  /// `Sign up here`
  String get signUpHere {
    return Intl.message(
      'Sign up here',
      name: 'signUpHere',
      desc: '',
      args: [],
    );
  }

  /// `Select User Type`
  String get selectUserType {
    return Intl.message(
      'Select User Type',
      name: 'selectUserType',
      desc: '',
      args: [],
    );
  }

  /// `Your One Step Solution for Home Needs`
  String get yourOneStepSolution {
    return Intl.message(
      'Your One Step Solution for Home Needs',
      name: 'yourOneStepSolution',
      desc: '',
      args: [],
    );
  }

  /// `I am a Client`
  String get iAmClient {
    return Intl.message(
      'I am a Client',
      name: 'iAmClient',
      desc: '',
      args: [],
    );
  }

  /// `Find trusted professionals for home services`
  String get findTrustedProfessionals {
    return Intl.message(
      'Find trusted professionals for home services',
      name: 'findTrustedProfessionals',
      desc: '',
      args: [],
    );
  }

  /// `I am a Service Provider`
  String get iAmServiceProvider {
    return Intl.message(
      'I am a Service Provider',
      name: 'iAmServiceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Join us and offer your service to a growing network`
  String get joinAndGrowNetwork {
    return Intl.message(
      'Join us and offer your service to a growing network',
      name: 'joinAndGrowNetwork',
      desc: '',
      args: [],
    );
  }

  /// `User Name is required`
  String get userNameRequired {
    return Intl.message(
      'User Name is required',
      name: 'userNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Email is required`
  String get emailRequired {
    return Intl.message(
      'Email is required',
      name: 'emailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `Address is required`
  String get addressRequired {
    return Intl.message(
      'Address is required',
      name: 'addressRequired',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Phone number must start with +218`
  String get phoneNumberInvalid {
    return Intl.message(
      'Phone number must start with +218',
      name: 'phoneNumberInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Female`
  String get female {
    return Intl.message(
      'Female',
      name: 'female',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get male {
    return Intl.message(
      'Male',
      name: 'male',
      desc: '',
      args: [],
    );
  }

  /// `Password is required`
  String get passwordRequired {
    return Intl.message(
      'Password is required',
      name: 'passwordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password does not match`
  String get passwordMismatch {
    return Intl.message(
      'Password does not match',
      name: 'passwordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Location is required`
  String get locationRequired {
    return Intl.message(
      'Location is required',
      name: 'locationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories {
    return Intl.message(
      'Categories',
      name: 'categories',
      desc: '',
      args: [],
    );
  }

  /// `At least one category is required`
  String get categoryRequired {
    return Intl.message(
      'At least one category is required',
      name: 'categoryRequired',
      desc: '',
      args: [],
    );
  }

  /// `Experience`
  String get experience {
    return Intl.message(
      'Experience',
      name: 'experience',
      desc: '',
      args: [],
    );
  }

  /// `Bio`
  String get bio {
    return Intl.message(
      'Bio',
      name: 'bio',
      desc: '',
      args: [],
    );
  }

  /// `Service Provider`
  String get serviceProvider {
    return Intl.message(
      'Service Provider',
      name: 'serviceProvider',
      desc: '',
      args: [],
    );
  }

  /// `All Fields Required`
  String get allFieldsRequired {
    return Intl.message(
      'All Fields Required',
      name: 'allFieldsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logOut {
    return Intl.message(
      'Log Out',
      name: 'logOut',
      desc: '',
      args: [],
    );
  }

  /// `Change Language`
  String get changeLanguage {
    return Intl.message(
      'Change Language',
      name: 'changeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Services`
  String get services {
    return Intl.message(
      'Services',
      name: 'services',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Login Failed`
  String get login_failed {
    return Intl.message(
      'Login Failed',
      name: 'login_failed',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Credentials`
  String get invalid_credentials {
    return Intl.message(
      'Invalid Credentials',
      name: 'invalid_credentials',
      desc: '',
      args: [],
    );
  }

  /// `Connection Error`
  String get connection_error {
    return Intl.message(
      'Connection Error',
      name: 'connection_error',
      desc: '',
      args: [],
    );
  }

  /// `Fill all fields`
  String get fill_all_fields {
    return Intl.message(
      'Fill all fields',
      name: 'fill_all_fields',
      desc: '',
      args: [],
    );
  }

  /// `Unexpected Response`
  String get unexpected_response {
    return Intl.message(
      'Unexpected Response',
      name: 'unexpected_response',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update profile`
  String get failedToUpdateProfile {
    return Intl.message(
      'Failed to update profile',
      name: 'failedToUpdateProfile',
      desc: '',
      args: [],
    );
  }

  /// `Profile updated success fully`
  String get profileUpdatedSuccessfully {
    return Intl.message(
      'Profile updated success fully',
      name: 'profileUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Comments`
  String get comments {
    return Intl.message(
      'Comments',
      name: 'comments',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
