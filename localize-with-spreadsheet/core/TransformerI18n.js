var spacesPattern = "  ";
var prefix = "{\n";
var suffix = "}\n";
var maxWords = 1000;

function makeResult(values, valuesColumn) {
    var result = prefix;
  
    var previousNames = new Array();
    
    for(var line = 0; line < maxWords; line++) {
  
      if(values[line] === undefined || values[line][0] == "" || values[line][0] == undefined) continue; // skip empty lines
      var names = values[line][0].split("."); // get keys parts
      var nextNames = values[line + 1] ? values[line + 1][0].split(".") : null
      var equal = 0; // Number of equal components
      for(var i = 0; i < previousNames.length && i < names.length; i++) {
        // find the number of equal components
        if(previousNames[i] !== names[i]) {
          equal = i;
          break;
        }
      }
  
      var isLast = true;
      if (nextNames) {
        if (nextNames.length !== names.length) {
          isLast = names[names.length - 2] !== nextNames[names.length - 2]
        } else {
          for(var i = names.length - 2; i >= 0; i--) {
            isLast = nextNames[i] !== names[i]
            if (isLast) { break; }
          }
        }
      }
    
      for(var i = previousNames.length - 2; i >= equal; i--) {
        result += spaces(i) + (i !== equal ? "}\n" : "},\n"); // close brackets
      }
      for(var i = equal; i < names.length - 1; i++) result += spaces(i) + '"' + names[i] + '"' + ": {\n"; // open new levels
      result += spaces(names.length - 1) + '"' + names[names.length-1] + '"' + ': "' + escape(values[line][valuesColumn - 1]) + (isLast ? '"\n' : '",\n'); // add value
      previousNames = names;
    }
    
    for(var i = 0; i < previousNames.length - 1; i++) result += spaces(previousNames.length - i - 2) + (isLast ? "}\n" : "},\n"); // close outstanding brackets
    
    result += suffix; // add closing suffix
    
    return result;
  }
  
  // get the string of spaces of the specified length 
  function spaces(n) {
    var res = "";
    for(var i = 0; i < n+1; i++) res += spacesPattern;
    return res;
  }
  
  // escape special characters
  function escape(input) {
    var tmp = (input+"").replace(/\\/, "\\\\");
    // tmp = tmp.replace(/'/g, "\\\\'");
    tmp = tmp.replace(/"/g, '\\"');
    tmp = tmp.replace(/\n/g, "\\n");
    return tmp;
  }

  module.exports = makeResult