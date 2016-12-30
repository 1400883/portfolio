/* Database search query builder */

// title:          { type: String, default: null },   /* The title of the image. */
// description:    { type: String, default: null },   /* Description of the image. */
// datetime:       { type: Number, default: null },   /* Time inserted into the gallery, epoch time */
// type:           { type: String, default: null },   /* Image MIME type. */
// animated:       { type: Boolean, default: null },  /* is the image animated */
// width:          { type: Number, default: null },   /* The width of the image in pixels */
// height:         { type: Number, default: null },   /* The height of the image in pixels */
// size:           { type: Number, default: null },   /* The size of the image in bytes */
// views:          { type: Number, default: null },   /* The number of image views */
// bandwidth:      { type: Number, default: null },   /* Bandwidth consumed by the image in bytes */
// link:           { type: String, default: null },   /* The direct link to the the image. (Note: if fetching an animated GIF that was over 20MB in original size, a .gif thumbnail will be returned) */
// comment_count:  { type: Number, default: null },   /* Number of comments on the gallery image. */
// topic:          { type: String, default: null },   /* Topic of the gallery image. */
// ups:            { type: Number, default: null },   /* Upvotes for the image */
// downs:          { type: Number, default: null },   /* Number of downvotes for the image */
// points:         { type: Number, default: null },   /* Upvotes minus downvotes */
// score:          { type: Number, default: null }    /* Imgur popularity score */

module.exports = function(schema) {
  var inputParser = require("./input-parser")(schema);

  var execute = function(rawInput, cb) {
    // Parse raw input into objects containing data compatible with the db
    inputParser.execute(rawInput, function(error, queryData) {
      if (error) {
        cb(error, null);
      } else {

        // Create actual db query

        // Global part
        var query = formGlobalQuery(schema, queryData);

        // Path-specific parts
        query += formPathQuery(schema, queryData);
        
        // if empty, make all-inclusive
        if (query.length == 0) query = "true";
        
        // console.log(query);
        cb(null, query);
      }
    });
  };

  function formGlobalQuery(schema, queryData) {
    var globalQuery = "";

    if (queryData.global.length > 0) {
      schema.paths.forEach(function(path) {

        if (queryData.global.toLowerCase() == "null") {
          globalQuery += 
            "(this." + path + " == null) || ";
        }
        globalQuery += 
          "(this." + path + " && this." + path + 
          ".toString().toLowerCase().includes(\"" + 
          queryData.global.toLowerCase() + "\")) || ";

      });
      globalQuery = globalQuery.replace(/\|\| $/, "");
      // console.log("Global query", globalQuery);
    }
    return globalQuery;
  };

  function formPathQuery(schema, queryData) {
    var pathQuery = "";
    var paths = queryData.paths;
    paths.forEach(function(path) {
      pathQuery += " || (";

      if (path.type === "String") {

        if (path.query.toLowerCase() == "null") {
          pathQuery += "this." + path.name + " == null || ";
        }
        pathQuery += "(this." + path.name + " && this." + path.name + 
          ".toLowerCase().includes(\"" + path.query.toLowerCase() + "\")))";

      } else if (path.type === "Number") {

        if (path.query == null) {
          pathQuery += "this." + path.name + " == null || ";
        }
        pathQuery += "(this." + path.name + " && this." + path.name + 
          " " + path.comparison + " " + path.query + "))";

      } else if (path.type === "Boolean") {

        if (path.query == null) {
          pathQuery += "this." + path.name + " == null || ";
        }
        pathQuery += "(this." + path.name + " && this." + path.name + 
          " == " + path.query + "))";
      }
    });

    if (queryData.global.length == 0) {
      // Only paths in the query -> remove leading " || " 
      pathQuery = pathQuery.substr(4);
    }
    // console.log("Path query", pathQuery);
    return pathQuery;
  };

  return {
    execute: execute
  }
};