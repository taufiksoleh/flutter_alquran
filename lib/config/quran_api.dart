class QuranApi {
  static const String BASE_URL = "https://quran.kemenag.go.id/index.php/api/v1";

  // @/surat/0/{SURAT_ID}
  static String getSurat({int limit = 114}) {
    return "$BASE_URL/surat/0/$limit";
  }

  // @/ayatweb/{SURAT_ID}/0/{START_FROM}/{LIMIT}
  static String getAyat({int suratId, int startFrom, int limit}){
    return "$BASE_URL/ayatweb/$suratId/0/$startFrom/$limit";
  }
}