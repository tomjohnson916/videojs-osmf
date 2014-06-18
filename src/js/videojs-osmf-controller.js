(function(window, videojs, document, undefined) {
  /**
   }
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
    init: function (player, options, ready) {
      var source, settings;

      source = options.source;
      settings = player.options();

      player.osmf = this;
      options.swf = settings.osmf.swf;

      options.flashVars = {
        'playerId': player.id(),
        'readyFunction': 'videojs.Osmf.onReady',
        'eventProxyFunction': 'videojs.Osmf.onEvent',
        'errorEventProxyFunction': 'videojs.Osmf.onError'
      };

      videojs.Flash.call(this, player, options, ready);
      player.tech = this;
      player.tech.firstplay = false;
      player.tech.loadstart = false;
      player.on('loadeddata', videojs.Osmf.onLoadedData);

      options.source = source;
    }
  });

  videojs.Osmf.formats = {
    'application/adobe-f4m': 'F4M',
    'application/adobe-f4v': 'F4V'
  };

//

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
    var attrUpper = attr.charAt(0).toUpperCase() + attr.slice(1);
    api['set'+attrUpper] = function(val){
      return this.el_.vjs_setProperty(attr, val);
    };
  };

  /**
   * @this {*}
   * @private
   */
  var createGetter = function(attr){
    api[attr] = function(){
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

//

// TODO: Figure out rules of support.
  videojs.Osmf.isSupported = function () {
    return true;
  };

// TODO: Figure out rules of support.
  videojs.Osmf.canPlaySource = function (srcObj) {
    var type;

    if (!srcObj.type) {
      return '';
    }

    type = srcObj.type.replace(/;.*/, '').toLowerCase();

    if (type in videojs.Osmf.formats) {
      return 'maybe';
    }
  };

videojs.Osmf.prototype.play = function(){
  this.el_.vjs_play();
};

videojs.Osmf.prototype.paused = function(){
  return this.el_.vjs_paused();
};

videojs.Osmf.prototype.pause = function(){
  this.el_.vjs_pause();
};

videojs.Osmf.prototype.currentTime = function(value) {
  if(value) {
    this.el_.vjs_setProperty('currentTime');
  } else {
    return this.el_.vjs_getProperty('currentTime');
  }
};


// Event Handlers
  videojs.Osmf.onLoadedData = function() {
    // If autoplay, go
    if(player.options().autoplay) {
      player.play();
    }
  };

  videojs.Osmf.onReady = function (currentSwf) {
    videojs.log('OSMF', 'Ready', currentSwf);

    // Set the tech element
    this.el_ = document.getElementById(currentSwf);

    // Tell Flash tech we are ready
    videojs.Flash.onReady(currentSwf);

    // Source known on ready rule (i.e. load it)
    if(player.currentSrc() &&
      player.currentSrc().length > 0) {
      this.el_.vjs_src(player.currentSrc());
    }
  };

  videojs.Osmf.onError = function (currentSwf, err) {
    videojs.log('OSMF', 'Error', err);
    videojs.Flash.onError(currentSwf, err);
  };

  videojs.Osmf.onEvent = function (currentSwf, event) {
    // First Play Rules
    if(event === 'playing' && player.tech.firstplay === false) {
      videojs.log('OSMF', 'Event', currentSwf, 'loadstart');
      player.trigger('loadstart');
      player.tech.loadstart = true;

      videojs.log('OSMF', 'Event', currentSwf, 'firstplay');
      player.trigger('firstplay');
      player.tech.firstplay = true;
    }

    // Mux the ready event here {OSMF vs. VJS/HTML5}
    if(event === 'ready') {
      event = 'loadeddata';
    }

    // Fire via Flash tech
    videojs.Flash.onEvent(currentSwf, event);

    // Logging if not a timeupdate
    if(event!=='timeupdate') {
      videojs.log('OSMF', 'Event', currentSwf, event);
    }
  };
//

  videojs.Osmf.prototype.supportsFullScreen = function () {
    return false; // Flash does not allow fullscreen through javascript
  };

  videojs.Osmf.prototype.enterFullScreen = function () {
    return false;
  };


// Setup a base object for osmf configuration
  videojs.options.osmf = {};

// Add OSMF to the standard tech order
  videojs.options.techOrder.push('osmf');

})(window, window.videojs, document);