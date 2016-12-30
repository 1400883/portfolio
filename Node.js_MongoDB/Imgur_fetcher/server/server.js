var express = require("express");
var app = express();
var httpServer = {
  instance: require("http").createServer(app),
  port:  3000
};
var io = require("socket.io")(httpServer.instance);
var path = require("path");

var imgur = require("./imgur");

var mongoose = require("./db-connection")(function(error) {
  if (error) {
    // TODO: Halt server / inform client?
    console.error(error);
  } else {
  }
});

var db = require("./dao")(mongoose);

var clientPath = path.resolve(__dirname, "../", "client/");

app.use("/", express.static(clientPath));

/***********************/
/* Socket.io callbacks */
/***********************/
io.on("connect", function(socket) {
  socket.on("loadMetadata", function(numImages) {    
    onLoadMetadata(numImages, socket);
  });

  socket.on("dbSearch", onDbSearch);

  socket.on("disconnect", function() {
    console.log("Client disconnected");
  });
});


function onLoadMetadata(numImages, socket) {
  var numRemaining = numImages;
  db.clear();
  imgur.getMetadata(numImages, function(error, dataFragment) {
    if (error) {
      socket.emit("loadProgress", error, null);
    } else {
      db.add(dataFragment.metadata, function(error) {
        if (error) console.error(error);
      });

      socket.emit("loadProgress", null, 
        Math.round((numImages - --numRemaining) / numImages * 100));
    }
  });
}

function onDbSearch(rawInput, cb) {
  db.queryBuilder.execute(rawInput, function(error, query) {
    if (error) {
      console.error(error);
      cb(error, null);
    } else {
      db.search(query, function(error, docs) {
        if (error) cb(error, null);
        else {
          // console.log(docs);
          cb(null, docs);
        }
      });
    }
  });
}

// HTTP server
httpServer.instance.listen(httpServer.port, function() {
  console.log("HTTP server listening @ port " + httpServer.port);
});

// Shut down gracefully
process.on('SIGINT', function() {
  if (mongoose && mongoose.connection) {
    mongoose.connection.close();
    console.log("Database connection closed");
  }
  process.exit();
})