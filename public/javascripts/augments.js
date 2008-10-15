

//setTimeout Shorthand
if (typeof Function.defer !== 'function') {
	Function.prototype.defer = function(){
		var func = this;
		var args = [];
		for (var i = 0; i < arguments.length - 1; i++) {
			args.push(arguments[i]);
		}
		setTimeout(function(){
			func(args);
		}, arguments[arguments.length - 1]);
	};
}

//New Object with Prototype, by Doug Crockford
if (typeof Object.child !== 'function') {
    Object.child = function (o) {
        function F() {}
        F.prototype = o;
        return new F();
    };
}

//New Object with Properties
if (typeof Object.create !== 'function') {
    Object.create = function (copy) {
        var result = {};
        for (i in copy) {
            if (typeof copy[i] == 'object') {
                result[i] = new Object.create(copy[i]);
            }
            else {
                result[i] = copy[i];
            }
        }
        result.prototype = copy;
        return result;
    };
}

//HTML Entity Replacement, by Doug Crockford
if (typeof String.entity !== 'function') {
	String.prototype.entity = function(){
		return this.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
	};
}

//String Escaping, by Doug Crockford
if (typeof String.escape !== 'function') {
	String.prototype.escape = function(){
		var o = '"';
		for (var i = 0; i < this.length; i++) {
			var c = this.charAt(i);
			if (c >= ' ') {
				if (c === '\\' || c === '"') {
					o += '\\';
				}
				o += c;
			}
			else {
				switch (c) {
					case '\b':
						o += '\\b';
						break;
					case '\f':
						o += '\\f';
						break;
					case '\n':
						o += '\\n';
						break;
					case '\r':
						o += '\\r';
						break;
					case '\t':
						o += '\\t';
						break;
					default:
						c = c.charCodeAt();
						o += '\\u00' + Math.floor(c / 16).toString(16) + (c % 16).toString(16);
				}
			}
		}
		return o + '"';
	};
}

//Trim Whitespace
if (typeof String.trim !== 'function') {
	String.prototype.trim = function(){
		return this.replace(/^\s+|\s+$/g, '');
	};
}

//Array Push (for legacy browsers)
if (typeof Array.push !== 'function') {
    Array.prototype.push = function() {
        for (var i=0; i < arguments.length; i++) {
            this[this.length] = arguments[i];
        }
        return this.length;
    };
}

//Array Shift (for legacy browsers)
if (typeof Array.shift !== 'function') {
    Array.prototype.shift = function(){
        var first = this[0];
        for (var i=0; i < this.length-1; i++) {
            this[i] = this[i+1];
        }
        delete this[this.length-1];
        this.length -= 1;
        return first;
    };
}