/* Database connection creation */

var mongoose = require("mongoose");
mongoose.Promise = global.Promise;

module.exports = function(cb, db) {
  var defaults = {
    host: "localhost",
    name: "imgur",
    collection: "images",
    port: 27017
  };

  // Parse db parameter and fill blanks from defaults
  sanitizeParams();

  mongoose.connect("mongodb://" + db.host + ":" + db.port + "/" + db.name);

  mongoose.connection.on("error", function(error) {
    cb(error);
  });

  mongoose.connection.once("open", function() {
    console.log("Connected to mongoDB server @ port " + db.port);
    cb(null);
  });

  mongoose.collectionName = db.collection;

  return mongoose;

  function sanitizeParams() {
    if (typeof cb !== "function") {
      console.error("Error: 1st parameter in database connection " +
        "init must be a callback.");
      throw 1;
    }

    if (typeof db === "object") {

      if (!db.hasOwnProperty("name")) {
        db.name = defaults.name;
      } else if (typeof db.name !== "string") {
        db.name = defaults.name;
        console.error("Error: invalid database 'name' property type" +
          "in database connection init. Using default name", 
          defaults.name);
      }

      if (!db.hasOwnProperty("collection")) {
        db.collection = defaults.collection;
      } else if (typeof db.collection !== "string") {
        db.collection = defaults.collection;
        console.error("Error: invalid database 'collection' property type" +
          "in database connection init. Using default collection", 
          defaults.collection);
      }

      if (!db.hasOwnProperty("host")) {
        db.host = defaults.host;
      } else if (typeof db.host !== "string") {
        db.host = defaults.host;
        console.error("Error: invalid database 'host' property type" +
          "in database connection init. Using default host", 
          defaults.host);
      }

      if (!db.hasOwnProperty("port")) {
        db.port = defaults.port;
      } else if (typeof db.port !== "number" || parseInt(db.port) !== db.port) {
        console.error("Error: invalid database 'port' property value / type" +
          "in database connection init. Using default port", 
          defaults.port);
      }
    } else {
      if (db !== undefined) {
        console.error("Error: invalid database parameter type in database",
          "connection init. Falling back to defaults", defaults.db);
      }
      db = defaults;
    }
  }
}
