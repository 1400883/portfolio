var chai = require("chai");
chai.use(require("chai-subset"));
var expect = chai.expect;

describe("Unit tests", function() {
  describe("Database", function() {
    var fs = require("fs");
    var path = require("path");
    var mongoose;
    var Model;
    var dao;

    var db = {
      name: "test_database",
      collection: "images",
      testDataFile: path.join(__filename, "..", "./helpers/db-test-data.json")
    };

    var testDataArray = JSON.parse(fs.readFileSync(db.testDataFile, "utf8"));

    before(function(done) {
      mongoose = require("../server/db-connection")( 
        function(error) { 
          if (error) { done(error); }
          else {
            dao = require("../server/dao")(mongoose);
            Model = mongoose.models.Image;

            // Clean start
            Model.remove().exec();
            done();
          }
        }, db);
    });

    beforeEach(function(done) {
      var isDone = false;

      // Init test db with some data

      // Uhhh...UGLY >.<
      testDataArray.slice(0, -1).forEach(function(dataEntry, i, a) {
        if (!isDone) {
          model = new Model(dataEntry);
          model.save(function(err) {
            if (!isDone) {
              if (err) { done(err); isDone = true; }
              else {
                Model.count(function(err, count) {
                  if (!isDone) {
                    if (err) { done(err); isDone = true; }
                    else if (count == testDataArray.length - 1) { 
                      done(); isDone = true; 
                    }
                  }
                });
              }
            }
          });
        }
      })
    });

    afterEach(function() {

      // Wipe test db documents
      Model.remove().exec();
    });

    after(function() {
      
      // Cleanup
      mongoose.connection.db.dropDatabase(function(err, result) {
        if (!err) { console.log("Test database removed"); }
        mongoose.connection.close();
        console.log("Database connection closed.");
      });
    });

    describe("#add", function() {

      it("should succeed with valid data", function(done) {
        var newMetadata = testDataArray[testDataArray.length - 1];
        Model.find().count(function(err, count) {
          if (err) { done(err); }
          else {
            expect(count).to.equal(4);
            dao.add(newMetadata, function(err, savedMetadata) {
              if (err) { done(err); }
              else {
                expect(savedMetadata).to.containSubset(newMetadata);
                Model.find().count(function(err, count) {
                  if (err) { done(err); }
                  else {
                    expect(count).to.equal(5);
                    done();
                  }
                });
              }
            });
          }
        });
      });

      it("should succeed with null/undefined/false data", function(done) {
        var newMetadata = testDataArray[testDataArray.length - 1];
        newMetadata.dummyfield = "abc";
        dao.add(null, function(err) {
          expect(err).to.be.null;
          dao.add(undefined, function(err) {
            expect(err).to.be.null;
            dao.add(false, function(err) {
              expect(err).to.be.null;

              done();
            });
          });
        });
      });

      it("should fail if data object fields contain incompatible type data", function(done) {
        var newMetadata = testDataArray[testDataArray.length - 1];
        newMetadata.downs = "abc";
        dao.add(newMetadata, function(err) {
          expect(err).not.to.be.null; 
          done();
        });
      });

      it("should fail if data object contains extra fields", function(done) {
        var newMetadata = testDataArray[testDataArray.length - 1];
        newMetadata.dummyfield = "abc";
        dao.add(newMetadata, function(err) {
          expect(err).not.to.be.null; 
          done();
        });
      });
    });

    describe("#search", function() {
      it("should succeed if query is valid", function(done) {
        var query = "true";
        dao.search(query, function(err, docs) {
          expect(err).to.be.null; 
          done();
        });
      });

      it("should return a correct result set on a matching valid query", 
        function(done) {
        var query = "this.title.toLowerCase().contains(\"a\")";
        Model.find({ title: /a/ }, function(err, results) {
          expect(err).to.be.null;
          dao.search(query, function(err, docs) {
            expect(err).to.be.null; 
            expect(JSON.stringify(docs)).to.equal(JSON.stringify(results))
            done();
          });
        });
      });

      it("should return an empty set on a valid query that matches no data", 
        function(done) {
        var query = "this.height > 5000";
        Model.find({ height: { $gt: 5000 }}).count(function(err, count) {
          expect(err).to.be.null; 
          dao.search(query, function(err, docs) {
            expect(err).to.be.null; 
            expect(count).to.equal(docs.length);
            expect(docs).to.be.empty;
            done();
          });
        });
      });

      it("should return an empty set if a syntactically correct query " +
        "points to a non-existent field", 
        function(done) {
        var query = "this.dummyProperty == \"absent\"";
        Model.find({ dummyProperty: "absent" }).count(function(err, count) {
          expect(err).to.be.null; 
          dao.search(query, function(err, docs) {
            expect(err).to.be.null; 
            expect(count).to.equal(docs.length);
            expect(docs).to.be.empty;
            done();
          });
        });
      });

      it("should fail if query is a garbled string", function(done) {
        var query = "sdf34";
        dao.search(query, function(err, docs) {
          expect(err).not.to.be.null; 
          done();
        });
      });
    });

    describe("#clear", function() {
      it("should result in empty database collection", function(done) {
        dao.clear(function(err) {
          expect(err).to.be.null;
          Model.find().count(function(err, count) {
            expect(err).to.be.null;
            expect(count).to.equal(0);
            done();
          });
        });
      });
    });
  });
});