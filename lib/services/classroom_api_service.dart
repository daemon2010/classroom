import "../models/classroom_models.dart";

class ClassroomApiService {
  Future<ClassroomProfile?> getMyProfile() async {
    return null;
  }

  Future<List<ClassroomCourse>> listCourses() async {
    return const [];
  }

  Future<List<ClassroomCourseWork>> listCourseWork(String courseId) async {
    return const [];
  }

  Future<List<ClassroomSubmission>> listStudentSubmissions({
    required String courseId,
    required String courseWorkId,
  }) async {
    return const [];
  }
}
