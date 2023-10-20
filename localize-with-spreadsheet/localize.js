const {makeLocalizationFiles, makeLocalizationI18nFiles} = require('./core/localizator');

const API_KEY = "AIzaSyBhUlVwdp-q2U3EgvzhIWSd5tDu83ZNxKs";

const SPREADSHEET_ID = "1-r8nJkw-vQiIa6rskd2V2oLFNABbU_heWsIQlUO4hrw"

const iOSConfiguration = {
  apiKey: API_KEY,
  spreadsheetId: SPREADSHEET_ID,
  resourcesDir: '../Noveo Training/Noveo Training/Resources',
  targetName: 'Localizable.strings',
  range: 'Devices!A2:E100',
  keyColumnIndex: 0,
  format: 'ios',
  languages: [
    { folder: "en.lproj", columnIndex: 1 }, // english
    { folder: "fr.lproj", columnIndex: 2 },   // french
    { folder: "es.lproj", columnIndex: 3 },   // spanish
    { folder: "ru.lproj", columnIndex: 4 }    // russian
  ]
}

makeLocalizationFiles(iOSConfiguration)