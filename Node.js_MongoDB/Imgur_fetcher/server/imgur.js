/* Access point to imgur-related behavior */

// Main imgur API interface 
var virals = require("./imgur-virals");

// Cover-image-from-album retriever using imgur API
var albumParser = require("./imgur-album-parser");

// Viral image / viral album metadata manipulation
var sanitize = require("./imgur-metadata-sanitize");

var numMaxImages = 200;

function isValidEntryCount(numImages) { 
  return typeof numImages === "number" && 
    numImages >= 1 && numImages <= numMaxImages;
};

/* Main interface to get viral metadata */
function getMetadata(numImages, cb) {
  if (!isValidEntryCount(numImages)) {
    cb("Error: invalid image count (choose 1-" + numMaxImages + ")", null);
  } else {
    virals.get(parseInt(numImages), function(error, results) {
      processVirals(error, results, cb);
    });
  }
};

function processVirals(error, results, cb) {
  if (error) {
    cb(error, null);
  } else {
    results.forEach(function(imageOrAlbum, idx) {

      // Some of the viral results are usually pointing to albums
      // and, as such, need to have the cover image data extracted
      // console.log(imageOrAlbum)
      if (imageOrAlbum.is_album) {
        var album = imageOrAlbum;
        albumParser.getData(album.cover, function(error, image) {
          if (error) {
            return cb(error, null);
          } else {

            // Combine viral album and its cover image 
            // metadata in a meaningful way

            sanitize.image(image);
            sanitize.album(album);
            var metadata = sanitize.combine(image, album);
            // console.log("album", metadata)
            cb(null, { metadata: metadata, index: idx });
          }
        });
      } else {
        var metadata = imageOrAlbum;
        sanitize.image(metadata);
        // console.log("image", metadata)
        cb(null, { metadata: metadata, index: idx });
      }
    });
  }
};

module.exports = {
  getMetadata: getMetadata
};