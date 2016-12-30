/* GUI search field input parsing */

var schema;

module.exports = function(sch) {
  schema = sch;
  return {
    execute: execute
  }
};

/* Parses raw input to global and path parts.
   Global string will be matched against all fields in db documents.
   Paths will limit matching to specific fields in db documents */
function execute(input, cb) {
  var matches = {
    // global: "alkfg"
    paths: [
      // { name: "title", query: "qrierui", type: "String" },
      // { name: "animated", query: true, type: "Boolean" },
      // { name: "ups", query: 300, type: "Number", comparison: ">" },
    ]
  };

  string = input.trim();

  // Sanitize input by escaping quotes
  string = string.replace(/(\\*)\"/g, function(match, backSlashes) {
    if (backSlashes.length % 2 == 0) {
        return "\\" + match;
    } else {
      return match; 
    }
  });

  // console.log("input string:", string);
  var path = findNextPath(string);
  if (path) {
    
    // Global match
    matches.global = string.substr(0, path.index - 2).toLowerCase();
    string = string.substr(path.index - 1);
    // console.log("global:", matches.global);

    // Paths
    var path;
    do {
      // Look for the next $pathName in the remaining string 
      if (!(path = findNextPath(string))) {
        return cb("Invalid path detected near '" + string + 
          "' in query '" + searchQuery + "'", null);
      }

      // Get path name and value
      if (!tryParsePathQuery(string, path)) {
        return cb("Invalid query detected in path '" + path.name);
      }

      // Get expected value type
      parsePathType(path);

      // console.log("Found path type", path.type);

      var lenQueryValue = path.query.value.length;

      // Get value as correct type
      if (path.type === "String") {
      } else if (path.type === "Boolean") {
        if (!tryParseBooleanQuery(path)) {
          return cb("Error: invalid query '" + path.query.value +
            "' detected in boolean path '" + path.name + "'." + 
            " Valid values: true|false|null", null);
        }
      } else if (path.type === "Number") {
        if (!tryParseNumberQuery(path)) {
          return cb("Error: invalid query '" + path.query.value + 
            "' detected in numeric path '" + path.name + "'." +
            " Valid values: comparison operator (==, !=, >, <, =>, =<)" +
            " followed by non-negative integer OR (==/!=) null", null);
        }
      } else {
        console.error("Unknown path type:", path.type);
        return cb("Internal server error", null);
      }

      string = string.substr(path.name.length + lenQueryValue + 3);

      var match = {
        name: path.name,
        type: path.type,
        query: path.query.value
      };

      // Comparison property only associated with number type
      if (path.type === "Number") {
        match.comparison = path.query.comparison;
      }

      matches.paths.push(match);
      
    } while (string.length > 0);

  } else {
    matches.global = string.toLowerCase();
  }

  // console.log(matches);
  cb(null, matches);
};

function tryParseBooleanQuery(path) {
  var value = path.query.value.toLowerCase();
  if (value == "true") path.query.value = true;
  else if (value == "false") path.query.value = false;
  else if (value == "null")  path.query.value = null;
  else return false;

  return true;
};

function tryParseNumberQuery(path) {
  var numberRegex = /^([!<=>]{0,2}) *(\d+|null)$/i;

  var queryComponentObject = path.query.value.match(numberRegex);
  if (queryComponentObject) {

    var comparison = queryComponentObject[1];
    if      (comparison == ">")  path.query.comparison = comparison;
    else if (comparison == "<")  path.query.comparison = comparison;
    else if (comparison == ">=") path.query.comparison = comparison;
    else if (comparison == "<=") path.query.comparison = comparison;
    else if (comparison == "==") path.query.comparison = comparison;
    else if (comparison == "!=") path.query.comparison = comparison;
    else if (comparison == "=")  path.query.comparison = "==";
    else if (comparison == "")   path.query.comparison = "==";
    else return false;

    var value = queryComponentObject[2].toLowerCase();
    path.query.value = value == "null" ? null : Number(value);

    return true;
  }
  return false;
};

/* Determine data type of the path in the query */
function parsePathType(path) {
  path.type = schema.types[schema.paths.indexOf(path.name)];
};

/* Extract value from after path in the query */
function tryParsePathQuery(string, path) {
  string = string.substr(path.index + path.name.length + 1);
  // console.log("tryParsePathQuery input:", string);
  var nextPath;
  if (nextPath = findNextPath(string)) {

    // console.log("tryParsePathQuery return:", 
      // string.substr(0, nextPath.index - 2).toLowerCase());
    path.query.value = string.substr(0, nextPath.index - 2).toLowerCase();
    return true;

  } else if (string.length > 0) {
    // console.log("tryParsePathQuery return:", string.toLowerCase()); 
    path.query.value = string.toLowerCase();
    return true;
  }
  return false;
};

/* Find the leftmost path in the string, if any */
function findNextPath(string) {
  var matchObjects = [];
  // console.log("findNextPath input:", string);

  // Find all paths in the rest of the input string
  for (var iPath = 0; iPath < schema.paths.length; ++iPath) {
    var path = schema.paths[iPath];
    var matchObject = string.match("(?:^|\\s)\\$(" + path + ")\\s", "i");

    if (matchObject) {
      matchObjects.push(matchObject);
    }
  }

  // Get the leftmost match
  if (matchObjects.length > 0) {
    var matchObject = matchObjects.reduce(function(a, b) {
      return a.index < b.index ? a : b;
    });

    var path = matchObject[1];
    // console.log("findNextPath return:", path.toLowerCase());
    return {
      name: path.toLowerCase(),
      index: string.indexOf(path),
      query: {}
    };
  } 
  // console.log("Next path not found");
  return null;
};