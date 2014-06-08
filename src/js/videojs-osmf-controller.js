/**
 * Video.JS OSMF Controller
 *
 * Use Video.js to initialize and control an OSMF supported swf
 *
 * @param {vjs.Player|Object} player
 * @param {Object=} options
 * @param {Function=} ready
 * @constructor
 */
videojs.Osmf = videojs.Flash.extend({
  init: function(player, options, ready) {
    videojs.log('init OSMF controller');

    var source, settings;

    source = options.source;
    settings = player.options();

    player.osmf = this;
    delete options.source;
    options.swf = settings.osmf.swf;

    console.log(options);

    videojs.Flash.call(this, player, options, ready);
    options.source = source;

    //videojs.Hls.prototype.src.call(this, options.source && options.source.src);

  }
});

videojs.Osmf.formats = {
  'application/adobe-f4m': 'F4M',
  'application/adobe-f4v': 'F4V'
};

// TODO: Figure out rules of support.
videojs.Osmf.isSupported = function(){
  return true;
};

// TODO: Figure out rules of support.
videojs.Osmf.canPlaySource = function(srcObj){
  var type;

  if (!srcObj.type) {
    return '';
  }

  type = srcObj.type.replace(/;.*/,'').toLowerCase();

  if (type in videojs.Osmf.formats) {
    return 'maybe';
  }
};

// TODO: Remove this because HLS should be doing this as well.
videojs.options.techOrder.push('hls');
//
videojs.options.osmf = {};
videojs.options.techOrder.push('osmf');