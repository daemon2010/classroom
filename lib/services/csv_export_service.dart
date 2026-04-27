import "dart:convert";

import "package:csv/csv.dart";
import "package:file_selector/file_selector.dart";
import "package:intl/intl.dart";

import "../models/classroom_models.dart";

class CsvExportService {
  String buildCsv(List<UngradedReportRow> rows) {
    final dateFormat = DateFormat("yyyy-MM-dd HH:mm");
    final data = <List<Object?>>[
      const [
        "Student Name",
        "Student Email",
        "Class Name",
        "Class Section",
        "Subject",
        "Assignment",
        "Submission State",
        "Late",
        "Submitted At",
        "Created At",
        "Max Points",
        "Submission Link",
        "Assignment Link",
      ],
      ...rows.map(
        (row) => [
          row.studentName,
          row.studentEmail ?? "",
          row.courseName,
          row.classSection ?? "",
          row.subject ?? "",
          row.assignmentTitle,
          _formatState(row.submissionState),
          row.isLate ? "Yes" : "No",
          _formatDate(dateFormat, row.submittedAt ?? row.updatedAt),
          _formatDate(dateFormat, row.createdAt),
          _formatMaxPoints(row.maxPoints),
          row.submissionUrl ?? "",
          row.assignmentUrl ?? "",
        ],
      ),
    ];

    return const CsvEncoder().convert(data);
  }

  Future<void> exportUngradedReportCsv(List<UngradedReportRow> rows) async {
    await _exportRows(rows);
  }

  Future<String?> exportCsvFile(List<UngradedReportRow> rows) {
    return _exportRows(rows);
  }

  Future<String?> _exportRows(List<UngradedReportRow> rows) async {
    const suggestedName = "classroom-ungraded-report.csv";
    final location = await getSaveLocation(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: "CSV",
          extensions: ["csv"],
          mimeTypes: ["text/csv"],
          uniformTypeIdentifiers: ["public.comma-separated-values-text"],
        ),
      ],
      suggestedName: suggestedName,
      confirmButtonText: "Export",
    );
    if (location == null) {
      return null;
    }

    final targetPath = _ensureCsvExtension(location.path);
    final bytes = utf8.encode(buildCsv(rows));
    final file = XFile.fromData(
      bytes,
      mimeType: "text/csv",
      name: suggestedName,
      length: bytes.length,
    );
    await file.saveTo(targetPath);
    return targetPath;
  }

  String _formatState(SubmissionState state) {
    return switch (state) {
      SubmissionState.newSubmission => "New",
      SubmissionState.created => "Assigned",
      SubmissionState.turnedIn => "Turned in",
      SubmissionState.returned => "Returned",
      SubmissionState.reclaimedByStudent => "Taken back",
      SubmissionState.unknown => "Unknown",
    };
  }

  String _formatDate(DateFormat dateFormat, DateTime? value) {
    if (value == null) {
      return "";
    }
    return dateFormat.format(value.toLocal());
  }

  String _formatMaxPoints(double? value) {
    if (value == null) {
      return "";
    }
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  String _ensureCsvExtension(String path) {
    if (path.toLowerCase().endsWith(".csv")) {
      return path;
    }
    return "$path.csv";
  }
}
