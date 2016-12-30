/* imgur viral gallery album cover image data parser */

var request = require("request");

var options = {
  headers: {
    Authorization: require("./imgur-client-id")
  },
  json: true
};

module.exports = (function() {
  return { 
    // Get image metadata from album cover ID
    getData: function(coverID, cb) {
      options.url = "https://api.imgur.com/3/image/" + coverID;

      request(options, function(error, response, body) {
        if (error) {
          cb(error, null);
        } else if (response.statusCode !== 200) {
          cb("Error: server returned status " + response.statusCode, null);
        } else {
          cb(null, body.data);
        }
      });
    }
  };
})();