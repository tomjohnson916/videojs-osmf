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

// Create setters and getters for attributes
var api = videojs.Osmf.prototype,
  readWrite = 'preload,defaultPlaybackRate,playbackRate,autoplay,loop,mediaGroup,controller,controls,volume,muted,defaultMuted'.split(','),
  readOnly = 'error,networkState,readyState,seeking,initialTime,duration,startOffsetTime,paused,played,seekable,ended,videoTracks,audioTracks,videoWidth,videoHeight,textTracks'.split(',');
// Overridden: buffered, currentTime, currentSrc

/**
 * @this {*}
 * @private
 */
var createSetter = function(attr){
  console.log('create setter', attr);
  var attrUpper = attr.charAt(0).toUpperCase() + attr.slice(1);
  api['set'+attrUpper] = function(val){ return this.el_.vjs_setProperty(attr, val); };
};

/**
 * @this {*}
 * @private
 */
var createGetter = function(attr){
  api[attr] = function(){
    console.log('create getter', attr);
    return this.el_.vjs_getProperty(attr);
  };
};

(function(){
  var i;
  // Create getter and setters for all read/write attributes
  for (i = 0; i < readWrite.length; i++) {
    createGetter(readWrite[i]);
    createSetter(readWrite[i]);
  }

  // Create getters for read-only attributes
  for (i = 0; i < readOnly.length; i++) {
    createGetter(readOnly[i]);
  }
})();

// API Overrides
videojs.Osmf.prototype.play = function(){
  videojs.log('PLAY ME PLAYA');
};

videojs.Osmf.prototype.buffered = function(){
  return videojs.createTimeRange(0, this.el_.vjs_getProperty('buffered'));
};

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
videojs.Osmf.onReady = function(currentSwf) {
  videojs.log('OSMF', 'Ready', currentSwf);
  videojs.Flash.onReady(currentSwf);
};
videojs.Osmf.onError = function(currentSwf, err) {
  videojs.log('OSMF', 'Error', err);
  videojs.Flash.onError(currentSwf, err);
};
videojs.Osmf.onEvent = function(currentSwf, event) {
  videojs.log('OSMF', 'Event', event);
  videojs.Flash.onEvent(currentSwf, event);
};

//
videojs.Osmf.prototype.supportsFullScreen = function(){
  return false; // Flash does not allow fullscreen through javascript
};

videojs.Osmf.prototype.enterFullScreen = function(){
  return false;
};


// Setup a base object for osmf configuration
videojs.options.osmf = {};

// Add OSMF to the standard tech order
videojs.options.techOrder.push('osmf');