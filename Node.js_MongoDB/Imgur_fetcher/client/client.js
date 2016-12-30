onload = function() {
  var socket = io();
  var searchTerm;

  /*************************************************/
  /* Element references + listener implementations */
  /*************************************************/
  var el = {
    spinner: {
      opts: {
        radius: 10,
        length: 7,
        position: "static",
        scale: 1.5
      }
    }, 
    progress: {},
    loadAnim: {
      ref: $("#load-anim")
    }, 
    guide: {
      ref: $("#guide-container")
    }, 
    search: {
      ref: $("#search-container")
    },
    searchResult: {
      ref: $("#search-result-container")
    },
    searchInput: {
      ref: $("#search-input"),
      listener: function() {
        searchTerm = $(this).val();
        // Delayed search (?)
        setTimeout(search, 0);
      }
    }, 
    searchInfoButton: {
      ref: $("#search-info-btn"),
      listener: function() {
        if ($(this).hasClass("unpressed-btn")) {
          el.guide.ref.show();
        } else {
          el.guide.ref.hide();
        }
        $(this).toggleClass("unpressed-btn");
        el.searchInput.ref.focus();
      }
    } 
  };

  // Loading spinner setup
  el.loadAnim.ref.spin(el.spinner.opts);
  el.spinner.ref = $("div.spinner");

  el.loadAnim.ref.append("<span>0%</span>");
  el.progress.ref = el.loadAnim.ref.children("span");

  el.spinner.ref.css({
    left: 0,
    display: "inline-block",
    width: "0.1px",
    top: "-" + (el.spinner.opts.radius + el.spinner.opts.length) + "px"
  });

  /************************/
  /* Event listener setup */
  /************************/
  el.searchInput.ref.on("input", el.searchInput.listener);
  el.searchInfoButton.ref.click(el.searchInfoButton.listener);


  /***********************/
  /* Socket.io callbacks */
  /***********************/
  socket.on("loadProgress", function(error, percentage) {
    if (error) {
      el.progress.ref.html(error);
    } else {
      el.progress.ref.html(percentage + "%");
      if (percentage == 100) {
        setTimeout(showPage, 1000);
      }
    }
  });

  /*******************/
  /* Database search */
  /*******************/
  function search() {
    socket.emit("dbSearch", searchTerm, function(error, results) {
      if (error) {
        console.log(error);
      } else {
        console.log(results);
        var html = "";
        results.forEach(function(result, idx) {
          html += 
            "<a target=\"_blank\" href=\"" + result.link + "\">" +
            "<img src=\"" + result.link.replace(/(\..{3}$)/, "s$1") + "\">" +
            "</a>";
        });
        el.searchResult.ref.html(html);
      }
    });
  };


  function showPage() {
    el.loadAnim.ref.spin(false);
    el.progress.ref.hide();
    el.search.ref.show();
  };

  
  // setTimeout(function() {
    // el.searchInput.ref.trigger("input");
  // });

  socket.emit("loadMetadata", 100);
};