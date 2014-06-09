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
    var source, settings;

    source = options.source;
    settings = player.options();

    player.osmf = this;

    console.log(source);

    options.swf = settings.osmf.swf;
    options.flashVars = {
      'playerId': player.id_,
      'readyFunction': 'videojs.Osmf.onReady',
      'eventProxyFunction': 'videojs.Osmf.onEvent',
      'errorEventProxyFunction': 'videojs.Osmf.onError'
    };

    videojs.Flash.call(this, player, options, ready);

    options.source = source;

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

// Event Handlers
videojs.Osmf.onReady = function(event) {
  videojs.log('OSMF', 'Ready', event);
  player.trigger('ready');
};
videojs.Osmf.onError = function(event) {
  videojs.log('OSMF', 'Error', event);
};
videojs.Osmf.onEvent = function(event) {
  videojs.log('OSMF', 'Event', event);
};

// Setup a base object for osmf configuration
videojs.options.osmf = {};

// Add OSMF to the standard tech order
videojs.options.techOrder.push('osmf');