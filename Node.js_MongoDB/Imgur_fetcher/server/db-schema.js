/* Database schema */

var schema = {};

schema.model = require("mongoose").Schema({
  title:          { type: String, default: null },   /* The title of the image. */
  description:    { type: String, default: null },   /* Description of the image. */
  datetime:       { type: Number, default: null },   /* Time inserted into the gallery, epoch time */
  type:           { type: String, default: null },   /* Image MIME type. */
  animated:       { type: Boolean, default: null },  /* is the image animated */
  width:          { type: Number, default: null },   /* The width of the image in pixels */
  height:         { type: Number, default: null },   /* The height of the image in pixels */
  size:           { type: Number, default: null },   /* The size of the image in bytes */
  views:          { type: Number, default: null },   /* The number of image views */
  bandwidth:      { type: Number, default: null },   /* Bandwidth consumed by the image in bytes */
  link:           { type: String, default: null },   /* The direct link to the the image. (Note: if fetching an animated GIF that was over 20MB in original size, a .gif thumbnail will be returned) */
  comment_count:  { type: Number, default: null },   /* Number of comments on the gallery image. */
  topic:          { type: String, default: null },   /* Topic of the gallery image. */
  ups:            { type: Number, default: null },   /* Upvotes for the image */
  downs:          { type: Number, default: null },   /* Number of downvotes for the image */
  points:         { type: Number, default: null },   /* Upvotes minus downvotes */
  score:          { type: Number, default: null }    /* Imgur popularity score */
});

schema.paths = (function() {
  var paths = [];
  for (var path in schema.model.obj) {
    paths.push(path);
  }
  return paths;
})();

schema.types = (function() {
  var types = [];
  schema.paths.forEach(function(path) {
    if (schema.paths.indexOf(path) > -1) {
      types.push(schema.model.paths[path].instance);
    }
  });
  return types;
})();

// console.log(schema)

module.exports = schema;