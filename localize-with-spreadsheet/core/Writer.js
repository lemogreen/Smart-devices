var fs = require('fs');
var EOL = '\n';

var Writer = function () {

};

Writer.prototype.write = function (filePath, lines, transformer) {

};


var FileWriter = function () {
};

FileWriter.prototype.write = function (filePath, encoding, lines, transformer, options) {
    var fileContent = '';
    if (fs.existsSync(filePath)) {
        fileContent = fs.readFileSync(filePath, encoding);
    }

    var valueToInsert = this.getTransformedLines(lines, transformer);

    var output = transformer.insert(fileContent, valueToInsert, options);

    writeFileAndCreateDirectoriesSync(filePath, output, 'utf8');
};

//https://gist.github.com/jrajav/4140206
var writeFileAndCreateDirectoriesSync = function (filepath, content, encoding) {
    var mkpath = require('mkpath');
    var path = require('path');

    var dirname = path.dirname(filepath);
    mkpath.sync(dirname);

    fs.writeFileSync(filepath, content, encoding);
};

FileWriter.prototype.getTransformedLines = function (lines, transformer) {
    var valueToInsert = transformer.empty();
    for (var i = 0; i < lines.length; i++) {
        var line = lines[i];
        var skipLine = false;
        if (line.hasData()) {
            var newValue = null
            if (line.isComment()) {
                newValue = transformer.transformComment(line.getComment());
            } else {
                newValue = transformer.transformKeyValue(line.getKey(), line.getValue());
            }
            valueToInsert = appendValueTo(valueToInsert, newValue);
            skipLine = newValue == null
        }

        if (!skipLine && (line.hasData() || line.isEmpty())) {
            valueToInsert = appendValueTo(valueToInsert, EOL);
        }
    }

    return valueToInsert;
}

var FakeWriter = function () {

};

FakeWriter.prototype.write = function (filePath, lines, transformer) {

};

FileWriter.prototype.I18nWrite =  (filepath, content, encoding)=> {
    var mkpath = require('mkpath');
    var path = require('path');
    var dirname = path.dirname(filepath);
    mkpath.sync(dirname);
    fs.writeFileSync(filepath, content, encoding);
};

module.exports = { File: FileWriter, Fake: FakeWriter };

function appendValueTo(container, value) {
    if (value == null) {
        /* Do nothing. */
    } else if (typeof container == 'string') {
        container += value
    } else if (typeof container == 'object') {
        container.push(value)
    }
    return container
}

