import "package:flutter/material.dart";

import "../models/classroom_models.dart";

class CourseFilter extends StatelessWidget {
  const CourseFilter({
    required this.courses,
    required this.selectedCourseId,
    required this.onlyTurnedIn,
    required this.searchQuery,
    required this.onCourseChanged,
    required this.onOnlyTurnedInChanged,
    required this.onSearchChanged,
    super.key,
  });

  final List<ClassroomCourse> courses;
  final String? selectedCourseId;
  final bool onlyTurnedIn;
  final String searchQuery;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<bool> onOnlyTurnedInChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: DropdownButtonFormField<String?>(
            initialValue: selectedCourseId,
            decoration: const InputDecoration(
              labelText: "Class",
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text("All classes"),
              ),
              for (final course in courses)
                DropdownMenuItem<String?>(
                  value: course.id,
                  child: Text(_courseLabel(course)),
                ),
            ],
            onChanged: courses.isEmpty ? null : onCourseChanged,
          ),
        ),
        SizedBox(
          width: 390,
          child: TextFormField(
            initialValue: searchQuery,
            decoration: const InputDecoration(
              labelText: "Search",
              hintText: "Student, class, subject, or assignment",
              border: OutlineInputBorder(),
              isDense: true,
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        FilterChip(
          selected: onlyTurnedIn,
          onSelected: onOnlyTurnedInChanged,
          avatar: Icon(
            onlyTurnedIn
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            size: 18,
          ),
          label: const Text("Only show works turned in by students"),
        ),
      ],
    );
  }

  static String _courseLabel(ClassroomCourse course) {
    final section = course.section;
    if (section == null || section.isEmpty) {
      return course.name;
    }
    return "${course.name} - $section";
  }
}
