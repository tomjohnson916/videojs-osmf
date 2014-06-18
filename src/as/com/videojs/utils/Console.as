package com.videojs.utils {

import flash.external.ExternalInterface;
import flash.utils.describeType;

public final class Console {
  private static const USE_CONSOLE:Boolean = false;
  private static const CONSOLE_REFERENCE:String = "OSMF_Tech";
  /**
   Call the JS console API
   @private @static @function

   @param {String} method The JS console's method to call
   @param {Array} arguments The arguments to provide to the console
   */
  private static function call(method:String, ...arguments):void {
    try {
      if (USE_CONSOLE) {
        var currentTime:Number = new Date().time;
        var args:Array = ["window.console." + method, CONSOLE_REFERENCE],
          i:uint = 0, count:uint,
          nativeTypes:Array = ["boolean", "number", "string"];

        if (arguments.length) {
          arguments = arguments[0];
          count = arguments.length;

          for (; i < count; i++) {
            args.push(
              (nativeTypes.indexOf(typeof arguments[i]) !== -1 || arguments[i] === undefined || arguments[i] === null || arguments[i] is Array || arguments[i] is Date) ?
                arguments[i] : fix(arguments[i])
            );
          }
        }

        ExternalInterface.call.apply(null, args);
      }
    } catch (err:TypeError) {
      call("** Problem Console **");
    }

  }

  /**
   ExternalInterface won't allow to pass local variable to JS, so we have to correct these values
   @private @static @function

   @param {Object} obj The object to fix

   @returns {Object} The corrected object
   */
  private static function fix(obj:*):Object {
    var
      fixed:Object = {},
      accessor:XML,
      nativeTypes:Array = ["boolean", "number", "string"],
      property:String, value:*;

    for each (accessor in describeType(obj)..accessor.@name) {
      property = accessor.toString();
      value = obj[property];

      value = (nativeTypes.indexOf(typeof value) !== -1 || value is Array || value is Date) ? value : value.toString();

      fixed[property] = value;
    }

    for (property in obj) {
      value = obj[property];

      value = (nativeTypes.indexOf(typeof value) !== -1 || value is Array || value is Date) ? value : value.toString();

      fixed[property] = value;
    }

    return fixed;
  }

  public static function log(...arguments):void {
    call("log", arguments);
  }

  public static function info(...arguments):void {
    call("info", arguments);
  }

  public static function warn(...arguments):void {
    call("warn", arguments);
  }

  public static function error(...arguments):void {
    call("error", arguments);
  }

  public static function clear():void {
    call("clear");
  }

}

}
