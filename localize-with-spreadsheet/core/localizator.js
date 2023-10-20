const fs = require('fs');
const readline = require('readline');
const {google} = require('googleapis');
const Line = require('./Line');
const FileWriter = require('./Writer').File;
const Transformer = require('./Transformer');
const makeResult = require('./TransformerI18n');

function makeLocalizationFiles(configuration) {
    const sheets = google.sheets({version: 'v4', auth: configuration.apiKey})
    sheets.spreadsheets.values.get({
      spreadsheetId: configuration.spreadsheetId,
      range: configuration.range,
    }, (err, res) => {
      if (err) {
          console.error('Fetching from Sheets API failed with error: ' + err)
          process.exit(1)
          return
      }
    
      const rows = res.data.values;
    
      if (rows.length) {
        console.log("Successfully fetched lines from the spreadsheet")

        configuration.languages.forEach(language => {
          const resoursePath = language.folder + "/" + configuration.targetName
          console.log("Creating " + resoursePath)

          const transformer = Transformer[configuration.format]
          
          const lines = rows.map(row => {
            return new Line(row[configuration.keyColumnIndex], row[language.columnIndex])
          })

          const writer = new FileWriter()
          const path = configuration.resourcesDir + "/" + resoursePath
          
          writer.write(path, undefined, lines, transformer, {})
        })

        console.log("All done!")
      } else {
        console.error('No data for transform found.')
        process.exit(1)
      }
    });
}

function makeLocalizationI18nFiles(configuration) {
  console.log("Fetching from Sheets API")
  const sheets = google.sheets({version: 'v4', auth: configuration.apiKey})
  sheets.spreadsheets.values.get({
    spreadsheetId: configuration.spreadsheetId,
    range: configuration.range,
  }, (err, res) => {
    if (err) {
        console.error('Fetching from Sheets API failed with error: ' + err)
        process.exit(1)
        return
    }
    const rows = res.data.values;
    if (rows.length) {
      console.log("Successfully fetched lines from the spreadsheet")
      configuration.languages.forEach(language => {
        const fileName = language.name+ ".json"
        const content = makeResult(rows, language.columnIndex)
        const writer = new FileWriter()
        const path = configuration.resourcesDir + "/" + fileName
        writer.I18nWrite(path,content, 'utf8')
      })
      console.log("All done!")
    } else {
      console.error('No data for transform found.')
      process.exit(1)
    }
  });
}




module.exports = {makeLocalizationFiles, makeLocalizationI18nFiles}