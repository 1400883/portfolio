/* imgur viral album / cover image metadata sanitization and combining */

exports.image = function(img) {
  if (!img.hasOwnProperty("topic")) {

    // Image fetched via associated album -> delete values
    // that come from album when combined later together 
    delete img.title;
    delete img.datetime;
    delete img.views;
    delete img.comment_count;
    delete img.ups;
    delete img.downs;
    delete img.points;
    delete img.score;
  }

  // Delete other uninteresting entries

  delete img.id;
  delete img.vote;
  delete img.favorite;
  delete img.nsfw;
  delete img.section;
  delete img.account_url;
  delete img.account_id;
  delete img.is_ad;
  delete img.in_gallery;
  delete img.topic_id;
  delete img.gifv;
  delete img.mp4;
  delete img.mp4_size;
  delete img.looping;
  delete img.is_album;

  // Fix animated gif links. imgur server automatically
  // provides large stillshots ('h' in file name just)
  // before the extension.

  if (img.animated && img.link.substr(-3) == "gif") {
    img.link = img.link.replace(/h(?=\.gif$)/, "");
  }
}

exports.album = function(alb) {
  delete alb.id;
  delete alb.description;
  delete alb.cover;
  delete alb.cover_width;
  delete alb.cover_height;
  delete alb.account_url;
  delete alb.account_id;

  delete alb.privacy;
  delete alb.layout;
  delete alb.link;
  delete alb.is_album;
  delete alb.vote;
  delete alb.favorite;
  delete alb.nsfw;
  delete alb.section;
  delete alb.images_count;
  delete alb.in_gallery;
  delete alb.is_ad;
  delete alb.topic_id;
}

exports.combine = function(img, alb) {
  var metadata = {};

  for (var key in alb) {
    metadata[key] = alb[key];
  };

  for (var key in img) {
    metadata[key] = img[key];
  }
  return metadata;
}