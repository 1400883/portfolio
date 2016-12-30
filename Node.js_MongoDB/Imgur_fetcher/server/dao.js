/* Data Access Object */

var schema = require("./db-schema");

// Converts parsed user input to db query
var queryBuilder = require("./mongo-query-builder")(schema);

module.exports = function(connection) {
  if (typeof connection !== "object") {
    console.error("Error: parameter must be a connection object");
    throw 1;
  }

  var Image = connection.model("Image", 
    schema.model, connection.collectionName);

  // Image.remove().exec();
  clearDocuments(null);

  // Add to database 
  function addDocument(metadata, cb) {
    (new Image(metadata)).save(function(err, savedMetadata, numAffected) {
      if (err) cb(err);
      else cb(null, savedMetadata, numAffected);
    });
  };

  // Search in the database 
  function searchDocuments(query, cb) {
    Image.$where(query).exec(cb);
  };

  function clearDocuments(cb) {
    Image.remove(function(err) {
      if (err) { if (cb) cb(err); }
      else if (cb) { cb(null); }
    });
  };

  return {
    add: addDocument,
    search: searchDocuments,
    clear: clearDocuments,
    queryBuilder: queryBuilder
  };
};