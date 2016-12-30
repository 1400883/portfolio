var schema = {
  image: require("./db-schema")
};

console.log(schema.image);
var connection = require("./db-connection")(function(error) {
  if (error) {
    console.error(error);
    // TODO: Halt server / inform client?
  } else {
    var Image = connection.db.model("Image", schema.image);
    // mongoose.model("Image", schema.image);

    Image.remove().exec(); 

    schema.paths = (function() {
      var paths = [];
      for (var path in Image.schema.obj) {
        paths.push(path);
      }
      return paths;
    })();

    schema.types = (function() {
      var types = [];
      for (var path in Image.schema.paths) {
        if (schema.paths.indexOf(path) > -1)
          types.push(Image.schema.paths[path].instance);
      }
      return types;
    })();

    exports.queryBuilder = require("./mongo-query-builder")(schema);
  }
});



/*
var db = mongoose.connection;
db.on('error', function(error) {
  console.error(error);
  // TODO: Halt server / inform client?
});

db.once('open', function() {
  console.log("Connected to mongoDB server @ port " + port);
  Image.remove().exec();
});
*/
exports.addDocument = function(metadata, cb) {
  var image = new Image();

  for (var key in metadata) {
    image[key] = metadata[key];
  }

  image.save(function(err) {
    if (err) cb(err);
    else cb(null);
  });
};

exports.searchDocuments = function(query, cb) {
  if (query.length == 0) query = "true";
  Image.$where(query).exec(cb);
};