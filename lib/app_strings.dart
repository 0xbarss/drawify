class AppStrings {
  static const Map<String, Map<String, String>> translations = {
    "TR": {
      "welcome": "Drawify'a Hoşgeldin",
      "description": "Sezgisel çizim araçlarımızla yaratıcılığınızı serbest bırakın. Hemen çizmeye başlayın!",
      "getStarted": "Hemen Başla",
      "inputs": "Girdiler",
      "canvas": "Çizim",
      "file": "Dosya",
      "addRow": "Satır Ekle",
      "viewFiles": "Görüntülenecek dosya yok",
      "filename": "Dosya İsmi",
      "enterFilename": "Dosya ismi girin",
      "savedSuccessfully": "Dosya başarıyla kaydedildi",
      "deletedSuccessfully": "Dosya başarıyla silindi",
      "save": "Kaydet",
      "cancel": "İptal",
      "saveJsonFile": "JSON Dosyası Kaydet",
      "length": "Uzunluk",
      "diameter": "Çap",
      "angle": "Açı (Yay)",
      "crossAngle": "Açı (Düzlem)",
      "width": "Genişlik",
      "height": "Yükseklik",
      "totalLength": "Toplam Uzunluk"
    },
    "EN": {
      "welcome": "Welcome to Drawify",
      "description": "Unleash your creativity with our intuitive drawing tools. Start sketching now!",
      "getStarted": "Get Started",
      "inputs": "Inputs",
      "canvas": "Canvas",
      "file": "File",
      "addRow": "Add Row",
      "viewFiles": "No files available",
      "filename": "Filename",
      "enterFilename": "Enter filename",
      "savedSuccessfully": "File saved successfully",
      "deletedSuccessfully": "File deleted successfully",
      "save": "Save",
      "cancel": "Cancel",
      "saveJsonFile": "Save JSON File",
      "diameter": "Diameter",
      "angle": "Angle (Arc)",
      "crossAngle": "Angle (Plane)",
      "width": "Width",
      "height": "Height",
      "totalLength": "Total Length"
    },
  };

  static String get(String key, String language) {
    return translations[language]?[key] ?? key;
  }
}