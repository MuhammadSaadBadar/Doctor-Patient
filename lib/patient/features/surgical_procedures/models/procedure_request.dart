// lib/patient/features/surgical_procedures/models/procedure_request.dart

class ProcedureRequest {
  final String procedureName;
  final DateTime procedureDate;
  final String? hospitalName;
  final String? notes;

  ProcedureRequest({
    required this.procedureName,
    required this.procedureDate,
    this.hospitalName,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'procedure_name': procedureName,
      'procedure_date': procedureDate.toIso8601String().split('T')[0],
      'hospital_name': hospitalName,
      'notes': notes,
    };
  }
}
