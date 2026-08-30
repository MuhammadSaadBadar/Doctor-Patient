// lib/features/profile/controllers/add_payment_method_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/network/api_exceptions.dart';
import 'package:doctor/core/utils/validation_utils.dart';
import 'package:doctor/doctor/features/profile/models/doc_add_payment_method.dart';
import 'package:doctor/doctor/features/profile/repositories/doc_add_payment_method_repository.dart';

class DoctorAddPaymentMethodController extends GetxController {
  final DoctorAddPaymentMethodRepository _repository =
      DoctorAddPaymentMethodRepository();

  // State
  final selectedMethod = PayoutMethod.bank.obs;
  final isSaving = false.obs;

  // Form controllers for bank
  final bankNameController = TextEditingController();
  final bankAccountTitleController = TextEditingController();
  final bankAccountNumberController = TextEditingController();
  final bankIbanController = TextEditingController();

  // Form controllers for JazzCash
  final jazzcashNumberController = TextEditingController();
  final jazzcashAccountTitleController = TextEditingController();

  // Form controllers for EasyPaisa
  final easypaisaNumberController = TextEditingController();
  final easypaisaAccountTitleController = TextEditingController();

  // Validation errors
  final bankNameError = ''.obs;
  final bankAccountTitleError = ''.obs;
  final bankAccountNumberError = ''.obs;
  final bankIbanError = ''.obs;
  final jazzcashNumberError = ''.obs;
  final jazzcashAccountTitleError = ''.obs;
  final easypaisaNumberError = ''.obs;
  final easypaisaAccountTitleError = ''.obs;
  final methodError = ''.obs;

  void selectMethod(PayoutMethod method) {
    selectedMethod.value = method;
    _clearAllErrors();
  }

  void _clearAllErrors() {
    bankNameError.value = '';
    bankAccountTitleError.value = '';
    bankAccountNumberError.value = '';
    bankIbanError.value = '';
    jazzcashNumberError.value = '';
    jazzcashAccountTitleError.value = '';
    easypaisaNumberError.value = '';
    easypaisaAccountTitleError.value = '';
  }

  bool validateForm() {
    bool isValid = true;
    _clearAllErrors();

    switch (selectedMethod.value) {
      case PayoutMethod.jazzcash:
        if (jazzcashNumberController.text.trim().isEmpty) {
          jazzcashNumberError.value = 'JazzCash number is required';
          isValid = false;
        } else if (jazzcashNumberController.text.trim().length < 10) {
          jazzcashNumberError.value = 'Please enter a valid phone number';
          isValid = false;
        }
        if (jazzcashAccountTitleController.text.trim().isEmpty) {
          jazzcashAccountTitleError.value = 'Account title is required';
          isValid = false;
        }
        break;

      case PayoutMethod.easypaisa:
        if (easypaisaNumberController.text.trim().isEmpty) {
          easypaisaNumberError.value = 'EasyPaisa number is required';
          isValid = false;
        } else if (easypaisaNumberController.text.trim().length < 10) {
          easypaisaNumberError.value = 'Please enter a valid phone number';
          isValid = false;
        }
        if (easypaisaAccountTitleController.text.trim().isEmpty) {
          easypaisaAccountTitleError.value = 'Account title is required';
          isValid = false;
        }
        break;

      case PayoutMethod.bank:
        if (bankNameController.text.trim().isEmpty) {
          bankNameError.value = 'Bank name is required';
          isValid = false;
        }
        if (bankAccountTitleController.text.trim().isEmpty) {
          bankAccountTitleError.value = 'Account title is required';
          isValid = false;
        }
        if (bankAccountNumberController.text.trim().isEmpty) {
          bankAccountNumberError.value = 'Account number is required';
          isValid = false;
        }
        if (bankIbanController.text.trim().isEmpty) {
          bankIbanError.value = 'IBAN is required';
          isValid = false;
        } else if (bankIbanController.text.trim().length < 15) {
          bankIbanError.value = 'Please enter a valid IBAN';
          isValid = false;
        }
        break;
    }

    return isValid;
  }

  Future<void> savePaymentMethod() async {
    if (!validateForm()) return;

    isSaving.value = true;

    try {
      AddPaymentMethodRequest request;

      switch (selectedMethod.value) {
        case PayoutMethod.jazzcash:
          request = AddPaymentMethodRequest(
            method: PayoutMethod.jazzcash,
            jazzcashNumber: jazzcashNumberController.text.trim(),
            jazzcashAccountTitle: jazzcashAccountTitleController.text.trim(),
          );
          break;

        case PayoutMethod.easypaisa:
          request = AddPaymentMethodRequest(
            method: PayoutMethod.easypaisa,
            easypaisaNumber: easypaisaNumberController.text.trim(),
            easypaisaAccountTitle: easypaisaAccountTitleController.text.trim(),
          );
          break;

        case PayoutMethod.bank:
          request = AddPaymentMethodRequest(
            method: PayoutMethod.bank,
            bankName: bankNameController.text.trim(),
            bankAccountTitle: bankAccountTitleController.text.trim(),
            bankAccountNumber: bankAccountNumberController.text.trim(),
            bankIban: bankIbanController.text.trim().toUpperCase(),
          );
          break;
      }

      final success = await _repository.updatePaymentMethod(request);

      if (success) {
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Payment method updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 2),
        );
      } else {
        throw Exception('Failed to update payment method');
      }
    } catch (e) {
      if (e is ApiException && e.fieldErrors != null) {
        handleApiFieldErrors(
          e.fieldErrors!,
          {
            'method': methodError,
            'bank_name': bankNameError,
            'bank_account_title': bankAccountTitleError,
            'bank_account_number': bankAccountNumberError,
            'bank_iban': bankIbanError,
            'jazzcash_number': jazzcashNumberError,
            'jazzcash_account_title': jazzcashAccountTitleError,
            'easypaisa_number': easypaisaNumberError,
            'easypaisa_account_title': easypaisaAccountTitleError,
          },
          fallbackSnackbar: (field, message) {
            Get.snackbar(
              'Error',
              message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red[800],
            );
          },
        );
      } else {
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
        );
      }
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    bankNameController.dispose();
    bankAccountTitleController.dispose();
    bankAccountNumberController.dispose();
    bankIbanController.dispose();
    jazzcashNumberController.dispose();
    jazzcashAccountTitleController.dispose();
    easypaisaNumberController.dispose();
    easypaisaAccountTitleController.dispose();
    super.onClose();
  }
}
