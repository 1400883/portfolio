/* imgur API access */

var request = require("request");

var virals;

// Main virals gallery request options
var options = {
  url: "https://api.imgur.com/3/gallery/hot/viral/0.json",
  headers: {
    Authorization: require("./imgur-client-id")
  },
  json: true,

  // Gallery page switching
  urlPageRegex: /\d+(?=\.json)/,
  urlToNextPage: function() {
    var currentPage = Number(this.url.match(this.urlPageRegex)[0]);
    this.url = this.url.replace(this.urlPageRegex, currentPage + 1);
  }
};

// Interface to imgur viral metadata
function get(numImages, cb) {
  virals = [];
  request(options, function(error, response, body) {
    collect(error, response, body, numImages, cb);
  });
}

// Method to collect requested amount of virals, 
// possibly spun across several imgur gallery pages
function collect(error, response, body, numWanted, cb) {
  if (error) {
    cb(error, null);
  } else if (response.statusCode !== 200) {
    // showRateLimits(response);
    cb("Error: server returned status " + response.statusCode, null);
  } else {

    
    // showRateLimits(response);

    // At the time of writing, imgur API returns data for  
    // only 60 images on the first page of the main gallery

    var numNeeded = numWanted - virals.length;
    // console.log(virals.length, numNeeded)
    if (body.data.length < numNeeded) {

      // Not enough images on the current gallery page to satisfy
      // the need -> recurse deeper into gallery pages

      virals = virals.concat(body.data);
      options.urlToNextPage();
      request(options, function(error, response, body) {
        collect(error, response, body, numWanted, cb);
      });
    } else {

      // Sufficient amount of images found on the gallery page

      virals = virals.concat(body.data.slice(0, numNeeded));
      // console.log(virals.length)
      cb(null, virals);
    }
  }
};

/* Connection debugging */
function showRateLimits(res) {
  console.log(
    /* Total credits that can be allocated. */
    "X-RateLimit-UserLimit:", res.headers["x-ratelimit-userlimit"], "\n",

    /* Total credits available. */
    "X-RateLimit-UserRemaining:", res.headers["x-ratelimit-userremaining"], "\n",

    /* Timestamp (unix epoch) for when the credits will be reset. */
    "X-RateLimit-UserReset:", res.headers["x-ratelimit-userreset"], "\n",

    /* Total credits that can be allocated for the application in a day. */
    "X-RateLimit-ClientLimit:", res.headers["x-ratelimit-clientlimit"], "\n",

    /* Total credits remaining for the application in a day. */
    "X-RateLimit-ClientRemaining:", res.headers["x-ratelimit-clientremaining"], "\n");
};

module.exports = {
  get: get
}