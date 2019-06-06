(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}




var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log = F2(function(tag, value)
{
	return value;
});

var _Debug_log_UNUSED = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString(value)
{
	return '<internals>';
}

function _Debug_toString_UNUSED(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File === 'function' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[94m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.bH.aW === region.cW.aW)
	{
		return 'on line ' + region.bH.aW;
	}
	return 'on lines ' + region.bH.aW + ' through ' + region.cW.aW;
}



// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	/**_UNUSED/
	if (x.$ === 'Set_elm_builtin')
	{
		x = elm$core$Set$toList(x);
		y = elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = elm$core$Dict$toList(x);
		y = elm$core$Dict$toList(y);
	}
	//*/

	/**/
	if (x.$ < 0)
	{
		x = elm$core$Dict$toList(x);
		y = elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**_UNUSED/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**/
	if (typeof x.$ === 'undefined')
	//*/
	/**_UNUSED/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? elm$core$Basics$LT : n ? elm$core$Basics$GT : elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0 = 0;
var _Utils_Tuple0_UNUSED = { $: '#0' };

function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2_UNUSED(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3_UNUSED(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr(c) { return c; }
function _Utils_chr_UNUSED(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil = { $: 0 };
var _List_Nil_UNUSED = { $: '[]' };

function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons_UNUSED(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === elm$core$Basics$EQ ? 0 : ord === elm$core$Basics$LT ? -1 : 1;
	}));
});



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return word
		? elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? elm$core$Maybe$Nothing
		: elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? elm$core$Maybe$Just(n) : elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




/**_UNUSED/
function _Json_errorToString(error)
{
	return elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? elm$core$Result$Ok(value)
		: (value instanceof String)
			? elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return elm$core$Result$Err(A2(elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return (elm$core$Result$isOk(result)) ? result : elm$core$Result$Err(A2(elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return (elm$core$Result$isOk(result)) ? result : elm$core$Result$Err(A2(elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!elm$core$Result$isOk(result))
					{
						return elm$core$Result$Err(A2(elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return elm$core$Result$Ok(elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if (elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return elm$core$Result$Err(elm$json$Json$Decode$OneOf(elm$core$List$reverse(errors)));

		case 1:
			return elm$core$Result$Err(A2(elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!elm$core$Result$isOk(result))
		{
			return elm$core$Result$Err(A2(elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2(elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return elm$core$Result$Err(A2(elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
function _Json_unwrap_UNUSED(value) { return value.a; }

function _Json_wrap(value) { return value; }
function _Json_unwrap(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});


/*
 * Copyright (c) 2010 Mozilla Corporation
 * Copyright (c) 2010 Vladimir Vukicevic
 * Copyright (c) 2013 John Mayer
 * Copyright (c) 2018 Andrey Kuzmin
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

// Vector2

var _MJS_v2 = F2(function(x, y) {
    return new Float64Array([x, y]);
});

var _MJS_v2getX = function(a) {
    return a[0];
};

var _MJS_v2getY = function(a) {
    return a[1];
};

var _MJS_v2setX = F2(function(x, a) {
    return new Float64Array([x, a[1]]);
});

var _MJS_v2setY = F2(function(y, a) {
    return new Float64Array([a[0], y]);
});

var _MJS_v2toRecord = function(a) {
    return { n: a[0], o: a[1] };
};

var _MJS_v2fromRecord = function(r) {
    return new Float64Array([r.n, r.o]);
};

var _MJS_v2add = F2(function(a, b) {
    var r = new Float64Array(2);
    r[0] = a[0] + b[0];
    r[1] = a[1] + b[1];
    return r;
});

var _MJS_v2sub = F2(function(a, b) {
    var r = new Float64Array(2);
    r[0] = a[0] - b[0];
    r[1] = a[1] - b[1];
    return r;
});

var _MJS_v2negate = function(a) {
    var r = new Float64Array(2);
    r[0] = -a[0];
    r[1] = -a[1];
    return r;
};

var _MJS_v2direction = F2(function(a, b) {
    var r = new Float64Array(2);
    r[0] = a[0] - b[0];
    r[1] = a[1] - b[1];
    var im = 1.0 / _MJS_v2lengthLocal(r);
    r[0] = r[0] * im;
    r[1] = r[1] * im;
    return r;
});

function _MJS_v2lengthLocal(a) {
    return Math.sqrt(a[0] * a[0] + a[1] * a[1]);
}
var _MJS_v2length = _MJS_v2lengthLocal;

var _MJS_v2lengthSquared = function(a) {
    return a[0] * a[0] + a[1] * a[1];
};

var _MJS_v2distance = F2(function(a, b) {
    var dx = a[0] - b[0];
    var dy = a[1] - b[1];
    return Math.sqrt(dx * dx + dy * dy);
});

var _MJS_v2distanceSquared = F2(function(a, b) {
    var dx = a[0] - b[0];
    var dy = a[1] - b[1];
    return dx * dx + dy * dy;
});

var _MJS_v2normalize = function(a) {
    var r = new Float64Array(2);
    var im = 1.0 / _MJS_v2lengthLocal(a);
    r[0] = a[0] * im;
    r[1] = a[1] * im;
    return r;
};

var _MJS_v2scale = F2(function(k, a) {
    var r = new Float64Array(2);
    r[0] = a[0] * k;
    r[1] = a[1] * k;
    return r;
});

var _MJS_v2dot = F2(function(a, b) {
    return a[0] * b[0] + a[1] * b[1];
});

// Vector3

var _MJS_v3temp1Local = new Float64Array(3);
var _MJS_v3temp2Local = new Float64Array(3);
var _MJS_v3temp3Local = new Float64Array(3);

var _MJS_v3 = F3(function(x, y, z) {
    return new Float64Array([x, y, z]);
});

var _MJS_v3getX = function(a) {
    return a[0];
};

var _MJS_v3getY = function(a) {
    return a[1];
};

var _MJS_v3getZ = function(a) {
    return a[2];
};

var _MJS_v3setX = F2(function(x, a) {
    return new Float64Array([x, a[1], a[2]]);
});

var _MJS_v3setY = F2(function(y, a) {
    return new Float64Array([a[0], y, a[2]]);
});

var _MJS_v3setZ = F2(function(z, a) {
    return new Float64Array([a[0], a[1], z]);
});

var _MJS_v3toRecord = function(a) {
    return { n: a[0], o: a[1], fL: a[2] };
};

var _MJS_v3fromRecord = function(r) {
    return new Float64Array([r.n, r.o, r.fL]);
};

var _MJS_v3add = F2(function(a, b) {
    var r = new Float64Array(3);
    r[0] = a[0] + b[0];
    r[1] = a[1] + b[1];
    r[2] = a[2] + b[2];
    return r;
});

function _MJS_v3subLocal(a, b, r) {
    if (r === undefined) {
        r = new Float64Array(3);
    }
    r[0] = a[0] - b[0];
    r[1] = a[1] - b[1];
    r[2] = a[2] - b[2];
    return r;
}
var _MJS_v3sub = F2(_MJS_v3subLocal);

var _MJS_v3negate = function(a) {
    var r = new Float64Array(3);
    r[0] = -a[0];
    r[1] = -a[1];
    r[2] = -a[2];
    return r;
};

function _MJS_v3directionLocal(a, b, r) {
    if (r === undefined) {
        r = new Float64Array(3);
    }
    return _MJS_v3normalizeLocal(_MJS_v3subLocal(a, b, r), r);
}
var _MJS_v3direction = F2(_MJS_v3directionLocal);

function _MJS_v3lengthLocal(a) {
    return Math.sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]);
}
var _MJS_v3length = _MJS_v3lengthLocal;

var _MJS_v3lengthSquared = function(a) {
    return a[0] * a[0] + a[1] * a[1] + a[2] * a[2];
};

var _MJS_v3distance = F2(function(a, b) {
    var dx = a[0] - b[0];
    var dy = a[1] - b[1];
    var dz = a[2] - b[2];
    return Math.sqrt(dx * dx + dy * dy + dz * dz);
});

var _MJS_v3distanceSquared = F2(function(a, b) {
    var dx = a[0] - b[0];
    var dy = a[1] - b[1];
    var dz = a[2] - b[2];
    return dx * dx + dy * dy + dz * dz;
});

function _MJS_v3normalizeLocal(a, r) {
    if (r === undefined) {
        r = new Float64Array(3);
    }
    var im = 1.0 / _MJS_v3lengthLocal(a);
    r[0] = a[0] * im;
    r[1] = a[1] * im;
    r[2] = a[2] * im;
    return r;
}
var _MJS_v3normalize = _MJS_v3normalizeLocal;

var _MJS_v3scale = F2(function(k, a) {
    return new Float64Array([a[0] * k, a[1] * k, a[2] * k]);
});

var _MJS_v3dotLocal = function(a, b) {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
};
var _MJS_v3dot = F2(_MJS_v3dotLocal);

function _MJS_v3crossLocal(a, b, r) {
    if (r === undefined) {
        r = new Float64Array(3);
    }
    r[0] = a[1] * b[2] - a[2] * b[1];
    r[1] = a[2] * b[0] - a[0] * b[2];
    r[2] = a[0] * b[1] - a[1] * b[0];
    return r;
}
var _MJS_v3cross = F2(_MJS_v3crossLocal);

var _MJS_v3mul4x4 = F2(function(m, v) {
    var w;
    var tmp = _MJS_v3temp1Local;
    var r = new Float64Array(3);

    tmp[0] = m[3];
    tmp[1] = m[7];
    tmp[2] = m[11];
    w = _MJS_v3dotLocal(v, tmp) + m[15];
    tmp[0] = m[0];
    tmp[1] = m[4];
    tmp[2] = m[8];
    r[0] = (_MJS_v3dotLocal(v, tmp) + m[12]) / w;
    tmp[0] = m[1];
    tmp[1] = m[5];
    tmp[2] = m[9];
    r[1] = (_MJS_v3dotLocal(v, tmp) + m[13]) / w;
    tmp[0] = m[2];
    tmp[1] = m[6];
    tmp[2] = m[10];
    r[2] = (_MJS_v3dotLocal(v, tmp) + m[14]) / w;
    return r;
});

// Vector4

var _MJS_v4 = F4(function(x, y, z, w) {
    return new Float64Array([x, y, z, w]);
});

var _MJS_v4getX = function(a) {
    return a[0];
};

var _MJS_v4getY = function(a) {
    return a[1];
};

var _MJS_v4getZ = function(a) {
    return a[2];
};

var _MJS_v4getW = function(a) {
    return a[3];
};

var _MJS_v4setX = F2(function(x, a) {
    return new Float64Array([x, a[1], a[2], a[3]]);
});

var _MJS_v4setY = F2(function(y, a) {
    return new Float64Array([a[0], y, a[2], a[3]]);
});

var _MJS_v4setZ = F2(function(z, a) {
    return new Float64Array([a[0], a[1], z, a[3]]);
});

var _MJS_v4setW = F2(function(w, a) {
    return new Float64Array([a[0], a[1], a[2], w]);
});

var _MJS_v4toRecord = function(a) {
    return { n: a[0], o: a[1], fL: a[2], ed: a[3] };
};

var _MJS_v4fromRecord = function(r) {
    return new Float64Array([r.n, r.o, r.fL, r.ed]);
};

var _MJS_v4add = F2(function(a, b) {
    var r = new Float64Array(4);
    r[0] = a[0] + b[0];
    r[1] = a[1] + b[1];
    r[2] = a[2] + b[2];
    r[3] = a[3] + b[3];
    return r;
});

var _MJS_v4sub = F2(function(a, b) {
    var r = new Float64Array(4);
    r[0] = a[0] - b[0];
    r[1] = a[1] - b[1];
    r[2] = a[2] - b[2];
    r[3] = a[3] - b[3];
    return r;
});

var _MJS_v4negate = function(a) {
    var r = new Float64Array(4);
    r[0] = -a[0];
    r[1] = -a[1];
    r[2] = -a[2];
    r[3] = -a[3];
    return r;
};

var _MJS_v4direction = F2(function(a, b) {
    var r = new Float64Array(4);
    r[0] = a[0] - b[0];
    r[1] = a[1] - b[1];
    r[2] = a[2] - b[2];
    r[3] = a[3] - b[3];
    var im = 1.0 / _MJS_v4lengthLocal(r);
    r[0] = r[0] * im;
    r[1] = r[1] * im;
    r[2] = r[2] * im;
    r[3] = r[3] * im;
    return r;
});

function _MJS_v4lengthLocal(a) {
    return Math.sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2] + a[3] * a[3]);
}
var _MJS_v4length = _MJS_v4lengthLocal;

var _MJS_v4lengthSquared = function(a) {
    return a[0] * a[0] + a[1] * a[1] + a[2] * a[2] + a[3] * a[3];
};

var _MJS_v4distance = F2(function(a, b) {
    var dx = a[0] - b[0];
    var dy = a[1] - b[1];
    var dz = a[2] - b[2];
    var dw = a[3] - b[3];
    return Math.sqrt(dx * dx + dy * dy + dz * dz + dw * dw);
});

var _MJS_v4distanceSquared = F2(function(a, b) {
    var dx = a[0] - b[0];
    var dy = a[1] - b[1];
    var dz = a[2] - b[2];
    var dw = a[3] - b[3];
    return dx * dx + dy * dy + dz * dz + dw * dw;
});

var _MJS_v4normalize = function(a) {
    var r = new Float64Array(4);
    var im = 1.0 / _MJS_v4lengthLocal(a);
    r[0] = a[0] * im;
    r[1] = a[1] * im;
    r[2] = a[2] * im;
    r[3] = a[3] * im;
    return r;
};

var _MJS_v4scale = F2(function(k, a) {
    var r = new Float64Array(4);
    r[0] = a[0] * k;
    r[1] = a[1] * k;
    r[2] = a[2] * k;
    r[3] = a[3] * k;
    return r;
});

var _MJS_v4dot = F2(function(a, b) {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3];
});

// Matrix4

var _MJS_m4x4temp1Local = new Float64Array(16);
var _MJS_m4x4temp2Local = new Float64Array(16);

var _MJS_m4x4identity = new Float64Array([
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
]);

var _MJS_m4x4fromRecord = function(r) {
    var m = new Float64Array(16);
    m[0] = r.eR;
    m[1] = r.eT;
    m[2] = r.eV;
    m[3] = r.eX;
    m[4] = r.eS;
    m[5] = r.eU;
    m[6] = r.eW;
    m[7] = r.eY;
    m[8] = r.dh;
    m[9] = r.dj;
    m[10] = r.dl;
    m[11] = r.dn;
    m[12] = r.di;
    m[13] = r.dk;
    m[14] = r.dm;
    m[15] = r.$7;
    return m;
};

var _MJS_m4x4toRecord = function(m) {
    return {
        eR: m[0], eT: m[1], eV: m[2], eX: m[3],
        eS: m[4], eU: m[5], eW: m[6], eY: m[7],
        dh: m[8], dj: m[9], dl: m[10], dn: m[11],
        di: m[12], dk: m[13], dm: m[14], $7: m[15]
    };
};

var _MJS_m4x4inverse = function(m) {
    var r = new Float64Array(16);

    r[0] = m[5] * m[10] * m[15] - m[5] * m[11] * m[14] - m[9] * m[6] * m[15] +
        m[9] * m[7] * m[14] + m[13] * m[6] * m[11] - m[13] * m[7] * m[10];
    r[4] = -m[4] * m[10] * m[15] + m[4] * m[11] * m[14] + m[8] * m[6] * m[15] -
        m[8] * m[7] * m[14] - m[12] * m[6] * m[11] + m[12] * m[7] * m[10];
    r[8] = m[4] * m[9] * m[15] - m[4] * m[11] * m[13] - m[8] * m[5] * m[15] +
        m[8] * m[7] * m[13] + m[12] * m[5] * m[11] - m[12] * m[7] * m[9];
    r[12] = -m[4] * m[9] * m[14] + m[4] * m[10] * m[13] + m[8] * m[5] * m[14] -
        m[8] * m[6] * m[13] - m[12] * m[5] * m[10] + m[12] * m[6] * m[9];
    r[1] = -m[1] * m[10] * m[15] + m[1] * m[11] * m[14] + m[9] * m[2] * m[15] -
        m[9] * m[3] * m[14] - m[13] * m[2] * m[11] + m[13] * m[3] * m[10];
    r[5] = m[0] * m[10] * m[15] - m[0] * m[11] * m[14] - m[8] * m[2] * m[15] +
        m[8] * m[3] * m[14] + m[12] * m[2] * m[11] - m[12] * m[3] * m[10];
    r[9] = -m[0] * m[9] * m[15] + m[0] * m[11] * m[13] + m[8] * m[1] * m[15] -
        m[8] * m[3] * m[13] - m[12] * m[1] * m[11] + m[12] * m[3] * m[9];
    r[13] = m[0] * m[9] * m[14] - m[0] * m[10] * m[13] - m[8] * m[1] * m[14] +
        m[8] * m[2] * m[13] + m[12] * m[1] * m[10] - m[12] * m[2] * m[9];
    r[2] = m[1] * m[6] * m[15] - m[1] * m[7] * m[14] - m[5] * m[2] * m[15] +
        m[5] * m[3] * m[14] + m[13] * m[2] * m[7] - m[13] * m[3] * m[6];
    r[6] = -m[0] * m[6] * m[15] + m[0] * m[7] * m[14] + m[4] * m[2] * m[15] -
        m[4] * m[3] * m[14] - m[12] * m[2] * m[7] + m[12] * m[3] * m[6];
    r[10] = m[0] * m[5] * m[15] - m[0] * m[7] * m[13] - m[4] * m[1] * m[15] +
        m[4] * m[3] * m[13] + m[12] * m[1] * m[7] - m[12] * m[3] * m[5];
    r[14] = -m[0] * m[5] * m[14] + m[0] * m[6] * m[13] + m[4] * m[1] * m[14] -
        m[4] * m[2] * m[13] - m[12] * m[1] * m[6] + m[12] * m[2] * m[5];
    r[3] = -m[1] * m[6] * m[11] + m[1] * m[7] * m[10] + m[5] * m[2] * m[11] -
        m[5] * m[3] * m[10] - m[9] * m[2] * m[7] + m[9] * m[3] * m[6];
    r[7] = m[0] * m[6] * m[11] - m[0] * m[7] * m[10] - m[4] * m[2] * m[11] +
        m[4] * m[3] * m[10] + m[8] * m[2] * m[7] - m[8] * m[3] * m[6];
    r[11] = -m[0] * m[5] * m[11] + m[0] * m[7] * m[9] + m[4] * m[1] * m[11] -
        m[4] * m[3] * m[9] - m[8] * m[1] * m[7] + m[8] * m[3] * m[5];
    r[15] = m[0] * m[5] * m[10] - m[0] * m[6] * m[9] - m[4] * m[1] * m[10] +
        m[4] * m[2] * m[9] + m[8] * m[1] * m[6] - m[8] * m[2] * m[5];

    var det = m[0] * r[0] + m[1] * r[4] + m[2] * r[8] + m[3] * r[12];

    if (det === 0) {
        return elm$core$Maybe$Nothing;
    }

    det = 1.0 / det;

    for (var i = 0; i < 16; i = i + 1) {
        r[i] = r[i] * det;
    }

    return elm$core$Maybe$Just(r);
};

var _MJS_m4x4inverseOrthonormal = function(m) {
    var r = _MJS_m4x4transposeLocal(m);
    var t = [m[12], m[13], m[14]];
    r[3] = r[7] = r[11] = 0;
    r[12] = -_MJS_v3dotLocal([r[0], r[4], r[8]], t);
    r[13] = -_MJS_v3dotLocal([r[1], r[5], r[9]], t);
    r[14] = -_MJS_v3dotLocal([r[2], r[6], r[10]], t);
    return r;
};

function _MJS_m4x4makeFrustumLocal(left, right, bottom, top, znear, zfar) {
    var r = new Float64Array(16);

    r[0] = 2 * znear / (right - left);
    r[1] = 0;
    r[2] = 0;
    r[3] = 0;
    r[4] = 0;
    r[5] = 2 * znear / (top - bottom);
    r[6] = 0;
    r[7] = 0;
    r[8] = (right + left) / (right - left);
    r[9] = (top + bottom) / (top - bottom);
    r[10] = -(zfar + znear) / (zfar - znear);
    r[11] = -1;
    r[12] = 0;
    r[13] = 0;
    r[14] = -2 * zfar * znear / (zfar - znear);
    r[15] = 0;

    return r;
}
var _MJS_m4x4makeFrustum = F6(_MJS_m4x4makeFrustumLocal);

var _MJS_m4x4makePerspective = F4(function(fovy, aspect, znear, zfar) {
    var ymax = znear * Math.tan(fovy * Math.PI / 360.0);
    var ymin = -ymax;
    var xmin = ymin * aspect;
    var xmax = ymax * aspect;

    return _MJS_m4x4makeFrustumLocal(xmin, xmax, ymin, ymax, znear, zfar);
});

function _MJS_m4x4makeOrthoLocal(left, right, bottom, top, znear, zfar) {
    var r = new Float64Array(16);

    r[0] = 2 / (right - left);
    r[1] = 0;
    r[2] = 0;
    r[3] = 0;
    r[4] = 0;
    r[5] = 2 / (top - bottom);
    r[6] = 0;
    r[7] = 0;
    r[8] = 0;
    r[9] = 0;
    r[10] = -2 / (zfar - znear);
    r[11] = 0;
    r[12] = -(right + left) / (right - left);
    r[13] = -(top + bottom) / (top - bottom);
    r[14] = -(zfar + znear) / (zfar - znear);
    r[15] = 1;

    return r;
}
var _MJS_m4x4makeOrtho = F6(_MJS_m4x4makeOrthoLocal);

var _MJS_m4x4makeOrtho2D = F4(function(left, right, bottom, top) {
    return _MJS_m4x4makeOrthoLocal(left, right, bottom, top, -1, 1);
});

function _MJS_m4x4mulLocal(a, b) {
    var r = new Float64Array(16);
    var a11 = a[0];
    var a21 = a[1];
    var a31 = a[2];
    var a41 = a[3];
    var a12 = a[4];
    var a22 = a[5];
    var a32 = a[6];
    var a42 = a[7];
    var a13 = a[8];
    var a23 = a[9];
    var a33 = a[10];
    var a43 = a[11];
    var a14 = a[12];
    var a24 = a[13];
    var a34 = a[14];
    var a44 = a[15];
    var b11 = b[0];
    var b21 = b[1];
    var b31 = b[2];
    var b41 = b[3];
    var b12 = b[4];
    var b22 = b[5];
    var b32 = b[6];
    var b42 = b[7];
    var b13 = b[8];
    var b23 = b[9];
    var b33 = b[10];
    var b43 = b[11];
    var b14 = b[12];
    var b24 = b[13];
    var b34 = b[14];
    var b44 = b[15];

    r[0] = a11 * b11 + a12 * b21 + a13 * b31 + a14 * b41;
    r[1] = a21 * b11 + a22 * b21 + a23 * b31 + a24 * b41;
    r[2] = a31 * b11 + a32 * b21 + a33 * b31 + a34 * b41;
    r[3] = a41 * b11 + a42 * b21 + a43 * b31 + a44 * b41;
    r[4] = a11 * b12 + a12 * b22 + a13 * b32 + a14 * b42;
    r[5] = a21 * b12 + a22 * b22 + a23 * b32 + a24 * b42;
    r[6] = a31 * b12 + a32 * b22 + a33 * b32 + a34 * b42;
    r[7] = a41 * b12 + a42 * b22 + a43 * b32 + a44 * b42;
    r[8] = a11 * b13 + a12 * b23 + a13 * b33 + a14 * b43;
    r[9] = a21 * b13 + a22 * b23 + a23 * b33 + a24 * b43;
    r[10] = a31 * b13 + a32 * b23 + a33 * b33 + a34 * b43;
    r[11] = a41 * b13 + a42 * b23 + a43 * b33 + a44 * b43;
    r[12] = a11 * b14 + a12 * b24 + a13 * b34 + a14 * b44;
    r[13] = a21 * b14 + a22 * b24 + a23 * b34 + a24 * b44;
    r[14] = a31 * b14 + a32 * b24 + a33 * b34 + a34 * b44;
    r[15] = a41 * b14 + a42 * b24 + a43 * b34 + a44 * b44;

    return r;
}
var _MJS_m4x4mul = F2(_MJS_m4x4mulLocal);

var _MJS_m4x4mulAffine = F2(function(a, b) {
    var r = new Float64Array(16);
    var a11 = a[0];
    var a21 = a[1];
    var a31 = a[2];
    var a12 = a[4];
    var a22 = a[5];
    var a32 = a[6];
    var a13 = a[8];
    var a23 = a[9];
    var a33 = a[10];
    var a14 = a[12];
    var a24 = a[13];
    var a34 = a[14];

    var b11 = b[0];
    var b21 = b[1];
    var b31 = b[2];
    var b12 = b[4];
    var b22 = b[5];
    var b32 = b[6];
    var b13 = b[8];
    var b23 = b[9];
    var b33 = b[10];
    var b14 = b[12];
    var b24 = b[13];
    var b34 = b[14];

    r[0] = a11 * b11 + a12 * b21 + a13 * b31;
    r[1] = a21 * b11 + a22 * b21 + a23 * b31;
    r[2] = a31 * b11 + a32 * b21 + a33 * b31;
    r[3] = 0;
    r[4] = a11 * b12 + a12 * b22 + a13 * b32;
    r[5] = a21 * b12 + a22 * b22 + a23 * b32;
    r[6] = a31 * b12 + a32 * b22 + a33 * b32;
    r[7] = 0;
    r[8] = a11 * b13 + a12 * b23 + a13 * b33;
    r[9] = a21 * b13 + a22 * b23 + a23 * b33;
    r[10] = a31 * b13 + a32 * b23 + a33 * b33;
    r[11] = 0;
    r[12] = a11 * b14 + a12 * b24 + a13 * b34 + a14;
    r[13] = a21 * b14 + a22 * b24 + a23 * b34 + a24;
    r[14] = a31 * b14 + a32 * b24 + a33 * b34 + a34;
    r[15] = 1;

    return r;
});

var _MJS_m4x4makeRotate = F2(function(angle, axis) {
    var r = new Float64Array(16);
    axis = _MJS_v3normalizeLocal(axis, _MJS_v3temp1Local);
    var x = axis[0];
    var y = axis[1];
    var z = axis[2];
    var c = Math.cos(angle);
    var c1 = 1 - c;
    var s = Math.sin(angle);

    r[0] = x * x * c1 + c;
    r[1] = y * x * c1 + z * s;
    r[2] = z * x * c1 - y * s;
    r[3] = 0;
    r[4] = x * y * c1 - z * s;
    r[5] = y * y * c1 + c;
    r[6] = y * z * c1 + x * s;
    r[7] = 0;
    r[8] = x * z * c1 + y * s;
    r[9] = y * z * c1 - x * s;
    r[10] = z * z * c1 + c;
    r[11] = 0;
    r[12] = 0;
    r[13] = 0;
    r[14] = 0;
    r[15] = 1;

    return r;
});

var _MJS_m4x4rotate = F3(function(angle, axis, m) {
    var r = new Float64Array(16);
    var im = 1.0 / _MJS_v3lengthLocal(axis);
    var x = axis[0] * im;
    var y = axis[1] * im;
    var z = axis[2] * im;
    var c = Math.cos(angle);
    var c1 = 1 - c;
    var s = Math.sin(angle);
    var xs = x * s;
    var ys = y * s;
    var zs = z * s;
    var xyc1 = x * y * c1;
    var xzc1 = x * z * c1;
    var yzc1 = y * z * c1;
    var t11 = x * x * c1 + c;
    var t21 = xyc1 + zs;
    var t31 = xzc1 - ys;
    var t12 = xyc1 - zs;
    var t22 = y * y * c1 + c;
    var t32 = yzc1 + xs;
    var t13 = xzc1 + ys;
    var t23 = yzc1 - xs;
    var t33 = z * z * c1 + c;
    var m11 = m[0], m21 = m[1], m31 = m[2], m41 = m[3];
    var m12 = m[4], m22 = m[5], m32 = m[6], m42 = m[7];
    var m13 = m[8], m23 = m[9], m33 = m[10], m43 = m[11];
    var m14 = m[12], m24 = m[13], m34 = m[14], m44 = m[15];

    r[0] = m11 * t11 + m12 * t21 + m13 * t31;
    r[1] = m21 * t11 + m22 * t21 + m23 * t31;
    r[2] = m31 * t11 + m32 * t21 + m33 * t31;
    r[3] = m41 * t11 + m42 * t21 + m43 * t31;
    r[4] = m11 * t12 + m12 * t22 + m13 * t32;
    r[5] = m21 * t12 + m22 * t22 + m23 * t32;
    r[6] = m31 * t12 + m32 * t22 + m33 * t32;
    r[7] = m41 * t12 + m42 * t22 + m43 * t32;
    r[8] = m11 * t13 + m12 * t23 + m13 * t33;
    r[9] = m21 * t13 + m22 * t23 + m23 * t33;
    r[10] = m31 * t13 + m32 * t23 + m33 * t33;
    r[11] = m41 * t13 + m42 * t23 + m43 * t33;
    r[12] = m14,
    r[13] = m24;
    r[14] = m34;
    r[15] = m44;

    return r;
});

function _MJS_m4x4makeScale3Local(x, y, z) {
    var r = new Float64Array(16);

    r[0] = x;
    r[1] = 0;
    r[2] = 0;
    r[3] = 0;
    r[4] = 0;
    r[5] = y;
    r[6] = 0;
    r[7] = 0;
    r[8] = 0;
    r[9] = 0;
    r[10] = z;
    r[11] = 0;
    r[12] = 0;
    r[13] = 0;
    r[14] = 0;
    r[15] = 1;

    return r;
}
var _MJS_m4x4makeScale3 = F3(_MJS_m4x4makeScale3Local);

var _MJS_m4x4makeScale = function(v) {
    return _MJS_m4x4makeScale3Local(v[0], v[1], v[2]);
};

var _MJS_m4x4scale3 = F4(function(x, y, z, m) {
    var r = new Float64Array(16);

    r[0] = m[0] * x;
    r[1] = m[1] * x;
    r[2] = m[2] * x;
    r[3] = m[3] * x;
    r[4] = m[4] * y;
    r[5] = m[5] * y;
    r[6] = m[6] * y;
    r[7] = m[7] * y;
    r[8] = m[8] * z;
    r[9] = m[9] * z;
    r[10] = m[10] * z;
    r[11] = m[11] * z;
    r[12] = m[12];
    r[13] = m[13];
    r[14] = m[14];
    r[15] = m[15];

    return r;
});

var _MJS_m4x4scale = F2(function(v, m) {
    var r = new Float64Array(16);
    var x = v[0];
    var y = v[1];
    var z = v[2];

    r[0] = m[0] * x;
    r[1] = m[1] * x;
    r[2] = m[2] * x;
    r[3] = m[3] * x;
    r[4] = m[4] * y;
    r[5] = m[5] * y;
    r[6] = m[6] * y;
    r[7] = m[7] * y;
    r[8] = m[8] * z;
    r[9] = m[9] * z;
    r[10] = m[10] * z;
    r[11] = m[11] * z;
    r[12] = m[12];
    r[13] = m[13];
    r[14] = m[14];
    r[15] = m[15];

    return r;
});

function _MJS_m4x4makeTranslate3Local(x, y, z) {
    var r = new Float64Array(16);

    r[0] = 1;
    r[1] = 0;
    r[2] = 0;
    r[3] = 0;
    r[4] = 0;
    r[5] = 1;
    r[6] = 0;
    r[7] = 0;
    r[8] = 0;
    r[9] = 0;
    r[10] = 1;
    r[11] = 0;
    r[12] = x;
    r[13] = y;
    r[14] = z;
    r[15] = 1;

    return r;
}
var _MJS_m4x4makeTranslate3 = F3(_MJS_m4x4makeTranslate3Local);

var _MJS_m4x4makeTranslate = function(v) {
    return _MJS_m4x4makeTranslate3Local(v[0], v[1], v[2]);
};

var _MJS_m4x4translate3 = F4(function(x, y, z, m) {
    var r = new Float64Array(16);
    var m11 = m[0];
    var m21 = m[1];
    var m31 = m[2];
    var m41 = m[3];
    var m12 = m[4];
    var m22 = m[5];
    var m32 = m[6];
    var m42 = m[7];
    var m13 = m[8];
    var m23 = m[9];
    var m33 = m[10];
    var m43 = m[11];

    r[0] = m11;
    r[1] = m21;
    r[2] = m31;
    r[3] = m41;
    r[4] = m12;
    r[5] = m22;
    r[6] = m32;
    r[7] = m42;
    r[8] = m13;
    r[9] = m23;
    r[10] = m33;
    r[11] = m43;
    r[12] = m11 * x + m12 * y + m13 * z + m[12];
    r[13] = m21 * x + m22 * y + m23 * z + m[13];
    r[14] = m31 * x + m32 * y + m33 * z + m[14];
    r[15] = m41 * x + m42 * y + m43 * z + m[15];

    return r;
});

var _MJS_m4x4translate = F2(function(v, m) {
    var r = new Float64Array(16);
    var x = v[0];
    var y = v[1];
    var z = v[2];
    var m11 = m[0];
    var m21 = m[1];
    var m31 = m[2];
    var m41 = m[3];
    var m12 = m[4];
    var m22 = m[5];
    var m32 = m[6];
    var m42 = m[7];
    var m13 = m[8];
    var m23 = m[9];
    var m33 = m[10];
    var m43 = m[11];

    r[0] = m11;
    r[1] = m21;
    r[2] = m31;
    r[3] = m41;
    r[4] = m12;
    r[5] = m22;
    r[6] = m32;
    r[7] = m42;
    r[8] = m13;
    r[9] = m23;
    r[10] = m33;
    r[11] = m43;
    r[12] = m11 * x + m12 * y + m13 * z + m[12];
    r[13] = m21 * x + m22 * y + m23 * z + m[13];
    r[14] = m31 * x + m32 * y + m33 * z + m[14];
    r[15] = m41 * x + m42 * y + m43 * z + m[15];

    return r;
});

var _MJS_m4x4makeLookAt = F3(function(eye, center, up) {
    var z = _MJS_v3directionLocal(eye, center, _MJS_v3temp1Local);
    var x = _MJS_v3normalizeLocal(_MJS_v3crossLocal(up, z, _MJS_v3temp2Local), _MJS_v3temp2Local);
    var y = _MJS_v3normalizeLocal(_MJS_v3crossLocal(z, x, _MJS_v3temp3Local), _MJS_v3temp3Local);
    var tm1 = _MJS_m4x4temp1Local;
    var tm2 = _MJS_m4x4temp2Local;

    tm1[0] = x[0];
    tm1[1] = y[0];
    tm1[2] = z[0];
    tm1[3] = 0;
    tm1[4] = x[1];
    tm1[5] = y[1];
    tm1[6] = z[1];
    tm1[7] = 0;
    tm1[8] = x[2];
    tm1[9] = y[2];
    tm1[10] = z[2];
    tm1[11] = 0;
    tm1[12] = 0;
    tm1[13] = 0;
    tm1[14] = 0;
    tm1[15] = 1;

    tm2[0] = 1; tm2[1] = 0; tm2[2] = 0; tm2[3] = 0;
    tm2[4] = 0; tm2[5] = 1; tm2[6] = 0; tm2[7] = 0;
    tm2[8] = 0; tm2[9] = 0; tm2[10] = 1; tm2[11] = 0;
    tm2[12] = -eye[0]; tm2[13] = -eye[1]; tm2[14] = -eye[2]; tm2[15] = 1;

    return _MJS_m4x4mulLocal(tm1, tm2);
});


function _MJS_m4x4transposeLocal(m) {
    var r = new Float64Array(16);

    r[0] = m[0]; r[1] = m[4]; r[2] = m[8]; r[3] = m[12];
    r[4] = m[1]; r[5] = m[5]; r[6] = m[9]; r[7] = m[13];
    r[8] = m[2]; r[9] = m[6]; r[10] = m[10]; r[11] = m[14];
    r[12] = m[3]; r[13] = m[7]; r[14] = m[11]; r[15] = m[15];

    return r;
}
var _MJS_m4x4transpose = _MJS_m4x4transposeLocal;

var _MJS_m4x4makeBasis = F3(function(vx, vy, vz) {
    var r = new Float64Array(16);

    r[0] = vx[0];
    r[1] = vx[1];
    r[2] = vx[2];
    r[3] = 0;
    r[4] = vy[0];
    r[5] = vy[1];
    r[6] = vy[2];
    r[7] = 0;
    r[8] = vz[0];
    r[9] = vz[1];
    r[10] = vz[2];
    r[11] = 0;
    r[12] = 0;
    r[13] = 0;
    r[14] = 0;
    r[15] = 1;

    return r;
});



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}


// BYTES

function _Bytes_width(bytes)
{
	return bytes.byteLength;
}

var _Bytes_getHostEndianness = F2(function(le, be)
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(new Uint8Array(new Uint32Array([1]))[0] === 1 ? le : be));
	});
});


// ENCODERS

function _Bytes_encode(encoder)
{
	var mutableBytes = new DataView(new ArrayBuffer(elm$bytes$Bytes$Encode$getWidth(encoder)));
	elm$bytes$Bytes$Encode$write(encoder)(mutableBytes)(0);
	return mutableBytes;
}


// SIGNED INTEGERS

var _Bytes_write_i8  = F3(function(mb, i, n) { mb.setInt8(i, n); return i + 1; });
var _Bytes_write_i16 = F4(function(mb, i, n, isLE) { mb.setInt16(i, n, isLE); return i + 2; });
var _Bytes_write_i32 = F4(function(mb, i, n, isLE) { mb.setInt32(i, n, isLE); return i + 4; });


// UNSIGNED INTEGERS

var _Bytes_write_u8  = F3(function(mb, i, n) { mb.setUint8(i, n); return i + 1 ;});
var _Bytes_write_u16 = F4(function(mb, i, n, isLE) { mb.setUint16(i, n, isLE); return i + 2; });
var _Bytes_write_u32 = F4(function(mb, i, n, isLE) { mb.setUint32(i, n, isLE); return i + 4; });


// FLOATS

var _Bytes_write_f32 = F4(function(mb, i, n, isLE) { mb.setFloat32(i, n, isLE); return i + 4; });
var _Bytes_write_f64 = F4(function(mb, i, n, isLE) { mb.setFloat64(i, n, isLE); return i + 8; });


// BYTES

var _Bytes_write_bytes = F3(function(mb, offset, bytes)
{
	for (var i = 0, len = bytes.byteLength, limit = len - 4; i <= limit; i += 4)
	{
		mb.setUint32(offset + i, bytes.getUint32(i));
	}
	for (; i < len; i++)
	{
		mb.setUint8(offset + i, bytes.getUint8(i));
	}
	return offset + len;
});


// STRINGS

function _Bytes_getStringWidth(string)
{
	for (var width = 0, i = 0; i < string.length; i++)
	{
		var code = string.charCodeAt(i);
		width +=
			(code < 0x80) ? 1 :
			(code < 0x800) ? 2 :
			(code < 0xD800 || 0xDBFF < code) ? 3 : (i++, 4);
	}
	return width;
}

var _Bytes_write_string = F3(function(mb, offset, string)
{
	for (var i = 0; i < string.length; i++)
	{
		var code = string.charCodeAt(i);
		offset +=
			(code < 0x80)
				? (mb.setUint8(offset, code)
				, 1
				)
				:
			(code < 0x800)
				? (mb.setUint16(offset, 0xC080 /* 0b1100000010000000 */
					| (code >>> 6 & 0x1F /* 0b00011111 */) << 8
					| code & 0x3F /* 0b00111111 */)
				, 2
				)
				:
			(code < 0xD800 || 0xDBFF < code)
				? (mb.setUint16(offset, 0xE080 /* 0b1110000010000000 */
					| (code >>> 12 & 0xF /* 0b00001111 */) << 8
					| code >>> 6 & 0x3F /* 0b00111111 */)
				, mb.setUint8(offset + 2, 0x80 /* 0b10000000 */
					| code & 0x3F /* 0b00111111 */)
				, 3
				)
				:
			(code = (code - 0xD800) * 0x400 + string.charCodeAt(++i) - 0xDC00 + 0x10000
			, mb.setUint32(offset, 0xF0808080 /* 0b11110000100000001000000010000000 */
				| (code >>> 18 & 0x7 /* 0b00000111 */) << 24
				| (code >>> 12 & 0x3F /* 0b00111111 */) << 16
				| (code >>> 6 & 0x3F /* 0b00111111 */) << 8
				| code & 0x3F /* 0b00111111 */)
			, 4
			);
	}
	return offset;
});


// DECODER

var _Bytes_decode = F2(function(decoder, bytes)
{
	try {
		return elm$core$Maybe$Just(A2(decoder, bytes, 0).b);
	} catch(e) {
		return elm$core$Maybe$Nothing;
	}
});

var _Bytes_read_i8  = F2(function(      bytes, offset) { return _Utils_Tuple2(offset + 1, bytes.getInt8(offset)); });
var _Bytes_read_i16 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 2, bytes.getInt16(offset, isLE)); });
var _Bytes_read_i32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getInt32(offset, isLE)); });
var _Bytes_read_u8  = F2(function(      bytes, offset) { return _Utils_Tuple2(offset + 1, bytes.getUint8(offset)); });
var _Bytes_read_u16 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 2, bytes.getUint16(offset, isLE)); });
var _Bytes_read_u32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getUint32(offset, isLE)); });
var _Bytes_read_f32 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getFloat32(offset, isLE)); });
var _Bytes_read_f64 = F3(function(isLE, bytes, offset) { return _Utils_Tuple2(offset + 8, bytes.getFloat64(offset, isLE)); });

var _Bytes_read_bytes = F3(function(len, bytes, offset)
{
	return _Utils_Tuple2(offset + len, new DataView(bytes.buffer, bytes.byteOffset + offset, len));
});

var _Bytes_read_string = F3(function(len, bytes, offset)
{
	var string = '';
	var end = offset + len;
	for (; offset < end;)
	{
		var byte = bytes.getUint8(offset++);
		string +=
			(byte < 128)
				? String.fromCharCode(byte)
				:
			((byte & 0xE0 /* 0b11100000 */) === 0xC0 /* 0b11000000 */)
				? String.fromCharCode((byte & 0x1F /* 0b00011111 */) << 6 | bytes.getUint8(offset++) & 0x3F /* 0b00111111 */)
				:
			((byte & 0xF0 /* 0b11110000 */) === 0xE0 /* 0b11100000 */)
				? String.fromCharCode(
					(byte & 0xF /* 0b00001111 */) << 12
					| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 6
					| bytes.getUint8(offset++) & 0x3F /* 0b00111111 */
				)
				:
				(byte =
					((byte & 0x7 /* 0b00000111 */) << 18
						| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 12
						| (bytes.getUint8(offset++) & 0x3F /* 0b00111111 */) << 6
						| bytes.getUint8(offset++) & 0x3F /* 0b00111111 */
					) - 0x10000
				, String.fromCharCode(Math.floor(byte / 0x400) + 0xD800, byte % 0x400 + 0xDC00)
				);
	}
	return _Utils_Tuple2(offset, string);
});

var _Bytes_decodeFailure = F2(function() { throw 0; });



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.eM,
		impl.fF,
		impl.fA,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);
	var managers = {};
	result = init(result.a);
	var model = result.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		result = A2(update, msg, model);
		stepper(model = result.a, viewMetadata);
		_Platform_dispatchEffects(managers, result.b, subscriptions(model));
	}

	_Platform_dispatchEffects(managers, result.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				p: bag.n,
				q: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.q)
		{
			x = temp.p(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		r: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].r;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		r: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].r;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}



// SEND REQUEST

var _Http_toTask = F3(function(router, toTask, request)
{
	return _Scheduler_binding(function(callback)
	{
		function done(response) {
			callback(toTask(request.w.a(response)));
		}

		var xhr = new XMLHttpRequest();
		xhr.addEventListener('error', function() { done(elm$http$Http$NetworkError_); });
		xhr.addEventListener('timeout', function() { done(elm$http$Http$Timeout_); });
		xhr.addEventListener('load', function() { done(_Http_toResponse(request.w.b, xhr)); });
		elm$core$Maybe$isJust(request.D) && _Http_track(router, xhr, request.D.a);

		try {
			xhr.open(request.dp, request.H, true);
		} catch (e) {
			return done(elm$http$Http$BadUrl_(request.H));
		}

		_Http_configureRequest(xhr, request);

		request.bU.a && xhr.setRequestHeader('Content-Type', request.bU.a);
		xhr.send(request.bU.b);

		return function() { xhr.c = true; xhr.abort(); };
	});
});


// CONFIGURE

function _Http_configureRequest(xhr, request)
{
	for (var headers = request.c4; headers.b; headers = headers.b) // WHILE_CONS
	{
		xhr.setRequestHeader(headers.a.a, headers.a.b);
	}
	xhr.timeout = request.d8.a || 0;
	xhr.responseType = request.w.d;
	xhr.withCredentials = request.aw;
}


// RESPONSES

function _Http_toResponse(toBody, xhr)
{
	return A2(
		200 <= xhr.status && xhr.status < 300 ? elm$http$Http$GoodStatus_ : elm$http$Http$BadStatus_,
		_Http_toMetadata(xhr),
		toBody(xhr.response)
	);
}


// METADATA

function _Http_toMetadata(xhr)
{
	return {
		H: xhr.responseURL,
		d0: xhr.status,
		fy: xhr.statusText,
		c4: _Http_parseHeaders(xhr.getAllResponseHeaders())
	};
}


// HEADERS

function _Http_parseHeaders(rawHeaders)
{
	if (!rawHeaders)
	{
		return elm$core$Dict$empty;
	}

	var headers = elm$core$Dict$empty;
	var headerPairs = rawHeaders.split('\r\n');
	for (var i = headerPairs.length; i--; )
	{
		var headerPair = headerPairs[i];
		var index = headerPair.indexOf(': ');
		if (index > 0)
		{
			var key = headerPair.substring(0, index);
			var value = headerPair.substring(index + 2);

			headers = A3(elm$core$Dict$update, key, function(oldValue) {
				return elm$core$Maybe$Just(elm$core$Maybe$isJust(oldValue)
					? value + ', ' + oldValue.a
					: value
				);
			}, headers);
		}
	}
	return headers;
}


// EXPECT

var _Http_expect = F3(function(type, toBody, toValue)
{
	return {
		$: 0,
		d: type,
		b: toBody,
		a: toValue
	};
});

var _Http_mapExpect = F2(function(func, expect)
{
	return {
		$: 0,
		d: expect.d,
		b: expect.b,
		a: function(x) { return func(expect.a(x)); }
	};
});

function _Http_toDataView(arrayBuffer)
{
	return new DataView(arrayBuffer);
}


// BODY and PARTS

var _Http_emptyBody = { $: 0 };
var _Http_pair = F2(function(a, b) { return { $: 0, a: a, b: b }; });

function _Http_toFormData(parts)
{
	for (var formData = new FormData(); parts.b; parts = parts.b) // WHILE_CONS
	{
		var part = parts.a;
		formData.append(part.a, part.b);
	}
	return formData;
}

var _Http_bytesToBlob = F2(function(mime, bytes)
{
	return new Blob([bytes], { type: mime });
});


// PROGRESS

function _Http_track(router, xhr, tracker)
{
	// TODO check out lengthComputable on loadstart event

	xhr.upload.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2(elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, elm$http$Http$Sending({
			ft: event.loaded,
			cs: event.total
		}))));
	});
	xhr.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2(elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, elm$http$Http$Receiving({
			fl: event.loaded,
			cs: event.lengthComputable ? elm$core$Maybe$Just(event.total) : elm$core$Maybe$Nothing
		}))));
	});
}



// STRINGS


var _Parser_isSubString = F5(function(smallString, offset, row, col, bigString)
{
	var smallLength = smallString.length;
	var isGood = offset + smallLength <= bigString.length;

	for (var i = 0; isGood && i < smallLength; )
	{
		var code = bigString.charCodeAt(offset);
		isGood =
			smallString[i++] === bigString[offset++]
			&& (
				code === 0x000A /* \n */
					? ( row++, col=1 )
					: ( col++, (code & 0xF800) === 0xD800 ? smallString[i++] === bigString[offset++] : 1 )
			)
	}

	return _Utils_Tuple3(isGood ? offset : -1, row, col);
});



// CHARS


var _Parser_isSubChar = F3(function(predicate, offset, string)
{
	return (
		string.length <= offset
			? -1
			:
		(string.charCodeAt(offset) & 0xF800) === 0xD800
			? (predicate(_Utils_chr(string.substr(offset, 2))) ? offset + 2 : -1)
			:
		(predicate(_Utils_chr(string[offset]))
			? ((string[offset] === '\n') ? -2 : (offset + 1))
			: -1
		)
	);
});


var _Parser_isAsciiCode = F3(function(code, offset, string)
{
	return string.charCodeAt(offset) === code;
});



// NUMBERS


var _Parser_chompBase10 = F2(function(offset, string)
{
	for (; offset < string.length; offset++)
	{
		var code = string.charCodeAt(offset);
		if (code < 0x30 || 0x39 < code)
		{
			return offset;
		}
	}
	return offset;
});


var _Parser_consumeBase = F3(function(base, offset, string)
{
	for (var total = 0; offset < string.length; offset++)
	{
		var digit = string.charCodeAt(offset) - 0x30;
		if (digit < 0 || base <= digit) break;
		total = base * total + digit;
	}
	return _Utils_Tuple2(offset, total);
});


var _Parser_consumeBase16 = F2(function(offset, string)
{
	for (var total = 0; offset < string.length; offset++)
	{
		var code = string.charCodeAt(offset);
		if (0x30 <= code && code <= 0x39)
		{
			total = 16 * total + code - 0x30;
		}
		else if (0x41 <= code && code <= 0x46)
		{
			total = 16 * total + code - 55;
		}
		else if (0x61 <= code && code <= 0x66)
		{
			total = 16 * total + code - 87;
		}
		else
		{
			break;
		}
	}
	return _Utils_Tuple2(offset, total);
});



// FIND STRING


var _Parser_findSubString = F5(function(smallString, offset, row, col, bigString)
{
	var newOffset = bigString.indexOf(smallString, offset);
	var target = newOffset < 0 ? bigString.length : newOffset + smallString.length;

	while (offset < target)
	{
		var code = bigString.charCodeAt(offset++);
		code === 0x000A /* \n */
			? ( col=1, row++ )
			: ( col++, (code & 0xF800) === 0xD800 && offset++ )
	}

	return _Utils_Tuple3(newOffset, row, col);
});


// eslint-disable-next-line no-unused-vars
var _Texture_load = F6(function (magnify, mininify, horizontalWrap, verticalWrap, flipY, url) {
  var isMipmap = mininify !== 9728 && mininify !== 9729;
  return _Scheduler_binding(function (callback) {
    var img = new Image();
    function createTexture(gl) {
      var texture = gl.createTexture();
      gl.bindTexture(gl.TEXTURE_2D, texture);
      gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, flipY);
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, magnify);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, mininify);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, horizontalWrap);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, verticalWrap);
      if (isMipmap) {
        gl.generateMipmap(gl.TEXTURE_2D);
      }
      gl.bindTexture(gl.TEXTURE_2D, null);
      return texture;
    }
    img.onload = function () {
      var width = img.width;
      var height = img.height;
      var widthPowerOfTwo = (width & (width - 1)) === 0;
      var heightPowerOfTwo = (height & (height - 1)) === 0;
      var isSizeValid = (widthPowerOfTwo && heightPowerOfTwo) || (
        !isMipmap
        && horizontalWrap === 33071 // clamp to edge
        && verticalWrap === 33071
      );
      if (isSizeValid) {
        callback(_Scheduler_succeed({
          $: 0,
          cQ: createTexture,
          a: width,
          b: height
        }));
      } else {
        callback(_Scheduler_fail(A2(
          elm_explorations$webgl$WebGL$Texture$SizeError,
          width,
          height
        )));
      }
    };
    img.onerror = function () {
      callback(_Scheduler_fail(elm_explorations$webgl$WebGL$Texture$LoadError));
    };
    if (url.slice(0, 5) !== 'data:') {
      img.crossOrigin = 'Anonymous';
    }
    img.src = url;
  });
});

// eslint-disable-next-line no-unused-vars
var _Texture_size = function (texture) {
  return _Utils_Tuple2(texture.a, texture.b);
};
var author$project$AltMath$Vector2$Vec2 = F2(
	function (x, y) {
		return {n: x, o: y};
	});
var author$project$AltMath$Vector2$vec2 = author$project$AltMath$Vector2$Vec2;
var author$project$Logic$GameFlow$Running = {$: 0};
var elm$core$Basics$EQ = 1;
var elm$core$Basics$LT = 0;
var elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var elm$core$Array$foldr = F3(
	function (func, baseCase, _n0) {
		var tree = _n0.c;
		var tail = _n0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
					var subTree = node.a;
					return A3(elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3(elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			elm$core$Elm$JsArray$foldr,
			helper,
			A3(elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var elm$core$List$cons = _List_cons;
var elm$core$Array$toList = function (array) {
	return A3(elm$core$Array$foldr, elm$core$List$cons, _List_Nil, array);
};
var elm$core$Basics$GT = 2;
var elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === -2) {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3(elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var elm$core$Dict$toList = function (dict) {
	return A3(
		elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var elm$core$Dict$keys = function (dict) {
	return A3(
		elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2(elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var elm$core$Set$toList = function (_n0) {
	var dict = _n0;
	return elm$core$Dict$keys(dict);
};
var author$project$Logic$Template$Component$Layer$empty = _List_Nil;
var elm$core$Basics$False = 1;
var author$project$Logic$Template$Component$OnScreenControl$emptyTwoButtonStick = {
	ei: false,
	aQ: {
		ei: false,
		t: {n: 0, o: 0}
	},
	aR: {
		ei: false,
		t: {n: 0, o: 0}
	},
	t: {n: 0, o: 0},
	ak: {n: 0, o: 0}
};
var elm$core$Basics$lt = _Utils_lt;
var elm$core$Basics$negate = function (n) {
	return -n;
};
var elm$core$Basics$abs = function (n) {
	return (n < 0) ? (-n) : n;
};
var elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var elm$core$Basics$ceiling = _Basics_ceiling;
var elm$core$Basics$fdiv = _Basics_fdiv;
var elm$core$Basics$sub = _Basics_sub;
var elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var elm$core$Dict$empty = elm$core$Dict$RBEmpty_elm_builtin;
var author$project$Broad$Grid$empty_ = F2(
	function (_n0, config) {
		var xmin = _n0.fI;
		var xmax = _n0.fH;
		var ymin = _n0.fK;
		var ymax = _n0.fJ;
		return _Utils_Tuple2(
			elm$core$Dict$empty,
			{
				s: _Utils_Tuple2(config.bc, config.bb),
				be: elm$core$Basics$ceiling(
					elm$core$Basics$abs(xmax - xmin) / config.bc),
				bD: elm$core$Basics$ceiling(
					elm$core$Basics$abs(ymax - ymin) / config.bb),
				fI: xmin,
				fK: ymin
			});
	});
var author$project$Broad$Grid$empty = A2(
	author$project$Broad$Grid$empty_,
	{fH: 0, fI: 0, fJ: 0, fK: 0},
	{bb: 0, bc: 0});
var author$project$Physic$AABB$empty = {
	eJ: A2(author$project$AltMath$Vector2$vec2, 0, -1),
	db: elm$core$Dict$empty,
	C: author$project$Broad$Grid$empty
};
var author$project$Logic$Template$Component$Physics$empty = author$project$Physic$AABB$empty;
var elm$core$Basics$identity = function (x) {
	return x;
};
var elm$core$Set$Set_elm_builtin = elm$core$Basics$identity;
var elm$core$Set$empty = elm$core$Dict$empty;
var elm$core$Array$branchFactor = 32;
var elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var elm$core$Basics$toFloat = _Basics_toFloat;
var elm$core$Array$shiftStep = elm$core$Basics$ceiling(
	A2(elm$core$Basics$logBase, 2, elm$core$Array$branchFactor));
var elm$core$Elm$JsArray$empty = _JsArray_empty;
var elm$core$Array$empty = A4(elm$core$Array$Array_elm_builtin, 0, elm$core$Array$shiftStep, elm$core$Elm$JsArray$empty, elm$core$Elm$JsArray$empty);
var elm$core$Array$Leaf = function (a) {
	return {$: 1, a: a};
};
var elm$core$Array$SubTree = function (a) {
	return {$: 0, a: a};
};
var elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var elm$core$List$reverse = function (list) {
	return A3(elm$core$List$foldl, elm$core$List$cons, _List_Nil, list);
};
var elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _n0 = A2(elm$core$Elm$JsArray$initializeFromList, elm$core$Array$branchFactor, nodes);
			var node = _n0.a;
			var remainingNodes = _n0.b;
			var newAcc = A2(
				elm$core$List$cons,
				elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var elm$core$Basics$eq = _Utils_equal;
var elm$core$Tuple$first = function (_n0) {
	var x = _n0.a;
	return x;
};
var elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = elm$core$Basics$ceiling(nodeListSize / elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2(elm$core$Elm$JsArray$initializeFromList, elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2(elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var elm$core$Basics$add = _Basics_add;
var elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var elm$core$Basics$floor = _Basics_floor;
var elm$core$Basics$gt = _Utils_gt;
var elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var elm$core$Basics$mul = _Basics_mul;
var elm$core$Elm$JsArray$length = _JsArray_length;
var elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.g) {
			return A4(
				elm$core$Array$Array_elm_builtin,
				elm$core$Elm$JsArray$length(builder.i),
				elm$core$Array$shiftStep,
				elm$core$Elm$JsArray$empty,
				builder.i);
		} else {
			var treeLen = builder.g * elm$core$Array$branchFactor;
			var depth = elm$core$Basics$floor(
				A2(elm$core$Basics$logBase, elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? elm$core$List$reverse(builder.j) : builder.j;
			var tree = A2(elm$core$Array$treeFromBuilder, correctNodeList, builder.g);
			return A4(
				elm$core$Array$Array_elm_builtin,
				elm$core$Elm$JsArray$length(builder.i) + treeLen,
				A2(elm$core$Basics$max, 5, depth * elm$core$Array$shiftStep),
				tree,
				builder.i);
		}
	});
var elm$core$Basics$idiv = _Basics_idiv;
var elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					elm$core$Array$builderToArray,
					false,
					{j: nodeList, g: (len / elm$core$Array$branchFactor) | 0, i: tail});
			} else {
				var leaf = elm$core$Array$Leaf(
					A3(elm$core$Elm$JsArray$initialize, elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2(elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var elm$core$Basics$le = _Utils_le;
var elm$core$Basics$remainderBy = _Basics_remainderBy;
var elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return elm$core$Array$empty;
		} else {
			var tailLen = len % elm$core$Array$branchFactor;
			var tail = A3(elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - elm$core$Array$branchFactor;
			return A5(elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var elm$core$Maybe$Just = function (a) {
	return {$: 0, a: a};
};
var elm$core$Maybe$Nothing = {$: 1};
var elm$core$Result$Err = function (a) {
	return {$: 1, a: a};
};
var elm$core$Result$Ok = function (a) {
	return {$: 0, a: a};
};
var elm$core$Basics$True = 0;
var elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var elm$json$Json$Decode$OneOf = function (a) {
	return {$: 2, a: a};
};
var elm$core$Basics$and = _Basics_and;
var elm$core$Basics$append = _Utils_append;
var elm$core$Basics$or = _Basics_or;
var elm$core$Char$toCode = _Char_toCode;
var elm$core$Char$isLower = function (_char) {
	var code = elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var elm$core$Char$isUpper = function (_char) {
	var code = elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var elm$core$Char$isAlpha = function (_char) {
	return elm$core$Char$isLower(_char) || elm$core$Char$isUpper(_char);
};
var elm$core$Char$isDigit = function (_char) {
	var code = elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var elm$core$Char$isAlphaNum = function (_char) {
	return elm$core$Char$isLower(_char) || (elm$core$Char$isUpper(_char) || elm$core$Char$isDigit(_char));
};
var elm$core$List$length = function (xs) {
	return A3(
		elm$core$List$foldl,
		F2(
			function (_n0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var elm$core$List$map2 = _List_map2;
var elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2(elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var elm$core$List$range = F2(
	function (lo, hi) {
		return A3(elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			elm$core$List$map2,
			f,
			A2(
				elm$core$List$range,
				0,
				elm$core$List$length(xs) - 1),
			xs);
	});
var elm$core$String$all = _String_all;
var elm$core$String$fromInt = _String_fromNumber;
var elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var elm$core$String$uncons = _String_uncons;
var elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var elm$json$Json$Decode$indent = function (str) {
	return A2(
		elm$core$String$join,
		'\n    ',
		A2(elm$core$String$split, '\n', str));
};
var elm$json$Json$Encode$encode = _Json_encode;
var elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + (elm$core$String$fromInt(i + 1) + (') ' + elm$json$Json$Decode$indent(
			elm$json$Json$Decode$errorToString(error))));
	});
var elm$json$Json$Decode$errorToString = function (error) {
	return A2(elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 0:
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _n1 = elm$core$String$uncons(f);
						if (_n1.$ === 1) {
							return false;
						} else {
							var _n2 = _n1.a;
							var _char = _n2.a;
							var rest = _n2.b;
							return elm$core$Char$isAlpha(_char) && A2(elm$core$String$all, elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2(elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 1:
					var i = error.a;
					var err = error.b;
					var indexName = '[' + (elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2(elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 2:
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									elm$core$String$join,
									'',
									elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										elm$core$String$join,
										'',
										elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + (elm$core$String$fromInt(
								elm$core$List$length(errors)) + ' ways:'));
							return A2(
								elm$core$String$join,
								'\n\n',
								A2(
									elm$core$List$cons,
									introduction,
									A2(elm$core$List$indexedMap, elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								elm$core$String$join,
								'',
								elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + (elm$json$Json$Decode$indent(
						A2(elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var elm$json$Json$Encode$null = _Json_encodeNull;
var author$project$Logic$Template$Component$SFX$empty = {
	aS: {ct: elm$core$Dict$empty, fv: _List_Nil, dZ: elm$json$Json$Encode$null},
	K: elm$core$Set$empty,
	at: elm$core$Dict$empty,
	ad: 0
};
var author$project$Logic$Component$empty = elm$core$Array$empty;
var author$project$Logic$Template$Component$Sprite$empty = author$project$Logic$Component$empty;
var author$project$Logic$Template$Component$TimeLine$empty = author$project$Logic$Component$empty;
var author$project$Logic$Template$Component$TimeLineDict$empty = author$project$Logic$Component$empty;
var elm$random$Random$Generator = elm$core$Basics$identity;
var elm$random$Random$constant = function (value) {
	return function (seed) {
		return _Utils_Tuple2(value, seed);
	};
};
var elm$core$Bitwise$and = _Bitwise_and;
var elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var elm$random$Random$Seed = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$random$Random$next = function (_n0) {
	var state0 = _n0.a;
	var incr = _n0.b;
	return A2(elm$random$Random$Seed, ((state0 * 1664525) + incr) >>> 0, incr);
};
var elm$core$Bitwise$xor = _Bitwise_xor;
var elm$random$Random$peel = function (_n0) {
	var state = _n0.a;
	var word = (state ^ (state >>> ((state >>> 28) + 4))) * 277803737;
	return ((word >>> 22) ^ word) >>> 0;
};
var elm$random$Random$float = F2(
	function (a, b) {
		return function (seed0) {
			var seed1 = elm$random$Random$next(seed0);
			var range = elm$core$Basics$abs(b - a);
			var n1 = elm$random$Random$peel(seed1);
			var n0 = elm$random$Random$peel(seed0);
			var lo = (134217727 & n1) * 1.0;
			var hi = (67108863 & n0) * 1.0;
			var val = ((hi * 1.34217728e8) + lo) / 9.007199254740992e15;
			var scaled = (val * range) + a;
			return _Utils_Tuple2(
				scaled,
				elm$random$Random$next(seed1));
		};
	});
var elm$random$Random$map2 = F3(
	function (func, _n0, _n1) {
		var genA = _n0;
		var genB = _n1;
		return function (seed0) {
			var _n2 = genA(seed0);
			var a = _n2.a;
			var seed1 = _n2.b;
			var _n3 = genB(seed1);
			var b = _n3.a;
			var seed2 = _n3.b;
			return _Utils_Tuple2(
				A2(func, a, b),
				seed2);
		};
	});
var elm$random$Random$map5 = F6(
	function (func, _n0, _n1, _n2, _n3, _n4) {
		var genA = _n0;
		var genB = _n1;
		var genC = _n2;
		var genD = _n3;
		var genE = _n4;
		return function (seed0) {
			var _n5 = genA(seed0);
			var a = _n5.a;
			var seed1 = _n5.b;
			var _n6 = genB(seed1);
			var b = _n6.a;
			var seed2 = _n6.b;
			var _n7 = genC(seed2);
			var c = _n7.a;
			var seed3 = _n7.b;
			var _n8 = genD(seed3);
			var d = _n8.a;
			var seed4 = _n8.b;
			var _n9 = genE(seed4);
			var e = _n9.a;
			var seed5 = _n9.b;
			return _Utils_Tuple2(
				A5(func, a, b, c, d, e),
				seed5);
		};
	});
var elm$random$Random$step = F2(
	function (_n0, seed) {
		var generator = _n0;
		return generator(seed);
	});
var elm_explorations$linear_algebra$Math$Vector4$vec4 = _MJS_v4;
var author$project$Logic$Template$GFX$Projectile$defaultSettings = {
	c0: F2(
		function (pos, i) {
			return A6(
				elm$random$Random$map5,
				F5(
					function (size, acceleration, velocity, position, lifespan) {
						return {
							bR: acceleration,
							cR: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, position.n, position.o, size, lifespan),
							c8: i,
							bO: velocity
						};
					}),
				A2(elm$random$Random$float, 10, 30),
				A3(
					elm$random$Random$map2,
					author$project$AltMath$Vector2$Vec2,
					elm$random$Random$constant(3.0e-6),
					elm$random$Random$constant(0)),
				A3(
					elm$random$Random$map2,
					author$project$AltMath$Vector2$Vec2,
					A2(elm$random$Random$float, -1.0e-3, 1.0e-3),
					A2(elm$random$Random$float, 1.0e-3, 3.0e-3)),
				elm$random$Random$constant(pos),
				A2(elm$random$Random$float, 10, 160));
		}),
	dX: function (seed) {
		return A2(
			elm$random$Random$step,
			A2(elm$random$Random$float, 5 / 60, 15 / 60),
			seed).a;
	}
};
var elm_explorations$linear_algebra$Math$Vector2$vec2 = _MJS_v2;
var author$project$Logic$Template$GFX$P16$empty = {
	cF: 0,
	ca: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	cb: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	cc: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	cd: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	ce: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	cf: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	cg: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	ch: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	ci: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	cj: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	ck: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	cl: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	cm: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	cn: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	co: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	cp: A4(elm_explorations$linear_algebra$Math$Vector4$vec4, 0, 0, 0, 0),
	a6: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0)
};
var author$project$Logic$Template$GFX$Projectile$fill = F2(
	function (amount, config) {
		var _n0 = A3(
			elm$core$List$foldl,
			F2(
				function (i, _n1) {
					var acc = _n1.a;
					var seed = _n1.b;
					var _n2 = A2(
						elm$random$Random$step,
						acc.c0(i),
						seed);
					var particle = _n2.a;
					var seed1 = _n2.b;
					return _Utils_Tuple2(
						_Utils_update(
							acc,
							{
								aT: A2(elm$core$List$cons, particle, acc.aT)
							}),
						seed1);
				}),
			_Utils_Tuple2(config, config.ad),
			A2(elm$core$List$range, 0, amount - 1));
		var result = _n0.a;
		return result;
	});
var elm_explorations$webgl$WebGL$Mesh1 = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm_explorations$webgl$WebGL$points = elm_explorations$webgl$WebGL$Mesh1(
	{J: 1, L: 0, P: 0});
var author$project$Logic$Template$GFX$P16$points = elm_explorations$webgl$WebGL$points(
	_List_fromArray(
		[
			{l: 0},
			{l: 1},
			{l: 2},
			{l: 3},
			{l: 4},
			{l: 5},
			{l: 6},
			{l: 7},
			{l: 8},
			{l: 9},
			{l: 10},
			{l: 11},
			{l: 12},
			{l: 13},
			{l: 14},
			{l: 15}
		]));
var author$project$Logic$Template$GFX$P16$vertexShader = {
	src: '\nprecision mediump float;\nattribute float index;\nuniform float aspectRatio;\nuniform vec4 p0;\nuniform vec4 p1;\nuniform vec4 p2;\nuniform vec4 p3;\nuniform vec4 p4;\nuniform vec4 p5;\nuniform vec4 p6;\nuniform vec4 p7;\nuniform vec4 p8;\nuniform vec4 p9;\nuniform vec4 p10;\nuniform vec4 p11;\nuniform vec4 p12;\nuniform vec4 p13;\nuniform vec4 p14;\nuniform vec4 p15;\nvarying vec4 data;\nuniform vec2 viewportOffset;\n\nmat4 viewport = mat4((2.0 / aspectRatio), 0, 0, 0, 0, 2, 0, 0, 0, 0, -1, 0, -1, -1, 0, 1);\n\nvoid main() {\n    data = vec4(0., 0., 0., 0.);\n    if(index == 0.) { data = p0; };\n    if(index == 1.) { data = p1; };\n    if(index == 2.) { data = p2; };\n    if(index == 3.) { data = p3; };\n    if(index == 4.) { data = p4; };\n    if(index == 5.) { data = p5; };\n    if(index == 6.) { data = p6; };\n    if(index == 7.) { data = p7; };\n    if(index == 8.) { data = p8; };\n    if(index == 9.) { data = p9; };\n    if(index == 10.) { data = p10; };\n    if(index == 11.) { data = p11; };\n    if(index == 12.) { data = p12; };\n    if(index == 13.) { data = p13; };\n    if(index == 14.) { data = p14; };\n    if(index == 15.) { data = p15; };\n    vec2 move = vec2(\n       (data.x - viewportOffset.x),\n       (data.y - viewportOffset.y)\n    );\n    gl_Position = viewport *  vec4(data.xy + move, 0, 1.0);\n    gl_PointSize = data.z;\n}\n    ',
	attributes: {index: 'l'},
	uniforms: {aspectRatio: 'cF', p0: 'ca', p1: 'cb', p10: 'cc', p11: 'cd', p12: 'ce', p13: 'cf', p14: 'cg', p15: 'ch', p2: 'ci', p3: 'cj', p4: 'ck', p5: 'cl', p6: 'cm', p7: 'cn', p8: 'co', p9: 'cp', viewportOffset: 'a6'}
};
var author$project$Logic$Template$GFX$Particle$simpleFragmentShader = {
	src: '\n        precision mediump float;\n        varying vec4 data;\n        //varying float index;\n//        uniform float aspectRatio;\n        float map(float min1, float max1, float min2, float max2, float value) {\n          return min2 + (value - min1) * (max2 - min2) / (max1 - min1);\n        }\n// Simplex 2D noise\n//\nvec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }\n\nfloat snoise(vec2 v){\n  const vec4 C = vec4(0.211324865405187, 0.366025403784439,\n           -0.577350269189626, 0.024390243902439);\n  vec2 i  = floor(v + dot(v, C.yy) );\n  vec2 x0 = v -   i + dot(i, C.xx);\n  vec2 i1;\n  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);\n  vec4 x12 = x0.xyxy + C.xxzz;\n  x12.xy -= i1;\n  i = mod(i, 289.0);\n  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))\n  + i.x + vec3(0.0, i1.x, 1.0 ));\n  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),\n    dot(x12.zw,x12.zw)), 0.0);\n  m = m*m ;\n  m = m*m ;\n  vec3 x = 2.0 * fract(p * C.www) - 1.0;\n  vec3 h = abs(x) - 0.5;\n  vec3 ox = floor(x + 0.5);\n  vec3 a0 = x - ox;\n  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );\n  vec3 g;\n  g.x  = a0.x  * x0.x  + h.x  * x0.y;\n  g.yz = a0.yz * x12.xz + h.yz * x12.yw;\n  return 130.0 * dot(m, g);\n}\n        void main () {\n\n//            vec3 color = vec3(snoise(gl_PointCoord + 15.),snoise(gl_PointCoord + 25.),snoise(gl_PointCoord + 45.));\n            float delme = ((snoise(gl_PointCoord) + 1.) /  2.);\n            vec3 color = vec3(delme, delme, delme);\n//            vec3 color = vec3(snoise(data.xy + gl_PointCoord),0.,0.);\n            float dist = distance( gl_PointCoord, vec2(0.5) );\n            float alpha = 1.0 - smoothstep(0.45,0.5,dist);\n            float alpha2 = map(0., 30., 0., 0.1, data.w);\n            gl_FragColor = vec4(color, alpha * alpha2 );\n        }\n    ',
	attributes: {},
	uniforms: {}
};
var elm_explorations$webgl$WebGL$Internal$ColorMask = F4(
	function (a, b, c, d) {
		return {$: 4, a: a, b: b, c: c, d: d};
	});
var elm_explorations$webgl$WebGL$Settings$colorMask = elm_explorations$webgl$WebGL$Internal$ColorMask;
var elm_explorations$webgl$WebGL$Internal$CullFace = function (a) {
	return {$: 5, a: a};
};
var elm_explorations$webgl$WebGL$Settings$cullFace = function (_n0) {
	var faceMode = _n0;
	return elm_explorations$webgl$WebGL$Internal$CullFace(faceMode);
};
var elm_explorations$webgl$WebGL$Settings$FaceMode = elm$core$Basics$identity;
var elm_explorations$webgl$WebGL$Settings$front = 1028;
var elm_explorations$webgl$WebGL$Internal$Blend = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return {$: 0, a: a, b: b, c: c, d: d, e: e, f: f, g: g, h: h, i: i, j: j};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var elm_explorations$webgl$WebGL$Settings$Blend$custom = function (_n0) {
	var r = _n0.fj;
	var g = _n0.bk;
	var b = _n0.f;
	var a = _n0.e;
	var color = _n0.bd;
	var alpha = _n0.ba;
	var expand = F2(
		function (_n1, _n2) {
			var eq1 = _n1.a;
			var f11 = _n1.b;
			var f12 = _n1.c;
			var eq2 = _n2.a;
			var f21 = _n2.b;
			var f22 = _n2.c;
			return elm_explorations$webgl$WebGL$Internal$Blend(eq1)(f11)(f12)(eq2)(f21)(f22)(r)(g)(b)(a);
		});
	return A2(expand, color, alpha);
};
var elm_explorations$webgl$WebGL$Settings$Blend$Blender = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var elm_explorations$webgl$WebGL$Settings$Blend$customAdd = F2(
	function (_n0, _n1) {
		var factor1 = _n0;
		var factor2 = _n1;
		return A3(elm_explorations$webgl$WebGL$Settings$Blend$Blender, 32774, factor1, factor2);
	});
var elm_explorations$webgl$WebGL$Settings$Blend$add = F2(
	function (factor1, factor2) {
		return elm_explorations$webgl$WebGL$Settings$Blend$custom(
			{
				e: 0,
				ba: A2(elm_explorations$webgl$WebGL$Settings$Blend$customAdd, factor1, factor2),
				f: 0,
				bd: A2(elm_explorations$webgl$WebGL$Settings$Blend$customAdd, factor1, factor2),
				bk: 0,
				fj: 0
			});
	});
var elm_explorations$webgl$WebGL$Settings$Blend$Factor = elm$core$Basics$identity;
var elm_explorations$webgl$WebGL$Settings$Blend$oneMinusSrcAlpha = 771;
var elm_explorations$webgl$WebGL$Settings$Blend$srcAlpha = 770;
var author$project$Logic$Template$GFX$Projectile$values = {
	cC: 16,
	cX: _List_fromArray(
		[
			elm_explorations$webgl$WebGL$Settings$cullFace(elm_explorations$webgl$WebGL$Settings$front),
			A2(elm_explorations$webgl$WebGL$Settings$Blend$add, elm_explorations$webgl$WebGL$Settings$Blend$srcAlpha, elm_explorations$webgl$WebGL$Settings$Blend$oneMinusSrcAlpha),
			A4(elm_explorations$webgl$WebGL$Settings$colorMask, true, true, true, false)
		]),
	c$: author$project$Logic$Template$GFX$Particle$simpleFragmentShader,
	dA: author$project$Logic$Template$GFX$P16$points,
	ec: author$project$Logic$Template$GFX$P16$vertexShader
};
var elm$random$Random$initialSeed = function (x) {
	var _n0 = elm$random$Random$next(
		A2(elm$random$Random$Seed, 0, 1013904223));
	var state1 = _n0.a;
	var incr = _n0.b;
	var state2 = (state1 + x) >>> 0;
	return elm$random$Random$next(
		A2(elm$random$Random$Seed, state2, incr));
};
var author$project$Logic$Template$GFX$Projectile$emptyWith = function (settings) {
	return A2(
		author$project$Logic$Template$GFX$Projectile$fill,
		author$project$Logic$Template$GFX$Projectile$values.cC,
		{
			aT: _List_Nil,
			c0: settings.c0(
				A2(author$project$AltMath$Vector2$Vec2, -3, -3)),
			aq: _List_Nil,
			aC: 0,
			aZ: author$project$Logic$Template$GFX$P16$empty,
			ad: elm$random$Random$initialSeed(42),
			dX: settings.dX
		});
};
var author$project$Logic$Template$GFX$Projectile$empty = author$project$Logic$Template$GFX$Projectile$emptyWith(author$project$Logic$Template$GFX$Projectile$defaultSettings);
var author$project$Logic$Template$Input$empty = {bg: author$project$Logic$Component$empty, dC: elm$core$Set$empty, dI: elm$core$Dict$empty};
var elm_explorations$linear_algebra$Math$Matrix4$identity = _MJS_m4x4identity;
var author$project$Logic$Template$RenderInfo$empty = {
	eh: elm_explorations$linear_algebra$Math$Matrix4$identity,
	eE: elm_explorations$linear_algebra$Math$Matrix4$identity,
	Q: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0),
	R: 0.1,
	bF: {bm: 1, bQ: 1}
};
var author$project$Logic$Template$Game$Platformer$Common$empty = function () {
	var physics = author$project$Logic$Template$Component$Physics$empty;
	var audiosprite = author$project$Logic$Template$Component$SFX$empty;
	return {
		cE: author$project$Logic$Template$Component$TimeLineDict$empty,
		cL: {
			c8: 0,
			a6: A2(author$project$AltMath$Vector2$vec2, 0, 200),
			ee: -1
		},
		bi: author$project$Logic$GameFlow$Running,
		X: 0,
		eO: author$project$Logic$Template$Input$empty,
		b3: author$project$Logic$Template$Component$Layer$empty,
		dv: author$project$Logic$Template$Component$OnScreenControl$emptyTwoButtonStick,
		dy: _Utils_update(
			physics,
			{
				eJ: {n: 0, o: -0.5}
			}),
		cq: author$project$Logic$Template$GFX$Projectile$empty,
		fo: author$project$Logic$Template$RenderInfo$empty,
		ac: 0,
		dS: audiosprite,
		dY: author$project$Logic$Template$Component$Sprite$empty,
		d7: author$project$Logic$Template$Component$TimeLine$empty
	};
}();
var author$project$Logic$Template$Camera$spec = {
	eH: function ($) {
		return $.cL;
	},
	fu: F2(
		function (comps, world) {
			return _Utils_update(
				world,
				{cL: comps});
		})
};
var author$project$Logic$Template$Component$Layer$spec = {
	eH: function ($) {
		return $.b3;
	},
	fu: F2(
		function (layers, world) {
			return _Utils_update(
				world,
				{b3: layers});
		})
};
var author$project$Logic$Template$Component$Physics$spec = {
	eH: function ($) {
		return $.dy;
	},
	fu: F2(
		function (comps, world) {
			return _Utils_update(
				world,
				{dy: comps});
		})
};
var author$project$Logic$Template$Component$SFX$spec = {
	eH: function ($) {
		return $.dS;
	},
	fu: F2(
		function (comps, world) {
			return _Utils_update(
				world,
				{dS: comps});
		})
};
var author$project$Logic$Template$Component$Sprite$spec = {
	eH: function ($) {
		return $.dY;
	},
	fu: F2(
		function (comps, world) {
			return _Utils_update(
				world,
				{dY: comps});
		})
};
var author$project$Logic$Template$Component$TimeLine$spec = {
	eH: function ($) {
		return $.d7;
	},
	fu: F2(
		function (comps, world) {
			return _Utils_update(
				world,
				{d7: comps});
		})
};
var author$project$Logic$Template$Component$TimeLineDict$spec = {
	eH: function ($) {
		return $.cE;
	},
	fu: F2(
		function (comps, world) {
			return _Utils_update(
				world,
				{cE: comps});
		})
};
var author$project$Logic$Template$Input$spec = {
	eH: function ($) {
		return $.eO;
	},
	fu: F2(
		function (comps, world) {
			return _Utils_update(
				world,
				{eO: comps});
		})
};
var elm$bytes$Bytes$BE = 1;
var elm$bytes$Bytes$Encode$F32 = F2(
	function (a, b) {
		return {$: 6, a: a, b: b};
	});
var elm$bytes$Bytes$Encode$float32 = elm$bytes$Bytes$Encode$F32;
var author$project$Logic$Template$SaveLoad$Internal$Encode$float = elm$bytes$Bytes$Encode$float32(1);
var author$project$Logic$Template$RenderInfo$encode = F2(
	function (_n0, world) {
		var get = _n0.eH;
		return author$project$Logic$Template$SaveLoad$Internal$Encode$float(
			get(world).R);
	});
var author$project$Logic$Template$RenderInfo$spec = {
	eH: function ($) {
		return $.fo;
	},
	fu: F2(
		function (comps, world) {
			return _Utils_update(
				world,
				{fo: comps});
		})
};
var elm$bytes$Bytes$Encode$U8 = function (a) {
	return {$: 3, a: a};
};
var elm$bytes$Bytes$Encode$unsignedInt8 = elm$bytes$Bytes$Encode$U8;
var author$project$Logic$Template$SaveLoad$Internal$Encode$bool = function (a) {
	return a ? elm$bytes$Bytes$Encode$unsignedInt8(1) : elm$bytes$Bytes$Encode$unsignedInt8(0);
};
var elm$bytes$Bytes$Encode$Seq = F2(
	function (a, b) {
		return {$: 8, a: a, b: b};
	});
var elm$bytes$Bytes$LE = 0;
var elm$bytes$Bytes$Encode$write = F3(
	function (builder, mb, offset) {
		switch (builder.$) {
			case 0:
				var n = builder.a;
				return A3(_Bytes_write_i8, mb, offset, n);
			case 1:
				var e = builder.a;
				var n = builder.b;
				return A4(_Bytes_write_i16, mb, offset, n, !e);
			case 2:
				var e = builder.a;
				var n = builder.b;
				return A4(_Bytes_write_i32, mb, offset, n, !e);
			case 3:
				var n = builder.a;
				return A3(_Bytes_write_u8, mb, offset, n);
			case 4:
				var e = builder.a;
				var n = builder.b;
				return A4(_Bytes_write_u16, mb, offset, n, !e);
			case 5:
				var e = builder.a;
				var n = builder.b;
				return A4(_Bytes_write_u32, mb, offset, n, !e);
			case 6:
				var e = builder.a;
				var n = builder.b;
				return A4(_Bytes_write_f32, mb, offset, n, !e);
			case 7:
				var e = builder.a;
				var n = builder.b;
				return A4(_Bytes_write_f64, mb, offset, n, !e);
			case 8:
				var bs = builder.b;
				return A3(elm$bytes$Bytes$Encode$writeSequence, bs, mb, offset);
			case 9:
				var s = builder.b;
				return A3(_Bytes_write_string, mb, offset, s);
			default:
				var bs = builder.a;
				return A3(_Bytes_write_bytes, mb, offset, bs);
		}
	});
var elm$bytes$Bytes$Encode$writeSequence = F3(
	function (builders, mb, offset) {
		writeSequence:
		while (true) {
			if (!builders.b) {
				return offset;
			} else {
				var b = builders.a;
				var bs = builders.b;
				var $temp$builders = bs,
					$temp$mb = mb,
					$temp$offset = A3(elm$bytes$Bytes$Encode$write, b, mb, offset);
				builders = $temp$builders;
				mb = $temp$mb;
				offset = $temp$offset;
				continue writeSequence;
			}
		}
	});
var elm$bytes$Bytes$Encode$getWidth = function (builder) {
	switch (builder.$) {
		case 0:
			return 1;
		case 1:
			return 2;
		case 2:
			return 4;
		case 3:
			return 1;
		case 4:
			return 2;
		case 5:
			return 4;
		case 6:
			return 4;
		case 7:
			return 8;
		case 8:
			var w = builder.a;
			return w;
		case 9:
			var w = builder.a;
			return w;
		default:
			var bs = builder.a;
			return _Bytes_width(bs);
	}
};
var elm$bytes$Bytes$Encode$getWidths = F2(
	function (width, builders) {
		getWidths:
		while (true) {
			if (!builders.b) {
				return width;
			} else {
				var b = builders.a;
				var bs = builders.b;
				var $temp$width = width + elm$bytes$Bytes$Encode$getWidth(b),
					$temp$builders = bs;
				width = $temp$width;
				builders = $temp$builders;
				continue getWidths;
			}
		}
	});
var elm$bytes$Bytes$Encode$sequence = function (builders) {
	return A2(
		elm$bytes$Bytes$Encode$Seq,
		A2(elm$bytes$Bytes$Encode$getWidths, 0, builders),
		builders);
};
var elm$bytes$Bytes$Encode$U32 = F2(
	function (a, b) {
		return {$: 5, a: a, b: b};
	});
var elm$bytes$Bytes$Encode$unsignedInt32 = elm$bytes$Bytes$Encode$U32;
var elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							elm$core$List$foldl,
							fn,
							acc,
							elm$core$List$reverse(r4)) : A4(elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4(elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var author$project$Logic$Template$SaveLoad$Internal$Encode$list = F2(
	function (f, l) {
		return elm$bytes$Bytes$Encode$sequence(
			A2(
				elm$core$List$cons,
				A2(
					elm$bytes$Bytes$Encode$unsignedInt32,
					1,
					elm$core$List$length(l)),
				A2(elm$core$List$map, f, l)));
	});
var elm$bytes$Bytes$Encode$getStringWidth = _Bytes_getStringWidth;
var elm$bytes$Bytes$Encode$Utf8 = F2(
	function (a, b) {
		return {$: 9, a: a, b: b};
	});
var elm$bytes$Bytes$Encode$string = function (str) {
	return A2(
		elm$bytes$Bytes$Encode$Utf8,
		_Bytes_getStringWidth(str),
		str);
};
var author$project$Logic$Template$SaveLoad$Internal$Encode$sizedString = function (str) {
	return elm$bytes$Bytes$Encode$sequence(
		_List_fromArray(
			[
				A2(
				elm$bytes$Bytes$Encode$unsignedInt32,
				1,
				elm$bytes$Bytes$Encode$getStringWidth(str)),
				elm$bytes$Bytes$Encode$string(str)
			]));
};
var author$project$Logic$Template$SaveLoad$AudioSprite$encode = F2(
	function (_n0, world) {
		var get = _n0.eH;
		var _n1 = get(world);
		var config = _n1.aS;
		var sprite = A2(
			author$project$Logic$Template$SaveLoad$Internal$Encode$list,
			function (_n2) {
				var key = _n2.a;
				var offset = _n2.b.Q;
				var duration = _n2.b.ax;
				var loop = _n2.b.aA;
				return elm$bytes$Bytes$Encode$sequence(
					_List_fromArray(
						[
							author$project$Logic$Template$SaveLoad$Internal$Encode$sizedString(key),
							author$project$Logic$Template$SaveLoad$Internal$Encode$float(offset),
							author$project$Logic$Template$SaveLoad$Internal$Encode$float(duration),
							author$project$Logic$Template$SaveLoad$Internal$Encode$bool(loop)
						]));
			},
			elm$core$Dict$toList(config.ct));
		var src = A2(author$project$Logic$Template$SaveLoad$Internal$Encode$list, author$project$Logic$Template$SaveLoad$Internal$Encode$sizedString, config.fv);
		return elm$bytes$Bytes$Encode$sequence(
			_List_fromArray(
				[src, sprite]));
	});
var author$project$Logic$Template$SaveLoad$Internal$Encode$id = elm$bytes$Bytes$Encode$unsignedInt32(1);
var author$project$Logic$Template$SaveLoad$Camera$encodeId = F2(
	function (_n0, world) {
		var get = _n0.eH;
		return author$project$Logic$Template$SaveLoad$Internal$Encode$id(
			get(world).c8);
	});
var author$project$Logic$Template$SaveLoad$Input$encode = F2(
	function (_n0, world) {
		var get = _n0.eH;
		var _n1 = get(world);
		var registered = _n1.dI;
		return A2(
			author$project$Logic$Template$SaveLoad$Internal$Encode$list,
			function (_n2) {
				var key = _n2.a;
				var _n3 = _n2.b;
				var id = _n3.a;
				var action = _n3.b;
				return elm$bytes$Bytes$Encode$sequence(
					_List_fromArray(
						[
							author$project$Logic$Template$SaveLoad$Internal$Encode$id(id),
							author$project$Logic$Template$SaveLoad$Internal$Encode$sizedString(key),
							author$project$Logic$Template$SaveLoad$Internal$Encode$sizedString(action)
						]));
			},
			elm$core$Dict$toList(registered));
	});
var elm$core$Elm$JsArray$foldl = _JsArray_foldl;
var elm$core$Array$foldl = F3(
	function (func, baseCase, _n0) {
		var tree = _n0.c;
		var tail = _n0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
					var subTree = node.a;
					return A3(elm$core$Elm$JsArray$foldl, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3(elm$core$Elm$JsArray$foldl, func, acc, values);
				}
			});
		return A3(
			elm$core$Elm$JsArray$foldl,
			func,
			A3(elm$core$Elm$JsArray$foldl, helper, baseCase, tree),
			tail);
	});
var elm$core$Tuple$second = function (_n0) {
	var y = _n0.b;
	return y;
};
var author$project$Logic$Internal$indexedFoldlArray = F3(
	function (func, acc, list) {
		var step = F2(
			function (x, _n0) {
				var i = _n0.a;
				var thisAcc = _n0.b;
				return _Utils_Tuple2(
					i + 1,
					A3(func, i, x, thisAcc));
			});
		return A3(
			elm$core$Array$foldl,
			step,
			_Utils_Tuple2(0, acc),
			list).b;
	});
var elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return elm$core$Maybe$Just(
				f(value));
		} else {
			return elm$core$Maybe$Nothing;
		}
	});
var elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var author$project$Logic$Entity$toList = A2(
	author$project$Logic$Internal$indexedFoldlArray,
	F3(
		function (i, a, acc) {
			return A2(
				elm$core$Maybe$withDefault,
				acc,
				A2(
					elm$core$Maybe$map,
					function (a_) {
						return A2(
							elm$core$List$cons,
							_Utils_Tuple2(i, a_),
							acc);
					},
					a));
		}),
	_List_Nil);
var author$project$Logic$Template$SaveLoad$Internal$Encode$xy = function (_n0) {
	var x = _n0.n;
	var y = _n0.o;
	return elm$bytes$Bytes$Encode$sequence(
		_List_fromArray(
			[
				author$project$Logic$Template$SaveLoad$Internal$Encode$float(x),
				author$project$Logic$Template$SaveLoad$Internal$Encode$float(y)
			]));
};
var author$project$Logic$Template$SaveLoad$Internal$Encode$xyz = function (_n0) {
	var x = _n0.n;
	var y = _n0.o;
	var z = _n0.fL;
	return elm$bytes$Bytes$Encode$sequence(
		_List_fromArray(
			[
				author$project$Logic$Template$SaveLoad$Internal$Encode$float(x),
				author$project$Logic$Template$SaveLoad$Internal$Encode$float(y),
				author$project$Logic$Template$SaveLoad$Internal$Encode$float(z)
			]));
};
var elm_explorations$linear_algebra$Math$Vector2$toRecord = _MJS_v2toRecord;
var elm_explorations$linear_algebra$Math$Vector3$toRecord = _MJS_v3toRecord;
var author$project$Logic$Template$SaveLoad$Layer$encode = F2(
	function (_n0, world) {
		var get = _n0.eH;
		var tilesData = F2(
			function (layerId, info) {
				return elm$bytes$Bytes$Encode$sequence(
					_List_fromArray(
						[
							elm$bytes$Bytes$Encode$unsignedInt8(layerId),
							author$project$Logic$Template$SaveLoad$Internal$Encode$id(info.c8),
							author$project$Logic$Template$SaveLoad$Internal$Encode$id(info.eD),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xy(
							elm_explorations$linear_algebra$Math$Vector2$toRecord(info.aI)),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xy(
							elm_explorations$linear_algebra$Math$Vector2$toRecord(info.aG)),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xy(
							elm_explorations$linear_algebra$Math$Vector2$toRecord(info.aJ)),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xyz(
							elm_explorations$linear_algebra$Math$Vector3$toRecord(info.T)),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xy(
							elm_explorations$linear_algebra$Math$Vector2$toRecord(info.a_))
						]));
			});
		var imageData = F2(
			function (layerId, info) {
				return elm$bytes$Bytes$Encode$sequence(
					_List_fromArray(
						[
							elm$bytes$Bytes$Encode$unsignedInt8(layerId),
							A2(elm$bytes$Bytes$Encode$unsignedInt32, 1, info.c8),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xy(
							elm_explorations$linear_algebra$Math$Vector2$toRecord(info.cs)),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xyz(
							elm_explorations$linear_algebra$Math$Vector3$toRecord(info.T)),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xy(
							elm_explorations$linear_algebra$Math$Vector2$toRecord(info.a_))
						]));
			});
		return A2(
			author$project$Logic$Template$SaveLoad$Internal$Encode$list,
			function (layer) {
				switch (layer.$) {
					case 6:
						var _n2 = layer.a;
						var info = _n2.b;
						var objectLayer = A2(
							author$project$Logic$Template$SaveLoad$Internal$Encode$list,
							function (_n3) {
								var i = _n3.a;
								return A2(elm$bytes$Bytes$Encode$unsignedInt32, 1, i);
							},
							author$project$Logic$Entity$toList(info));
						return elm$bytes$Bytes$Encode$sequence(
							_List_fromArray(
								[
									elm$bytes$Bytes$Encode$unsignedInt8(0),
									objectLayer
								]));
					case 2:
						var info = layer.a;
						return A2(imageData, 1, info);
					case 3:
						var info = layer.a;
						return A2(imageData, 2, info);
					case 4:
						var info = layer.a;
						return A2(imageData, 3, info);
					case 5:
						var info = layer.a;
						return A2(imageData, 4, info);
					case 0:
						var info = layer.a;
						return A2(tilesData, 5, info);
					default:
						return elm$bytes$Bytes$Encode$unsignedInt8(6);
				}
			},
			get(world));
	});
var author$project$Broad$Grid$getConfig = function (_n0) {
	var config = _n0.b;
	var _n1 = config.s;
	var cellW = _n1.a;
	var cellH = _n1.b;
	return {
		aP: {fH: cellW * config.be, fI: config.fI, fJ: cellH * config.bD, fK: config.fK},
		s: {bm: cellH, bQ: cellW}
	};
};
var elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === -2) {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3(elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var elm$core$Dict$Black = 1;
var elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: -1, a: a, b: b, c: c, d: d, e: e};
	});
var elm$core$Basics$compare = _Utils_compare;
var elm$core$Dict$Red = 0;
var elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === -1) && (!right.a)) {
			var _n1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === -1) && (!left.a)) {
				var _n3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					0,
					key,
					value,
					A5(elm$core$Dict$RBNode_elm_builtin, 1, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rLeft, rRight));
			} else {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === -1) && (!left.a)) && (left.d.$ === -1)) && (!left.d.a)) {
				var _n5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _n6 = left.d;
				var _n7 = _n6.a;
				var llK = _n6.b;
				var llV = _n6.c;
				var llLeft = _n6.d;
				var llRight = _n6.e;
				var lRight = left.e;
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					0,
					lK,
					lV,
					A5(elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 1, key, value, lRight, right));
			} else {
				return A5(elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === -2) {
			return A5(elm$core$Dict$RBNode_elm_builtin, 0, key, value, elm$core$Dict$RBEmpty_elm_builtin, elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _n1 = A2(elm$core$Basics$compare, key, nKey);
			switch (_n1) {
				case 0:
					return A5(
						elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3(elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 1:
					return A5(elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3(elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _n0 = A3(elm$core$Dict$insertHelp, key, value, dict);
		if ((_n0.$ === -1) && (!_n0.a)) {
			var _n1 = _n0.a;
			var k = _n0.b;
			var v = _n0.c;
			var l = _n0.d;
			var r = _n0.e;
			return A5(elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _n0;
			return x;
		}
	});
var elm$core$Dict$union = F2(
	function (t1, t2) {
		return A3(elm$core$Dict$foldl, elm$core$Dict$insert, t2, t1);
	});
var elm$core$Dict$values = function (dict) {
	return A3(
		elm$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return A2(elm$core$List$cons, value, valueList);
			}),
		_List_Nil,
		dict);
};
var author$project$Broad$Grid$toList = function (_n0) {
	var table = _n0.a;
	return elm$core$Dict$values(
		A3(
			elm$core$Dict$foldl,
			function (_n1) {
				return elm$core$Dict$union;
			},
			elm$core$Dict$empty,
			table));
};
var author$project$Broad$Grid$toBytes = F2(
	function (eItem, grid) {
		var list = F2(
			function (f, l) {
				return elm$bytes$Bytes$Encode$sequence(
					A2(
						elm$core$List$cons,
						A2(
							elm$bytes$Bytes$Encode$unsignedInt32,
							1,
							elm$core$List$length(l)),
						A2(elm$core$List$map, f, l)));
			});
		var items = A2(
			list,
			eItem,
			author$project$Broad$Grid$toList(grid));
		var config = function (_n0) {
			var boundary = _n0.aP;
			var cell = _n0.s;
			return elm$bytes$Bytes$Encode$sequence(
				_List_fromArray(
					[
						A2(elm$bytes$Bytes$Encode$float32, 1, boundary.fI),
						A2(elm$bytes$Bytes$Encode$float32, 1, boundary.fH),
						A2(elm$bytes$Bytes$Encode$float32, 1, boundary.fK),
						A2(elm$bytes$Bytes$Encode$float32, 1, boundary.fJ),
						A2(elm$bytes$Bytes$Encode$float32, 1, cell.bQ),
						A2(elm$bytes$Bytes$Encode$float32, 1, cell.bm)
					]));
		}(
			author$project$Broad$Grid$getConfig(grid));
		return elm$bytes$Bytes$Encode$sequence(
			_List_fromArray(
				[config, items]));
	});
var author$project$Physic$Narrow$AABB$toBytes = F2(
	function (enId, _n0) {
		var c = _n0.a;
		var h = _n0.b.c3;
		return elm$bytes$Bytes$Encode$sequence(
			_List_fromArray(
				[
					enId(c.l),
					author$project$Logic$Template$SaveLoad$Internal$Encode$xy(c.bC),
					author$project$Logic$Template$SaveLoad$Internal$Encode$xy(c.fj),
					author$project$Logic$Template$SaveLoad$Internal$Encode$float(c.az),
					author$project$Logic$Template$SaveLoad$Internal$Encode$float(h)
				]));
	});
var elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var author$project$Logic$Template$SaveLoad$Physics$encode = F2(
	function (_n0, world) {
		var get = _n0.eH;
		var itemEncoder = author$project$Physic$Narrow$AABB$toBytes(
			A2(
				elm$core$Basics$composeR,
				elm$core$Maybe$map(
					elm$core$Basics$add(1)),
				A2(
					elm$core$Basics$composeR,
					elm$core$Maybe$withDefault(0),
					author$project$Logic$Template$SaveLoad$Internal$Encode$id)));
		var _static = A2(
			author$project$Broad$Grid$toBytes,
			itemEncoder,
			get(world).C);
		var indexedEncoder = function (indexed) {
			return A2(
				author$project$Logic$Template$SaveLoad$Internal$Encode$list,
				function (_n2) {
					var id = _n2.a;
					var item = _n2.b;
					return elm$bytes$Bytes$Encode$sequence(
						_List_fromArray(
							[
								author$project$Logic$Template$SaveLoad$Internal$Encode$id(id),
								itemEncoder(item)
							]));
				},
				elm$core$Dict$toList(indexed));
		};
		return function (_n1) {
			var gravity = _n1.eJ;
			var indexed = _n1.db;
			return elm$bytes$Bytes$Encode$sequence(
				_List_fromArray(
					[
						author$project$Logic$Template$SaveLoad$Internal$Encode$xy(gravity),
						indexedEncoder(indexed),
						_static
					]));
		}(
			get(world));
	});
var author$project$Logic$Template$SaveLoad$Sprite$encode = F2(
	function (_n0, world) {
		var get = _n0.eH;
		return A2(
			author$project$Logic$Template$SaveLoad$Internal$Encode$list,
			function (_n1) {
				var id = _n1.a;
				var item = _n1.b;
				return elm$bytes$Bytes$Encode$sequence(
					_List_fromArray(
						[
							author$project$Logic$Template$SaveLoad$Internal$Encode$id(id),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xy(
							elm_explorations$linear_algebra$Math$Vector2$toRecord(item.bN)),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xy(
							elm_explorations$linear_algebra$Math$Vector2$toRecord(item.bK)),
							author$project$Logic$Template$SaveLoad$Internal$Encode$float(item.bL),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xy(
							elm_explorations$linear_algebra$Math$Vector2$toRecord(item.aG)),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xy(
							elm_explorations$linear_algebra$Math$Vector2$toRecord(item.aJ)),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xy(
							elm_explorations$linear_algebra$Math$Vector2$toRecord(item.bM)),
							author$project$Logic$Template$SaveLoad$Internal$Encode$xyz(
							elm_explorations$linear_algebra$Math$Vector3$toRecord(item.T)),
							author$project$Logic$Template$SaveLoad$Internal$Encode$id(item.cG)
						]));
			},
			author$project$Logic$Entity$toList(
				get(world)));
	});
var author$project$Logic$Template$Internal$toList = function (_n0) {
	var a = _n0.a;
	var l = _n0.b;
	return A2(
		elm$core$List$cons,
		a,
		elm$core$Array$toList(l));
};
var author$project$Logic$Template$SaveLoad$TimeLine$encodeSimple = function (item) {
	return elm$bytes$Bytes$Encode$sequence(
		_List_fromArray(
			[
				A2(
				author$project$Logic$Template$SaveLoad$Internal$Encode$list,
				author$project$Logic$Template$SaveLoad$Internal$Encode$float,
				author$project$Logic$Template$Internal$toList(item.bJ)),
				author$project$Logic$Template$SaveLoad$Internal$Encode$xy(
				elm_explorations$linear_algebra$Math$Vector2$toRecord(item.bM))
			]));
};
var author$project$Logic$Template$SaveLoad$TimeLine$encode = F2(
	function (_n0, world) {
		var get = _n0.eH;
		return A2(
			author$project$Logic$Template$SaveLoad$Internal$Encode$list,
			function (_n1) {
				var id = _n1.a;
				var item = _n1.b;
				return elm$bytes$Bytes$Encode$sequence(
					_List_fromArray(
						[
							A2(elm$bytes$Bytes$Encode$unsignedInt32, 1, id),
							author$project$Logic$Template$SaveLoad$TimeLine$encodeSimple(item)
						]));
			},
			author$project$Logic$Entity$toList(
				get(world)));
	});
var author$project$Logic$Template$SaveLoad$TimeLineDict$encodeAnimationId = function (_n0) {
	var a = _n0.a;
	var b = _n0.b;
	return elm$bytes$Bytes$Encode$sequence(
		_List_fromArray(
			[
				author$project$Logic$Template$SaveLoad$Internal$Encode$sizedString(a),
				elm$bytes$Bytes$Encode$unsignedInt8(b)
			]));
};
var author$project$Logic$Template$SaveLoad$TimeLineDict$encode = F2(
	function (_n0, world) {
		var get = _n0.eH;
		return A2(
			author$project$Logic$Template$SaveLoad$Internal$Encode$list,
			function (_n1) {
				var id = _n1.a;
				var _n2 = _n1.b;
				var current = _n2.a;
				var dict = _n2.b;
				var encodeDict = A2(
					author$project$Logic$Template$SaveLoad$Internal$Encode$list,
					function (_n3) {
						var animId = _n3.a;
						var animLine = _n3.b;
						return elm$bytes$Bytes$Encode$sequence(
							_List_fromArray(
								[
									author$project$Logic$Template$SaveLoad$TimeLineDict$encodeAnimationId(animId),
									author$project$Logic$Template$SaveLoad$TimeLine$encodeSimple(animLine)
								]));
					},
					elm$core$Dict$toList(dict));
				return elm$bytes$Bytes$Encode$sequence(
					_List_fromArray(
						[
							author$project$Logic$Template$SaveLoad$Internal$Encode$id(id),
							author$project$Logic$Template$SaveLoad$TimeLineDict$encodeAnimationId(current),
							encodeDict
						]));
			},
			author$project$Logic$Entity$toList(
				get(world)));
	});
var author$project$Logic$Template$Game$Platformer$Common$encoders = _List_fromArray(
	[
		author$project$Logic$Template$SaveLoad$Sprite$encode(author$project$Logic$Template$Component$Sprite$spec),
		author$project$Logic$Template$SaveLoad$Input$encode(author$project$Logic$Template$Input$spec),
		author$project$Logic$Template$SaveLoad$TimeLine$encode(author$project$Logic$Template$Component$TimeLine$spec),
		author$project$Logic$Template$SaveLoad$TimeLineDict$encode(author$project$Logic$Template$Component$TimeLineDict$spec),
		author$project$Logic$Template$RenderInfo$encode(author$project$Logic$Template$RenderInfo$spec),
		author$project$Logic$Template$SaveLoad$Layer$encode(author$project$Logic$Template$Component$Layer$spec),
		author$project$Logic$Template$SaveLoad$Physics$encode(author$project$Logic$Template$Component$Physics$spec),
		author$project$Logic$Template$SaveLoad$Camera$encodeId(author$project$Logic$Template$Camera$spec),
		author$project$Logic$Template$SaveLoad$AudioSprite$encode(author$project$Logic$Template$Component$SFX$spec)
	]);
var author$project$Logic$Template$SaveLoad$Internal$Reader$Sync = function (a) {
	return {$: 0, a: a};
};
var author$project$Logic$Template$SaveLoad$Internal$Reader$None = {$: 2};
var author$project$Logic$Template$SaveLoad$Internal$Reader$defaultRead = {bp: author$project$Logic$Template$SaveLoad$Internal$Reader$None, bq: author$project$Logic$Template$SaveLoad$Internal$Reader$None, br: author$project$Logic$Template$SaveLoad$Internal$Reader$None, bs: author$project$Logic$Template$SaveLoad$Internal$Reader$None, eQ: author$project$Logic$Template$SaveLoad$Internal$Reader$None, bw: author$project$Logic$Template$SaveLoad$Internal$Reader$None, bx: author$project$Logic$Template$SaveLoad$Internal$Reader$None, by: author$project$Logic$Template$SaveLoad$Internal$Reader$None, bz: author$project$Logic$Template$SaveLoad$Internal$Reader$None, bA: author$project$Logic$Template$SaveLoad$Internal$Reader$None, e9: author$project$Logic$Template$SaveLoad$Internal$Reader$None};
var author$project$Logic$Template$SaveLoad$Internal$Util$intFromHexChar = function (s) {
	switch (s) {
		case '0':
			return elm$core$Maybe$Just(0);
		case '1':
			return elm$core$Maybe$Just(1);
		case '2':
			return elm$core$Maybe$Just(2);
		case '3':
			return elm$core$Maybe$Just(3);
		case '4':
			return elm$core$Maybe$Just(4);
		case '5':
			return elm$core$Maybe$Just(5);
		case '6':
			return elm$core$Maybe$Just(6);
		case '7':
			return elm$core$Maybe$Just(7);
		case '8':
			return elm$core$Maybe$Just(8);
		case '9':
			return elm$core$Maybe$Just(9);
		case 'a':
			return elm$core$Maybe$Just(10);
		case 'b':
			return elm$core$Maybe$Just(11);
		case 'c':
			return elm$core$Maybe$Just(12);
		case 'd':
			return elm$core$Maybe$Just(13);
		case 'e':
			return elm$core$Maybe$Just(14);
		case 'f':
			return elm$core$Maybe$Just(15);
		default:
			return elm$core$Maybe$Nothing;
	}
};
var author$project$Logic$Template$SaveLoad$Internal$Util$maybeMap6 = F7(
	function (func, ma, mb, mc, md, me, mf) {
		if (ma.$ === 1) {
			return elm$core$Maybe$Nothing;
		} else {
			var a = ma.a;
			if (mb.$ === 1) {
				return elm$core$Maybe$Nothing;
			} else {
				var b = mb.a;
				if (mc.$ === 1) {
					return elm$core$Maybe$Nothing;
				} else {
					var c = mc.a;
					if (md.$ === 1) {
						return elm$core$Maybe$Nothing;
					} else {
						var d = md.a;
						if (me.$ === 1) {
							return elm$core$Maybe$Nothing;
						} else {
							var e = me.a;
							if (mf.$ === 1) {
								return elm$core$Maybe$Nothing;
							} else {
								var f = mf.a;
								return elm$core$Maybe$Just(
									A6(func, a, b, c, d, e, f));
							}
						}
					}
				}
			}
		}
	});
var elm$core$String$length = _String_length;
var elm$core$String$slice = _String_slice;
var elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			elm$core$String$slice,
			n,
			elm$core$String$length(string),
			string);
	});
var elm$core$String$startsWith = _String_startsWith;
var elm$core$String$foldr = _String_foldr;
var elm$core$String$toList = function (string) {
	return A3(elm$core$String$foldr, elm$core$List$cons, _List_Nil, string);
};
var elm_explorations$linear_algebra$Math$Vector3$vec3 = _MJS_v3;
var author$project$Logic$Template$SaveLoad$Internal$Util$hexColor2Vec3 = function (str) {
	var withoutHash = A2(elm$core$String$startsWith, '#', str) ? A2(elm$core$String$dropLeft, 1, str) : str;
	var _n0 = elm$core$String$toList(withoutHash);
	if ((((((_n0.b && _n0.b.b) && _n0.b.b.b) && _n0.b.b.b.b) && _n0.b.b.b.b.b) && _n0.b.b.b.b.b.b) && (!_n0.b.b.b.b.b.b.b)) {
		var r1 = _n0.a;
		var _n1 = _n0.b;
		var r2 = _n1.a;
		var _n2 = _n1.b;
		var g1 = _n2.a;
		var _n3 = _n2.b;
		var g2 = _n3.a;
		var _n4 = _n3.b;
		var b1 = _n4.a;
		var _n5 = _n4.b;
		var b2 = _n5.a;
		return A7(
			author$project$Logic$Template$SaveLoad$Internal$Util$maybeMap6,
			F6(
				function (a, b, c, d, e, f) {
					return A3(elm_explorations$linear_algebra$Math$Vector3$vec3, ((a * 16) + b) / 255, ((c * 16) + d) / 255, ((e * 16) + f) / 255);
				}),
			author$project$Logic$Template$SaveLoad$Internal$Util$intFromHexChar(r1),
			author$project$Logic$Template$SaveLoad$Internal$Util$intFromHexChar(r2),
			author$project$Logic$Template$SaveLoad$Internal$Util$intFromHexChar(g1),
			author$project$Logic$Template$SaveLoad$Internal$Util$intFromHexChar(g2),
			author$project$Logic$Template$SaveLoad$Internal$Util$intFromHexChar(b1),
			author$project$Logic$Template$SaveLoad$Internal$Util$intFromHexChar(b2));
	} else {
		return elm$core$Maybe$Nothing;
	}
};
var elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === -2) {
				return elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _n1 = A2(elm$core$Basics$compare, targetKey, key);
				switch (_n1) {
					case 0:
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 1:
						return elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var elm$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		if (!maybeValue.$) {
			var value = maybeValue.a;
			return callback(value);
		} else {
			return elm$core$Maybe$Nothing;
		}
	});
var author$project$Logic$Template$SaveLoad$Internal$Util$propWrap = F4(
	function (dict, parser, key, _default) {
		return A2(
			elm$core$Maybe$withDefault,
			_default,
			A2(
				elm$core$Maybe$andThen,
				parser,
				A2(elm$core$Dict$get, key, dict)));
	});
var author$project$Logic$Template$SaveLoad$Internal$Util$propertiesWithDefault = function (object) {
	return {
		bV: A2(
			author$project$Logic$Template$SaveLoad$Internal$Util$propWrap,
			object.fi,
			function (r) {
				if (!r.$) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		bd: A2(
			author$project$Logic$Template$SaveLoad$Internal$Util$propWrap,
			object.fi,
			function (r) {
				if (r.$ === 4) {
					var i = r.a;
					return author$project$Logic$Template$SaveLoad$Internal$Util$hexColor2Vec3(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		eC: A2(
			author$project$Logic$Template$SaveLoad$Internal$Util$propWrap,
			object.fi,
			function (r) {
				if (r.$ === 5) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		eG: A2(
			author$project$Logic$Template$SaveLoad$Internal$Util$propWrap,
			object.fi,
			function (r) {
				if (r.$ === 2) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		b1: A2(
			author$project$Logic$Template$SaveLoad$Internal$Util$propWrap,
			object.fi,
			function (r) {
				if (r.$ === 1) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		cu: A2(
			author$project$Logic$Template$SaveLoad$Internal$Util$propWrap,
			object.fi,
			function (r) {
				if (r.$ === 3) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			})
	};
};
var author$project$Logic$Template$SaveLoad$Internal$Util$levelProps = function (level) {
	switch (level.$) {
		case 0:
			var info = level.a;
			return author$project$Logic$Template$SaveLoad$Internal$Util$propertiesWithDefault(info);
		case 1:
			var info = level.a;
			return author$project$Logic$Template$SaveLoad$Internal$Util$propertiesWithDefault(info);
		case 2:
			var info = level.a;
			return author$project$Logic$Template$SaveLoad$Internal$Util$propertiesWithDefault(info);
		default:
			var info = level.a;
			return author$project$Logic$Template$SaveLoad$Internal$Util$propertiesWithDefault(info);
	}
};
var author$project$Logic$Template$RenderInfo$read = function (_n0) {
	var get = _n0.eH;
	var set = _n0.fu;
	return _Utils_update(
		author$project$Logic$Template$SaveLoad$Internal$Reader$defaultRead,
		{
			eQ: author$project$Logic$Template$SaveLoad$Internal$Reader$Sync(
				F2(
					function (level, _n1) {
						var entityID = _n1.a;
						var world = _n1.b;
						var renderInfo = get(world);
						return _Utils_Tuple2(
							entityID,
							A2(
								set,
								_Utils_update(
									renderInfo,
									{
										R: function (prop) {
											return 1 / A2(prop.eG, 'pixelsPerUnit', 0.1);
										}(
											author$project$Logic$Template$SaveLoad$Internal$Util$levelProps(level))
									}),
								world));
					}))
		});
};
var author$project$Logic$Launcher$Error = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var author$project$Logic$Template$SaveLoad$Internal$Loader$Json_ = function (a) {
	return {$: 3, a: a};
};
var elm$core$Result$mapError = F2(
	function (f, result) {
		if (!result.$) {
			var v = result.a;
			return elm$core$Result$Ok(v);
		} else {
			var e = result.a;
			return elm$core$Result$Err(
				f(e));
		}
	});
var elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === -1) && (dict.d.$ === -1)) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.e.d.$ === -1) && (!dict.e.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _n1 = dict.d;
			var lClr = _n1.a;
			var lK = _n1.b;
			var lV = _n1.c;
			var lLeft = _n1.d;
			var lRight = _n1.e;
			var _n2 = dict.e;
			var rClr = _n2.a;
			var rK = _n2.b;
			var rV = _n2.c;
			var rLeft = _n2.d;
			var _n3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _n2.e;
			return A5(
				elm$core$Dict$RBNode_elm_builtin,
				0,
				rlK,
				rlV,
				A5(
					elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					rlL),
				A5(elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _n4 = dict.d;
			var lClr = _n4.a;
			var lK = _n4.b;
			var lV = _n4.c;
			var lLeft = _n4.d;
			var lRight = _n4.e;
			var _n5 = dict.e;
			var rClr = _n5.a;
			var rK = _n5.b;
			var rV = _n5.c;
			var rLeft = _n5.d;
			var rRight = _n5.e;
			if (clr === 1) {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.d.d.$ === -1) && (!dict.d.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _n1 = dict.d;
			var lClr = _n1.a;
			var lK = _n1.b;
			var lV = _n1.c;
			var _n2 = _n1.d;
			var _n3 = _n2.a;
			var llK = _n2.b;
			var llV = _n2.c;
			var llLeft = _n2.d;
			var llRight = _n2.e;
			var lRight = _n1.e;
			var _n4 = dict.e;
			var rClr = _n4.a;
			var rK = _n4.b;
			var rV = _n4.c;
			var rLeft = _n4.d;
			var rRight = _n4.e;
			return A5(
				elm$core$Dict$RBNode_elm_builtin,
				0,
				lK,
				lV,
				A5(elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
				A5(
					elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					lRight,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _n5 = dict.d;
			var lClr = _n5.a;
			var lK = _n5.b;
			var lV = _n5.c;
			var lLeft = _n5.d;
			var lRight = _n5.e;
			var _n6 = dict.e;
			var rClr = _n6.a;
			var rK = _n6.b;
			var rV = _n6.c;
			var rLeft = _n6.d;
			var rRight = _n6.e;
			if (clr === 1) {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5(elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5(elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === -1) && (!left.a)) {
			var _n1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5(elm$core$Dict$RBNode_elm_builtin, 0, key, value, lRight, right));
		} else {
			_n2$2:
			while (true) {
				if ((right.$ === -1) && (right.a === 1)) {
					if (right.d.$ === -1) {
						if (right.d.a === 1) {
							var _n3 = right.a;
							var _n4 = right.d;
							var _n5 = _n4.a;
							return elm$core$Dict$moveRedRight(dict);
						} else {
							break _n2$2;
						}
					} else {
						var _n6 = right.a;
						var _n7 = right.d;
						return elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _n2$2;
				}
			}
			return dict;
		}
	});
var elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === -1) && (dict.d.$ === -1)) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor === 1) {
			if ((lLeft.$ === -1) && (!lLeft.a)) {
				var _n3 = lLeft.a;
				return A5(
					elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					elm$core$Dict$removeMin(left),
					right);
			} else {
				var _n4 = elm$core$Dict$moveRedLeft(dict);
				if (_n4.$ === -1) {
					var nColor = _n4.a;
					var nKey = _n4.b;
					var nValue = _n4.c;
					var nLeft = _n4.d;
					var nRight = _n4.e;
					return A5(
						elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === -2) {
			return elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === -1) && (left.a === 1)) {
					var _n4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === -1) && (!lLeft.a)) {
						var _n6 = lLeft.a;
						return A5(
							elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2(elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _n7 = elm$core$Dict$moveRedLeft(dict);
						if (_n7.$ === -1) {
							var nColor = _n7.a;
							var nKey = _n7.b;
							var nValue = _n7.c;
							var nLeft = _n7.d;
							var nRight = _n7.e;
							return A5(
								elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2(elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2(elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7(elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === -1) {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _n1 = elm$core$Dict$getMin(right);
				if (_n1.$ === -1) {
					var minKey = _n1.b;
					var minValue = _n1.c;
					return A5(
						elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						elm$core$Dict$removeMin(right));
				} else {
					return elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2(elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var elm$core$Dict$remove = F2(
	function (key, dict) {
		var _n0 = A2(elm$core$Dict$removeHelp, key, dict);
		if ((_n0.$ === -1) && (!_n0.a)) {
			var _n1 = _n0.a;
			var k = _n0.b;
			var v = _n0.c;
			var l = _n0.d;
			var r = _n0.e;
			return A5(elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _n0;
			return x;
		}
	});
var elm$core$Dict$update = F3(
	function (targetKey, alter, dictionary) {
		var _n0 = alter(
			A2(elm$core$Dict$get, targetKey, dictionary));
		if (!_n0.$) {
			var value = _n0.a;
			return A3(elm$core$Dict$insert, targetKey, value, dictionary);
		} else {
			return A2(elm$core$Dict$remove, targetKey, dictionary);
		}
	});
var elm$core$Maybe$isJust = function (maybe) {
	if (!maybe.$) {
		return true;
	} else {
		return false;
	}
};
var elm$core$Platform$sendToApp = _Platform_sendToApp;
var elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var elm$core$Result$map = F2(
	function (func, ra) {
		if (!ra.$) {
			var a = ra.a;
			return elm$core$Result$Ok(
				func(a));
		} else {
			var e = ra.a;
			return elm$core$Result$Err(e);
		}
	});
var elm$http$Http$BadStatus_ = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var elm$http$Http$BadUrl_ = function (a) {
	return {$: 0, a: a};
};
var elm$http$Http$GoodStatus_ = F2(
	function (a, b) {
		return {$: 4, a: a, b: b};
	});
var elm$http$Http$NetworkError_ = {$: 2};
var elm$http$Http$Receiving = function (a) {
	return {$: 1, a: a};
};
var elm$http$Http$Sending = function (a) {
	return {$: 0, a: a};
};
var elm$http$Http$Timeout_ = {$: 1};
var elm$http$Http$emptyBody = _Http_emptyBody;
var elm$http$Http$stringResolver = A2(_Http_expect, '', elm$core$Basics$identity);
var elm$core$Task$fail = _Scheduler_fail;
var elm$core$Task$succeed = _Scheduler_succeed;
var elm$http$Http$resultToTask = function (result) {
	if (!result.$) {
		var a = result.a;
		return elm$core$Task$succeed(a);
	} else {
		var x = result.a;
		return elm$core$Task$fail(x);
	}
};
var elm$http$Http$task = function (r) {
	return A3(
		_Http_toTask,
		0,
		elm$http$Http$resultToTask,
		{aw: false, bU: r.bU, w: r.dM, c4: r.c4, dp: r.dp, d8: r.d8, D: elm$core$Maybe$Nothing, H: r.H});
};
var elm$json$Json$Decode$decodeString = _Json_runOnString;
var author$project$Logic$Template$SaveLoad$Internal$Loader$getJson_ = F2(
	function (url, decoder) {
		return elm$http$Http$task(
			{
				bU: elm$http$Http$emptyBody,
				c4: _List_Nil,
				dp: 'GET',
				dM: elm$http$Http$stringResolver(
					function (response) {
						switch (response.$) {
							case 4:
								var meta = response.a;
								var body = response.b;
								return A2(
									elm$core$Result$mapError,
									A2(
										elm$core$Basics$composeR,
										elm$json$Json$Decode$errorToString,
										author$project$Logic$Launcher$Error(4004)),
									A2(elm$json$Json$Decode$decodeString, decoder, body));
							case 0:
								var info = response.a;
								return elm$core$Result$Err(
									A2(author$project$Logic$Launcher$Error, 4000, info));
							case 1:
								return elm$core$Result$Err(
									A2(author$project$Logic$Launcher$Error, 4001, 'Timeout'));
							case 2:
								return elm$core$Result$Err(
									A2(author$project$Logic$Launcher$Error, 4002, 'NetworkError'));
							default:
								var statusCode = response.a.d0;
								return elm$core$Result$Err(
									A2(
										author$project$Logic$Launcher$Error,
										4003,
										'BadStatus:' + elm$core$String$fromInt(statusCode)));
						}
					}),
				d8: elm$core$Maybe$Nothing,
				H: url
			});
	});
var elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var elm$core$Task$andThen = _Scheduler_andThen;
var elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			elm$core$Task$andThen,
			function (a) {
				return elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var elm$json$Json$Decode$value = _Json_decodeValue;
var author$project$Logic$Template$SaveLoad$Internal$Loader$getJson = function (url) {
	return A2(
		elm$core$Basics$composeR,
		elm$core$Task$andThen(
			function (d) {
				var _n0 = A2(elm$core$Dict$get, url, d.c);
				if ((!_n0.$) && (_n0.a.$ === 3)) {
					var r = _n0.a.a;
					return elm$core$Task$succeed(
						_Utils_Tuple2(r, d));
				} else {
					return A2(
						elm$core$Task$map,
						function (r) {
							return _Utils_Tuple2(r, d);
						},
						A2(
							author$project$Logic$Template$SaveLoad$Internal$Loader$getJson_,
							_Utils_ap(d.H, url),
							elm$json$Json$Decode$value));
				}
			}),
		elm$core$Task$map(
			function (_n1) {
				var resp = _n1.a;
				var d = _n1.b;
				var relUrl = A2(
					elm$core$String$join,
					'/',
					elm$core$List$reverse(
						A2(
							elm$core$List$cons,
							'',
							A2(
								elm$core$List$drop,
								1,
								elm$core$List$reverse(
									A2(elm$core$String$split, '/', url))))));
				return _Utils_Tuple2(
					resp,
					_Utils_update(
						d,
						{
							c: A3(
								elm$core$Dict$insert,
								url,
								author$project$Logic$Template$SaveLoad$Internal$Loader$Json_(resp),
								d.c),
							H: relUrl
						}));
			}));
};
var author$project$Logic$Template$SaveLoad$Internal$Reader$Async = function (a) {
	return {$: 1, a: a};
};
var author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen = function (f) {
	return elm$core$Task$andThen(
		function (_n0) {
			var a = _n0.a;
			var d1 = _n0.b;
			return A2(
				elm$core$Task$map,
				function (_n1) {
					var b = _n1.a;
					var d2 = _n1.b;
					return _Utils_Tuple2(
						b,
						_Utils_update(
							d1,
							{
								c: A2(elm$core$Dict$union, d1.c, d2.c)
							}));
				},
				A2(
					f,
					a,
					elm$core$Task$succeed(d1)));
		});
};
var author$project$Logic$Template$SaveLoad$Internal$ResourceTask$fail = F2(
	function (e, _n0) {
		return elm$core$Task$fail(e);
	});
var elm$core$Tuple$pair = F2(
	function (a, b) {
		return _Utils_Tuple2(a, b);
	});
var author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed = function (a) {
	return elm$core$Task$andThen(
		A2(
			elm$core$Basics$composeR,
			elm$core$Tuple$pair(a),
			elm$core$Task$succeed));
};
var author$project$Logic$Template$SaveLoad$Internal$Util$common = function (level) {
	switch (level.$) {
		case 0:
			var info = level.a;
			return {W: info.W, bm: info.bm, Y: info.Y, b3: info.b3, _: info._, fi: info.fi, ab: info.ab, ae: info.ae, af: info.af, z: info.z, ag: info.ag, ai: info.ai, bQ: info.bQ};
		case 1:
			var info = level.a;
			return {W: info.W, bm: info.bm, Y: info.Y, b3: info.b3, _: info._, fi: info.fi, ab: info.ab, ae: info.ae, af: info.af, z: info.z, ag: info.ag, ai: info.ai, bQ: info.bQ};
		case 2:
			var info = level.a;
			return {W: info.W, bm: info.bm, Y: info.Y, b3: info.b3, _: info._, fi: info.fi, ab: info.ab, ae: info.ae, af: info.af, z: info.z, ag: info.ag, ai: info.ai, bQ: info.bQ};
		default:
			var info = level.a;
			return {W: info.W, bm: info.bm, Y: info.Y, b3: info.b3, _: info._, fi: info.fi, ab: info.ab, ae: info.ae, af: info.af, z: info.z, ag: info.ag, ai: info.ai, bQ: info.bQ};
	}
};
var author$project$Logic$Template$SaveLoad$Internal$Util$properties = function (object) {
	var propWrap_ = F3(
		function (dict, parser, key) {
			return A2(
				elm$core$Maybe$andThen,
				parser,
				A2(elm$core$Dict$get, key, dict));
		});
	return {
		bV: A2(
			propWrap_,
			object.fi,
			function (r) {
				if (!r.$) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		bd: A2(
			propWrap_,
			object.fi,
			function (r) {
				if (r.$ === 4) {
					var i = r.a;
					return author$project$Logic$Template$SaveLoad$Internal$Util$hexColor2Vec3(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		eC: A2(
			propWrap_,
			object.fi,
			function (r) {
				if (r.$ === 5) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		eG: A2(
			propWrap_,
			object.fi,
			function (r) {
				if (r.$ === 2) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		b1: A2(
			propWrap_,
			object.fi,
			function (r) {
				if (r.$ === 1) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		cu: A2(
			propWrap_,
			object.fi,
			function (r) {
				if (r.$ === 3) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			})
	};
};
var elm$core$Tuple$mapSecond = F2(
	function (func, _n0) {
		var x = _n0.a;
		var y = _n0.b;
		return _Utils_Tuple2(
			x,
			func(y));
	});
var elm$json$Json$Decode$bool = _Json_decodeBool;
var elm$json$Json$Decode$decodeValue = _Json_run;
var elm$core$Dict$fromList = function (assocs) {
	return A3(
		elm$core$List$foldl,
		F2(
			function (_n0, dict) {
				var key = _n0.a;
				var value = _n0.b;
				return A3(elm$core$Dict$insert, key, value, dict);
			}),
		elm$core$Dict$empty,
		assocs);
};
var elm$json$Json$Decode$keyValuePairs = _Json_decodeKeyValuePairs;
var elm$json$Json$Decode$map = _Json_map1;
var elm$json$Json$Decode$dict = function (decoder) {
	return A2(
		elm$json$Json$Decode$map,
		elm$core$Dict$fromList,
		elm$json$Json$Decode$keyValuePairs(decoder));
};
var elm$json$Json$Decode$field = _Json_decodeField;
var elm$json$Json$Decode$float = _Json_decodeFloat;
var elm$json$Json$Decode$index = _Json_decodeIndex;
var elm$json$Json$Decode$list = _Json_decodeList;
var elm$json$Json$Decode$map3 = _Json_map3;
var elm$json$Json$Decode$oneOf = _Json_oneOf;
var elm$json$Json$Decode$string = _Json_decodeString;
var elm$json$Json$Decode$succeed = _Json_succeed;
var author$project$Logic$Template$SaveLoad$AudioSprite$read = function (spec) {
	return _Utils_update(
		author$project$Logic$Template$SaveLoad$Internal$Reader$defaultRead,
		{
			eQ: author$project$Logic$Template$SaveLoad$Internal$Reader$Async(
				function (level) {
					var spriteDecode = A4(
						elm$json$Json$Decode$map3,
						F3(
							function (a, b, c) {
								return {cK: elm$json$Json$Encode$null, ax: b, aA: c, Q: a};
							}),
						A2(elm$json$Json$Decode$index, 0, elm$json$Json$Decode$float),
						A2(elm$json$Json$Decode$index, 1, elm$json$Json$Decode$float),
						elm$json$Json$Decode$oneOf(
							_List_fromArray(
								[
									A2(elm$json$Json$Decode$index, 2, elm$json$Json$Decode$bool),
									elm$json$Json$Decode$succeed(false)
								])));
					var audiosprite = A3(
						elm$core$Basics$apR,
						author$project$Logic$Template$SaveLoad$Internal$Util$properties(
							author$project$Logic$Template$SaveLoad$Internal$Util$common(level)),
						function ($) {
							return $.eC;
						},
						'audiosprite');
					if (!audiosprite.$) {
						var url = audiosprite.a;
						return A2(
							elm$core$Basics$composeR,
							author$project$Logic$Template$SaveLoad$Internal$Loader$getJson(url),
							author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
								function (value) {
									var empty = author$project$Logic$Template$Component$SFX$empty;
									var config_ = A2(
										elm$json$Json$Decode$decodeValue,
										A4(
											elm$json$Json$Decode$map3,
											F3(
												function (src, sprite, srcCache) {
													return {ct: sprite, fv: src, dZ: srcCache};
												}),
											A2(
												elm$json$Json$Decode$field,
												'src',
												elm$json$Json$Decode$list(elm$json$Json$Decode$string)),
											A2(
												elm$json$Json$Decode$field,
												'sprite',
												elm$json$Json$Decode$dict(spriteDecode)),
											A2(elm$json$Json$Decode$field, 'src', elm$json$Json$Decode$value)),
										value);
									if (!config_.$) {
										var config = config_.a;
										return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed(
											elm$core$Tuple$mapSecond(
												spec.fu(
													elm$core$Basics$identity(
														_Utils_update(
															empty,
															{aS: config})))));
									} else {
										var e = config_.a;
										return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$fail(
											A2(
												author$project$Logic$Launcher$Error,
												8001,
												elm$json$Json$Decode$errorToString(e)));
									}
								}));
					} else {
						return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed(elm$core$Basics$identity);
					}
				})
		});
};
var elm$parser$Parser$ExpectingEnd = {$: 10};
var elm$parser$Parser$Advanced$Bad = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var elm$parser$Parser$Advanced$Good = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var elm$parser$Parser$Advanced$Parser = elm$core$Basics$identity;
var elm$parser$Parser$Advanced$AddRight = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var elm$parser$Parser$Advanced$DeadEnd = F4(
	function (row, col, problem, contextStack) {
		return {cO: col, ep: contextStack, dD: problem, dO: row};
	});
var elm$parser$Parser$Advanced$Empty = {$: 0};
var elm$parser$Parser$Advanced$fromState = F2(
	function (s, x) {
		return A2(
			elm$parser$Parser$Advanced$AddRight,
			elm$parser$Parser$Advanced$Empty,
			A4(elm$parser$Parser$Advanced$DeadEnd, s.dO, s.cO, x, s.a));
	});
var elm$parser$Parser$Advanced$end = function (x) {
	return function (s) {
		return _Utils_eq(
			elm$core$String$length(s.fv),
			s.Q) ? A3(elm$parser$Parser$Advanced$Good, false, 0, s) : A2(
			elm$parser$Parser$Advanced$Bad,
			false,
			A2(elm$parser$Parser$Advanced$fromState, s, x));
	};
};
var elm$parser$Parser$end = elm$parser$Parser$Advanced$end(elm$parser$Parser$ExpectingEnd);
var elm$core$Basics$always = F2(
	function (a, _n0) {
		return a;
	});
var elm$parser$Parser$Advanced$map2 = F3(
	function (func, _n0, _n1) {
		var parseA = _n0;
		var parseB = _n1;
		return function (s0) {
			var _n2 = parseA(s0);
			if (_n2.$ === 1) {
				var p = _n2.a;
				var x = _n2.b;
				return A2(elm$parser$Parser$Advanced$Bad, p, x);
			} else {
				var p1 = _n2.a;
				var a = _n2.b;
				var s1 = _n2.c;
				var _n3 = parseB(s1);
				if (_n3.$ === 1) {
					var p2 = _n3.a;
					var x = _n3.b;
					return A2(elm$parser$Parser$Advanced$Bad, p1 || p2, x);
				} else {
					var p2 = _n3.a;
					var b = _n3.b;
					var s2 = _n3.c;
					return A3(
						elm$parser$Parser$Advanced$Good,
						p1 || p2,
						A2(func, a, b),
						s2);
				}
			}
		};
	});
var elm$parser$Parser$Advanced$ignorer = F2(
	function (keepParser, ignoreParser) {
		return A3(elm$parser$Parser$Advanced$map2, elm$core$Basics$always, keepParser, ignoreParser);
	});
var elm$parser$Parser$ignorer = elm$parser$Parser$Advanced$ignorer;
var elm$parser$Parser$Advanced$keeper = F2(
	function (parseFunc, parseArg) {
		return A3(elm$parser$Parser$Advanced$map2, elm$core$Basics$apL, parseFunc, parseArg);
	});
var elm$parser$Parser$keeper = elm$parser$Parser$Advanced$keeper;
var elm$parser$Parser$ExpectingKeyword = function (a) {
	return {$: 9, a: a};
};
var elm$parser$Parser$Advanced$Token = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$core$Basics$not = _Basics_not;
var elm$core$String$isEmpty = function (string) {
	return string === '';
};
var elm$parser$Parser$Advanced$isSubChar = _Parser_isSubChar;
var elm$parser$Parser$Advanced$isSubString = _Parser_isSubString;
var elm$parser$Parser$Advanced$keyword = function (_n0) {
	var kwd = _n0.a;
	var expecting = _n0.b;
	var progress = !elm$core$String$isEmpty(kwd);
	return function (s) {
		var _n1 = A5(elm$parser$Parser$Advanced$isSubString, kwd, s.Q, s.dO, s.cO, s.fv);
		var newOffset = _n1.a;
		var newRow = _n1.b;
		var newCol = _n1.c;
		return (_Utils_eq(newOffset, -1) || (0 <= A3(
			elm$parser$Parser$Advanced$isSubChar,
			function (c) {
				return elm$core$Char$isAlphaNum(c) || (c === '_');
			},
			newOffset,
			s.fv))) ? A2(
			elm$parser$Parser$Advanced$Bad,
			false,
			A2(elm$parser$Parser$Advanced$fromState, s, expecting)) : A3(
			elm$parser$Parser$Advanced$Good,
			progress,
			0,
			{cO: newCol, a: s.a, b: s.b, Q: newOffset, dO: newRow, fv: s.fv});
	};
};
var elm$parser$Parser$keyword = function (kwd) {
	return elm$parser$Parser$Advanced$keyword(
		A2(
			elm$parser$Parser$Advanced$Token,
			kwd,
			elm$parser$Parser$ExpectingKeyword(kwd)));
};
var elm$parser$Parser$Advanced$succeed = function (a) {
	return function (s) {
		return A3(elm$parser$Parser$Advanced$Good, false, a, s);
	};
};
var elm$parser$Parser$succeed = elm$parser$Parser$Advanced$succeed;
var elm$parser$Parser$ExpectingSymbol = function (a) {
	return {$: 8, a: a};
};
var elm$parser$Parser$Advanced$token = function (_n0) {
	var str = _n0.a;
	var expecting = _n0.b;
	var progress = !elm$core$String$isEmpty(str);
	return function (s) {
		var _n1 = A5(elm$parser$Parser$Advanced$isSubString, str, s.Q, s.dO, s.cO, s.fv);
		var newOffset = _n1.a;
		var newRow = _n1.b;
		var newCol = _n1.c;
		return _Utils_eq(newOffset, -1) ? A2(
			elm$parser$Parser$Advanced$Bad,
			false,
			A2(elm$parser$Parser$Advanced$fromState, s, expecting)) : A3(
			elm$parser$Parser$Advanced$Good,
			progress,
			0,
			{cO: newCol, a: s.a, b: s.b, Q: newOffset, dO: newRow, fv: s.fv});
	};
};
var elm$parser$Parser$Advanced$symbol = elm$parser$Parser$Advanced$token;
var elm$parser$Parser$symbol = function (str) {
	return elm$parser$Parser$Advanced$symbol(
		A2(
			elm$parser$Parser$Advanced$Token,
			str,
			elm$parser$Parser$ExpectingSymbol(str)));
};
var elm$parser$Parser$ExpectingVariable = {$: 7};
var elm$core$Dict$member = F2(
	function (key, dict) {
		var _n0 = A2(elm$core$Dict$get, key, dict);
		if (!_n0.$) {
			return true;
		} else {
			return false;
		}
	});
var elm$core$Set$member = F2(
	function (key, _n0) {
		var dict = _n0;
		return A2(elm$core$Dict$member, key, dict);
	});
var elm$parser$Parser$Advanced$varHelp = F7(
	function (isGood, offset, row, col, src, indent, context) {
		varHelp:
		while (true) {
			var newOffset = A3(elm$parser$Parser$Advanced$isSubChar, isGood, offset, src);
			if (_Utils_eq(newOffset, -1)) {
				return {cO: col, a: context, b: indent, Q: offset, dO: row, fv: src};
			} else {
				if (_Utils_eq(newOffset, -2)) {
					var $temp$isGood = isGood,
						$temp$offset = offset + 1,
						$temp$row = row + 1,
						$temp$col = 1,
						$temp$src = src,
						$temp$indent = indent,
						$temp$context = context;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					src = $temp$src;
					indent = $temp$indent;
					context = $temp$context;
					continue varHelp;
				} else {
					var $temp$isGood = isGood,
						$temp$offset = newOffset,
						$temp$row = row,
						$temp$col = col + 1,
						$temp$src = src,
						$temp$indent = indent,
						$temp$context = context;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					src = $temp$src;
					indent = $temp$indent;
					context = $temp$context;
					continue varHelp;
				}
			}
		}
	});
var elm$parser$Parser$Advanced$variable = function (i) {
	return function (s) {
		var firstOffset = A3(elm$parser$Parser$Advanced$isSubChar, i.bH, s.Q, s.fv);
		if (_Utils_eq(firstOffset, -1)) {
			return A2(
				elm$parser$Parser$Advanced$Bad,
				false,
				A2(elm$parser$Parser$Advanced$fromState, s, i.cZ));
		} else {
			var s1 = _Utils_eq(firstOffset, -2) ? A7(elm$parser$Parser$Advanced$varHelp, i.eN, s.Q + 1, s.dO + 1, 1, s.fv, s.b, s.a) : A7(elm$parser$Parser$Advanced$varHelp, i.eN, firstOffset, s.dO, s.cO + 1, s.fv, s.b, s.a);
			var name = A3(elm$core$String$slice, s.Q, s1.Q, s.fv);
			return A2(elm$core$Set$member, name, i.fq) ? A2(
				elm$parser$Parser$Advanced$Bad,
				false,
				A2(elm$parser$Parser$Advanced$fromState, s, i.cZ)) : A3(elm$parser$Parser$Advanced$Good, true, name, s1);
		}
	};
};
var elm$parser$Parser$variable = function (i) {
	return elm$parser$Parser$Advanced$variable(
		{cZ: elm$parser$Parser$ExpectingVariable, eN: i.eN, fq: i.fq, bH: i.bH});
};
var author$project$Logic$Template$SaveLoad$Camera$getFollowId = function () {
	var _var = elm$parser$Parser$variable(
		{
			eN: function (c) {
				return elm$core$Char$isAlphaNum(c) || (c === '_');
			},
			fq: elm$core$Set$empty,
			bH: elm$core$Char$isAlphaNum
		});
	return A2(
		elm$parser$Parser$keeper,
		A2(
			elm$parser$Parser$keeper,
			A2(
				elm$parser$Parser$ignorer,
				A2(
					elm$parser$Parser$ignorer,
					elm$parser$Parser$succeed(
						F2(
							function (a, b) {
								return _Utils_Tuple2(a, b);
							})),
					elm$parser$Parser$keyword('camera')),
				elm$parser$Parser$symbol('.')),
			A2(
				elm$parser$Parser$ignorer,
				_var,
				elm$parser$Parser$symbol('.'))),
		A2(elm$parser$Parser$ignorer, _var, elm$parser$Parser$end));
}();
var author$project$AltMath$Vector2$getX = function ($) {
	return $.n;
};
var author$project$AltMath$Vector2$getY = function ($) {
	return $.o;
};
var author$project$Logic$Template$SaveLoad$Camera$read = function (spec_) {
	return _Utils_update(
		author$project$Logic$Template$SaveLoad$Internal$Reader$defaultRead,
		{
			eQ: author$project$Logic$Template$SaveLoad$Internal$Reader$Sync(
				F2(
					function (level, _n0) {
						var entityID = _n0.a;
						var world = _n0.b;
						var cameraComp = function (prop) {
							var cam = spec_.eH(world);
							var x = A2(
								prop.eG,
								'offset.x',
								author$project$AltMath$Vector2$getX(cam.a6));
							var y = A2(
								prop.eG,
								'offset.y',
								author$project$AltMath$Vector2$getY(cam.a6));
							return _Utils_update(
								cam,
								{
									a6: A2(author$project$AltMath$Vector2$vec2, x, y)
								});
						}(
							author$project$Logic$Template$SaveLoad$Internal$Util$levelProps(level));
						return _Utils_Tuple2(
							entityID,
							A2(spec_.fu, cameraComp, world));
					}))
		});
};
var elm$core$Dict$filter = F2(
	function (isGood, dict) {
		return A3(
			elm$core$Dict$foldl,
			F3(
				function (k, v, d) {
					return A2(isGood, k, v) ? A3(elm$core$Dict$insert, k, v, d) : d;
				}),
			elm$core$Dict$empty,
			dict);
	});
var elm$parser$Parser$DeadEnd = F3(
	function (row, col, problem) {
		return {cO: col, dD: problem, dO: row};
	});
var elm$parser$Parser$problemToDeadEnd = function (p) {
	return A3(elm$parser$Parser$DeadEnd, p.dO, p.cO, p.dD);
};
var elm$parser$Parser$Advanced$bagToList = F2(
	function (bag, list) {
		bagToList:
		while (true) {
			switch (bag.$) {
				case 0:
					return list;
				case 1:
					var bag1 = bag.a;
					var x = bag.b;
					var $temp$bag = bag1,
						$temp$list = A2(elm$core$List$cons, x, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
				default:
					var bag1 = bag.a;
					var bag2 = bag.b;
					var $temp$bag = bag1,
						$temp$list = A2(elm$parser$Parser$Advanced$bagToList, bag2, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
			}
		}
	});
var elm$parser$Parser$Advanced$run = F2(
	function (_n0, src) {
		var parse = _n0;
		var _n1 = parse(
			{cO: 1, a: _List_Nil, b: 1, Q: 0, dO: 1, fv: src});
		if (!_n1.$) {
			var value = _n1.b;
			return elm$core$Result$Ok(value);
		} else {
			var bag = _n1.b;
			return elm$core$Result$Err(
				A2(elm$parser$Parser$Advanced$bagToList, bag, _List_Nil));
		}
	});
var elm$parser$Parser$run = F2(
	function (parser, source) {
		var _n0 = A2(elm$parser$Parser$Advanced$run, parser, source);
		if (!_n0.$) {
			var a = _n0.a;
			return elm$core$Result$Ok(a);
		} else {
			var problems = _n0.a;
			return elm$core$Result$Err(
				A2(elm$core$List$map, elm$parser$Parser$problemToDeadEnd, problems));
		}
	});
var author$project$Logic$Template$SaveLoad$Camera$readId = function (spec_) {
	var baseRead = author$project$Logic$Template$SaveLoad$Camera$read(spec_);
	return _Utils_update(
		baseRead,
		{
			e9: author$project$Logic$Template$SaveLoad$Internal$Reader$Sync(
				F2(
					function (_n0, _n1) {
						var properties = _n0.fi;
						var entityID = _n1.a;
						var world = _n1.b;
						return A3(
							elm$core$List$foldl,
							F2(
								function (item, acc) {
									var eID = acc.a;
									var w = acc.b;
									var _n3 = A2(elm$parser$Parser$run, author$project$Logic$Template$SaveLoad$Camera$getFollowId, item);
									if (((!_n3.$) && (_n3.a.a === 'follow')) && (_n3.a.b === 'x')) {
										var _n4 = _n3.a;
										var cam = spec_.eH(w);
										return _Utils_Tuple2(
											eID,
											A2(
												spec_.fu,
												_Utils_update(
													cam,
													{c8: eID}),
												w));
									} else {
										return acc;
									}
								}),
							_Utils_Tuple2(entityID, world),
							elm$core$Dict$keys(
								A2(
									elm$core$Dict$filter,
									F2(
										function (a, _n2) {
											return A2(elm$core$String$startsWith, 'camera', a);
										}),
									properties)));
					}))
		});
};
var elm$core$Elm$JsArray$appendN = _JsArray_appendN;
var elm$core$Elm$JsArray$slice = _JsArray_slice;
var elm$core$Array$appendHelpBuilder = F2(
	function (tail, builder) {
		var tailLen = elm$core$Elm$JsArray$length(tail);
		var notAppended = (elm$core$Array$branchFactor - elm$core$Elm$JsArray$length(builder.i)) - tailLen;
		var appended = A3(elm$core$Elm$JsArray$appendN, elm$core$Array$branchFactor, builder.i, tail);
		return (notAppended < 0) ? {
			j: A2(
				elm$core$List$cons,
				elm$core$Array$Leaf(appended),
				builder.j),
			g: builder.g + 1,
			i: A3(elm$core$Elm$JsArray$slice, notAppended, tailLen, tail)
		} : ((!notAppended) ? {
			j: A2(
				elm$core$List$cons,
				elm$core$Array$Leaf(appended),
				builder.j),
			g: builder.g + 1,
			i: elm$core$Elm$JsArray$empty
		} : {j: builder.j, g: builder.g, i: appended});
	});
var elm$core$Array$bitMask = 4294967295 >>> (32 - elm$core$Array$shiftStep);
var elm$core$Basics$ge = _Utils_ge;
var elm$core$Elm$JsArray$push = _JsArray_push;
var elm$core$Elm$JsArray$singleton = _JsArray_singleton;
var elm$core$Elm$JsArray$unsafeGet = _JsArray_unsafeGet;
var elm$core$Elm$JsArray$unsafeSet = _JsArray_unsafeSet;
var elm$core$Array$insertTailInTree = F4(
	function (shift, index, tail, tree) {
		var pos = elm$core$Array$bitMask & (index >>> shift);
		if (_Utils_cmp(
			pos,
			elm$core$Elm$JsArray$length(tree)) > -1) {
			if (shift === 5) {
				return A2(
					elm$core$Elm$JsArray$push,
					elm$core$Array$Leaf(tail),
					tree);
			} else {
				var newSub = elm$core$Array$SubTree(
					A4(elm$core$Array$insertTailInTree, shift - elm$core$Array$shiftStep, index, tail, elm$core$Elm$JsArray$empty));
				return A2(elm$core$Elm$JsArray$push, newSub, tree);
			}
		} else {
			var value = A2(elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (!value.$) {
				var subTree = value.a;
				var newSub = elm$core$Array$SubTree(
					A4(elm$core$Array$insertTailInTree, shift - elm$core$Array$shiftStep, index, tail, subTree));
				return A3(elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			} else {
				var newSub = elm$core$Array$SubTree(
					A4(
						elm$core$Array$insertTailInTree,
						shift - elm$core$Array$shiftStep,
						index,
						tail,
						elm$core$Elm$JsArray$singleton(value)));
				return A3(elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			}
		}
	});
var elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var elm$core$Array$unsafeReplaceTail = F2(
	function (newTail, _n0) {
		var len = _n0.a;
		var startShift = _n0.b;
		var tree = _n0.c;
		var tail = _n0.d;
		var originalTailLen = elm$core$Elm$JsArray$length(tail);
		var newTailLen = elm$core$Elm$JsArray$length(newTail);
		var newArrayLen = len + (newTailLen - originalTailLen);
		if (_Utils_eq(newTailLen, elm$core$Array$branchFactor)) {
			var overflow = _Utils_cmp(newArrayLen >>> elm$core$Array$shiftStep, 1 << startShift) > 0;
			if (overflow) {
				var newShift = startShift + elm$core$Array$shiftStep;
				var newTree = A4(
					elm$core$Array$insertTailInTree,
					newShift,
					len,
					newTail,
					elm$core$Elm$JsArray$singleton(
						elm$core$Array$SubTree(tree)));
				return A4(elm$core$Array$Array_elm_builtin, newArrayLen, newShift, newTree, elm$core$Elm$JsArray$empty);
			} else {
				return A4(
					elm$core$Array$Array_elm_builtin,
					newArrayLen,
					startShift,
					A4(elm$core$Array$insertTailInTree, startShift, len, newTail, tree),
					elm$core$Elm$JsArray$empty);
			}
		} else {
			return A4(elm$core$Array$Array_elm_builtin, newArrayLen, startShift, tree, newTail);
		}
	});
var elm$core$Array$appendHelpTree = F2(
	function (toAppend, array) {
		var len = array.a;
		var tree = array.c;
		var tail = array.d;
		var itemsToAppend = elm$core$Elm$JsArray$length(toAppend);
		var notAppended = (elm$core$Array$branchFactor - elm$core$Elm$JsArray$length(tail)) - itemsToAppend;
		var appended = A3(elm$core$Elm$JsArray$appendN, elm$core$Array$branchFactor, tail, toAppend);
		var newArray = A2(elm$core$Array$unsafeReplaceTail, appended, array);
		if (notAppended < 0) {
			var nextTail = A3(elm$core$Elm$JsArray$slice, notAppended, itemsToAppend, toAppend);
			return A2(elm$core$Array$unsafeReplaceTail, nextTail, newArray);
		} else {
			return newArray;
		}
	});
var elm$core$Array$builderFromArray = function (_n0) {
	var len = _n0.a;
	var tree = _n0.c;
	var tail = _n0.d;
	var helper = F2(
		function (node, acc) {
			if (!node.$) {
				var subTree = node.a;
				return A3(elm$core$Elm$JsArray$foldl, helper, acc, subTree);
			} else {
				return A2(elm$core$List$cons, node, acc);
			}
		});
	return {
		j: A3(elm$core$Elm$JsArray$foldl, helper, _List_Nil, tree),
		g: (len / elm$core$Array$branchFactor) | 0,
		i: tail
	};
};
var elm$core$Array$append = F2(
	function (a, _n0) {
		var aTail = a.d;
		var bLen = _n0.a;
		var bTree = _n0.c;
		var bTail = _n0.d;
		if (_Utils_cmp(bLen, elm$core$Array$branchFactor * 4) < 1) {
			var foldHelper = F2(
				function (node, array) {
					if (!node.$) {
						var tree = node.a;
						return A3(elm$core$Elm$JsArray$foldl, foldHelper, array, tree);
					} else {
						var leaf = node.a;
						return A2(elm$core$Array$appendHelpTree, leaf, array);
					}
				});
			return A2(
				elm$core$Array$appendHelpTree,
				bTail,
				A3(elm$core$Elm$JsArray$foldl, foldHelper, a, bTree));
		} else {
			var foldHelper = F2(
				function (node, builder) {
					if (!node.$) {
						var tree = node.a;
						return A3(elm$core$Elm$JsArray$foldl, foldHelper, builder, tree);
					} else {
						var leaf = node.a;
						return A2(elm$core$Array$appendHelpBuilder, leaf, builder);
					}
				});
			return A2(
				elm$core$Array$builderToArray,
				true,
				A2(
					elm$core$Array$appendHelpBuilder,
					bTail,
					A3(
						elm$core$Elm$JsArray$foldl,
						foldHelper,
						elm$core$Array$builderFromArray(a),
						bTree)));
		}
	});
var elm$core$Array$length = function (_n0) {
	var len = _n0.a;
	return len;
};
var elm$core$Array$push = F2(
	function (a, array) {
		var tail = array.d;
		return A2(
			elm$core$Array$unsafeReplaceTail,
			A2(elm$core$Elm$JsArray$push, a, tail),
			array);
	});
var elm$core$Array$repeat = F2(
	function (n, e) {
		return A2(
			elm$core$Array$initialize,
			n,
			function (_n0) {
				return e;
			});
	});
var elm$core$Array$setHelp = F4(
	function (shift, index, value, tree) {
		var pos = elm$core$Array$bitMask & (index >>> shift);
		var _n0 = A2(elm$core$Elm$JsArray$unsafeGet, pos, tree);
		if (!_n0.$) {
			var subTree = _n0.a;
			var newSub = A4(elm$core$Array$setHelp, shift - elm$core$Array$shiftStep, index, value, subTree);
			return A3(
				elm$core$Elm$JsArray$unsafeSet,
				pos,
				elm$core$Array$SubTree(newSub),
				tree);
		} else {
			var values = _n0.a;
			var newLeaf = A3(elm$core$Elm$JsArray$unsafeSet, elm$core$Array$bitMask & index, value, values);
			return A3(
				elm$core$Elm$JsArray$unsafeSet,
				pos,
				elm$core$Array$Leaf(newLeaf),
				tree);
		}
	});
var elm$core$Array$tailIndex = function (len) {
	return (len >>> 5) << 5;
};
var elm$core$Array$set = F3(
	function (index, value, array) {
		var len = array.a;
		var startShift = array.b;
		var tree = array.c;
		var tail = array.d;
		return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? array : ((_Utils_cmp(
			index,
			elm$core$Array$tailIndex(len)) > -1) ? A4(
			elm$core$Array$Array_elm_builtin,
			len,
			startShift,
			tree,
			A3(elm$core$Elm$JsArray$unsafeSet, elm$core$Array$bitMask & index, value, tail)) : A4(
			elm$core$Array$Array_elm_builtin,
			len,
			startShift,
			A4(elm$core$Array$setHelp, startShift, index, value, tree),
			tail));
	});
var author$project$Logic$Entity$spawnComponent = F3(
	function (index, value, components) {
		return ((index - elm$core$Array$length(components)) < 0) ? A3(
			elm$core$Array$set,
			index,
			elm$core$Maybe$Just(value),
			components) : A2(
			elm$core$Array$push,
			elm$core$Maybe$Just(value),
			A2(
				elm$core$Array$append,
				components,
				A2(
					elm$core$Array$repeat,
					index - elm$core$Array$length(components),
					elm$core$Maybe$Nothing)));
	});
var author$project$Logic$Entity$with = F2(
	function (_n0, _n1) {
		var get = _n0.a.eH;
		var set = _n0.a.fu;
		var component = _n0.b;
		var mId = _n1.a;
		var world = _n1.b;
		var updatedComponents = A3(
			author$project$Logic$Entity$spawnComponent,
			mId,
			component,
			get(world));
		var updatedWorld = A2(set, updatedComponents, world);
		return _Utils_Tuple2(mId, updatedWorld);
	});
var author$project$Logic$Template$Input$emptyComp = {cA: elm$core$Set$empty, cU: '', dg: '', dN: '', eb: '', n: 0, o: 0};
var elm$core$Result$withDefault = F2(
	function (def, result) {
		if (!result.$) {
			var a = result.a;
			return a;
		} else {
			return def;
		}
	});
var author$project$Logic$Template$SaveLoad$Input$read = function (spec) {
	var setKey = F5(
		function (entityId, registered_, comp_, dir, key) {
			var comp = A2(elm$core$Maybe$withDefault, author$project$Logic$Template$Input$emptyComp, comp_);
			if (dir.$ === 3) {
				switch (dir.a) {
					case 'Move.south':
						return _Utils_Tuple2(
							elm$core$Maybe$Just(
								_Utils_update(
									comp,
									{cU: key})),
							A3(
								elm$core$Dict$insert,
								key,
								_Utils_Tuple2(entityId, 'Move.south'),
								registered_));
					case 'Move.west':
						return _Utils_Tuple2(
							elm$core$Maybe$Just(
								_Utils_update(
									comp,
									{dg: key})),
							A3(
								elm$core$Dict$insert,
								key,
								_Utils_Tuple2(entityId, 'Move.west'),
								registered_));
					case 'Move.east':
						return _Utils_Tuple2(
							elm$core$Maybe$Just(
								_Utils_update(
									comp,
									{dN: key})),
							A3(
								elm$core$Dict$insert,
								key,
								_Utils_Tuple2(entityId, 'Move.east'),
								registered_));
					case 'Move.north':
						return _Utils_Tuple2(
							elm$core$Maybe$Just(
								_Utils_update(
									comp,
									{eb: key})),
							A3(
								elm$core$Dict$insert,
								key,
								_Utils_Tuple2(entityId, 'Move.north'),
								registered_));
					default:
						var other = dir.a;
						return _Utils_Tuple2(
							elm$core$Maybe$Just(comp),
							A3(
								elm$core$Dict$insert,
								key,
								_Utils_Tuple2(entityId, other),
								registered_));
				}
			} else {
				return _Utils_Tuple2(comp_, registered_);
			}
		});
	var filterKeys = F2(
		function (props, _n4) {
			var entityId = _n4.a;
			var registered = _n4.b;
			var keyVar = elm$parser$Parser$variable(
				{
					eN: function (c) {
						return elm$core$Char$isAlphaNum(c) || ((c === '_') || (c === ' '));
					},
					fq: elm$core$Set$empty,
					bH: function (c) {
						return elm$core$Char$isAlphaNum(c) || (c === ' ');
					}
				});
			var onKey = A2(
				elm$parser$Parser$keeper,
				A2(
					elm$parser$Parser$ignorer,
					A2(
						elm$parser$Parser$ignorer,
						elm$parser$Parser$succeed(elm$core$Basics$identity),
						elm$parser$Parser$keyword('onKey')),
					elm$parser$Parser$symbol('[')),
				A2(
					elm$parser$Parser$ignorer,
					A2(
						elm$parser$Parser$ignorer,
						keyVar,
						elm$parser$Parser$symbol(']')),
					elm$parser$Parser$end));
			return A3(
				elm$core$Dict$foldl,
				F3(
					function (k, v, _n3) {
						var maybeComp = _n3.a;
						var registered_ = _n3.b;
						return A2(
							elm$core$Result$withDefault,
							_Utils_Tuple2(maybeComp, registered_),
							A2(
								elm$core$Result$map,
								A4(setKey, entityId, registered_, maybeComp, v),
								A2(elm$parser$Parser$run, onKey, k)));
					}),
				_Utils_Tuple2(elm$core$Maybe$Nothing, registered),
				props);
		});
	var compsSpec = {
		eH: A2(
			elm$core$Basics$composeR,
			spec.eH,
			function ($) {
				return $.bg;
			}),
		fu: F2(
			function (comps, world) {
				var dir = spec.eH(world);
				return A2(
					spec.fu,
					_Utils_update(
						dir,
						{bg: comps}),
					world);
			})
	};
	return _Utils_update(
		author$project$Logic$Template$SaveLoad$Internal$Reader$defaultRead,
		{
			e9: author$project$Logic$Template$SaveLoad$Internal$Reader$Sync(
				F2(
					function (_n0, _n1) {
						var properties = _n0.fi;
						var entityId = _n1.a;
						var world = _n1.b;
						var dir = spec.eH(world);
						var _n2 = A2(
							filterKeys,
							properties,
							_Utils_Tuple2(entityId, dir.dI));
						var comp_ = _n2.a;
						var registered = _n2.b;
						var newWorld = A2(
							spec.fu,
							_Utils_update(
								dir,
								{dI: registered}),
							world);
						return A2(
							elm$core$Maybe$withDefault,
							elm$core$Basics$identity,
							A2(
								elm$core$Maybe$map,
								function (comp) {
									return author$project$Logic$Entity$with(
										_Utils_Tuple2(compsSpec, comp));
								},
								comp_))(
							_Utils_Tuple2(entityId, newWorld));
					}))
		});
};
var author$project$Logic$Component$Singleton$update = F3(
	function (spec, f, world) {
		return A2(
			spec.fu,
			f(
				spec.eH(world)),
			world);
	});
var author$project$Logic$Template$Component$Layer$Object = function (a) {
	return {$: 6, a: a};
};
var elm$core$Tuple$mapFirst = F2(
	function (func, _n0) {
		var x = _n0.a;
		var y = _n0.b;
		return _Utils_Tuple2(
			func(x),
			y);
	});
var author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map = F2(
	function (f, task) {
		return A2(
			elm$core$Task$map,
			elm$core$Tuple$mapFirst(f),
			task);
	});
var author$project$Logic$Template$SaveLoad$Internal$Reader$combine_ = F3(
	function (getKey, r1, r2) {
		var _n0 = _Utils_Tuple2(
			getKey(r1),
			getKey(r2));
		_n0$5:
		while (true) {
			switch (_n0.a.$) {
				case 1:
					switch (_n0.b.$) {
						case 0:
							var f1 = _n0.a.a;
							var f2 = _n0.b.a;
							return author$project$Logic$Template$SaveLoad$Internal$Reader$Async(
								F2(
									function (a, b) {
										return A2(
											author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map,
											F2(
												function (_n3, d) {
													return A2(f2, a, d);
												}),
											A2(f1, a, b));
									}));
						case 1:
							var f1 = _n0.a.a;
							var f2 = _n0.b.a;
							return author$project$Logic$Template$SaveLoad$Internal$Reader$Async(
								F2(
									function (a, b) {
										return A2(
											author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen,
											F2(
												function (_n4, d) {
													return A2(f2, a, d);
												}),
											A2(f1, a, b));
									}));
						default:
							break _n0$5;
					}
				case 0:
					switch (_n0.b.$) {
						case 0:
							var f1 = _n0.a.a;
							var f2 = _n0.b.a;
							return author$project$Logic$Template$SaveLoad$Internal$Reader$Sync(
								F2(
									function (a, b) {
										return A2(
											f2,
											a,
											A2(f1, a, b));
									}));
						case 1:
							var f1 = _n0.a.a;
							var f2 = _n0.b.a;
							return author$project$Logic$Template$SaveLoad$Internal$Reader$Async(
								F2(
									function (a, b) {
										return A2(
											author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen,
											F2(
												function (_n5, d) {
													return A2(f2, a, d);
												}),
											A2(
												author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed,
												f1(a),
												b));
									}));
						default:
							break _n0$5;
					}
				default:
					if (_n0.b.$ === 2) {
						var _n1 = _n0.a;
						var _n2 = _n0.b;
						return author$project$Logic$Template$SaveLoad$Internal$Reader$None;
					} else {
						var _n7 = _n0.a;
						var f2 = _n0.b;
						return f2;
					}
			}
		}
		var f1 = _n0.a;
		var _n6 = _n0.b;
		return f1;
	});
var author$project$Logic$Template$SaveLoad$Internal$Reader$combine = F2(
	function (r1, r2) {
		return {
			bp: A3(
				author$project$Logic$Template$SaveLoad$Internal$Reader$combine_,
				function ($) {
					return $.bp;
				},
				r1,
				r2),
			bq: A3(
				author$project$Logic$Template$SaveLoad$Internal$Reader$combine_,
				function ($) {
					return $.bq;
				},
				r1,
				r2),
			br: A3(
				author$project$Logic$Template$SaveLoad$Internal$Reader$combine_,
				function ($) {
					return $.br;
				},
				r1,
				r2),
			bs: A3(
				author$project$Logic$Template$SaveLoad$Internal$Reader$combine_,
				function ($) {
					return $.bs;
				},
				r1,
				r2),
			eQ: A3(
				author$project$Logic$Template$SaveLoad$Internal$Reader$combine_,
				function ($) {
					return $.eQ;
				},
				r1,
				r2),
			bw: A3(
				author$project$Logic$Template$SaveLoad$Internal$Reader$combine_,
				function ($) {
					return $.bw;
				},
				r1,
				r2),
			bx: A3(
				author$project$Logic$Template$SaveLoad$Internal$Reader$combine_,
				function ($) {
					return $.bx;
				},
				r1,
				r2),
			by: A3(
				author$project$Logic$Template$SaveLoad$Internal$Reader$combine_,
				function ($) {
					return $.by;
				},
				r1,
				r2),
			bz: A3(
				author$project$Logic$Template$SaveLoad$Internal$Reader$combine_,
				function ($) {
					return $.bz;
				},
				r1,
				r2),
			bA: A3(
				author$project$Logic$Template$SaveLoad$Internal$Reader$combine_,
				function ($) {
					return $.bA;
				},
				r1,
				r2),
			e9: A3(
				author$project$Logic$Template$SaveLoad$Internal$Reader$combine_,
				function ($) {
					return $.e9;
				},
				r1,
				r2)
		};
	});
var author$project$Logic$Template$SaveLoad$Layer$findObjLayer = F2(
	function (id, list) {
		findObjLayer:
		while (true) {
			if (!list.b) {
				return author$project$Logic$Component$empty;
			} else {
				var first = list.a;
				var rest = list.b;
				if (first.$ === 6) {
					var _n2 = first.a;
					var checkMe = _n2.a;
					var objLayerComponents = _n2.b;
					if (_Utils_eq(checkMe, id)) {
						return objLayerComponents;
					} else {
						var $temp$id = id,
							$temp$list = rest;
						id = $temp$id;
						list = $temp$list;
						continue findObjLayer;
					}
				} else {
					var $temp$id = id,
						$temp$list = rest;
					id = $temp$id;
					list = $temp$list;
					continue findObjLayer;
				}
			}
		}
	});
var author$project$Logic$Template$SaveLoad$Layer$objLayerRead = function (spec) {
	return _Utils_update(
		author$project$Logic$Template$SaveLoad$Internal$Reader$defaultRead,
		{
			bw: author$project$Logic$Template$SaveLoad$Internal$Reader$Sync(
				function (_n0) {
					var layer = _n0.aV;
					return author$project$Logic$Entity$with(
						_Utils_Tuple2(
							spec(layer.c8),
							0));
				}),
			bx: author$project$Logic$Template$SaveLoad$Internal$Reader$Sync(
				function (_n1) {
					var layer = _n1.aV;
					return author$project$Logic$Entity$with(
						_Utils_Tuple2(
							spec(layer.c8),
							0));
				}),
			by: author$project$Logic$Template$SaveLoad$Internal$Reader$Sync(
				function (_n2) {
					var layer = _n2.aV;
					return author$project$Logic$Entity$with(
						_Utils_Tuple2(
							spec(layer.c8),
							0));
				}),
			bz: author$project$Logic$Template$SaveLoad$Internal$Reader$Sync(
				function (_n3) {
					var layer = _n3.aV;
					return author$project$Logic$Entity$with(
						_Utils_Tuple2(
							spec(layer.c8),
							0));
				}),
			bA: author$project$Logic$Template$SaveLoad$Internal$Reader$Sync(
				function (_n4) {
					var layer = _n4.aV;
					return author$project$Logic$Entity$with(
						_Utils_Tuple2(
							spec(layer.c8),
							0));
				}),
			e9: author$project$Logic$Template$SaveLoad$Internal$Reader$Sync(
				function (_n5) {
					var layer = _n5.aV;
					return author$project$Logic$Entity$with(
						_Utils_Tuple2(
							spec(layer.c8),
							0));
				})
		});
};
var author$project$Logic$Template$SaveLoad$Layer$updateObjLayer = F4(
	function (id, value, next, prev) {
		updateObjLayer:
		while (true) {
			if (!prev.b) {
				return elm$core$List$reverse(
					_Utils_ap(
						prev,
						A2(elm$core$List$cons, value, next)));
			} else {
				var first = prev.a;
				var rest = prev.b;
				if (first.$ === 6) {
					var _n2 = first.a;
					var checkMe = _n2.a;
					if (_Utils_eq(checkMe, id)) {
						return _Utils_ap(
							elm$core$List$reverse(
								A2(elm$core$List$cons, value, next)),
							rest);
					} else {
						var $temp$id = id,
							$temp$value = value,
							$temp$next = A2(elm$core$List$cons, first, next),
							$temp$prev = rest;
						id = $temp$id;
						value = $temp$value;
						next = $temp$next;
						prev = $temp$prev;
						continue updateObjLayer;
					}
				} else {
					var $temp$id = id,
						$temp$value = value,
						$temp$next = A2(elm$core$List$cons, first, next),
						$temp$prev = rest;
					id = $temp$id;
					value = $temp$value;
					next = $temp$next;
					prev = $temp$prev;
					continue updateObjLayer;
				}
			}
		}
	});
var author$project$Logic$Template$Component$Layer$Image = function (a) {
	return {$: 5, a: a};
};
var author$project$Logic$Template$Component$Layer$ImageNo = function (a) {
	return {$: 2, a: a};
};
var author$project$Logic$Template$Component$Layer$ImageX = function (a) {
	return {$: 3, a: a};
};
var author$project$Logic$Template$Component$Layer$ImageY = function (a) {
	return {$: 4, a: a};
};
var author$project$Logic$Template$SaveLoad$Layer$wrapImageLayer = function (_n0) {
	var id = _n0.c8;
	var repeat = _n0.fp;
	var image = _n0.b0;
	var size = _n0.cs;
	var uTransparentColor = _n0.T;
	var scrollRatio = _n0.a_;
	return function () {
		switch (repeat) {
			case 0:
				return author$project$Logic$Template$Component$Layer$ImageX;
			case 1:
				return author$project$Logic$Template$Component$Layer$ImageY;
			case 2:
				return author$project$Logic$Template$Component$Layer$ImageNo;
			default:
				return author$project$Logic$Template$Component$Layer$Image;
		}
	}()(
		{c8: id, b0: image, a_: scrollRatio, cs: size, T: uTransparentColor});
};
var author$project$Logic$Template$Component$Layer$AnimatedTiles = function (a) {
	return {$: 1, a: a};
};
var author$project$Logic$Template$Component$Layer$Tiles = function (a) {
	return {$: 0, a: a};
};
var author$project$Logic$Template$SaveLoad$Layer$wrapTileLayer = function (layer) {
	if (!layer.$) {
		var info = layer.a;
		return author$project$Logic$Template$Component$Layer$Tiles(info);
	} else {
		var info = layer.a;
		return author$project$Logic$Template$Component$Layer$AnimatedTiles(info);
	}
};
var author$project$Logic$Template$SaveLoad$Internal$Loader$Texture_ = function (a) {
	return {$: 0, a: a};
};
var author$project$Logic$Template$SaveLoad$Internal$Loader$textureError = F2(
	function (url, e) {
		if (!e.$) {
			return A2(author$project$Logic$Launcher$Error, 4005, 'Texture.LoadError: ' + url);
		} else {
			var a = e.a;
			var b = e.b;
			return A2(author$project$Logic$Launcher$Error, 4006, 'Texture.SizeError: ' + url);
		}
	});
var elm_explorations$webgl$WebGL$Texture$Resize = elm$core$Basics$identity;
var elm_explorations$webgl$WebGL$Texture$linear = 9729;
var elm_explorations$webgl$WebGL$Texture$Wrap = elm$core$Basics$identity;
var elm_explorations$webgl$WebGL$Texture$clampToEdge = 33071;
var elm_explorations$webgl$WebGL$Texture$nearest = 9728;
var elm_explorations$webgl$WebGL$Texture$nonPowerOfTwoOptions = {bh: true, bn: elm_explorations$webgl$WebGL$Texture$clampToEdge, eZ: elm_explorations$webgl$WebGL$Texture$linear, e$: elm_explorations$webgl$WebGL$Texture$nearest, bP: elm_explorations$webgl$WebGL$Texture$clampToEdge};
var author$project$Logic$Template$SaveLoad$Internal$Loader$textureOption = _Utils_update(
	elm_explorations$webgl$WebGL$Texture$nonPowerOfTwoOptions,
	{eZ: elm_explorations$webgl$WebGL$Texture$linear, e$: elm_explorations$webgl$WebGL$Texture$linear});
var elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var elm$core$Task$onError = _Scheduler_onError;
var elm$core$Task$mapError = F2(
	function (convert, task) {
		return A2(
			elm$core$Task$onError,
			A2(elm$core$Basics$composeL, elm$core$Task$fail, convert),
			task);
	});
var elm_explorations$webgl$WebGL$Texture$LoadError = {$: 0};
var elm_explorations$webgl$WebGL$Texture$SizeError = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var elm_explorations$webgl$WebGL$Texture$loadWith = F2(
	function (_n0, url) {
		var magnify = _n0.eZ;
		var minify = _n0.e$;
		var horizontalWrap = _n0.bn;
		var verticalWrap = _n0.bP;
		var flipY = _n0.bh;
		var expand = F4(
			function (_n1, _n2, _n3, _n4) {
				var mag = _n1;
				var min = _n2;
				var hor = _n3;
				var vert = _n4;
				return A6(_Texture_load, mag, min, hor, vert, flipY, url);
			});
		return A4(expand, magnify, minify, horizontalWrap, verticalWrap);
	});
var author$project$Logic$Template$SaveLoad$Internal$Loader$getTextureTiled = function (url) {
	return A2(
		elm$core$Basics$composeR,
		elm$core$Task$andThen(
			function (d) {
				var _n0 = A2(elm$core$Dict$get, url, d.c);
				if ((!_n0.$) && (!_n0.a.$)) {
					var r = _n0.a.a;
					return elm$core$Task$succeed(
						_Utils_Tuple2(r, d));
				} else {
					return A2(
						elm$core$Task$map,
						function (r) {
							return _Utils_Tuple2(r, d);
						},
						A2(
							elm$core$Task$mapError,
							author$project$Logic$Template$SaveLoad$Internal$Loader$textureError(url),
							A2(
								elm_explorations$webgl$WebGL$Texture$loadWith,
								author$project$Logic$Template$SaveLoad$Internal$Loader$textureOption,
								A2(elm$core$String$startsWith, 'data:image', url) ? url : _Utils_ap(d.H, url))));
				}
			}),
		elm$core$Task$map(
			function (_n1) {
				var resp = _n1.a;
				var d = _n1.b;
				return _Utils_Tuple2(
					resp,
					_Utils_update(
						d,
						{
							c: A3(
								elm$core$Dict$insert,
								url,
								author$project$Logic$Template$SaveLoad$Internal$Loader$Texture_(resp),
								d.c)
						}));
			}));
};
var author$project$Logic$Template$SaveLoad$Internal$Util$scrollRatio = F2(
	function (dual, props) {
		return dual ? A2(
			elm_explorations$linear_algebra$Math$Vector2$vec2,
			A2(props.eG, 'scrollRatio.x', 1),
			A2(props.eG, 'scrollRatio.y', 1)) : A2(
			elm_explorations$linear_algebra$Math$Vector2$vec2,
			A2(props.eG, 'scrollRatio', 1),
			A2(props.eG, 'scrollRatio', 1));
	});
var author$project$Logic$Template$SaveLoad$Layer$ImageLayer$Repeat = 3;
var author$project$Logic$Template$SaveLoad$Layer$ImageLayer$RepeatNo = 2;
var author$project$Logic$Template$SaveLoad$Layer$ImageLayer$RepeatX = 0;
var author$project$Logic$Template$SaveLoad$Layer$ImageLayer$RepeatY = 1;
var elm_explorations$webgl$WebGL$Texture$size = _Texture_size;
var author$project$Logic$Template$SaveLoad$Layer$ImageLayer$imageLayerNew = function (imageData) {
	var props = author$project$Logic$Template$SaveLoad$Internal$Util$propertiesWithDefault(imageData);
	return A2(
		elm$core$Basics$composeR,
		author$project$Logic$Template$SaveLoad$Internal$Loader$getTextureTiled(imageData.b0),
		author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
			function (t) {
				var _n0 = elm_explorations$webgl$WebGL$Texture$size(t);
				var width = _n0.a;
				var height = _n0.b;
				return {
					c8: imageData.c8,
					b0: t,
					fp: function () {
						var _n1 = A2(props.cu, 'repeat', 'repeat');
						switch (_n1) {
							case 'repeat-x':
								return 0;
							case 'repeat-y':
								return 1;
							case 'no-repeat':
								return 2;
							default:
								return 3;
						}
					}(),
					a_: A2(
						author$project$Logic$Template$SaveLoad$Internal$Util$scrollRatio,
						_Utils_eq(
							A2(elm$core$Dict$get, 'scrollRatio', imageData.fi),
							elm$core$Maybe$Nothing),
						props),
					cs: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, width, height),
					T: A2(
						props.bd,
						'uTransparentColor',
						A3(elm_explorations$linear_algebra$Math$Vector3$vec3, 1, 0, 1))
				};
			}));
};
var author$project$Logic$Template$SaveLoad$Layer$ImageLayer$read = function (_n0) {
	var set = _n0.fu;
	var get = _n0.eH;
	return _Utils_update(
		author$project$Logic$Template$SaveLoad$Internal$Reader$defaultRead,
		{
			bp: author$project$Logic$Template$SaveLoad$Internal$Reader$Async(
				function (info) {
					return A2(
						elm$core$Basics$composeR,
						author$project$Logic$Template$SaveLoad$Layer$ImageLayer$imageLayerNew(info),
						author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
							F2(
								function (parsedLayers, _n1) {
									var id = _n1.a;
									var w = _n1.b;
									return _Utils_Tuple2(
										id,
										A2(
											set,
											_Utils_ap(
												get(w),
												_List_fromArray(
													[parsedLayers])),
											w));
								})));
				})
		});
};
var author$project$Logic$Template$SaveLoad$Internal$ResourceTask$sequence = F2(
	function (ltask, cache) {
		return A3(
			elm$core$List$foldl,
			F2(
				function (t, acc) {
					return A2(
						author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen,
						F2(
							function (newList, t2) {
								return A2(
									author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map,
									function (r) {
										return A2(elm$core$List$cons, r, newList);
									},
									t(t2));
							}),
						acc);
				}),
			A2(author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed, _List_Nil, cache),
			ltask);
	});
var author$project$Logic$Template$SaveLoad$Internal$Loader$Tileset_ = function (a) {
	return {$: 1, a: a};
};
var elm$json$Json$Decode$map2 = _Json_map2;
var NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom = elm$json$Json$Decode$map2(elm$core$Basics$apR);
var NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded = A2(elm$core$Basics$composeR, elm$json$Json$Decode$succeed, NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom);
var elm$json$Json$Decode$andThen = _Json_andThen;
var elm$json$Json$Decode$fail = _Json_fail;
var elm$json$Json$Decode$null = _Json_decodeNull;
var NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optionalDecoder = F3(
	function (pathDecoder, valDecoder, fallback) {
		var nullOr = function (decoder) {
			return elm$json$Json$Decode$oneOf(
				_List_fromArray(
					[
						decoder,
						elm$json$Json$Decode$null(fallback)
					]));
		};
		var handleResult = function (input) {
			var _n0 = A2(elm$json$Json$Decode$decodeValue, pathDecoder, input);
			if (!_n0.$) {
				var rawValue = _n0.a;
				var _n1 = A2(
					elm$json$Json$Decode$decodeValue,
					nullOr(valDecoder),
					rawValue);
				if (!_n1.$) {
					var finalResult = _n1.a;
					return elm$json$Json$Decode$succeed(finalResult);
				} else {
					var finalErr = _n1.a;
					return elm$json$Json$Decode$fail(
						elm$json$Json$Decode$errorToString(finalErr));
				}
			} else {
				return elm$json$Json$Decode$succeed(fallback);
			}
		};
		return A2(elm$json$Json$Decode$andThen, handleResult, elm$json$Json$Decode$value);
	});
var NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional = F4(
	function (key, valDecoder, fallback, decoder) {
		return A2(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
			A3(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optionalDecoder,
				A2(elm$json$Json$Decode$field, key, elm$json$Json$Decode$value),
				valDecoder,
				fallback),
			decoder);
	});
var NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required = F3(
	function (key, valDecoder, decoder) {
		return A2(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
			A2(elm$json$Json$Decode$field, key, valDecoder),
			decoder);
	});
var author$project$Tiled$Properties$PropBool = function (a) {
	return {$: 0, a: a};
};
var author$project$Tiled$Properties$PropColor = function (a) {
	return {$: 4, a: a};
};
var author$project$Tiled$Properties$PropFile = function (a) {
	return {$: 5, a: a};
};
var author$project$Tiled$Properties$PropFloat = function (a) {
	return {$: 2, a: a};
};
var author$project$Tiled$Properties$PropInt = function (a) {
	return {$: 1, a: a};
};
var author$project$Tiled$Properties$PropString = function (a) {
	return {$: 3, a: a};
};
var elm$json$Json$Decode$int = _Json_decodeInt;
var author$project$Tiled$Properties$decodeProperty = function (typeString) {
	switch (typeString) {
		case 'bool':
			return A2(elm$json$Json$Decode$map, author$project$Tiled$Properties$PropBool, elm$json$Json$Decode$bool);
		case 'color':
			return A2(elm$json$Json$Decode$map, author$project$Tiled$Properties$PropColor, elm$json$Json$Decode$string);
		case 'float':
			return A2(elm$json$Json$Decode$map, author$project$Tiled$Properties$PropFloat, elm$json$Json$Decode$float);
		case 'file':
			return A2(elm$json$Json$Decode$map, author$project$Tiled$Properties$PropFile, elm$json$Json$Decode$string);
		case 'int':
			return A2(elm$json$Json$Decode$map, author$project$Tiled$Properties$PropInt, elm$json$Json$Decode$int);
		case 'string':
			return A2(elm$json$Json$Decode$map, author$project$Tiled$Properties$PropString, elm$json$Json$Decode$string);
		default:
			return elm$json$Json$Decode$fail('I can\'t decode the type ' + typeString);
	}
};
var author$project$Tiled$Properties$decode = A2(
	elm$json$Json$Decode$map,
	elm$core$Dict$fromList,
	elm$json$Json$Decode$list(
		A2(
			elm$json$Json$Decode$andThen,
			function (kind) {
				return A3(
					NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'value',
					author$project$Tiled$Properties$decodeProperty(kind),
					A3(
						NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'name',
						elm$json$Json$Decode$string,
						elm$json$Json$Decode$succeed(
							F2(
								function (a, b) {
									return _Utils_Tuple2(a, b);
								}))));
			},
			A3(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'type',
				elm$json$Json$Decode$string,
				elm$json$Json$Decode$succeed(elm$core$Basics$identity)))));
var author$project$Tiled$Tileset$Embedded = function (a) {
	return {$: 1, a: a};
};
var author$project$Tiled$Tileset$EmbeddedTileData = function (columns) {
	return function (firstgid) {
		return function (image) {
			return function (imageheight) {
				return function (imagewidth) {
					return function (margin) {
						return function (name) {
							return function (spacing) {
								return function (tilecount) {
									return function (tileheight) {
										return function (tilewidth) {
											return function (transparentcolor) {
												return function (tiles) {
													return function (properties) {
														return {bf: columns, eD: firstgid, b0: image, c9: imageheight, da: imagewidth, bu: margin, x: name, fi: properties, bG: spacing, au: tilecount, af: tileheight, d6: tiles, ag: tilewidth, ea: transparentcolor};
													};
												};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var author$project$Tiled$Tileset$SpriteAnimation = F2(
	function (duration, tileid) {
		return {ax: duration, fD: tileid};
	});
var author$project$Tiled$Tileset$decodeSpriteAnimation = A3(
	elm$json$Json$Decode$map2,
	author$project$Tiled$Tileset$SpriteAnimation,
	A2(elm$json$Json$Decode$field, 'duration', elm$json$Json$Decode$int),
	A2(elm$json$Json$Decode$field, 'tileid', elm$json$Json$Decode$int));
var author$project$Tiled$Layer$Index = 1;
var author$project$Tiled$Layer$TopDown = 0;
var author$project$Tiled$Layer$decodeDraworder = A2(
	elm$json$Json$Decode$andThen,
	function (result) {
		switch (result) {
			case 'topdown':
				return elm$json$Json$Decode$succeed(0);
			case 'index':
				return elm$json$Json$Decode$succeed(1);
			default:
				return elm$json$Json$Decode$fail('Unknow render order');
		}
	},
	elm$json$Json$Decode$string);
var author$project$Tiled$Object$Ellipse = function (a) {
	return {$: 2, a: a};
};
var author$project$Tiled$Object$Point = function (a) {
	return {$: 0, a: a};
};
var author$project$Tiled$Object$PolyLine = function (a) {
	return {$: 4, a: a};
};
var author$project$Tiled$Object$Polygon = function (a) {
	return {$: 3, a: a};
};
var author$project$Tiled$Object$Rectangle = function (a) {
	return {$: 1, a: a};
};
var author$project$Tiled$Object$Tile = function (a) {
	return {$: 5, a: a};
};
var author$project$Tiled$Object$commonDimension = F2(
	function (a, b) {
		return {bm: b.bm, c8: a.c8, M: a.M, x: a.x, fi: a.fi, S: a.S, A: a.A, bQ: b.bQ, n: a.n, o: a.o};
	});
var author$project$Tiled$Object$commonDimensionArgsGid = F3(
	function (a, b, c) {
		return {b$: c, bm: b.bm, c8: a.c8, M: a.M, x: a.x, fi: a.fi, S: a.S, A: a.A, bQ: b.bQ, n: a.n, o: a.o};
	});
var author$project$Tiled$Object$commonDimensionPolyPoints = F3(
	function (a, b, c) {
		return {bm: b.bm, c8: a.c8, M: a.M, x: a.x, dA: c, fi: a.fi, S: a.S, A: a.A, bQ: b.bQ, n: a.n, o: a.o};
	});
var author$project$Tiled$Object$decodeCommon = function () {
	var common = F8(
		function (id, name, kind, visible, x, y, rotation, properties) {
			return {c8: id, M: kind, x: name, fi: properties, S: rotation, A: visible, n: x, o: y};
		});
	return A4(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
		'properties',
		author$project$Tiled$Properties$decode,
		elm$core$Dict$empty,
		A3(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'rotation',
			elm$json$Json$Decode$float,
			A3(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'y',
				elm$json$Json$Decode$float,
				A3(
					NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'x',
					elm$json$Json$Decode$float,
					A3(
						NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'visible',
						elm$json$Json$Decode$bool,
						A3(
							NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'type',
							elm$json$Json$Decode$string,
							A3(
								NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'name',
								elm$json$Json$Decode$string,
								A3(
									NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'id',
									elm$json$Json$Decode$int,
									elm$json$Json$Decode$succeed(common)))))))));
}();
var author$project$Tiled$Object$decodeDimension = function () {
	var dimension = F2(
		function (width, height) {
			return {bm: height, bQ: width};
		});
	return A3(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'height',
		elm$json$Json$Decode$float,
		A3(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'width',
			elm$json$Json$Decode$float,
			elm$json$Json$Decode$succeed(dimension)));
}();
var author$project$Tiled$Object$decodeGid = A2(elm$json$Json$Decode$field, 'gid', elm$json$Json$Decode$int);
var author$project$Tiled$Object$decodePolyPoints = elm$json$Json$Decode$list(
	A3(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'y',
		elm$json$Json$Decode$float,
		A3(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'x',
			elm$json$Json$Decode$float,
			elm$json$Json$Decode$succeed(
				F2(
					function (x, y) {
						return {n: x, o: y};
					})))));
var elm_community$json_extra$Json$Decode$Extra$when = F3(
	function (checkDecoder, check, passDecoder) {
		return A2(
			elm$json$Json$Decode$andThen,
			function (checkVal) {
				return check(checkVal) ? passDecoder : elm$json$Json$Decode$fail('Check failed with input');
			},
			checkDecoder);
	});
var author$project$Tiled$Object$decode = function () {
	var tile = A3(
		elm_community$json_extra$Json$Decode$Extra$when,
		A2(elm$json$Json$Decode$field, 'gid', elm$json$Json$Decode$int),
		elm$core$Basics$lt(0),
		A2(
			elm$json$Json$Decode$map,
			author$project$Tiled$Object$Tile,
			A4(elm$json$Json$Decode$map3, author$project$Tiled$Object$commonDimensionArgsGid, author$project$Tiled$Object$decodeCommon, author$project$Tiled$Object$decodeDimension, author$project$Tiled$Object$decodeGid)));
	var rectangle = A2(
		elm$json$Json$Decode$map,
		author$project$Tiled$Object$Rectangle,
		A3(elm$json$Json$Decode$map2, author$project$Tiled$Object$commonDimension, author$project$Tiled$Object$decodeCommon, author$project$Tiled$Object$decodeDimension));
	var polyline = A2(
		elm$json$Json$Decode$map,
		author$project$Tiled$Object$PolyLine,
		A4(
			elm$json$Json$Decode$map3,
			author$project$Tiled$Object$commonDimensionPolyPoints,
			author$project$Tiled$Object$decodeCommon,
			author$project$Tiled$Object$decodeDimension,
			A2(elm$json$Json$Decode$field, 'polyline', author$project$Tiled$Object$decodePolyPoints)));
	var polygon = A2(
		elm$json$Json$Decode$map,
		author$project$Tiled$Object$Polygon,
		A4(
			elm$json$Json$Decode$map3,
			author$project$Tiled$Object$commonDimensionPolyPoints,
			author$project$Tiled$Object$decodeCommon,
			author$project$Tiled$Object$decodeDimension,
			A2(elm$json$Json$Decode$field, 'polygon', author$project$Tiled$Object$decodePolyPoints)));
	var point = A3(
		elm_community$json_extra$Json$Decode$Extra$when,
		A2(elm$json$Json$Decode$field, 'point', elm$json$Json$Decode$bool),
		elm$core$Basics$eq(true),
		A2(elm$json$Json$Decode$map, author$project$Tiled$Object$Point, author$project$Tiled$Object$decodeCommon));
	var ellipse = A3(
		elm_community$json_extra$Json$Decode$Extra$when,
		A2(elm$json$Json$Decode$field, 'ellipse', elm$json$Json$Decode$bool),
		elm$core$Basics$eq(true),
		A2(
			elm$json$Json$Decode$map,
			author$project$Tiled$Object$Ellipse,
			A3(elm$json$Json$Decode$map2, author$project$Tiled$Object$commonDimension, author$project$Tiled$Object$decodeCommon, author$project$Tiled$Object$decodeDimension)));
	return elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[point, ellipse, tile, polygon, polyline, rectangle]));
}();
var author$project$Tiled$Tileset$TilesDataObjectgroup = F7(
	function (draworder, name, objects, opacity, visible, x, y) {
		return {cV: draworder, x: name, dt: objects, b9: opacity, A: visible, n: x, o: y};
	});
var author$project$Tiled$Tileset$decodeTilesDataObjectgroup = A3(
	NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'y',
	elm$json$Json$Decode$int,
	A3(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'x',
		elm$json$Json$Decode$int,
		A3(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'visible',
			elm$json$Json$Decode$bool,
			A3(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'opacity',
				elm$json$Json$Decode$int,
				A3(
					NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'objects',
					elm$json$Json$Decode$list(author$project$Tiled$Object$decode),
					A3(
						NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'name',
						elm$json$Json$Decode$string,
						A3(
							NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'draworder',
							author$project$Tiled$Layer$decodeDraworder,
							elm$json$Json$Decode$succeed(author$project$Tiled$Tileset$TilesDataObjectgroup))))))));
var elm$json$Json$Decode$maybe = function (decoder) {
	return elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2(elm$json$Json$Decode$map, elm$core$Maybe$Just, decoder),
				elm$json$Json$Decode$succeed(elm$core$Maybe$Nothing)
			]));
};
var author$project$Tiled$Tileset$decodeTilesData = A3(
	NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'id',
	elm$json$Json$Decode$int,
	A4(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
		'properties',
		author$project$Tiled$Properties$decode,
		elm$core$Dict$empty,
		A4(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
			'objectgroup',
			elm$json$Json$Decode$maybe(author$project$Tiled$Tileset$decodeTilesDataObjectgroup),
			elm$core$Maybe$Nothing,
			A4(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
				'animation',
				elm$json$Json$Decode$list(author$project$Tiled$Tileset$decodeSpriteAnimation),
				_List_Nil,
				elm$json$Json$Decode$succeed(
					F4(
						function (a, b, c, d) {
							var _n0 = _Utils_Tuple3(
								a,
								b,
								elm$core$Dict$toList(c));
							if (((!_n0.a.b) && (_n0.b.$ === 1)) && (!_n0.c.b)) {
								var _n1 = _n0.b;
								return elm$core$Maybe$Nothing;
							} else {
								return elm$core$Maybe$Just(
									{cD: a, c8: d, fa: b, fi: c});
							}
						}))))));
var author$project$Tiled$Tileset$decodeTiles = A2(
	elm$json$Json$Decode$andThen,
	A2(
		elm$core$List$foldl,
		F2(
			function (info_, acc) {
				if (!info_.$) {
					var info = info_.a;
					return A2(
						elm$json$Json$Decode$andThen,
						A2(
							elm$core$Basics$composeR,
							A2(
								elm$core$Dict$insert,
								info.c8,
								{cD: info.cD, fa: info.fa, fi: info.fi}),
							elm$json$Json$Decode$succeed),
						acc);
				} else {
					return acc;
				}
			}),
		elm$json$Json$Decode$succeed(elm$core$Dict$empty)),
	elm$json$Json$Decode$list(author$project$Tiled$Tileset$decodeTilesData));
var author$project$Tiled$Tileset$decodeEmbeddedTileset = function (firstgid) {
	return A2(
		elm$json$Json$Decode$map,
		author$project$Tiled$Tileset$Embedded,
		A4(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
			'properties',
			author$project$Tiled$Properties$decode,
			elm$core$Dict$empty,
			A4(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
				'tiles',
				author$project$Tiled$Tileset$decodeTiles,
				elm$core$Dict$empty,
				A4(
					NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
					'transparentcolor',
					elm$json$Json$Decode$string,
					'none',
					A3(
						NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'tilewidth',
						elm$json$Json$Decode$int,
						A3(
							NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'tileheight',
							elm$json$Json$Decode$int,
							A3(
								NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'tilecount',
								elm$json$Json$Decode$int,
								A3(
									NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'spacing',
									elm$json$Json$Decode$int,
									A3(
										NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
										'name',
										elm$json$Json$Decode$string,
										A3(
											NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
											'margin',
											elm$json$Json$Decode$int,
											A3(
												NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
												'imagewidth',
												elm$json$Json$Decode$int,
												A3(
													NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
													'imageheight',
													elm$json$Json$Decode$int,
													A3(
														NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
														'image',
														elm$json$Json$Decode$string,
														firstgid(
															A3(
																NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
																'columns',
																elm$json$Json$Decode$int,
																elm$json$Json$Decode$succeed(author$project$Tiled$Tileset$EmbeddedTileData))))))))))))))));
};
var author$project$Tiled$Tileset$ImageCollection = function (a) {
	return {$: 2, a: a};
};
var author$project$Tiled$Tileset$ImageCollectionTileData = function (columns) {
	return function (firstgid) {
		return function (margin) {
			return function (name) {
				return function (spacing) {
					return function (tilecount) {
						return function (tilewidth) {
							return function (tileheight) {
								return function (tiles) {
									return function (properties) {
										return function (grid) {
											return {bf: columns, eD: firstgid, ap: grid, bu: margin, x: name, fi: properties, bG: spacing, au: tilecount, af: tileheight, d6: tiles, ag: tilewidth};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var author$project$Tiled$Tileset$GridData = F3(
	function (height, orientation, width) {
		return {bm: height, dw: orientation, bQ: width};
	});
var author$project$Tiled$Tileset$decodeGrid = A3(
	NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'width',
	elm$json$Json$Decode$int,
	A3(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'orientation',
		elm$json$Json$Decode$string,
		A3(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'height',
			elm$json$Json$Decode$int,
			elm$json$Json$Decode$succeed(author$project$Tiled$Tileset$GridData))));
var author$project$Tiled$Tileset$decodeImageCollectionTileDataTiles = function () {
	var decodeImageTile = A4(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
		'properties',
		author$project$Tiled$Properties$decode,
		elm$core$Dict$empty,
		A4(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
			'objectgroup',
			elm$json$Json$Decode$maybe(author$project$Tiled$Tileset$decodeTilesDataObjectgroup),
			elm$core$Maybe$Nothing,
			A4(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
				'animation',
				elm$json$Json$Decode$list(author$project$Tiled$Tileset$decodeSpriteAnimation),
				_List_Nil,
				A3(
					NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'imagewidth',
					elm$json$Json$Decode$int,
					A3(
						NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'imageheight',
						elm$json$Json$Decode$int,
						A3(
							NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'image',
							elm$json$Json$Decode$string,
							A3(
								NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'id',
								elm$json$Json$Decode$int,
								elm$json$Json$Decode$succeed(
									F7(
										function (id, image, imageheight, imagewidth, animation, objectgroup, properties) {
											return _Utils_Tuple2(
												id,
												{cD: animation, b0: image, c9: imageheight, da: imagewidth, fa: objectgroup, fi: properties});
										})))))))));
	return A2(
		elm$json$Json$Decode$map,
		A2(
			elm$core$List$foldl,
			F2(
				function (_n0, acc) {
					var i = _n0.a;
					var v = _n0.b;
					return A3(elm$core$Dict$insert, i, v, acc);
				}),
			elm$core$Dict$empty),
		A2(
			elm$json$Json$Decode$field,
			'tiles',
			elm$json$Json$Decode$list(decodeImageTile)));
}();
var author$project$Tiled$Tileset$decodeImageCollectionTileData = function (firstgid) {
	return A2(
		elm$json$Json$Decode$map,
		author$project$Tiled$Tileset$ImageCollection,
		A4(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
			'grid',
			A2(elm$json$Json$Decode$map, elm$core$Maybe$Just, author$project$Tiled$Tileset$decodeGrid),
			elm$core$Maybe$Nothing,
			A4(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
				'properties',
				author$project$Tiled$Properties$decode,
				elm$core$Dict$empty,
				A2(
					NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
					author$project$Tiled$Tileset$decodeImageCollectionTileDataTiles,
					A3(
						NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'tileheight',
						elm$json$Json$Decode$int,
						A3(
							NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'tilewidth',
							elm$json$Json$Decode$int,
							A3(
								NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'tilecount',
								elm$json$Json$Decode$int,
								A3(
									NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'spacing',
									elm$json$Json$Decode$int,
									A3(
										NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
										'name',
										elm$json$Json$Decode$string,
										A3(
											NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
											'margin',
											elm$json$Json$Decode$int,
											firstgid(
												A3(
													NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
													'columns',
													elm$json$Json$Decode$int,
													elm$json$Json$Decode$succeed(author$project$Tiled$Tileset$ImageCollectionTileData)))))))))))));
};
var author$project$Tiled$Tileset$decodeFile = function (firstgid) {
	return elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				author$project$Tiled$Tileset$decodeEmbeddedTileset(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded(firstgid)),
				author$project$Tiled$Tileset$decodeImageCollectionTileData(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded(firstgid))
			]));
};
var author$project$Logic$Template$SaveLoad$Internal$Loader$getTileset = F2(
	function (url, firstgid) {
		return A2(
			elm$core$Basics$composeR,
			elm$core$Task$andThen(
				function (d) {
					var _n0 = A2(elm$core$Dict$get, url, d.c);
					if ((!_n0.$) && (_n0.a.$ === 1)) {
						var r = _n0.a.a;
						return elm$core$Task$succeed(
							_Utils_Tuple2(r, d));
					} else {
						return A2(
							elm$core$Task$map,
							function (r) {
								return _Utils_Tuple2(r, d);
							},
							A2(
								author$project$Logic$Template$SaveLoad$Internal$Loader$getJson_,
								_Utils_ap(d.H, url),
								author$project$Tiled$Tileset$decodeFile(firstgid)));
					}
				}),
			elm$core$Task$map(
				function (_n1) {
					var resp = _n1.a;
					var d = _n1.b;
					return _Utils_Tuple2(
						resp,
						_Utils_update(
							d,
							{
								c: A3(
									elm$core$Dict$insert,
									url,
									author$project$Logic$Template$SaveLoad$Internal$Loader$Tileset_(resp),
									d.c)
							}));
				}));
	});
var author$project$Logic$Template$SaveLoad$Internal$Util$firstGid = function (item) {
	switch (item.$) {
		case 0:
			var info = item.a;
			return info.eD;
		case 1:
			var info = item.a;
			return info.eD;
		default:
			var info = item.a;
			return info.eD;
	}
};
var author$project$Logic$Template$SaveLoad$Internal$Util$tilesetById = F2(
	function (tilesets_, id) {
		var innerfind = F2(
			function (predicate, list) {
				innerfind:
				while (true) {
					if (list.b) {
						if (list.b.b) {
							var first = list.a;
							var _n1 = list.b;
							var next = _n1.a;
							var rest = _n1.b;
							if (A2(
								predicate,
								first,
								elm$core$Maybe$Just(next))) {
								return elm$core$Maybe$Just(first);
							} else {
								var $temp$predicate = predicate,
									$temp$list = A2(elm$core$List$cons, next, rest);
								predicate = $temp$predicate;
								list = $temp$list;
								continue innerfind;
							}
						} else {
							var first = list.a;
							var rest = list.b;
							if (A2(predicate, first, elm$core$Maybe$Nothing)) {
								return elm$core$Maybe$Just(first);
							} else {
								var $temp$predicate = predicate,
									$temp$list = rest;
								predicate = $temp$predicate;
								list = $temp$list;
								continue innerfind;
							}
						}
					} else {
						return elm$core$Maybe$Nothing;
					}
				}
			});
		return A2(
			innerfind,
			F2(
				function (item, next) {
					var _n2 = _Utils_Tuple2(item, next);
					switch (_n2.a.$) {
						case 0:
							if (_n2.b.$ === 1) {
								var _n3 = _n2.b;
								return true;
							} else {
								var info = _n2.a.a;
								var nextTileset = _n2.b.a;
								return (_Utils_cmp(id, info.eD) > -1) && (_Utils_cmp(
									id,
									author$project$Logic$Template$SaveLoad$Internal$Util$firstGid(nextTileset)) < 0);
							}
						case 1:
							var info = _n2.a.a;
							return (_Utils_cmp(id, info.eD) > -1) && (_Utils_cmp(id, info.eD + info.au) < 0);
						default:
							var info = _n2.a.a;
							return (_Utils_cmp(id, info.eD) > -1) && (_Utils_cmp(id, info.eD + info.au) < 0);
					}
				}),
			tilesets_);
	});
var author$project$Logic$Template$SaveLoad$Internal$Util$updateTileset = F4(
	function (was, now, begin, end) {
		updateTileset:
		while (true) {
			if (begin.b) {
				var item = begin.a;
				var left = begin.b;
				if (_Utils_eq(item, was)) {
					return elm$core$List$reverse(
						_Utils_ap(
							left,
							A2(elm$core$List$cons, now, end)));
				} else {
					var $temp$was = was,
						$temp$now = now,
						$temp$begin = left,
						$temp$end = A2(elm$core$List$cons, item, end);
					was = $temp$was;
					now = $temp$now;
					begin = $temp$begin;
					end = $temp$end;
					continue updateTileset;
				}
			} else {
				return elm$core$List$reverse(end);
			}
		}
	});
var author$project$Logic$Template$SaveLoad$Internal$Util$animation = F2(
	function (_n0, id) {
		var tiles = _n0.d6;
		return A2(
			elm$core$Maybe$andThen,
			function (info) {
				return (elm$core$List$length(info.cD) > 0) ? elm$core$Maybe$Just(info.cD) : elm$core$Maybe$Nothing;
			},
			A2(elm$core$Dict$get, id, tiles));
	});
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$prepend = F2(
	function (id, _n0) {
		var t = _n0.a;
		var v = _n0.b;
		return _Utils_Tuple2(
			t,
			A2(elm$core$List$cons, id, v));
	});
var elm$core$Dict$map = F2(
	function (func, dict) {
		if (dict.$ === -2) {
			return elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			return A5(
				elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				A2(func, key, value),
				A2(elm$core$Dict$map, func, left),
				A2(elm$core$Dict$map, func, right));
		}
	});
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$updateOthers = F2(
	function (f, k) {
		return elm$core$Dict$map(
			F2(
				function (k_, v) {
					return _Utils_eq(k_, k) ? v : f(v);
				}));
	});
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$others = author$project$Logic$Template$SaveLoad$Layer$TileLayer$updateOthers(
	author$project$Logic$Template$SaveLoad$Layer$TileLayer$prepend(0));
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$fillTiles = F3(
	function (tileId, info, _n0) {
		var cache = _n0.cK;
		var _static = _n0.C;
		var animated = _n0.B;
		var _n1 = A2(elm$core$Dict$get, tileId, animated);
		if (!_n1.$) {
			var _n2 = _n1.a;
			var t_ = _n2.a;
			var v = _n2.b;
			return {
				B: A2(
					author$project$Logic$Template$SaveLoad$Layer$TileLayer$others,
					tileId,
					A3(
						elm$core$Dict$insert,
						tileId,
						_Utils_Tuple2(
							t_,
							A2(elm$core$List$cons, 1, v)),
						animated)),
				cK: A2(elm$core$List$cons, 0, cache),
				C: A2(author$project$Logic$Template$SaveLoad$Layer$TileLayer$others, 0, _static)
			};
		} else {
			var _n3 = A2(author$project$Logic$Template$SaveLoad$Internal$Util$animation, info, tileId - info.eD);
			if (!_n3.$) {
				var anim = _n3.a;
				return {
					B: A2(
						author$project$Logic$Template$SaveLoad$Layer$TileLayer$others,
						tileId,
						A3(
							elm$core$Dict$insert,
							tileId,
							_Utils_Tuple2(
								_Utils_Tuple2(info, anim),
								A2(elm$core$List$cons, 1, cache)),
							animated)),
					cK: A2(elm$core$List$cons, 0, cache),
					C: A2(author$project$Logic$Template$SaveLoad$Layer$TileLayer$others, 0, _static)
				};
			} else {
				var relativeId = (tileId - info.eD) + 1;
				var _n4 = A2(elm$core$Dict$get, info.eD, _static);
				if (!_n4.$) {
					var _n5 = _n4.a;
					var t_ = _n5.a;
					var v = _n5.b;
					return {
						B: A2(author$project$Logic$Template$SaveLoad$Layer$TileLayer$others, 0, animated),
						cK: A2(elm$core$List$cons, 0, cache),
						C: A2(
							author$project$Logic$Template$SaveLoad$Layer$TileLayer$others,
							info.eD,
							A3(
								elm$core$Dict$insert,
								info.eD,
								_Utils_Tuple2(
									t_,
									A2(elm$core$List$cons, relativeId, v)),
								_static))
					};
				} else {
					return {
						B: A2(author$project$Logic$Template$SaveLoad$Layer$TileLayer$others, 0, animated),
						cK: A2(elm$core$List$cons, 0, cache),
						C: A2(
							author$project$Logic$Template$SaveLoad$Layer$TileLayer$others,
							info.eD,
							A3(
								elm$core$Dict$insert,
								info.eD,
								_Utils_Tuple2(
									info,
									A2(elm$core$List$cons, relativeId, cache)),
								_static))
					};
				}
			}
		}
	});
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$splitTileLayerByTileSet2 = F4(
	function (tilesets, getTileset, dataLeft, acc) {
		splitTileLayerByTileSet2:
		while (true) {
			var cache = acc.cK;
			var _static = acc.C;
			var animated = acc.B;
			if (dataLeft.b) {
				var gid = dataLeft.a;
				var rest = dataLeft.b;
				if (!gid) {
					var $temp$tilesets = tilesets,
						$temp$getTileset = getTileset,
						$temp$dataLeft = rest,
						$temp$acc = {
						B: A2(author$project$Logic$Template$SaveLoad$Layer$TileLayer$others, 0, animated),
						cK: A2(elm$core$List$cons, 0, cache),
						C: A2(author$project$Logic$Template$SaveLoad$Layer$TileLayer$others, 0, _static)
					};
					tilesets = $temp$tilesets;
					getTileset = $temp$getTileset;
					dataLeft = $temp$dataLeft;
					acc = $temp$acc;
					continue splitTileLayerByTileSet2;
				} else {
					var _n1 = A2(author$project$Logic$Template$SaveLoad$Internal$Util$tilesetById, tilesets, gid);
					if (!_n1.$) {
						var t = _n1.a;
						switch (t.$) {
							case 1:
								var info = t.a;
								var $temp$tilesets = tilesets,
									$temp$getTileset = getTileset,
									$temp$dataLeft = rest,
									$temp$acc = A3(author$project$Logic$Template$SaveLoad$Layer$TileLayer$fillTiles, gid, info, acc);
								tilesets = $temp$tilesets;
								getTileset = $temp$getTileset;
								dataLeft = $temp$dataLeft;
								acc = $temp$acc;
								continue splitTileLayerByTileSet2;
							case 0:
								var was = t;
								var firstgid = was.a.eD;
								var source = was.a.dV;
								return A2(
									elm$core$Basics$composeR,
									A2(author$project$Logic$Template$SaveLoad$Internal$Loader$getTileset, source, firstgid),
									author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
										function (tileset) {
											return A4(
												author$project$Logic$Template$SaveLoad$Layer$TileLayer$splitTileLayerByTileSet2,
												A4(author$project$Logic$Template$SaveLoad$Internal$Util$updateTileset, was, tileset, tilesets, _List_Nil),
												getTileset,
												dataLeft,
												acc);
										}));
							default:
								var $temp$tilesets = tilesets,
									$temp$getTileset = getTileset,
									$temp$dataLeft = rest,
									$temp$acc = _Utils_update(
									acc,
									{
										cK: A2(elm$core$List$cons, 0, cache)
									});
								tilesets = $temp$tilesets;
								getTileset = $temp$getTileset;
								dataLeft = $temp$dataLeft;
								acc = $temp$acc;
								continue splitTileLayerByTileSet2;
						}
					} else {
						return A2(
							elm$core$Basics$composeR,
							getTileset(gid),
							author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
								function (t) {
									return A4(
										author$project$Logic$Template$SaveLoad$Layer$TileLayer$splitTileLayerByTileSet2,
										A2(elm$core$List$cons, t, tilesets),
										getTileset,
										dataLeft,
										acc);
								}));
					}
				}
			} else {
				return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed(
					{
						B: elm$core$Dict$values(acc.B),
						C: elm$core$Dict$values(acc.C),
						z: tilesets
					});
			}
		}
	});
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$AnimatedTiles = function (a) {
	return {$: 1, a: a};
};
var author$project$Image$Bit24 = 0;
var author$project$Image$LeftUp = 3;
var author$project$Image$defaultOptions = {es: 16776960, et: 0, ff: 3};
var elm$core$Bitwise$shiftRightBy = _Bitwise_shiftRightBy;
var author$project$Image$Internal$unsignedInt24 = F2(
	function (endian, num) {
		return (!endian) ? elm$bytes$Bytes$Encode$sequence(
			_List_fromArray(
				[
					elm$bytes$Bytes$Encode$unsignedInt8(num & 255),
					elm$bytes$Bytes$Encode$unsignedInt8((num & 65280) >> 8),
					elm$bytes$Bytes$Encode$unsignedInt8((num & 16711680) >> 16)
				])) : elm$bytes$Bytes$Encode$sequence(
			_List_fromArray(
				[
					elm$bytes$Bytes$Encode$unsignedInt8((num & 16711680) >> 16),
					elm$bytes$Bytes$Encode$unsignedInt8((num & 65280) >> 8),
					elm$bytes$Bytes$Encode$unsignedInt8(num & 255)
				]));
	});
var author$project$Image$pixelInt24 = function (e1) {
	return A2(author$project$Image$Internal$unsignedInt24, 0, e1);
};
var elm$bytes$Bytes$Encode$U16 = F2(
	function (a, b) {
		return {$: 4, a: a, b: b};
	});
var elm$bytes$Bytes$Encode$unsignedInt16 = elm$bytes$Bytes$Encode$U16;
var author$project$Image$BMP$header = F3(
	function (w, h, dataSize) {
		return _List_fromArray(
			[
				A2(elm$bytes$Bytes$Encode$unsignedInt16, 1, 16973),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 54 + dataSize),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 0),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 54),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 40),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, w),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, h),
				A2(elm$bytes$Bytes$Encode$unsignedInt16, 0, 1),
				A2(elm$bytes$Bytes$Encode$unsignedInt16, 0, 24),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 0),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, dataSize),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 2835),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 2835),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 0),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 0)
			]);
	});
var author$project$Image$LeftDown = 2;
var author$project$Image$RightDown = 0;
var author$project$Image$RightUp = 1;
var elm$bytes$Bytes$Decode$Done = function (a) {
	return {$: 1, a: a};
};
var elm$bytes$Bytes$Decode$Loop = function (a) {
	return {$: 0, a: a};
};
var elm$bytes$Bytes$Decode$Decoder = elm$core$Basics$identity;
var elm$bytes$Bytes$Decode$map = F2(
	function (func, _n0) {
		var decodeA = _n0;
		return F2(
			function (bites, offset) {
				var _n1 = A2(decodeA, bites, offset);
				var aOffset = _n1.a;
				var a = _n1.b;
				return _Utils_Tuple2(
					aOffset,
					func(a));
			});
	});
var elm$bytes$Bytes$Decode$succeed = function (a) {
	return F2(
		function (_n0, offset) {
			return _Utils_Tuple2(offset, a);
		});
};
var author$project$Image$BMP$listStep = F2(
	function (decoder, _n0) {
		var n = _n0.a;
		var xs = _n0.b;
		return (n <= 0) ? elm$bytes$Bytes$Decode$succeed(
			elm$bytes$Bytes$Decode$Done(xs)) : A2(
			elm$bytes$Bytes$Decode$map,
			function (x) {
				return elm$bytes$Bytes$Decode$Loop(
					_Utils_Tuple2(
						n - 1,
						A2(elm$core$List$cons, x, xs)));
			},
			decoder);
	});
var elm$bytes$Bytes$Decode$loopHelp = F4(
	function (state, callback, bites, offset) {
		loopHelp:
		while (true) {
			var _n0 = callback(state);
			var decoder = _n0;
			var _n1 = A2(decoder, bites, offset);
			var newOffset = _n1.a;
			var step = _n1.b;
			if (!step.$) {
				var newState = step.a;
				var $temp$state = newState,
					$temp$callback = callback,
					$temp$bites = bites,
					$temp$offset = newOffset;
				state = $temp$state;
				callback = $temp$callback;
				bites = $temp$bites;
				offset = $temp$offset;
				continue loopHelp;
			} else {
				var result = step.a;
				return _Utils_Tuple2(newOffset, result);
			}
		}
	});
var elm$bytes$Bytes$Decode$loop = F2(
	function (state, callback) {
		return A2(elm$bytes$Bytes$Decode$loopHelp, state, callback);
	});
var author$project$Image$BMP$splitToList = F2(
	function (len, decoder) {
		return A2(
			elm$bytes$Bytes$Decode$loop,
			_Utils_Tuple2(len, _List_Nil),
			author$project$Image$BMP$listStep(decoder));
	});
var elm$bytes$Bytes$Decode$bytes = function (n) {
	return _Bytes_read_bytes(n);
};
var elm$bytes$Bytes$Decode$decode = F2(
	function (_n0, bs) {
		var decoder = _n0;
		return A2(_Bytes_decode, decoder, bs);
	});
var elm$bytes$Bytes$Encode$Bytes = function (a) {
	return {$: 10, a: a};
};
var elm$bytes$Bytes$Encode$bytes = elm$bytes$Bytes$Encode$Bytes;
var elm$bytes$Bytes$Encode$encode = _Bytes_encode;
var elm$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (n <= 0) {
				return result;
			} else {
				var $temp$result = A2(elm$core$List$cons, value, result),
					$temp$n = n - 1,
					$temp$value = value;
				result = $temp$result;
				n = $temp$n;
				value = $temp$value;
				continue repeatHelp;
			}
		}
	});
var elm$core$List$repeat = F2(
	function (n, value) {
		return A3(elm$core$List$repeatHelp, _List_Nil, n, value);
	});
var author$project$Image$BMP$pixelData_ = F4(
	function (_n0, w, h, bytes) {
		var defaultColor = _n0.es;
		var order = _n0.ff;
		var depth = _n0.et;
		var reverseVertical = (order === 2) || (!order);
		var reverseHorizontal = (!order) || (order === 1);
		var _n1 = function () {
			var bPerPx = 3;
			var size_ = w * bPerPx;
			var pad_ = (4 - (size_ & bPerPx)) & bPerPx;
			var pad__ = elm$bytes$Bytes$Encode$sequence(
				A2(
					elm$core$List$repeat,
					pad_,
					elm$bytes$Bytes$Encode$unsignedInt8(0)));
			return _Utils_Tuple3(size_, pad__, bPerPx);
		}();
		var rowLength = _n1.a;
		var pad = _n1.b;
		var bytesPerPixel = _n1.c;
		var rowCreate = A2(
			elm$bytes$Bytes$Decode$map,
			function (row) {
				return reverseHorizontal ? elm$bytes$Bytes$Encode$sequence(
					_List_fromArray(
						[
							elm$bytes$Bytes$Encode$sequence(
							A2(
								elm$core$List$map,
								elm$bytes$Bytes$Encode$bytes,
								A2(
									elm$core$Maybe$withDefault,
									_List_Nil,
									A2(
										elm$bytes$Bytes$Decode$decode,
										A2(
											author$project$Image$BMP$splitToList,
											w,
											elm$bytes$Bytes$Decode$bytes(bytesPerPixel)),
										row)))),
							pad
						])) : elm$bytes$Bytes$Encode$sequence(
					_List_fromArray(
						[
							elm$bytes$Bytes$Encode$bytes(row),
							pad
						]));
			},
			elm$bytes$Bytes$Decode$bytes(rowLength));
		return elm$bytes$Bytes$Encode$encode(
			elm$bytes$Bytes$Encode$sequence(
				(reverseVertical ? elm$core$List$reverse : elm$core$Basics$identity)(
					A2(
						elm$core$Maybe$withDefault,
						_List_Nil,
						A2(
							elm$bytes$Bytes$Decode$decode,
							A2(author$project$Image$BMP$splitToList, h, rowCreate),
							bytes)))));
	});
var elm$bytes$Bytes$width = _Bytes_width;
var author$project$Image$BMP$encodeBytesWith = F4(
	function (opt, w, h, bytes) {
		var pixels_ = A4(author$project$Image$BMP$pixelData_, opt, w, h, bytes);
		return elm$bytes$Bytes$Encode$encode(
			elm$bytes$Bytes$Encode$sequence(
				_List_fromArray(
					[
						elm$bytes$Bytes$Encode$sequence(
						A3(
							author$project$Image$BMP$header,
							w,
							h,
							elm$bytes$Bytes$width(pixels_))),
						elm$bytes$Bytes$Encode$bytes(pixels_)
					])));
	});
var elm$bytes$Bytes$Decode$unsignedInt8 = _Bytes_read_u8;
var danfishgold$base64_bytes$Decode$intsDecoder = function (width) {
	return A2(
		elm$bytes$Bytes$Decode$map,
		A2(elm$core$Basics$composeR, elm$core$Tuple$second, elm$core$List$reverse),
		A2(
			elm$bytes$Bytes$Decode$loop,
			_Utils_Tuple2(width, _List_Nil),
			function (_n0) {
				var len = _n0.a;
				var ints = _n0.b;
				return (len <= 0) ? elm$bytes$Bytes$Decode$succeed(
					elm$bytes$Bytes$Decode$Done(
						_Utils_Tuple2(len, ints))) : A2(
					elm$bytes$Bytes$Decode$map,
					function (_int) {
						return elm$bytes$Bytes$Decode$Loop(
							_Utils_Tuple2(
								len - 1,
								A2(elm$core$List$cons, _int, ints)));
					},
					elm$bytes$Bytes$Decode$unsignedInt8);
			}));
};
var danfishgold$base64_bytes$Basic$listFromMaybeList = function (xs) {
	return A2(
		elm$core$Maybe$map,
		elm$core$List$reverse,
		A3(
			elm$core$List$foldl,
			F2(
				function (hd, res) {
					var _n0 = _Utils_Tuple2(res, hd);
					if (_n0.a.$ === 1) {
						var _n1 = _n0.a;
						return elm$core$Maybe$Nothing;
					} else {
						if (_n0.b.$ === 1) {
							var _n2 = _n0.b;
							return elm$core$Maybe$Nothing;
						} else {
							var tl = _n0.a.a;
							var x = _n0.b.a;
							return elm$core$Maybe$Just(
								A2(elm$core$List$cons, x, tl));
						}
					}
				}),
			elm$core$Maybe$Just(_List_Nil),
			xs));
};
var danfishgold$base64_bytes$Basic$tripleMap = F2(
	function (fn, xs) {
		var reverseHelper = F3(
			function (fn_, xs_, ys) {
				reverseHelper:
				while (true) {
					if (xs_.b) {
						if (xs_.b.b) {
							if (xs_.b.b.b) {
								var hd = xs_.a;
								var _n1 = xs_.b;
								var nk = _n1.a;
								var _n2 = _n1.b;
								var tr = _n2.a;
								var tl = _n2.b;
								var $temp$fn_ = fn_,
									$temp$xs_ = tl,
									$temp$ys = A2(
									elm$core$List$cons,
									A3(
										fn_,
										hd,
										elm$core$Maybe$Just(nk),
										elm$core$Maybe$Just(tr)),
									ys);
								fn_ = $temp$fn_;
								xs_ = $temp$xs_;
								ys = $temp$ys;
								continue reverseHelper;
							} else {
								var hd = xs_.a;
								var _n3 = xs_.b;
								var nk = _n3.a;
								return A2(
									elm$core$List$cons,
									A3(
										fn_,
										hd,
										elm$core$Maybe$Just(nk),
										elm$core$Maybe$Nothing),
									ys);
							}
						} else {
							var hd = xs_.a;
							return A2(
								elm$core$List$cons,
								A3(fn_, hd, elm$core$Maybe$Nothing, elm$core$Maybe$Nothing),
								ys);
						}
					} else {
						return ys;
					}
				}
			});
		return elm$core$List$reverse(
			A3(reverseHelper, fn, xs, _List_Nil));
	});
var danfishgold$base64_bytes$Basic$intToChar = function (n) {
	switch (n) {
		case 0:
			return elm$core$Maybe$Just('A');
		case 1:
			return elm$core$Maybe$Just('B');
		case 2:
			return elm$core$Maybe$Just('C');
		case 3:
			return elm$core$Maybe$Just('D');
		case 4:
			return elm$core$Maybe$Just('E');
		case 5:
			return elm$core$Maybe$Just('F');
		case 6:
			return elm$core$Maybe$Just('G');
		case 7:
			return elm$core$Maybe$Just('H');
		case 8:
			return elm$core$Maybe$Just('I');
		case 9:
			return elm$core$Maybe$Just('J');
		case 10:
			return elm$core$Maybe$Just('K');
		case 11:
			return elm$core$Maybe$Just('L');
		case 12:
			return elm$core$Maybe$Just('M');
		case 13:
			return elm$core$Maybe$Just('N');
		case 14:
			return elm$core$Maybe$Just('O');
		case 15:
			return elm$core$Maybe$Just('P');
		case 16:
			return elm$core$Maybe$Just('Q');
		case 17:
			return elm$core$Maybe$Just('R');
		case 18:
			return elm$core$Maybe$Just('S');
		case 19:
			return elm$core$Maybe$Just('T');
		case 20:
			return elm$core$Maybe$Just('U');
		case 21:
			return elm$core$Maybe$Just('V');
		case 22:
			return elm$core$Maybe$Just('W');
		case 23:
			return elm$core$Maybe$Just('X');
		case 24:
			return elm$core$Maybe$Just('Y');
		case 25:
			return elm$core$Maybe$Just('Z');
		case 26:
			return elm$core$Maybe$Just('a');
		case 27:
			return elm$core$Maybe$Just('b');
		case 28:
			return elm$core$Maybe$Just('c');
		case 29:
			return elm$core$Maybe$Just('d');
		case 30:
			return elm$core$Maybe$Just('e');
		case 31:
			return elm$core$Maybe$Just('f');
		case 32:
			return elm$core$Maybe$Just('g');
		case 33:
			return elm$core$Maybe$Just('h');
		case 34:
			return elm$core$Maybe$Just('i');
		case 35:
			return elm$core$Maybe$Just('j');
		case 36:
			return elm$core$Maybe$Just('k');
		case 37:
			return elm$core$Maybe$Just('l');
		case 38:
			return elm$core$Maybe$Just('m');
		case 39:
			return elm$core$Maybe$Just('n');
		case 40:
			return elm$core$Maybe$Just('o');
		case 41:
			return elm$core$Maybe$Just('p');
		case 42:
			return elm$core$Maybe$Just('q');
		case 43:
			return elm$core$Maybe$Just('r');
		case 44:
			return elm$core$Maybe$Just('s');
		case 45:
			return elm$core$Maybe$Just('t');
		case 46:
			return elm$core$Maybe$Just('u');
		case 47:
			return elm$core$Maybe$Just('v');
		case 48:
			return elm$core$Maybe$Just('w');
		case 49:
			return elm$core$Maybe$Just('x');
		case 50:
			return elm$core$Maybe$Just('y');
		case 51:
			return elm$core$Maybe$Just('z');
		case 52:
			return elm$core$Maybe$Just('0');
		case 53:
			return elm$core$Maybe$Just('1');
		case 54:
			return elm$core$Maybe$Just('2');
		case 55:
			return elm$core$Maybe$Just('3');
		case 56:
			return elm$core$Maybe$Just('4');
		case 57:
			return elm$core$Maybe$Just('5');
		case 58:
			return elm$core$Maybe$Just('6');
		case 59:
			return elm$core$Maybe$Just('7');
		case 60:
			return elm$core$Maybe$Just('8');
		case 61:
			return elm$core$Maybe$Just('9');
		case 62:
			return elm$core$Maybe$Just('+');
		case 63:
			return elm$core$Maybe$Just('/');
		default:
			return elm$core$Maybe$Nothing;
	}
};
var elm$core$Basics$modBy = _Basics_modBy;
var elm$core$Basics$pow = _Basics_pow;
var danfishgold$base64_bytes$Decode$threeBytesToFourChars = F3(
	function (a, b, c) {
		var n = ((a * A2(elm$core$Basics$pow, 2, 16)) + (A2(elm$core$Maybe$withDefault, 0, b) * A2(elm$core$Basics$pow, 2, 8))) + A2(elm$core$Maybe$withDefault, 0, c);
		var c4 = _Utils_eq(c, elm$core$Maybe$Nothing) ? elm$core$Maybe$Just('=') : danfishgold$base64_bytes$Basic$intToChar(
			A2(
				elm$core$Basics$modBy,
				A2(elm$core$Basics$pow, 2, 6),
				n));
		var c3 = (_Utils_eq(c, elm$core$Maybe$Nothing) && _Utils_eq(b, elm$core$Maybe$Nothing)) ? elm$core$Maybe$Just('=') : danfishgold$base64_bytes$Basic$intToChar(
			A2(
				elm$core$Basics$modBy,
				A2(elm$core$Basics$pow, 2, 6),
				(n / A2(elm$core$Basics$pow, 2, 6)) | 0));
		var c2 = danfishgold$base64_bytes$Basic$intToChar(
			A2(
				elm$core$Basics$modBy,
				A2(elm$core$Basics$pow, 2, 6),
				(n / A2(elm$core$Basics$pow, 2, 12)) | 0));
		var c1 = danfishgold$base64_bytes$Basic$intToChar(
			(n / A2(elm$core$Basics$pow, 2, 18)) | 0);
		return danfishgold$base64_bytes$Basic$listFromMaybeList(
			_List_fromArray(
				[c1, c2, c3, c4]));
	});
var elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3(elm$core$List$foldr, elm$core$List$cons, ys, xs);
		}
	});
var elm$core$List$concat = function (lists) {
	return A3(elm$core$List$foldr, elm$core$List$append, _List_Nil, lists);
};
var elm$core$String$fromList = _String_fromList;
var danfishgold$base64_bytes$Decode$intsToString = function (ints) {
	return A2(
		elm$core$Maybe$map,
		elm$core$String$fromList,
		A2(
			elm$core$Maybe$map,
			elm$core$List$concat,
			danfishgold$base64_bytes$Basic$listFromMaybeList(
				A2(danfishgold$base64_bytes$Basic$tripleMap, danfishgold$base64_bytes$Decode$threeBytesToFourChars, ints))));
};
var elm$bytes$Bytes$Decode$andThen = F2(
	function (callback, _n0) {
		var decodeA = _n0;
		return F2(
			function (bites, offset) {
				var _n1 = A2(decodeA, bites, offset);
				var newOffset = _n1.a;
				var a = _n1.b;
				var _n2 = callback(a);
				var decodeB = _n2;
				return A2(decodeB, bites, newOffset);
			});
	});
var elm$bytes$Bytes$Decode$fail = _Bytes_decodeFailure;
var danfishgold$base64_bytes$Decode$decoder = function (width) {
	return A2(
		elm$bytes$Bytes$Decode$andThen,
		function (ints) {
			var _n0 = danfishgold$base64_bytes$Decode$intsToString(ints);
			if (_n0.$ === 1) {
				return elm$bytes$Bytes$Decode$fail;
			} else {
				var string = _n0.a;
				return elm$bytes$Bytes$Decode$succeed(string);
			}
		},
		danfishgold$base64_bytes$Decode$intsDecoder(width));
};
var danfishgold$base64_bytes$Decode$fromBytes = function (bytes) {
	return A2(
		elm$bytes$Bytes$Decode$decode,
		danfishgold$base64_bytes$Decode$decoder(
			elm$bytes$Bytes$width(bytes)),
		bytes);
};
var danfishgold$base64_bytes$Base64$fromBytes = danfishgold$base64_bytes$Decode$fromBytes;
var author$project$Image$BMP$encodeWith = F4(
	function (opt, w, h, data) {
		var bytes = elm$bytes$Bytes$Encode$encode(
			elm$bytes$Bytes$Encode$sequence(
				A2(elm$core$List$map, author$project$Image$pixelInt24, data)));
		var result = A4(author$project$Image$BMP$encodeBytesWith, opt, w, h, bytes);
		var imageData = A2(
			elm$core$Maybe$withDefault,
			'',
			danfishgold$base64_bytes$Base64$fromBytes(result));
		return 'data:image/bmp;base64,' + imageData;
	});
var elm$core$List$concatMap = F2(
	function (f, list) {
		return elm$core$List$concat(
			A2(elm$core$List$map, f, list));
	});
var author$project$Logic$Template$SaveLoad$Internal$Util$animationFraming = function (anim) {
	return A2(
		elm$core$List$concatMap,
		function (_n0) {
			var duration = _n0.ax;
			var tileid = _n0.fD;
			return A2(
				elm$core$List$repeat,
				elm$core$Basics$floor((duration / 1000) * 60),
				tileid);
		},
		anim);
};
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$imageOptions = function () {
	var opt = author$project$Image$defaultOptions;
	return _Utils_update(
		opt,
		{ff: 0});
}();
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$tileAnimatedLayerBuilder_ = F2(
	function (constructor, layerData) {
		return elm$core$List$map(
			function (_n0) {
				var _n1 = _n0.a;
				var tileset = _n1.a;
				var anim = _n1.b;
				var data = _n0.b;
				var layerProps = author$project$Logic$Template$SaveLoad$Internal$Util$propertiesWithDefault(layerData);
				var animLutData = author$project$Logic$Template$SaveLoad$Internal$Util$animationFraming(anim);
				var animLength = elm$core$List$length(animLutData);
				return A2(
					elm$core$Basics$composeR,
					author$project$Logic$Template$SaveLoad$Internal$Loader$getTextureTiled(tileset.b0),
					author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
						function (tileSetImage) {
							return A2(
								elm$core$Basics$composeR,
								author$project$Logic$Template$SaveLoad$Internal$Loader$getTextureTiled(
									A4(author$project$Image$BMP$encodeWith, author$project$Logic$Template$SaveLoad$Layer$TileLayer$imageOptions, layerData.bQ, layerData.bm, data)),
								author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
									function (lut) {
										return A2(
											elm$core$Basics$composeR,
											author$project$Logic$Template$SaveLoad$Internal$Loader$getTextureTiled(
												A4(author$project$Image$BMP$encodeWith, author$project$Image$defaultOptions, animLength, 1, animLutData)),
											author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
												function (animLUT) {
													return constructor(
														{
															bS: animLUT,
															bT: animLength,
															cR: data,
															a_: A2(
																author$project$Logic$Template$SaveLoad$Internal$Util$scrollRatio,
																_Utils_eq(
																	A2(elm$core$Dict$get, 'scrollRatio', layerData.fi),
																	elm$core$Maybe$Nothing),
																layerProps),
															aF: tileSetImage,
															aG: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, tileset.da, tileset.c9),
															aH: lut,
															aI: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, layerData.bQ, layerData.bm),
															aJ: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, tileset.ag, tileset.af),
															T: A2(
																elm$core$Maybe$withDefault,
																A3(elm_explorations$linear_algebra$Math$Vector3$vec3, 1, 0, 1),
																author$project$Logic$Template$SaveLoad$Internal$Util$hexColor2Vec3(tileset.ea))
														});
												}));
									}));
						}));
			});
	});
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$tileAnimatedLayerBuilder2 = author$project$Logic$Template$SaveLoad$Layer$TileLayer$tileAnimatedLayerBuilder_(author$project$Logic$Template$SaveLoad$Layer$TileLayer$AnimatedTiles);
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$Tiles = function (a) {
	return {$: 0, a: a};
};
var author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map2 = F3(
	function (f, task1, task2) {
		return A2(
			elm$core$Basics$composeR,
			task1,
			author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
				function (a) {
					return A2(
						elm$core$Basics$composeR,
						task2,
						author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
							function (b) {
								return A2(f, a, b);
							}));
				}));
	});
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$tileStaticLayerBuilder_ = F2(
	function (constructor, layerData) {
		return elm$core$List$map(
			function (_n0) {
				var tileset = _n0.a;
				var data = _n0.b;
				var layerProps = author$project$Logic$Template$SaveLoad$Internal$Util$propertiesWithDefault(layerData);
				return A3(
					author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map2,
					F2(
						function (tileSetImage, lut) {
							return constructor(
								{
									cR: data,
									eD: tileset.eD,
									c8: layerData.c8,
									a_: A2(
										author$project$Logic$Template$SaveLoad$Internal$Util$scrollRatio,
										_Utils_eq(
											A2(elm$core$Dict$get, 'scrollRatio', layerData.fi),
											elm$core$Maybe$Nothing),
										layerProps),
									aF: tileSetImage,
									aG: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, tileset.da, tileset.c9),
									aH: lut,
									aI: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, layerData.bQ, layerData.bm),
									aJ: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, tileset.ag, tileset.af),
									T: A2(
										elm$core$Maybe$withDefault,
										A3(elm_explorations$linear_algebra$Math$Vector3$vec3, 1, 0, 1),
										author$project$Logic$Template$SaveLoad$Internal$Util$hexColor2Vec3(tileset.ea))
								});
						}),
					author$project$Logic$Template$SaveLoad$Internal$Loader$getTextureTiled(tileset.b0),
					author$project$Logic$Template$SaveLoad$Internal$Loader$getTextureTiled(
						A4(author$project$Image$BMP$encodeWith, author$project$Logic$Template$SaveLoad$Layer$TileLayer$imageOptions, layerData.bQ, layerData.bm, data)));
			});
	});
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$tileStaticLayerBuilder2 = author$project$Logic$Template$SaveLoad$Layer$TileLayer$tileStaticLayerBuilder_(author$project$Logic$Template$SaveLoad$Layer$TileLayer$Tiles);
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$tileLayer2_ = function (tileDataWith) {
	return A2(
		elm$core$Basics$composeR,
		A4(
			author$project$Logic$Template$SaveLoad$Layer$TileLayer$splitTileLayerByTileSet2,
			_List_Nil,
			tileDataWith.bl,
			tileDataWith.cR,
			{B: elm$core$Dict$empty, cK: _List_Nil, C: elm$core$Dict$empty}),
		author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
			function (_n0) {
				var tilesets = _n0.z;
				var animated = _n0.B;
				var _static = _n0.C;
				return A2(
					elm$core$Basics$composeR,
					author$project$Logic$Template$SaveLoad$Internal$ResourceTask$sequence(
						_Utils_ap(
							A2(author$project$Logic$Template$SaveLoad$Layer$TileLayer$tileStaticLayerBuilder2, tileDataWith, _static),
							A2(author$project$Logic$Template$SaveLoad$Layer$TileLayer$tileAnimatedLayerBuilder2, tileDataWith, animated))),
					author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
						function (layers) {
							return _Utils_Tuple2(layers, tilesets);
						}));
			}));
};
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$tileLayerNew = function (layerData) {
	return A2(
		elm$core$Basics$composeR,
		author$project$Logic$Template$SaveLoad$Layer$TileLayer$tileLayer2_(layerData),
		author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(elm$core$Tuple$first));
};
var author$project$Logic$Template$SaveLoad$Layer$TileLayer$read = function (_n0) {
	var set = _n0.fu;
	var get = _n0.eH;
	return _Utils_update(
		author$project$Logic$Template$SaveLoad$Internal$Reader$defaultRead,
		{
			bs: author$project$Logic$Template$SaveLoad$Internal$Reader$Async(
				function (info) {
					return A2(
						elm$core$Basics$composeR,
						author$project$Logic$Template$SaveLoad$Layer$TileLayer$tileLayerNew(info),
						author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
							F2(
								function (parsedLayers, _n1) {
									var id = _n1.a;
									var w = _n1.b;
									return _Utils_Tuple2(
										id,
										A2(
											set,
											_Utils_ap(
												get(w),
												parsedLayers),
											w));
								})));
				})
		});
};
var author$project$Logic$Template$SaveLoad$Layer$read = function (spec) {
	var tileLayerSpec = {
		eH: function (_n1) {
			return _List_Nil;
		},
		fu: function (c) {
			return A2(
				author$project$Logic$Component$Singleton$update,
				spec,
				function (layers) {
					return _Utils_ap(
						layers,
						A2(elm$core$List$map, author$project$Logic$Template$SaveLoad$Layer$wrapTileLayer, c));
				});
		}
	};
	var objLayerSpec = function (id) {
		return {
			eH: function (w) {
				return A2(
					author$project$Logic$Template$SaveLoad$Layer$findObjLayer,
					id,
					spec.eH(w));
			},
			fu: function (c) {
				return A2(
					author$project$Logic$Component$Singleton$update,
					spec,
					function (layers) {
						return A4(
							author$project$Logic$Template$SaveLoad$Layer$updateObjLayer,
							id,
							author$project$Logic$Template$Component$Layer$Object(
								_Utils_Tuple2(id, c)),
							_List_Nil,
							layers);
					});
			}
		};
	};
	var imageLayerSpec = {
		eH: function (_n0) {
			return _List_Nil;
		},
		fu: function (c) {
			return A2(
				author$project$Logic$Component$Singleton$update,
				spec,
				function (layers) {
					return _Utils_ap(
						layers,
						A2(elm$core$List$map, author$project$Logic$Template$SaveLoad$Layer$wrapImageLayer, c));
				});
		}
	};
	return A2(
		author$project$Logic$Template$SaveLoad$Internal$Reader$combine,
		author$project$Logic$Template$SaveLoad$Layer$objLayerRead(objLayerSpec),
		A2(
			author$project$Logic$Template$SaveLoad$Internal$Reader$combine,
			author$project$Logic$Template$SaveLoad$Layer$TileLayer$read(tileLayerSpec),
			author$project$Logic$Template$SaveLoad$Layer$ImageLayer$read(imageLayerSpec)));
};
var author$project$Logic$Template$SaveLoad$Internal$Util$extractObjectData = F2(
	function (gid, t_) {
		if (t_.$ === 1) {
			var t = t_.a;
			return A2(
				elm$core$Maybe$andThen,
				function ($) {
					return $.fa;
				},
				A2(elm$core$Dict$get, gid - t.eD, t.d6));
		} else {
			return elm$core$Maybe$Nothing;
		}
	});
var author$project$Logic$Template$SaveLoad$Internal$Util$maybeDo = F3(
	function (f, maybe, b) {
		if (!maybe.$) {
			var a = maybe.a;
			return A2(f, a, b);
		} else {
			return b;
		}
	});
var author$project$Physic$Narrow$AABB$AABB = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var author$project$Physic$Narrow$Common$empty = F3(
	function (p, r, options) {
		return {
			bW: A2(author$project$AltMath$Vector2$vec2, 0, 0),
			l: options.l,
			az: 1 / options.b5,
			bC: p,
			fj: r,
			bO: A2(author$project$AltMath$Vector2$vec2, 0, 0)
		};
	});
var author$project$Physic$Narrow$AABB$rectWith = F5(
	function (x, y, w, h, options) {
		return A2(
			author$project$Physic$Narrow$AABB$AABB,
			A3(
				author$project$Physic$Narrow$Common$empty,
				A2(author$project$AltMath$Vector2$vec2, x, y),
				A2(author$project$AltMath$Vector2$vec2, w / 2, 0),
				options),
			{c3: h / 2});
	});
var author$project$Physic$Narrow$Common$defaultOptions = {l: elm$core$Maybe$Nothing, b5: 0.8, dT: false};
var author$project$Physic$Narrow$AABB$rect = F4(
	function (x, y, w, h) {
		return A5(author$project$Physic$Narrow$AABB$rectWith, x, y, w, h, author$project$Physic$Narrow$Common$defaultOptions);
	});
var author$project$Logic$Template$SaveLoad$Physics$createDynamicAABB = F2(
	function (_n0, o) {
		var x = _n0.n;
		var y = _n0.o;
		var height = _n0.bm;
		var width = _n0.bQ;
		switch (o.$) {
			case 0:
				var data = o.a;
				return elm$core$Maybe$Just(
					A4(author$project$Physic$Narrow$AABB$rect, x, y, 1, 1));
			case 2:
				var data = o.a;
				return elm$core$Maybe$Just(
					function (o_) {
						return A4(author$project$Physic$Narrow$AABB$rect, ((x - (width / 2)) + (o_.bQ / 2)) + o_.n, ((y + (height / 2)) - o_.o) - (o_.bm / 2), o_.bQ, o_.bm);
					}(data));
			case 1:
				var data = o.a;
				return elm$core$Maybe$Just(
					function (o_) {
						return A4(author$project$Physic$Narrow$AABB$rect, ((x - (width / 2)) + (o_.bQ / 2)) + o_.n, ((y + (height / 2)) - o_.o) - (o_.bm / 2), o_.bQ, o_.bm);
					}(data));
			default:
				return elm$core$Maybe$Nothing;
		}
	});
var author$project$Logic$Template$SaveLoad$Physics$createEnvAABB_ = F3(
	function (obj, offSetX, offSetY) {
		var getY = F2(
			function (y, height) {
				return (offSetY - (height / 2)) - y;
			});
		var getX = F2(
			function (x, width) {
				return (offSetX + x) + (width / 2);
			});
		switch (obj.$) {
			case 0:
				var x = obj.a.n;
				var y = obj.a.o;
				return A4(author$project$Physic$Narrow$AABB$rect, offSetX + x, offSetY + y, 0, 0);
			case 1:
				var x = obj.a.n;
				var y = obj.a.o;
				var width = obj.a.bQ;
				var height = obj.a.bm;
				return A4(
					author$project$Physic$Narrow$AABB$rect,
					A2(getX, x, width),
					A2(getY, y, height),
					width,
					height);
			case 2:
				var x = obj.a.n;
				var y = obj.a.o;
				var width = obj.a.bQ;
				var height = obj.a.bm;
				return A4(
					author$project$Physic$Narrow$AABB$rect,
					A2(getX, x, width),
					A2(getY, y, height),
					width,
					height);
			case 3:
				var x = obj.a.n;
				var y = obj.a.o;
				var width = obj.a.bQ;
				var height = obj.a.bm;
				return A4(
					author$project$Physic$Narrow$AABB$rect,
					A2(getX, x, width),
					A2(getY, y, height),
					width,
					height);
			case 4:
				var x = obj.a.n;
				var y = obj.a.o;
				var width = obj.a.bQ;
				var height = obj.a.bm;
				return A4(
					author$project$Physic$Narrow$AABB$rect,
					A2(getX, x, width),
					A2(getY, y, height),
					width,
					height);
			default:
				var x = obj.a.n;
				var y = obj.a.o;
				var width = obj.a.bQ;
				var height = obj.a.bm;
				return A4(
					author$project$Physic$Narrow$AABB$rect,
					A2(getX, x, width),
					A2(getY, y, height),
					width,
					height);
		}
	});
var author$project$Broad$Grid$getCell = F2(
	function (_n0, cellSize) {
		var x = _n0.a;
		var y = _n0.b;
		var _n1 = cellSize;
		var cellWidth = _n1.a;
		var cellHeight = _n1.b;
		var yCell = elm$core$Basics$floor(y / cellHeight);
		var xCell = elm$core$Basics$floor(x / cellWidth);
		return _Utils_Tuple2(xCell, yCell);
	});
var author$project$Broad$Grid$intersectsCellsBoundary = F2(
	function (_n0, _n1) {
		var xmin = _n0.fI;
		var xmax = _n0.fH;
		var ymin = _n0.fK;
		var ymax = _n0.fJ;
		var config = _n1.b;
		var y2 = ymax - config.fI;
		var y1 = ymin - config.fI;
		var x2 = xmax - config.fI;
		var x1 = xmin - config.fI;
		var edgeFix = 1.0e-7;
		var _n2 = A2(
			author$project$Broad$Grid$getCell,
			_Utils_Tuple2(x2 - edgeFix, y2 - edgeFix),
			config.s);
		var x22 = _n2.a;
		var y22 = _n2.b;
		var _n3 = A2(
			author$project$Broad$Grid$getCell,
			_Utils_Tuple2(x1, y1),
			config.s);
		var x11 = _n3.a;
		var y11 = _n3.b;
		return _Utils_Tuple2(
			_Utils_Tuple2(x11, y11),
			_Utils_Tuple2(x22, y22));
	});
var elm$core$Dict$singleton = F2(
	function (key, value) {
		return A5(elm$core$Dict$RBNode_elm_builtin, 1, key, value, elm$core$Dict$RBEmpty_elm_builtin, elm$core$Dict$RBEmpty_elm_builtin);
	});
var author$project$Broad$Grid$setUpdater = F2(
	function (k, v) {
		return A2(
			elm$core$Basics$composeR,
			elm$core$Maybe$map(
				A2(elm$core$Dict$insert, k, v)),
			A2(
				elm$core$Basics$composeR,
				elm$core$Maybe$withDefault(
					A2(elm$core$Dict$singleton, k, v)),
				elm$core$Maybe$Just));
	});
var author$project$Broad$Grid$insert = F3(
	function (boundary, value, grid) {
		var table = grid.a;
		var config = grid.b;
		var key = _Utils_Tuple2(
			_Utils_Tuple2(boundary.fI, boundary.fK),
			_Utils_Tuple2(boundary.fH, boundary.fJ));
		var _n0 = A2(author$project$Broad$Grid$intersectsCellsBoundary, boundary, grid);
		var _n1 = _n0.a;
		var x11 = _n1.a;
		var y11 = _n1.b;
		var _n2 = _n0.b;
		var x22 = _n2.a;
		var y22 = _n2.b;
		var newTable = A3(
			elm$core$List$foldl,
			F2(
				function (cellX, acc1) {
					return A3(
						elm$core$List$foldl,
						F2(
							function (cellY, acc2) {
								return A3(
									elm$core$Dict$update,
									_Utils_Tuple2(cellX, cellY),
									A2(author$project$Broad$Grid$setUpdater, key, value),
									acc2);
							}),
						acc1,
						A2(elm$core$List$range, y11, y22));
				}),
			table,
			A2(elm$core$List$range, x11, x22));
		return _Utils_Tuple2(newTable, config);
	});
var elm$core$Basics$sqrt = _Basics_sqrt;
var author$project$AltMath$Vector2$length = function (_n0) {
	var x = _n0.n;
	var y = _n0.o;
	return elm$core$Basics$sqrt((x * x) + (y * y));
};
var author$project$AltMath$Vector2$toRecord = elm$core$Basics$identity;
var author$project$Physic$Narrow$AABB$boundary = function (_n0) {
	var o = _n0.a;
	var h = _n0.b.c3;
	var w = author$project$AltMath$Vector2$length(o.fj);
	var _n1 = author$project$AltMath$Vector2$toRecord(o.bC);
	var x = _n1.n;
	var y = _n1.o;
	return {fH: x + w, fI: x - w, fJ: y + h, fK: y - h};
};
var author$project$Physic$Narrow$AABB$getFromGeneric__ = F2(
	function (f, _n0) {
		var o = _n0.a;
		return f(o);
	});
var author$project$Physic$Narrow$AABB$getIndex = function (body) {
	return A2(
		author$project$Physic$Narrow$AABB$getFromGeneric__,
		function ($) {
			return $.l;
		},
		body);
};
var author$project$Physic$Narrow$AABB$isStatic = function (body) {
	return A2(
		author$project$Physic$Narrow$AABB$getFromGeneric__,
		A2(
			elm$core$Basics$composeR,
			function ($) {
				return $.az;
			},
			elm$core$Basics$eq(0)),
		body);
};
var author$project$Physic$AABB$addBody = F2(
	function (aabb, engine) {
		var _static = engine.C;
		var indexed = engine.db;
		var insert = F2(
			function (aabb_, grid) {
				return A3(
					author$project$Broad$Grid$insert,
					author$project$Physic$Narrow$AABB$boundary(aabb_),
					aabb_,
					grid);
			});
		var _n0 = author$project$Physic$Narrow$AABB$getIndex(aabb);
		if (!_n0.$) {
			var index = _n0.a;
			return _Utils_update(
				engine,
				{
					db: A3(elm$core$Dict$insert, index, aabb, indexed)
				});
		} else {
			return author$project$Physic$Narrow$AABB$isStatic(aabb) ? _Utils_update(
				engine,
				{
					C: A2(insert, aabb, _static)
				}) : engine;
		}
	});
var author$project$Physic$AABB$getConfig = function (world) {
	return {
		eJ: world.eJ,
		ap: author$project$Broad$Grid$getConfig(world.C)
	};
};
var author$project$Physic$Narrow$AABB$updateGeneric__ = F2(
	function (f, _n0) {
		var o = _n0.a;
		var a = _n0.b;
		return A2(
			author$project$Physic$Narrow$AABB$AABB,
			f(o),
			a);
	});
var author$project$Physic$Narrow$AABB$toStatic = function (body) {
	return A2(
		author$project$Physic$Narrow$AABB$updateGeneric__,
		function (o) {
			return _Utils_update(
				o,
				{az: 0});
		},
		body);
};
var author$project$Logic$Template$SaveLoad$Physics$createEnvAABB = F3(
	function (i, obj, physicsWorld) {
		var config = author$project$Physic$AABB$getConfig(physicsWorld);
		var _n0 = _Utils_Tuple2(config.ap.s.bQ, config.ap.s.bm);
		var cellW = _n0.a;
		var cellH = _n0.b;
		var rows = elm$core$Basics$ceiling(
			elm$core$Basics$abs(config.ap.aP.fJ - config.ap.aP.fK) / cellH);
		var cols = elm$core$Basics$ceiling(
			elm$core$Basics$abs(config.ap.aP.fH - config.ap.aP.fI) / cellW);
		var offSetY = cellH + (cellH * ((rows - 1) - elm$core$Basics$floor(i / cols)));
		var offSetX = A2(elm$core$Basics$modBy, cols, i) * cellW;
		var body_ = author$project$Physic$Narrow$AABB$toStatic(
			A3(author$project$Logic$Template$SaveLoad$Physics$createEnvAABB_, obj, offSetX, offSetY));
		var result = A2(author$project$Physic$AABB$addBody, body_, physicsWorld);
		return result;
	});
var author$project$Logic$Template$SaveLoad$Physics$recursionSpawn = F4(
	function (f, get, dataLeft, _n0) {
		recursionSpawn:
		while (true) {
			var i = _n0.a;
			var cache = _n0.b;
			var acc = _n0.c;
			var spawnMagic = F2(
				function (index, acc_) {
					return A2(
						elm$core$Basics$composeR,
						function ($) {
							return $.dt;
						},
						A2(
							elm$core$List$foldl,
							F2(
								function (o, a) {
									return A2(
										elm$core$Basics$composeR,
										a,
										A2(f, index, o));
								}),
							acc_));
				});
			if (dataLeft.b) {
				var gid_ = dataLeft.a;
				var rest = dataLeft.b;
				var _n2 = _Utils_Tuple2(
					gid_,
					A2(elm$core$Dict$get, gid_, cache));
				_n2$0:
				while (true) {
					if (!_n2.b.$) {
						if (_n2.b.a.$ === 1) {
							if (!_n2.a) {
								break _n2$0;
							} else {
								var _n3 = _n2.b.a;
								var $temp$f = f,
									$temp$get = get,
									$temp$dataLeft = rest,
									$temp$_n0 = _Utils_Tuple3(i + 1, cache, acc);
								f = $temp$f;
								get = $temp$get;
								dataLeft = $temp$dataLeft;
								_n0 = $temp$_n0;
								continue recursionSpawn;
							}
						} else {
							if (!_n2.a) {
								break _n2$0;
							} else {
								var info = _n2.b.a.a;
								var $temp$f = f,
									$temp$get = get,
									$temp$dataLeft = rest,
									$temp$_n0 = _Utils_Tuple3(
									i + 1,
									cache,
									A3(spawnMagic, i, acc, info));
								f = $temp$f;
								get = $temp$get;
								dataLeft = $temp$dataLeft;
								_n0 = $temp$_n0;
								continue recursionSpawn;
							}
						}
					} else {
						if (!_n2.a) {
							break _n2$0;
						} else {
							var gid = _n2.a;
							var _n4 = _n2.b;
							return A2(
								elm$core$Basics$composeR,
								get(gid),
								author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
									function (t) {
										var cacheValue = A2(author$project$Logic$Template$SaveLoad$Internal$Util$extractObjectData, gid, t);
										var newAcc = A2(
											elm$core$Maybe$withDefault,
											acc,
											A2(
												elm$core$Maybe$map,
												A2(spawnMagic, i, acc),
												cacheValue));
										return A4(
											author$project$Logic$Template$SaveLoad$Physics$recursionSpawn,
											f,
											get,
											rest,
											_Utils_Tuple3(
												i + 1,
												A3(elm$core$Dict$insert, gid, cacheValue, cache),
												newAcc));
									}));
						}
					}
				}
				var $temp$f = f,
					$temp$get = get,
					$temp$dataLeft = rest,
					$temp$_n0 = _Utils_Tuple3(i + 1, cache, acc);
				f = $temp$f;
				get = $temp$get;
				dataLeft = $temp$dataLeft;
				_n0 = $temp$_n0;
				continue recursionSpawn;
			} else {
				return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed(acc);
			}
		}
	});
var elm$core$Basics$min = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) < 0) ? x : y;
	});
var author$project$Broad$Grid$combine = F5(
	function (canCombine, k1, v1, k2, v2) {
		var combineValue = A2(canCombine, v1, v2);
		var _n0 = k2;
		var _n1 = _n0.a;
		var xmin2 = _n1.a;
		var ymin2 = _n1.b;
		var _n2 = _n0.b;
		var xmax2 = _n2.a;
		var ymax2 = _n2.b;
		var _n3 = k1;
		var _n4 = _n3.a;
		var xmin1 = _n4.a;
		var ymin1 = _n4.b;
		var _n5 = _n3.b;
		var xmax1 = _n5.a;
		var ymax1 = _n5.b;
		var horizontally = _Utils_eq(ymin1, ymin2) && (_Utils_eq(ymax1, ymax2) && (_Utils_eq(xmin1, xmax2) || _Utils_eq(xmin2, xmax1)));
		var vertically = _Utils_eq(xmin1, xmin2) && (_Utils_eq(xmax1, xmax2) && (_Utils_eq(ymin1, ymax2) || _Utils_eq(ymin2, ymax1)));
		return (vertically || horizontally) ? A2(
			elm$core$Maybe$map,
			function (newValue) {
				return _Utils_Tuple2(
					_Utils_Tuple2(
						_Utils_Tuple2(
							A2(elm$core$Basics$min, xmin1, xmin2),
							A2(elm$core$Basics$min, ymin1, ymin2)),
						_Utils_Tuple2(
							A2(elm$core$Basics$max, xmax1, xmax2),
							A2(elm$core$Basics$max, ymax1, ymax2))),
					newValue);
			},
			combineValue) : elm$core$Maybe$Nothing;
	});
var author$project$Broad$Grid$innerFoldOverAll_ = F6(
	function (validate, apply, a, _n0, skipped, acc) {
		innerFoldOverAll_:
		while (true) {
			var l1 = _n0.a;
			var l2 = _n0.b;
			if (l1.b) {
				var b = l1.a;
				var rest = l1.b;
				var _n2 = A2(validate, a, b);
				if (!_n2.$) {
					var gotCombined = _n2.a;
					var $temp$validate = validate,
						$temp$apply = apply,
						$temp$a = gotCombined,
						$temp$_n0 = _Utils_Tuple2(
						_Utils_ap(l2, rest),
						_List_Nil),
						$temp$skipped = skipped,
						$temp$acc = A4(apply, a, b, gotCombined, acc);
					validate = $temp$validate;
					apply = $temp$apply;
					a = $temp$a;
					_n0 = $temp$_n0;
					skipped = $temp$skipped;
					acc = $temp$acc;
					continue innerFoldOverAll_;
				} else {
					var $temp$validate = validate,
						$temp$apply = apply,
						$temp$a = a,
						$temp$_n0 = _Utils_Tuple2(
						rest,
						A2(elm$core$List$cons, b, l2)),
						$temp$skipped = skipped,
						$temp$acc = acc;
					validate = $temp$validate;
					apply = $temp$apply;
					a = $temp$a;
					_n0 = $temp$_n0;
					skipped = $temp$skipped;
					acc = $temp$acc;
					continue innerFoldOverAll_;
				}
			} else {
				return (elm$core$List$length(skipped) > 0) ? function (_n3) {
					var newRest = _n3.a;
					var newAcc = _n3.b;
					var newSkipped = _n3.c;
					return _Utils_Tuple3(
						l2,
						newAcc,
						_Utils_ap(newRest, newSkipped));
				}(
					A6(
						author$project$Broad$Grid$innerFoldOverAll_,
						validate,
						apply,
						a,
						_Utils_Tuple2(skipped, _List_Nil),
						_List_Nil,
						acc)) : _Utils_Tuple3(
					l2,
					acc,
					A2(elm$core$List$cons, a, skipped));
			}
		}
	});
var author$project$Broad$Grid$foldOverAll_ = F4(
	function (validate, apply, _n0, acc) {
		var l1 = _n0.a;
		var l2 = _n0.b;
		if (l1.b) {
			var a = l1.a;
			var rest = l1.b;
			return function (_n2) {
				var newRest = _n2.a;
				var newAcc = _n2.b;
				var skipped = _n2.c;
				return A4(
					author$project$Broad$Grid$foldOverAll_,
					validate,
					apply,
					_Utils_Tuple2(newRest, skipped),
					newAcc);
			}(
				A6(
					author$project$Broad$Grid$innerFoldOverAll_,
					validate,
					apply,
					a,
					_Utils_Tuple2(rest, _List_Nil),
					l2,
					acc));
		} else {
			return acc;
		}
	});
var author$project$Broad$Grid$getAll_ = A2(
	elm$core$Dict$foldl,
	function (_n0) {
		return elm$core$Dict$union;
	},
	elm$core$Dict$empty);
var author$project$Broad$Grid$keyToBoundary = function (_n0) {
	var _n1 = _n0.a;
	var xmin = _n1.a;
	var ymin = _n1.b;
	var _n2 = _n0.b;
	var xmax = _n2.a;
	var ymax = _n2.b;
	return {fH: xmax, fI: xmin, fJ: ymax, fK: ymin};
};
var author$project$Broad$Grid$remove = F2(
	function (k, grid) {
		var table = grid.a;
		var config = grid.b;
		var _n0 = A2(
			author$project$Broad$Grid$intersectsCellsBoundary,
			author$project$Broad$Grid$keyToBoundary(k),
			grid);
		var _n1 = _n0.a;
		var x11 = _n1.a;
		var y11 = _n1.b;
		var _n2 = _n0.b;
		var x22 = _n2.a;
		var y22 = _n2.b;
		var newTable = A3(
			elm$core$List$foldl,
			F2(
				function (cellX, acc1) {
					return A3(
						elm$core$List$foldl,
						function (cellY) {
							return A2(
								elm$core$Dict$update,
								_Utils_Tuple2(cellX, cellY),
								elm$core$Maybe$map(
									elm$core$Dict$remove(k)));
						},
						acc1,
						A2(elm$core$List$range, y11, y22));
				}),
			table,
			A2(elm$core$List$range, x11, x22));
		return _Utils_Tuple2(newTable, config);
	});
var author$project$Broad$Grid$optimize = F2(
	function (combineValue, grid) {
		var table = grid.a;
		var validate = F2(
			function (_n3, _n4) {
				var k1 = _n3.a;
				var v1 = _n3.b;
				var k2 = _n4.a;
				var v2 = _n4.b;
				return A5(author$project$Broad$Grid$combine, combineValue, k1, v1, k2, v2);
			});
		var apply = F4(
			function (_n0, _n1, _n2, acc) {
				var k1 = _n0.a;
				var k2 = _n1.a;
				var gotCombined = _n2.a;
				var newValue = _n2.b;
				return A3(
					author$project$Broad$Grid$insert,
					author$project$Broad$Grid$keyToBoundary(gotCombined),
					newValue,
					A2(
						author$project$Broad$Grid$remove,
						k2,
						A2(author$project$Broad$Grid$remove, k1, acc)));
			});
		return A4(
			author$project$Broad$Grid$foldOverAll_,
			validate,
			apply,
			_Utils_Tuple2(
				elm$core$Dict$toList(
					author$project$Broad$Grid$getAll_(table)),
				_List_Nil),
			grid);
	});
var author$project$Physic$Narrow$AABB$union = F2(
	function (body1, body2) {
		var o1 = body1.a;
		var o11 = body1.b;
		var o2 = body2.a;
		var o22 = body2.b;
		var b2 = author$project$Physic$Narrow$AABB$boundary(body2);
		var b1 = author$project$Physic$Narrow$AABB$boundary(body1);
		var newShape = _Utils_eq(o1.bC.n, o2.bC.n) ? ((_Utils_cmp(b1.fK, b2.fK) < 0) ? A2(
			author$project$Physic$Narrow$AABB$AABB,
			_Utils_update(
				o1,
				{
					bC: A2(author$project$AltMath$Vector2$vec2, o1.bC.n, ((b2.fJ - b1.fK) / 2) + b1.fK)
				}),
			{c3: o11.c3 + o22.c3}) : A2(
			author$project$Physic$Narrow$AABB$AABB,
			_Utils_update(
				o1,
				{
					bC: A2(author$project$AltMath$Vector2$vec2, o1.bC.n, ((b1.fJ - b2.fK) / 2) + b2.fK)
				}),
			{c3: o11.c3 + o22.c3})) : ((_Utils_cmp(b1.fI, b2.fI) < 0) ? A2(
			author$project$Physic$Narrow$AABB$AABB,
			_Utils_update(
				o1,
				{
					bC: A2(author$project$AltMath$Vector2$vec2, ((b2.fH - b1.fI) / 2) + b1.fI, o1.bC.o),
					fj: A2(author$project$AltMath$Vector2$vec2, o1.fj.n + o2.fj.n, 0)
				}),
			{c3: o11.c3}) : ((_Utils_cmp(b1.fI, b2.fI) > 0) ? A2(
			author$project$Physic$Narrow$AABB$AABB,
			_Utils_update(
				o1,
				{
					bC: A2(author$project$AltMath$Vector2$vec2, ((b1.fH - b2.fI) / 2) + b2.fI, o1.bC.o),
					fj: A2(author$project$AltMath$Vector2$vec2, o1.fj.n + o2.fj.n, 0)
				}),
			{c3: o11.c3}) : A2(author$project$Physic$Narrow$AABB$AABB, o1, o11)));
		return elm$core$Maybe$Just(newShape);
	});
var author$project$Physic$AABB$clear = function (world) {
	return _Utils_update(
		world,
		{
			C: A2(author$project$Broad$Grid$optimize, author$project$Physic$Narrow$AABB$union, world.C)
		});
};
var author$project$Broad$Grid$setConfig = F2(
	function (newConfig, _n0) {
		var table = _n0.a;
		var config = _n0.b;
		var cellW = newConfig.s.bQ;
		var cellH = newConfig.s.bm;
		var _n1 = newConfig.aP;
		var xmin = _n1.fI;
		var xmax = _n1.fH;
		var ymin = _n1.fK;
		var ymax = _n1.fJ;
		return _Utils_Tuple2(
			table,
			_Utils_update(
				config,
				{
					s: _Utils_Tuple2(cellW, cellH),
					be: elm$core$Basics$ceiling(
						elm$core$Basics$abs(xmax - xmin) / cellW),
					bD: elm$core$Basics$ceiling(
						elm$core$Basics$abs(ymax - ymin) / cellH),
					fI: xmin,
					fK: ymin
				}));
	});
var author$project$Physic$AABB$setConfig = F2(
	function (config, world) {
		return _Utils_update(
			world,
			{
				eJ: config.eJ,
				C: A2(author$project$Broad$Grid$setConfig, config.ap, world.C)
			});
	});
var author$project$Physic$Narrow$AABB$setMass = F2(
	function (mass, body) {
		return A2(
			author$project$Physic$Narrow$AABB$updateGeneric__,
			function (o) {
				return _Utils_update(
					o,
					{
						az: (mass > 0) ? (1 / mass) : 0
					});
			},
			body);
	});
var author$project$Physic$Narrow$AABB$withIndex = F2(
	function (i, body) {
		return A2(
			author$project$Physic$Narrow$AABB$updateGeneric__,
			function (o) {
				return _Utils_update(
					o,
					{
						l: elm$core$Maybe$Just(i)
					});
			},
			body);
	});
var elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return elm$core$Maybe$Just(x);
	} else {
		return elm$core$Maybe$Nothing;
	}
};
var author$project$Logic$Template$SaveLoad$Physics$read = function (spec) {
	var updateConfig = F2(
		function (f, info) {
			return A2(
				author$project$Physic$AABB$setConfig,
				f(
					author$project$Physic$AABB$getConfig(info)),
				info);
		});
	var staticBody = author$project$Logic$Template$SaveLoad$Physics$createEnvAABB;
	var setIndex = author$project$Physic$Narrow$AABB$withIndex;
	var indexedBody = author$project$Logic$Template$SaveLoad$Physics$createDynamicAABB;
	var clear = author$project$Physic$AABB$clear;
	var addBody = author$project$Physic$AABB$addBody;
	return _Utils_update(
		author$project$Logic$Template$SaveLoad$Internal$Reader$defaultRead,
		{
			bs: author$project$Logic$Template$SaveLoad$Internal$Reader$Async(
				function (_n0) {
					var data = _n0.cR;
					var getTilesetByGid = _n0.bl;
					return A2(
						elm$core$Basics$composeR,
						A4(
							author$project$Logic$Template$SaveLoad$Physics$recursionSpawn,
							staticBody,
							getTilesetByGid,
							data,
							_Utils_Tuple3(0, elm$core$Dict$empty, elm$core$Basics$identity)),
						author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
							F2(
								function (spawn, _n1) {
									var mId = _n1.a;
									var world = _n1.b;
									var result = clear(
										spawn(
											spec.eH(world)));
									var newWorld = A2(spec.fu, result, world);
									return _Utils_Tuple2(mId, newWorld);
								})));
				}),
			eQ: author$project$Logic$Template$SaveLoad$Internal$Reader$Sync(
				F2(
					function (level, _n2) {
						var entityID = _n2.a;
						var world = _n2.b;
						var info = spec.eH(world);
						var _n3 = author$project$Logic$Template$SaveLoad$Internal$Util$common(level);
						var tileheight = _n3.af;
						var tilewidth = _n3.ag;
						var width = _n3.bQ;
						var height = _n3.bm;
						var boundary = {fH: width * tilewidth, fI: 0, fJ: height * tileheight, fK: 0};
						var withNewConfig = A2(
							updateConfig,
							function (config) {
								return _Utils_update(
									config,
									{
										ap: {
											aP: boundary,
											s: {bm: tileheight, bQ: tilewidth}
										}
									});
							},
							info);
						return _Utils_Tuple2(
							entityID,
							A2(spec.fu, withNewConfig, world));
					})),
			e9: author$project$Logic$Template$SaveLoad$Internal$Reader$Async(
				function (info) {
					var gid = info.b$;
					var getTilesetByGid = info.bl;
					return A2(
						elm$core$Basics$composeR,
						getTilesetByGid(gid),
						author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
							F2(
								function (t_, _n4) {
									var mId = _n4.a;
									var world = _n4.b;
									return A2(
										elm$core$Maybe$withDefault,
										_Utils_Tuple2(mId, world),
										A2(
											elm$core$Maybe$map,
											function (body_) {
												var setMass = A2(
													author$project$Logic$Template$SaveLoad$Internal$Util$maybeDo,
													author$project$Physic$Narrow$AABB$setMass,
													author$project$Logic$Template$SaveLoad$Internal$Util$properties(info).eG('mass'));
												var result = A2(
													addBody,
													setMass(
														A2(setIndex, mId, body_)),
													spec.eH(world));
												return _Utils_Tuple2(
													mId,
													A2(spec.fu, result, world));
											},
											A2(
												elm$core$Maybe$andThen,
												indexedBody(info),
												A2(
													elm$core$Maybe$andThen,
													elm$core$List$head,
													A2(
														elm$core$Maybe$map,
														function ($) {
															return $.dt;
														},
														A2(author$project$Logic$Template$SaveLoad$Internal$Util$extractObjectData, gid, t_))))));
								})));
				})
		});
};
var author$project$Logic$Template$Component$Sprite$emptyComp = function (uAtlas) {
	return {
		cG: 0,
		aF: uAtlas,
		aG: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0),
		bK: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0),
		bL: 0,
		bM: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0),
		bN: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0),
		aJ: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0),
		T: A3(elm_explorations$linear_algebra$Math$Vector3$vec3, 1, 0, 1)
	};
};
var author$project$Logic$Template$SaveLoad$Internal$Util$boolToFloat = function (bool) {
	return bool ? 1 : 0;
};
var author$project$Logic$Template$SaveLoad$Sprite$read = function (spec) {
	return _Utils_update(
		author$project$Logic$Template$SaveLoad$Internal$Reader$defaultRead,
		{
			e9: author$project$Logic$Template$SaveLoad$Internal$Reader$Async(
				function (_n0) {
					var x = _n0.n;
					var y = _n0.o;
					var width = _n0.bQ;
					var height = _n0.bm;
					var gid = _n0.b$;
					var fh = _n0.bZ;
					var fv = _n0.b_;
					var getTilesetByGid = _n0.bl;
					return A2(
						elm$core$Basics$composeR,
						getTilesetByGid(gid),
						author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
							function (t_) {
								if (t_.$ === 1) {
									var t = t_.a;
									var uIndex = gid - t.eD;
									return A2(
										elm$core$Basics$composeR,
										author$project$Logic$Template$SaveLoad$Internal$Loader$getTextureTiled(t.b0),
										author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
											function (tileSetImage) {
												var obj_ = author$project$Logic$Template$Component$Sprite$emptyComp(tileSetImage);
												var obj = _Utils_update(
													obj_,
													{
														cG: t.eD,
														aG: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, t.da, t.c9),
														bK: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, width, height),
														bL: uIndex,
														bM: A2(
															elm_explorations$linear_algebra$Math$Vector2$vec2,
															author$project$Logic$Template$SaveLoad$Internal$Util$boolToFloat(fh),
															author$project$Logic$Template$SaveLoad$Internal$Util$boolToFloat(fv)),
														bN: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, x, y),
														aJ: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, t.ag, t.af),
														T: A2(
															elm$core$Maybe$withDefault,
															A3(elm_explorations$linear_algebra$Math$Vector3$vec3, 1, 0, 1),
															author$project$Logic$Template$SaveLoad$Internal$Util$hexColor2Vec3(t.ea))
													});
												return author$project$Logic$Entity$with(
													_Utils_Tuple2(spec, obj));
											}));
								} else {
									return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$fail(
										A2(author$project$Logic$Launcher$Error, 6002, 'object tile readers works only with single image tilesets'));
								}
							}));
				})
		});
};
var author$project$Logic$Template$Internal$Nonempty = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$core$Array$fromListHelp = F3(
	function (list, nodeList, nodeListSize) {
		fromListHelp:
		while (true) {
			var _n0 = A2(elm$core$Elm$JsArray$initializeFromList, elm$core$Array$branchFactor, list);
			var jsArray = _n0.a;
			var remainingItems = _n0.b;
			if (_Utils_cmp(
				elm$core$Elm$JsArray$length(jsArray),
				elm$core$Array$branchFactor) < 0) {
				return A2(
					elm$core$Array$builderToArray,
					true,
					{j: nodeList, g: nodeListSize, i: jsArray});
			} else {
				var $temp$list = remainingItems,
					$temp$nodeList = A2(
					elm$core$List$cons,
					elm$core$Array$Leaf(jsArray),
					nodeList),
					$temp$nodeListSize = nodeListSize + 1;
				list = $temp$list;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue fromListHelp;
			}
		}
	});
var elm$core$Array$fromList = function (list) {
	if (!list.b) {
		return elm$core$Array$empty;
	} else {
		return A3(elm$core$Array$fromListHelp, list, _List_Nil, 0);
	}
};
var author$project$Logic$Template$Internal$timeline = F2(
	function (first, rest) {
		return A2(
			author$project$Logic$Template$Internal$Nonempty,
			first,
			elm$core$Array$fromList(rest));
	});
var author$project$Logic$Template$Component$TimeLine$emptyComp = function (l) {
	if (l.b) {
		var x = l.a;
		var xs = l.b;
		return {
			bH: 0,
			bJ: A2(author$project$Logic$Template$Internal$timeline, x, xs),
			bM: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0)
		};
	} else {
		return {
			bH: 0,
			bJ: A2(author$project$Logic$Template$Internal$timeline, 0, _List_Nil),
			bM: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0)
		};
	}
};
var author$project$Logic$Template$SaveLoad$TimeLine$read = function (spec) {
	return _Utils_update(
		author$project$Logic$Template$SaveLoad$Internal$Reader$defaultRead,
		{
			e9: author$project$Logic$Template$SaveLoad$Internal$Reader$Async(
				function (_n0) {
					var gid = _n0.b$;
					var getTilesetByGid = _n0.bl;
					return A2(
						elm$core$Basics$composeR,
						getTilesetByGid(gid),
						author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
							function (t_) {
								if (t_.$ === 1) {
									var t = t_.a;
									return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed(
										function (_n2) {
											var entityID = _n2.a;
											var world = _n2.b;
											var index = gid - t.eD;
											var _n3 = A2(
												elm$core$Maybe$map,
												A2(
													elm$core$Basics$composeR,
													author$project$Logic$Template$SaveLoad$Internal$Util$animationFraming,
													A2(
														elm$core$Basics$composeR,
														elm$core$List$map(elm$core$Basics$toFloat),
														author$project$Logic$Template$Component$TimeLine$emptyComp)),
												A2(author$project$Logic$Template$SaveLoad$Internal$Util$animation, t, index));
											if (!_n3.$) {
												var obj = _n3.a;
												return A2(
													author$project$Logic$Entity$with,
													_Utils_Tuple2(spec, obj),
													_Utils_Tuple2(entityID, world));
											} else {
												return _Utils_Tuple2(entityID, world);
											}
										});
								} else {
									return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$fail(
										A2(author$project$Logic$Launcher$Error, 6002, 'object tile readers works only with single image tilesets'));
								}
							}));
				})
		});
};
var author$project$Direction$East = 2;
var author$project$Direction$Neither = 8;
var author$project$Direction$North = 0;
var author$project$Direction$NorthEast = 1;
var author$project$Direction$NorthWest = 7;
var author$project$Direction$South = 4;
var author$project$Direction$SouthEast = 3;
var author$project$Direction$SouthWest = 5;
var author$project$Direction$West = 6;
var author$project$Direction$opposite = function (dir) {
	switch (dir) {
		case 0:
			return 4;
		case 1:
			return 5;
		case 2:
			return 6;
		case 3:
			return 7;
		case 4:
			return 0;
		case 5:
			return 1;
		case 6:
			return 2;
		case 7:
			return 3;
		default:
			return 8;
	}
};
var author$project$Direction$oppositeMirror = function (dir) {
	switch (dir) {
		case 0:
			return {n: 0, o: 1};
		case 1:
			return {n: 1, o: 1};
		case 2:
			return {n: 1, o: 0};
		case 3:
			return {n: 1, o: 1};
		case 4:
			return {n: 0, o: 1};
		case 5:
			return {n: 1, o: 1};
		case 6:
			return {n: 1, o: 0};
		case 7:
			return {n: 1, o: 1};
		default:
			return {n: 0, o: 0};
	}
};
var author$project$Direction$toInt = function (dir) {
	switch (dir) {
		case 0:
			return 1;
		case 1:
			return 2;
		case 2:
			return 3;
		case 3:
			return 4;
		case 4:
			return 5;
		case 5:
			return 6;
		case 6:
			return 7;
		case 7:
			return 8;
		default:
			return 0;
	}
};
var author$project$Direction$toString = function (dir) {
	switch (dir) {
		case 0:
			return _List_fromArray(
				['north', 'N']);
		case 1:
			return _List_fromArray(
				['north-east', 'NE']);
		case 2:
			return _List_fromArray(
				['east', 'E']);
		case 3:
			return _List_fromArray(
				['south-east', 'SE']);
		case 4:
			return _List_fromArray(
				['south', 'S']);
		case 5:
			return _List_fromArray(
				['south-west', 'SW']);
		case 6:
			return _List_fromArray(
				['west', 'W']);
		case 7:
			return _List_fromArray(
				['north-west', 'NW']);
		default:
			return _List_Nil;
	}
};
var author$project$Logic$Template$SaveLoad$TimeLineDict$animLutPlusImageTask = F2(
	function (t, uIndex) {
		var _n0 = A2(author$project$Logic$Template$SaveLoad$Internal$Util$animation, t, uIndex);
		if (!_n0.$) {
			var anim = _n0.a;
			var animLutData = A2(
				elm$core$List$map,
				elm$core$Basics$toFloat,
				author$project$Logic$Template$SaveLoad$Internal$Util$animationFraming(anim));
			return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed(
				author$project$Logic$Template$Component$TimeLine$emptyComp(animLutData));
		} else {
			return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$fail(
				A2(
					author$project$Logic$Launcher$Error,
					6005,
					'Sprite with index ' + (elm$core$String$fromInt(uIndex) + 'must have animation')));
		}
	});
var author$project$Logic$Template$SaveLoad$TimeLineDict$dictGetFirst = F2(
	function (keys, dict) {
		dictGetFirst:
		while (true) {
			if (keys.b) {
				var k = keys.a;
				var rest = keys.b;
				var _n1 = A2(elm$core$Dict$get, k, dict);
				if (!_n1.$) {
					var v = _n1.a;
					return elm$core$Maybe$Just(
						_Utils_Tuple2(k, v));
				} else {
					var $temp$keys = rest,
						$temp$dict = dict;
					keys = $temp$keys;
					dict = $temp$dict;
					continue dictGetFirst;
				}
			} else {
				return elm$core$Maybe$Nothing;
			}
		}
	});
var author$project$Direction$fromString = function (dir) {
	switch (dir) {
		case 'north':
			return 0;
		case 'N':
			return 0;
		case 'north-east':
			return 1;
		case 'NE':
			return 1;
		case 'east':
			return 2;
		case 'E':
			return 2;
		case 'south-east':
			return 3;
		case 'SE':
			return 3;
		case 'south':
			return 4;
		case 'S':
			return 4;
		case 'south-west':
			return 5;
		case 'SW':
			return 5;
		case 'west':
			return 6;
		case 'W':
			return 6;
		case 'north-west':
			return 7;
		case 'NW':
			return 7;
		default:
			return 8;
	}
};
var author$project$Logic$Template$SaveLoad$TimeLineDict$Id = 0;
var author$project$Logic$Template$SaveLoad$TimeLineDict$Tileset = 1;
var elm$parser$Parser$Advanced$map = F2(
	function (func, _n0) {
		var parse = _n0;
		return function (s0) {
			var _n1 = parse(s0);
			if (!_n1.$) {
				var p = _n1.a;
				var a = _n1.b;
				var s1 = _n1.c;
				return A3(
					elm$parser$Parser$Advanced$Good,
					p,
					func(a),
					s1);
			} else {
				var p = _n1.a;
				var x = _n1.b;
				return A2(elm$parser$Parser$Advanced$Bad, p, x);
			}
		};
	});
var elm$parser$Parser$map = elm$parser$Parser$Advanced$map;
var elm$parser$Parser$Advanced$Append = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var elm$parser$Parser$Advanced$oneOfHelp = F3(
	function (s0, bag, parsers) {
		oneOfHelp:
		while (true) {
			if (!parsers.b) {
				return A2(elm$parser$Parser$Advanced$Bad, false, bag);
			} else {
				var parse = parsers.a;
				var remainingParsers = parsers.b;
				var _n1 = parse(s0);
				if (!_n1.$) {
					var step = _n1;
					return step;
				} else {
					var step = _n1;
					var p = step.a;
					var x = step.b;
					if (p) {
						return step;
					} else {
						var $temp$s0 = s0,
							$temp$bag = A2(elm$parser$Parser$Advanced$Append, bag, x),
							$temp$parsers = remainingParsers;
						s0 = $temp$s0;
						bag = $temp$bag;
						parsers = $temp$parsers;
						continue oneOfHelp;
					}
				}
			}
		}
	});
var elm$parser$Parser$Advanced$oneOf = function (parsers) {
	return function (s) {
		return A3(elm$parser$Parser$Advanced$oneOfHelp, s, elm$parser$Parser$Advanced$Empty, parsers);
	};
};
var elm$parser$Parser$oneOf = elm$parser$Parser$Advanced$oneOf;
var author$project$Logic$Template$SaveLoad$TimeLineDict$parseName = function () {
	var _var = elm$parser$Parser$variable(
		{
			eN: function (c) {
				return elm$core$Char$isAlphaNum(c) || (c === '_');
			},
			fq: elm$core$Set$empty,
			bH: elm$core$Char$isAlphaNum
		});
	return A2(
		elm$parser$Parser$keeper,
		A2(
			elm$parser$Parser$keeper,
			A2(
				elm$parser$Parser$keeper,
				A2(
					elm$parser$Parser$ignorer,
					A2(
						elm$parser$Parser$ignorer,
						elm$parser$Parser$succeed(
							F3(
								function (a, b, c) {
									return _Utils_Tuple3(a, b, c);
								})),
						elm$parser$Parser$keyword('anim')),
					elm$parser$Parser$symbol('.')),
				A2(
					elm$parser$Parser$ignorer,
					_var,
					elm$parser$Parser$symbol('.'))),
			A2(
				elm$parser$Parser$ignorer,
				A2(elm$parser$Parser$map, author$project$Direction$fromString, _var),
				elm$parser$Parser$symbol('.'))),
		A2(
			elm$parser$Parser$ignorer,
			elm$parser$Parser$oneOf(
				_List_fromArray(
					[
						A2(
						elm$parser$Parser$map,
						function (_n0) {
							return 0;
						},
						elm$parser$Parser$keyword('id')),
						A2(
						elm$parser$Parser$map,
						function (_n1) {
							return 1;
						},
						elm$parser$Parser$keyword('tileset'))
					])),
			elm$parser$Parser$end));
}();
var elm$core$Dict$isEmpty = function (dict) {
	if (dict.$ === -2) {
		return true;
	} else {
		return false;
	}
};
var elm_explorations$linear_algebra$Math$Vector2$fromRecord = _MJS_v2fromRecord;
var author$project$Logic$Template$SaveLoad$TimeLineDict$fillAnimation = F4(
	function (spec, t, acc, all) {
		fillAnimation:
		while (true) {
			var _n0 = elm$core$Dict$toList(all);
			if (_n0.b) {
				var _n1 = _n0.a;
				var k = _n1.a;
				var v = _n1.b;
				var _n2 = _Utils_Tuple2(
					A2(elm$parser$Parser$run, author$project$Logic$Template$SaveLoad$TimeLineDict$parseName, k),
					v);
				_n2$0:
				while (true) {
					_n2$3:
					while (true) {
						if (!_n2.a.$) {
							if (!_n2.a.a.c) {
								if (_n2.a.a.b === 8) {
									break _n2$0;
								} else {
									if (_n2.b.$ === 1) {
										var _n5 = _n2.a.a;
										var name = _n5.a;
										var dir = _n5.b;
										var _n6 = _n5.c;
										var index = _n2.b.a;
										return A2(
											elm$core$Basics$composeR,
											A2(author$project$Logic$Template$SaveLoad$TimeLineDict$animLutPlusImageTask, t, index),
											author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
												function (info) {
													var rest = A2(elm$core$Dict$remove, k, all);
													var opposite = author$project$Direction$opposite(dir);
													var haveOpposite = A2(
														elm$core$List$map,
														function (k2) {
															return 'anim.' + (name + ('.' + (k2 + '.id')));
														},
														author$project$Direction$toString(opposite));
													var accWithCurrent = A3(
														elm$core$Dict$insert,
														_Utils_Tuple2(
															name,
															author$project$Direction$toInt(dir)),
														info,
														acc);
													var _n7 = A2(author$project$Logic$Template$SaveLoad$TimeLineDict$dictGetFirst, haveOpposite, all);
													if ((!_n7.$) && (_n7.a.b.$ === 1)) {
														var _n8 = _n7.a;
														var k2 = _n8.a;
														var uIndex2 = _n8.b.a;
														return A2(
															elm$core$Basics$composeR,
															A2(author$project$Logic$Template$SaveLoad$TimeLineDict$animLutPlusImageTask, t, uIndex2),
															author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
																function (info2) {
																	return A4(
																		author$project$Logic$Template$SaveLoad$TimeLineDict$fillAnimation,
																		spec,
																		t,
																		A3(
																			elm$core$Dict$insert,
																			_Utils_Tuple2(
																				name,
																				author$project$Direction$toInt(opposite)),
																			info2,
																			accWithCurrent),
																		A2(elm$core$Dict$remove, k2, rest));
																}));
													} else {
														return A4(
															author$project$Logic$Template$SaveLoad$TimeLineDict$fillAnimation,
															spec,
															t,
															A3(
																elm$core$Dict$insert,
																_Utils_Tuple2(
																	name,
																	author$project$Direction$toInt(opposite)),
																_Utils_update(
																	info,
																	{
																		bM: elm_explorations$linear_algebra$Math$Vector2$fromRecord(
																			author$project$Direction$oppositeMirror(dir))
																	}),
																accWithCurrent),
															rest);
													}
												}));
									} else {
										break _n2$3;
									}
								}
							} else {
								if (_n2.a.a.b === 8) {
									break _n2$0;
								} else {
									if (_n2.b.$ === 1) {
										var _n9 = _n2.a.a;
										var _n10 = _n9.c;
										return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$fail(
											A2(author$project$Logic$Launcher$Error, 6004, 'Animation from other tile set not implemented yet'));
									} else {
										break _n2$3;
									}
								}
							}
						} else {
							break _n2$3;
						}
					}
					var $temp$spec = spec,
						$temp$t = t,
						$temp$acc = acc,
						$temp$all = A2(elm$core$Dict$remove, k, all);
					spec = $temp$spec;
					t = $temp$t;
					acc = $temp$acc;
					all = $temp$all;
					continue fillAnimation;
				}
				var _n3 = _n2.a.a;
				var _n4 = _n3.b;
				var $temp$spec = spec,
					$temp$t = t,
					$temp$acc = acc,
					$temp$all = A2(elm$core$Dict$remove, k, all);
				spec = $temp$spec;
				t = $temp$t;
				acc = $temp$acc;
				all = $temp$all;
				continue fillAnimation;
			} else {
				return elm$core$Dict$isEmpty(acc) ? author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed(elm$core$Basics$identity) : author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed(
					author$project$Logic$Entity$with(
						_Utils_Tuple2(
							spec,
							_Utils_Tuple2(
								_Utils_Tuple2('none', 3),
								acc))));
			}
		}
	});
var author$project$Logic$Template$SaveLoad$TimeLineDict$read = function (spec) {
	return _Utils_update(
		author$project$Logic$Template$SaveLoad$Internal$Reader$defaultRead,
		{
			e9: author$project$Logic$Template$SaveLoad$Internal$Reader$Async(
				function (_n0) {
					var properties = _n0.fi;
					var gid = _n0.b$;
					var getTilesetByGid = _n0.bl;
					return A2(
						elm$core$Basics$composeR,
						getTilesetByGid(gid),
						author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
							function (t_) {
								if (t_.$ === 1) {
									var t = t_.a;
									return A4(
										author$project$Logic$Template$SaveLoad$TimeLineDict$fillAnimation,
										spec,
										t,
										elm$core$Dict$empty,
										A2(
											elm$core$Dict$filter,
											F2(
												function (a, _n2) {
													return A2(elm$core$String$startsWith, 'anim', a);
												}),
											properties));
								} else {
									return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$fail(
										A2(author$project$Logic$Launcher$Error, 8003, 'object tile readers works only with single image tilesets'));
								}
							}));
				})
		});
};
var author$project$Logic$Template$Game$Platformer$Common$read = _List_fromArray(
	[
		author$project$Logic$Template$SaveLoad$Sprite$read(author$project$Logic$Template$Component$Sprite$spec),
		author$project$Logic$Template$SaveLoad$Input$read(author$project$Logic$Template$Input$spec),
		author$project$Logic$Template$SaveLoad$Camera$readId(author$project$Logic$Template$Camera$spec),
		author$project$Logic$Template$RenderInfo$read(author$project$Logic$Template$RenderInfo$spec),
		author$project$Logic$Template$SaveLoad$Physics$read(author$project$Logic$Template$Component$Physics$spec),
		author$project$Logic$Template$SaveLoad$TimeLine$read(author$project$Logic$Template$Component$TimeLine$spec),
		author$project$Logic$Template$SaveLoad$TimeLineDict$read(author$project$Logic$Template$Component$TimeLineDict$spec),
		author$project$Logic$Template$SaveLoad$Layer$read(author$project$Logic$Template$Component$Layer$spec),
		author$project$Logic$Template$SaveLoad$AudioSprite$read(author$project$Logic$Template$Component$SFX$spec)
	]);
var author$project$Logic$Template$SaveLoad$Internal$Encode$encoder = F2(
	function (encoders, w) {
		return elm$bytes$Bytes$Encode$sequence(
			A2(
				elm$core$List$map,
				function (f) {
					return f(w);
				},
				encoders));
	});
var author$project$Logic$Template$SaveLoad$Internal$Loader$Level_ = function (a) {
	return {$: 2, a: a};
};
var author$project$Tiled$Level$Hexagonal = function (a) {
	return {$: 3, a: a};
};
var author$project$Tiled$Level$Isometric = function (a) {
	return {$: 1, a: a};
};
var author$project$Tiled$Level$Orthogonal = function (a) {
	return {$: 0, a: a};
};
var author$project$Tiled$Level$Staggered = function (a) {
	return {$: 2, a: a};
};
var author$project$Tiled$Layer$Image = function (a) {
	return {$: 0, a: a};
};
var author$project$Tiled$Layer$InfiniteTile = function (a) {
	return {$: 3, a: a};
};
var author$project$Tiled$Layer$Object = function (a) {
	return {$: 1, a: a};
};
var author$project$Tiled$Layer$Tile = function (a) {
	return {$: 2, a: a};
};
var author$project$Tiled$Layer$ImageData = F9(
	function (id, image, name, opacity, visible, x, y, transparentcolor, properties) {
		return {c8: id, b0: image, x: name, b9: opacity, fi: properties, ea: transparentcolor, A: visible, n: x, o: y};
	});
var author$project$Tiled$Layer$decodeImage = A4(
	NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
	'properties',
	author$project$Tiled$Properties$decode,
	elm$core$Dict$empty,
	A4(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
		'transparentcolor',
		elm$json$Json$Decode$string,
		'none',
		A3(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'y',
			elm$json$Json$Decode$float,
			A3(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'x',
				elm$json$Json$Decode$float,
				A3(
					NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'visible',
					elm$json$Json$Decode$bool,
					A3(
						NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'opacity',
						elm$json$Json$Decode$float,
						A3(
							NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'name',
							elm$json$Json$Decode$string,
							A3(
								NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'image',
								elm$json$Json$Decode$string,
								A3(
									NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'id',
									elm$json$Json$Decode$int,
									elm$json$Json$Decode$succeed(author$project$Tiled$Layer$ImageData))))))))));
var author$project$Tiled$Layer$ObjectData = function (id) {
	return function (draworder) {
		return function (name) {
			return function (objects) {
				return function (opacity) {
					return function (visible) {
						return function (x) {
							return function (y) {
								return function (color) {
									return function (properties) {
										return {bd: color, cV: draworder, c8: id, x: name, dt: objects, b9: opacity, fi: properties, A: visible, n: x, o: y};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var author$project$Tiled$Layer$decodeObjectLayer = A4(
	NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
	'properties',
	author$project$Tiled$Properties$decode,
	elm$core$Dict$empty,
	A4(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
		'color',
		elm$json$Json$Decode$string,
		'none',
		A3(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'y',
			elm$json$Json$Decode$float,
			A3(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'x',
				elm$json$Json$Decode$float,
				A3(
					NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'visible',
					elm$json$Json$Decode$bool,
					A3(
						NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'opacity',
						elm$json$Json$Decode$float,
						A3(
							NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'objects',
							elm$json$Json$Decode$list(author$project$Tiled$Object$decode),
							A3(
								NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'name',
								elm$json$Json$Decode$string,
								A3(
									NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'draworder',
									author$project$Tiled$Layer$decodeDraworder,
									A3(
										NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
										'id',
										elm$json$Json$Decode$int,
										elm$json$Json$Decode$succeed(author$project$Tiled$Layer$ObjectData)))))))))));
var author$project$Tiled$Layer$TileData = function (id) {
	return function (data) {
		return function (name) {
			return function (opacity) {
				return function (visible) {
					return function (width) {
						return function (height) {
							return function (x) {
								return function (y) {
									return function (properties) {
										return {cR: data, bm: height, c8: id, x: name, b9: opacity, fi: properties, A: visible, bQ: width, n: x, o: y};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var elm$core$Basics$neq = _Utils_notEqual;
var author$project$Tiled$Layer$decodeTileData = F2(
	function (encoding, compression) {
		return (compression !== 'none') ? elm$json$Json$Decode$fail('Tile layer compression not supported yet') : ((encoding === 'base64') ? elm$json$Json$Decode$fail('Tile layer encoded not supported yet') : elm$json$Json$Decode$list(elm$json$Json$Decode$int));
	});
var author$project$Tiled$Layer$decodeTile = A2(
	elm$json$Json$Decode$andThen,
	function (_n0) {
		var encoding = _n0.a;
		var compression = _n0.b;
		return A4(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
			'properties',
			author$project$Tiled$Properties$decode,
			elm$core$Dict$empty,
			A3(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'y',
				elm$json$Json$Decode$float,
				A3(
					NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'x',
					elm$json$Json$Decode$float,
					A3(
						NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'height',
						elm$json$Json$Decode$int,
						A3(
							NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'width',
							elm$json$Json$Decode$int,
							A3(
								NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'visible',
								elm$json$Json$Decode$bool,
								A3(
									NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'opacity',
									elm$json$Json$Decode$float,
									A3(
										NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
										'name',
										elm$json$Json$Decode$string,
										A3(
											NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
											'data',
											A2(author$project$Tiled$Layer$decodeTileData, encoding, compression),
											A3(
												NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
												'id',
												elm$json$Json$Decode$int,
												elm$json$Json$Decode$succeed(author$project$Tiled$Layer$TileData)))))))))));
	},
	A4(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
		'compression',
		elm$json$Json$Decode$string,
		'none',
		A4(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
			'encoding',
			elm$json$Json$Decode$string,
			'none',
			elm$json$Json$Decode$succeed(elm$core$Tuple$pair))));
var author$project$Tiled$Layer$TileChunkedData = function (id) {
	return function (chunks) {
		return function (name) {
			return function (opacity) {
				return function (visible) {
					return function (width) {
						return function (height) {
							return function (startx) {
								return function (starty) {
									return function (x) {
										return function (y) {
											return function (properties) {
												return {cN: chunks, bm: height, c8: id, x: name, b9: opacity, fi: properties, fw: startx, fx: starty, A: visible, bQ: width, n: x, o: y};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var author$project$Tiled$Layer$Chunk = F5(
	function (data, height, width, x, y) {
		return {cR: data, bm: height, bQ: width, n: x, o: y};
	});
var author$project$Tiled$Layer$decodeChunk = F2(
	function (encoding, compression) {
		return A3(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'y',
			elm$json$Json$Decode$int,
			A3(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'x',
				elm$json$Json$Decode$int,
				A3(
					NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'width',
					elm$json$Json$Decode$int,
					A3(
						NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'height',
						elm$json$Json$Decode$int,
						A3(
							NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'data',
							A2(author$project$Tiled$Layer$decodeTileData, encoding, compression),
							elm$json$Json$Decode$succeed(author$project$Tiled$Layer$Chunk))))));
	});
var author$project$Tiled$Layer$decodeTileChunkedData = A2(
	elm$json$Json$Decode$andThen,
	function (_n0) {
		var encoding = _n0.a;
		var compression = _n0.b;
		return A4(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
			'properties',
			author$project$Tiled$Properties$decode,
			elm$core$Dict$empty,
			A3(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'y',
				elm$json$Json$Decode$float,
				A3(
					NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'x',
					elm$json$Json$Decode$float,
					A3(
						NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'starty',
						elm$json$Json$Decode$int,
						A3(
							NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'startx',
							elm$json$Json$Decode$int,
							A3(
								NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'height',
								elm$json$Json$Decode$int,
								A3(
									NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'width',
									elm$json$Json$Decode$int,
									A3(
										NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
										'visible',
										elm$json$Json$Decode$bool,
										A3(
											NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
											'opacity',
											elm$json$Json$Decode$float,
											A3(
												NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
												'name',
												elm$json$Json$Decode$string,
												A3(
													NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
													'chunks',
													elm$json$Json$Decode$list(
														A2(author$project$Tiled$Layer$decodeChunk, encoding, compression)),
													A3(
														NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
														'id',
														elm$json$Json$Decode$int,
														elm$json$Json$Decode$succeed(author$project$Tiled$Layer$TileChunkedData)))))))))))));
	},
	A4(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
		'compression',
		elm$json$Json$Decode$string,
		'none',
		A4(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
			'encoding',
			elm$json$Json$Decode$string,
			'none',
			elm$json$Json$Decode$succeed(elm$core$Tuple$pair))));
var author$project$Tiled$Layer$decode = A2(
	elm$json$Json$Decode$andThen,
	function (string) {
		switch (string) {
			case 'tilelayer':
				return elm$json$Json$Decode$oneOf(
					_List_fromArray(
						[
							A2(elm$json$Json$Decode$map, author$project$Tiled$Layer$InfiniteTile, author$project$Tiled$Layer$decodeTileChunkedData),
							A2(elm$json$Json$Decode$map, author$project$Tiled$Layer$Tile, author$project$Tiled$Layer$decodeTile)
						]));
			case 'imagelayer':
				return A2(elm$json$Json$Decode$map, author$project$Tiled$Layer$Image, author$project$Tiled$Layer$decodeImage);
			case 'objectgroup':
				return A2(elm$json$Json$Decode$map, author$project$Tiled$Layer$Object, author$project$Tiled$Layer$decodeObjectLayer);
			default:
				return elm$json$Json$Decode$fail('Invalid layer type: ' + string);
		}
	},
	A2(elm$json$Json$Decode$field, 'type', elm$json$Json$Decode$string));
var author$project$Tiled$Level$LeftDown = 2;
var author$project$Tiled$Level$LeftUp = 3;
var author$project$Tiled$Level$RightDown = 0;
var author$project$Tiled$Level$RightUp = 1;
var author$project$Tiled$Level$decodeRenderOrder = A2(
	elm$json$Json$Decode$andThen,
	function (result) {
		switch (result) {
			case 'right-down':
				return elm$json$Json$Decode$succeed(0);
			case 'right-up':
				return elm$json$Json$Decode$succeed(1);
			case 'left-down':
				return elm$json$Json$Decode$succeed(2);
			case 'left-up':
				return elm$json$Json$Decode$succeed(3);
			default:
				return elm$json$Json$Decode$fail('Unknow render order');
		}
	},
	elm$json$Json$Decode$string);
var author$project$Tiled$Tileset$Source = function (a) {
	return {$: 0, a: a};
};
var author$project$Tiled$Tileset$SourceTileData = F2(
	function (firstgid, source) {
		return {eD: firstgid, dV: source};
	});
var author$project$Tiled$Tileset$decodeSourceTileset = A2(
	elm$json$Json$Decode$map,
	author$project$Tiled$Tileset$Source,
	A3(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'source',
		elm$json$Json$Decode$string,
		A3(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'firstgid',
			elm$json$Json$Decode$int,
			elm$json$Json$Decode$succeed(author$project$Tiled$Tileset$SourceTileData))));
var author$project$Tiled$Tileset$decode = elm$json$Json$Decode$oneOf(
	_List_fromArray(
		[
			author$project$Tiled$Tileset$decodeEmbeddedTileset(
			A2(NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required, 'firstgid', elm$json$Json$Decode$int)),
			author$project$Tiled$Tileset$decodeSourceTileset,
			author$project$Tiled$Tileset$decodeImageCollectionTileData(
			A2(NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required, 'firstgid', elm$json$Json$Decode$int))
		]));
var author$project$Tiled$Level$decodeLevelData = A4(
	NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
	'properties',
	author$project$Tiled$Properties$decode,
	elm$core$Dict$empty,
	A3(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'width',
		elm$json$Json$Decode$int,
		A3(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'version',
			elm$json$Json$Decode$float,
			A3(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'tilewidth',
				elm$json$Json$Decode$int,
				A3(
					NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'tilesets',
					elm$json$Json$Decode$list(author$project$Tiled$Tileset$decode),
					A3(
						NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'tileheight',
						elm$json$Json$Decode$int,
						A3(
							NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'tiledversion',
							elm$json$Json$Decode$string,
							A3(
								NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'renderorder',
								author$project$Tiled$Level$decodeRenderOrder,
								A3(
									NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'nextobjectid',
									elm$json$Json$Decode$int,
									A3(
										NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
										'layers',
										elm$json$Json$Decode$list(author$project$Tiled$Layer$decode),
										A3(
											NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
											'infinite',
											elm$json$Json$Decode$bool,
											A3(
												NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
												'height',
												elm$json$Json$Decode$int,
												A4(
													NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
													'backgroundcolor',
													elm$json$Json$Decode$string,
													'',
													elm$json$Json$Decode$succeed(
														function (backgroundcolor) {
															return function (height) {
																return function (infinite) {
																	return function (layers) {
																		return function (nextobjectid) {
																			return function (renderorder) {
																				return function (tiledversion) {
																					return function (tileheight) {
																						return function (tilesets) {
																							return function (tilewidth) {
																								return function (version) {
																									return function (width) {
																										return function (props) {
																											return {W: backgroundcolor, bm: height, Y: infinite, b3: layers, _: nextobjectid, fi: props, ab: renderorder, ae: tiledversion, af: tileheight, z: tilesets, ag: tilewidth, ai: version, bQ: width};
																										};
																									};
																								};
																							};
																						};
																					};
																				};
																			};
																		};
																	};
																};
															};
														}))))))))))))));
var author$project$Tiled$Level$X = 0;
var author$project$Tiled$Level$Y = 1;
var author$project$Tiled$Level$decodeAxis = A2(
	elm$json$Json$Decode$andThen,
	function (a) {
		switch (a) {
			case 'x':
				return elm$json$Json$Decode$succeed(0);
			case 'y':
				return elm$json$Json$Decode$succeed(1);
			default:
				return elm$json$Json$Decode$fail('Uknown axis `' + (a + '`'));
		}
	},
	elm$json$Json$Decode$string);
var author$project$Tiled$Level$Even = 1;
var author$project$Tiled$Level$Odd = 0;
var author$project$Tiled$Level$decodeOddOrEven = A2(
	elm$json$Json$Decode$andThen,
	function (a) {
		switch (a) {
			case 'odd':
				return elm$json$Json$Decode$succeed(0);
			case 'even':
				return elm$json$Json$Decode$succeed(1);
			default:
				return elm$json$Json$Decode$fail('Uknown axis `' + (a + '`'));
		}
	},
	elm$json$Json$Decode$string);
var author$project$Tiled$Level$decodeStaggeredlevelData = A3(
	NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'staggerindex',
	author$project$Tiled$Level$decodeOddOrEven,
	A3(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'staggeraxis',
		author$project$Tiled$Level$decodeAxis,
		A3(
			NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'hexsidelength',
			elm$json$Json$Decode$int,
			A4(
				NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
				'properties',
				author$project$Tiled$Properties$decode,
				elm$core$Dict$empty,
				A3(
					NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'width',
					elm$json$Json$Decode$int,
					A3(
						NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'version',
						elm$json$Json$Decode$float,
						A3(
							NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'tilewidth',
							elm$json$Json$Decode$int,
							A3(
								NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'tilesets',
								elm$json$Json$Decode$list(author$project$Tiled$Tileset$decode),
								A3(
									NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'tileheight',
									elm$json$Json$Decode$int,
									A3(
										NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
										'tiledversion',
										elm$json$Json$Decode$string,
										A3(
											NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
											'renderorder',
											author$project$Tiled$Level$decodeRenderOrder,
											A3(
												NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
												'nextobjectid',
												elm$json$Json$Decode$int,
												A3(
													NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
													'layers',
													elm$json$Json$Decode$list(author$project$Tiled$Layer$decode),
													A3(
														NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
														'infinite',
														elm$json$Json$Decode$bool,
														A3(
															NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
															'height',
															elm$json$Json$Decode$int,
															A4(
																NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$optional,
																'backgroundcolor',
																elm$json$Json$Decode$string,
																'',
																elm$json$Json$Decode$succeed(
																	function (backgroundcolor) {
																		return function (height) {
																			return function (infinite) {
																				return function (layers) {
																					return function (nextobjectid) {
																						return function (renderorder) {
																							return function (tiledversion) {
																								return function (tileheight) {
																									return function (tilesets) {
																										return function (tilewidth) {
																											return function (version) {
																												return function (width) {
																													return function (props) {
																														return function (hexsidelength) {
																															return function (staggeraxis) {
																																return function (staggerindex) {
																																	return {W: backgroundcolor, bm: height, c6: hexsidelength, Y: infinite, b3: layers, _: nextobjectid, fi: props, ab: renderorder, d_: staggeraxis, d$: staggerindex, ae: tiledversion, af: tileheight, z: tilesets, ag: tilewidth, ai: version, bQ: width};
																																};
																															};
																														};
																													};
																												};
																											};
																										};
																									};
																								};
																							};
																						};
																					};
																				};
																			};
																		};
																	})))))))))))))))));
var author$project$Tiled$Level$decode = A2(
	elm$json$Json$Decode$andThen,
	function (orientation) {
		switch (orientation) {
			case 'orthogonal':
				return A2(elm$json$Json$Decode$map, author$project$Tiled$Level$Orthogonal, author$project$Tiled$Level$decodeLevelData);
			case 'isometric':
				return A2(elm$json$Json$Decode$map, author$project$Tiled$Level$Isometric, author$project$Tiled$Level$decodeLevelData);
			case 'staggered':
				return A2(elm$json$Json$Decode$map, author$project$Tiled$Level$Staggered, author$project$Tiled$Level$decodeStaggeredlevelData);
			case 'hexagonal':
				return A2(elm$json$Json$Decode$map, author$project$Tiled$Level$Hexagonal, author$project$Tiled$Level$decodeStaggeredlevelData);
			default:
				return elm$json$Json$Decode$fail('Unknown orientation `' + (orientation + '`'));
		}
	},
	A2(elm$json$Json$Decode$field, 'orientation', elm$json$Json$Decode$string));
var author$project$Logic$Template$SaveLoad$Internal$Loader$getLevel = function (url) {
	return A2(
		elm$core$Basics$composeR,
		elm$core$Task$andThen(
			function (d) {
				var _n0 = A2(elm$core$Dict$get, url, d.c);
				if ((!_n0.$) && (_n0.a.$ === 2)) {
					var r = _n0.a.a;
					return elm$core$Task$succeed(
						_Utils_Tuple2(r, d));
				} else {
					return A2(
						elm$core$Task$map,
						function (r) {
							return _Utils_Tuple2(r, d);
						},
						A2(author$project$Logic$Template$SaveLoad$Internal$Loader$getJson_, url, author$project$Tiled$Level$decode));
				}
			}),
		elm$core$Task$map(
			function (_n1) {
				var resp = _n1.a;
				var d = _n1.b;
				var relUrl = A2(
					elm$core$String$join,
					'/',
					elm$core$List$reverse(
						A2(
							elm$core$List$cons,
							'',
							A2(
								elm$core$List$drop,
								1,
								elm$core$List$reverse(
									A2(elm$core$String$split, '/', url))))));
				return _Utils_Tuple2(
					resp,
					_Utils_update(
						d,
						{
							c: A3(
								elm$core$Dict$insert,
								url,
								author$project$Logic$Template$SaveLoad$Internal$Loader$Level_(resp),
								d.c),
							H: relUrl
						}));
			}));
};
var author$project$Logic$Template$SaveLoad$Internal$ResourceTask$init = elm$core$Task$succeed(
	{c: elm$core$Dict$empty, H: ''});
var author$project$Logic$Template$SaveLoad$Internal$TexturesManager$empty = _List_Nil;
var elm$bytes$Bytes$Encode$I8 = function (a) {
	return {$: 0, a: a};
};
var elm$bytes$Bytes$Encode$signedInt8 = elm$bytes$Bytes$Encode$I8;
var author$project$Logic$Template$SaveLoad$Internal$TexturesManager$encoder = function (textures) {
	var bytesEndode = function (image) {
		return elm$bytes$Bytes$Encode$sequence(
			_List_fromArray(
				[
					A2(
					elm$bytes$Bytes$Encode$unsignedInt32,
					1,
					elm$bytes$Bytes$width(image)),
					elm$bytes$Bytes$Encode$bytes(image)
				]));
	};
	var itemEncoder = function (item_) {
		switch (item_.$) {
			case 0:
				var firstgid = item_.a.eD;
				var tilecount = item_.a.au;
				var image = item_.a.b0;
				return elm$bytes$Bytes$Encode$sequence(
					_List_fromArray(
						[
							elm$bytes$Bytes$Encode$signedInt8(0),
							author$project$Logic$Template$SaveLoad$Internal$Encode$id(firstgid),
							author$project$Logic$Template$SaveLoad$Internal$Encode$id(tilecount),
							bytesEndode(image)
						]));
			case 1:
				var id = item_.a.c8;
				var image = item_.a.b0;
				return elm$bytes$Bytes$Encode$sequence(
					_List_fromArray(
						[
							elm$bytes$Bytes$Encode$signedInt8(1),
							author$project$Logic$Template$SaveLoad$Internal$Encode$id(id),
							bytesEndode(image)
						]));
			default:
				var id = item_.a.c8;
				var image = item_.a.b0;
				var w = item_.a.ed;
				var h = item_.a.c3;
				return elm$bytes$Bytes$Encode$sequence(
					_List_fromArray(
						[
							elm$bytes$Bytes$Encode$signedInt8(2),
							author$project$Logic$Template$SaveLoad$Internal$Encode$id(id),
							author$project$Logic$Template$SaveLoad$Internal$Encode$id(w),
							author$project$Logic$Template$SaveLoad$Internal$Encode$id(h),
							bytesEndode(image)
						]));
		}
	};
	return A2(author$project$Logic$Template$SaveLoad$Internal$Encode$list, itemEncoder, textures);
};
var author$project$Logic$Template$SaveLoad$Internal$Loader$Bytes_ = function (a) {
	return {$: 4, a: a};
};
var elm$http$Http$bytesResolver = A2(_Http_expect, 'arraybuffer', _Http_toDataView);
var author$project$Logic$Template$SaveLoad$Internal$Loader$getBytes_ = function (url) {
	return elm$http$Http$task(
		{
			bU: elm$http$Http$emptyBody,
			c4: _List_Nil,
			dp: 'GET',
			dM: elm$http$Http$bytesResolver(
				function (response) {
					switch (response.$) {
						case 4:
							var meta = response.a;
							var body = response.b;
							return elm$core$Result$Ok(body);
						case 0:
							var info = response.a;
							return elm$core$Result$Err(
								A2(author$project$Logic$Launcher$Error, 4000, info));
						case 1:
							return elm$core$Result$Err(
								A2(author$project$Logic$Launcher$Error, 4001, 'Timeout'));
						case 2:
							return elm$core$Result$Err(
								A2(author$project$Logic$Launcher$Error, 4002, 'NetworkError'));
						default:
							var statusCode = response.a.d0;
							return elm$core$Result$Err(
								A2(
									author$project$Logic$Launcher$Error,
									4003,
									'BadStatus:' + elm$core$String$fromInt(statusCode)));
					}
				}),
			d8: elm$core$Maybe$Nothing,
			H: url
		});
};
var author$project$Logic$Template$SaveLoad$Internal$Loader$getBytesTiled = function (url) {
	return A2(
		elm$core$Basics$composeR,
		elm$core$Task$andThen(
			function (d) {
				var _n0 = A2(elm$core$Dict$get, 'bytes::' + url, d.c);
				if ((!_n0.$) && (_n0.a.$ === 4)) {
					var r = _n0.a.a;
					return elm$core$Task$succeed(
						_Utils_Tuple2(r, d));
				} else {
					return A2(
						elm$core$Task$map,
						function (r) {
							return _Utils_Tuple2(r, d);
						},
						author$project$Logic$Template$SaveLoad$Internal$Loader$getBytes_(
							_Utils_ap(d.H, url)));
				}
			}),
		elm$core$Task$map(
			function (_n1) {
				var resp = _n1.a;
				var d = _n1.b;
				return _Utils_Tuple2(
					resp,
					_Utils_update(
						d,
						{
							c: A3(
								elm$core$Dict$insert,
								'bytes::' + url,
								author$project$Logic$Template$SaveLoad$Internal$Loader$Bytes_(resp),
								d.c)
						}));
			}));
};
var author$project$Logic$Template$SaveLoad$Internal$TexturesManager$Image_ = function (a) {
	return {$: 1, a: a};
};
var author$project$Logic$Template$SaveLoad$Internal$TexturesManager$imagesReader = F3(
	function (mapper, acc, info) {
		return A2(
			elm$core$Basics$composeR,
			author$project$Logic$Template$SaveLoad$Internal$Loader$getBytesTiled(info.b0),
			author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
				function (image) {
					var newAcc = A2(
						elm$core$Basics$composeR,
						acc,
						elm$core$List$cons(
							author$project$Logic$Template$SaveLoad$Internal$TexturesManager$Image_(
								{c8: info.c8, b0: image})));
					return elm$core$Tuple$mapSecond(
						A2(author$project$Logic$Component$Singleton$update, mapper, newAcc));
				}));
	});
var author$project$Logic$Template$SaveLoad$Internal$TexturesManager$Atlas_ = function (a) {
	return {$: 0, a: a};
};
var author$project$Logic$Template$SaveLoad$Internal$TexturesManager$tilesetReader = F3(
	function (mapper, acc, l) {
		if (l.b) {
			switch (l.a.$) {
				case 0:
					var source = l.a.a.dV;
					var firstgid = l.a.a.eD;
					var rest = l.b;
					return A2(
						elm$core$Basics$composeR,
						A2(author$project$Logic$Template$SaveLoad$Internal$Loader$getTileset, source, firstgid),
						author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
							function (tileset) {
								switch (tileset.$) {
									case 0:
										var info = tileset.a;
										return _Utils_eq(info.dV, source) ? author$project$Logic$Template$SaveLoad$Internal$ResourceTask$fail(
											A2(author$project$Logic$Launcher$Error, 7001, 'Downloading Tileset Source, and got back Source - Infinity recursion')) : A3(
											author$project$Logic$Template$SaveLoad$Internal$TexturesManager$tilesetReader,
											mapper,
											acc,
											A2(elm$core$List$cons, tileset, rest));
									case 1:
										return A3(
											author$project$Logic$Template$SaveLoad$Internal$TexturesManager$tilesetReader,
											mapper,
											acc,
											A2(elm$core$List$cons, tileset, rest));
									default:
										return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$fail(
											A2(author$project$Logic$Launcher$Error, 7102, 'Tileset.ImageCollection not yet supported'));
								}
							}));
				case 1:
					var info = l.a.a;
					var rest = l.b;
					return A2(
						elm$core$Basics$composeR,
						author$project$Logic$Template$SaveLoad$Internal$Loader$getBytesTiled(info.b0),
						author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
							function (image) {
								return A3(
									author$project$Logic$Template$SaveLoad$Internal$TexturesManager$tilesetReader,
									mapper,
									A2(
										elm$core$Basics$composeR,
										acc,
										function (all) {
											var newItem = author$project$Logic$Template$SaveLoad$Internal$TexturesManager$Atlas_(
												{eD: info.eD, b0: image, au: info.au});
											return A2(elm$core$List$cons, newItem, all);
										}),
									rest);
							}));
				default:
					return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$fail(
						A2(author$project$Logic$Launcher$Error, 7003, 'Tileset.ImageCollection not yet supported'));
			}
		} else {
			return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed(
				elm$core$Tuple$mapSecond(
					A2(author$project$Logic$Component$Singleton$update, mapper, acc)));
		}
	});
var author$project$Logic$Template$SaveLoad$Internal$Util$tilesets = function (level) {
	switch (level.$) {
		case 0:
			var info = level.a;
			return info.z;
		case 1:
			var info = level.a;
			return info.z;
		case 2:
			var info = level.a;
			return info.z;
		default:
			var info = level.a;
			return info.z;
	}
};
var author$project$Logic$Template$SaveLoad$Internal$TexturesManager$read = function () {
	var spec_ = {
		eH: elm$core$Basics$identity,
		fu: F2(
			function (c, _n0) {
				return c;
			})
	};
	return _Utils_update(
		author$project$Logic$Template$SaveLoad$Internal$Reader$defaultRead,
		{
			bp: author$project$Logic$Template$SaveLoad$Internal$Reader$Async(
				function (image) {
					return A3(author$project$Logic$Template$SaveLoad$Internal$TexturesManager$imagesReader, spec_, elm$core$Basics$identity, image);
				}),
			eQ: author$project$Logic$Template$SaveLoad$Internal$Reader$Async(
				function (level) {
					return A3(
						author$project$Logic$Template$SaveLoad$Internal$TexturesManager$tilesetReader,
						spec_,
						elm$core$Basics$identity,
						author$project$Logic$Template$SaveLoad$Internal$Util$tilesets(level));
				})
		});
}();
var author$project$Logic$Template$SaveLoad$Internal$Reader$combineListInTask = F4(
	function (getKey, arg, readers, acc) {
		combineListInTask:
		while (true) {
			if (readers.b) {
				var item = readers.a;
				var rest = readers.b;
				var _n1 = getKey(item);
				switch (_n1.$) {
					case 2:
						var $temp$getKey = getKey,
							$temp$arg = arg,
							$temp$readers = rest,
							$temp$acc = acc;
						getKey = $temp$getKey;
						arg = $temp$arg;
						readers = $temp$readers;
						acc = $temp$acc;
						continue combineListInTask;
					case 0:
						var f = _n1.a;
						var $temp$getKey = getKey,
							$temp$arg = arg,
							$temp$readers = rest,
							$temp$acc = A2(f, arg, acc);
						getKey = $temp$getKey;
						arg = $temp$arg;
						readers = $temp$readers;
						acc = $temp$acc;
						continue combineListInTask;
					default:
						var f = _n1.a;
						return A2(
							elm$core$Basics$composeR,
							f(arg),
							author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
								function (f1) {
									return A4(
										author$project$Logic$Template$SaveLoad$Internal$Reader$combineListInTask,
										getKey,
										arg,
										rest,
										f1(acc));
								}));
				}
			} else {
				return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed(acc);
			}
		}
	});
var author$project$Logic$Template$SaveLoad$Internal$Reader$tileDataWith = F2(
	function (getTilesetByGid, tileData) {
		return {cR: tileData.cR, bl: getTilesetByGid, bm: tileData.bm, c8: tileData.c8, x: tileData.x, b9: tileData.b9, fi: tileData.fi, A: tileData.A, bQ: tileData.bQ, n: tileData.n, o: tileData.o};
	});
var author$project$Logic$Template$SaveLoad$Internal$Util$getTilesetByGid = F2(
	function (tilesets_, gid) {
		var _n0 = A2(author$project$Logic$Template$SaveLoad$Internal$Util$tilesetById, tilesets_, gid);
		if (!_n0.$) {
			if (!_n0.a.$) {
				var info = _n0.a.a;
				return A2(author$project$Logic$Template$SaveLoad$Internal$Loader$getTileset, info.dV, info.eD);
			} else {
				var t = _n0.a;
				return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed(t);
			}
		} else {
			return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$fail(
				A2(
					author$project$Logic$Launcher$Error,
					5001,
					'Not found Tileset for GID:' + elm$core$String$fromInt(gid)));
		}
	});
var author$project$Logic$Template$SaveLoad$Internal$Util$objFix = F2(
	function (levelHeight, obj) {
		switch (obj.$) {
			case 0:
				return obj;
			case 1:
				return obj;
			case 2:
				return obj;
			case 3:
				return obj;
			case 4:
				return obj;
			default:
				var c = obj.a;
				return author$project$Tiled$Object$Tile(
					_Utils_update(
						c,
						{n: c.n + (c.bQ / 2), o: (levelHeight - c.o) + (c.bm / 2)}));
		}
	});
var author$project$Logic$Entity$create = F2(
	function (id, world) {
		return _Utils_Tuple2(id, world);
	});
var author$project$Logic$Template$SaveLoad$Internal$Reader$pointData = F2(
	function (layer, a) {
		return {c8: a.c8, M: a.M, aV: layer, x: a.x, fi: a.fi, S: a.S, A: a.A, n: a.n, o: a.o};
	});
var author$project$Logic$Template$SaveLoad$Internal$Reader$polygonData = F2(
	function (layer, a) {
		return {bm: a.bm, c8: a.c8, M: a.M, aV: layer, x: a.x, dA: a.dA, fi: a.fi, S: a.S, A: a.A, bQ: a.bQ, n: a.n, o: a.o};
	});
var author$project$Logic$Template$SaveLoad$Internal$Reader$rectangleData = F2(
	function (layer, a) {
		return {bm: a.bm, c8: a.c8, M: a.M, aV: layer, x: a.x, fi: a.fi, S: a.S, A: a.A, bQ: a.bQ, n: a.n, o: a.o};
	});
var author$project$Logic$Template$SaveLoad$Internal$Reader$tileArgs = F4(
	function (objectData, a, c, d) {
		return {bY: c.bY, bZ: c.bZ, b_: c.b_, bl: d, b$: c.b$, bm: a.bm, c8: a.c8, M: a.M, aV: objectData, x: a.x, fi: a.fi, S: a.S, A: a.A, bQ: a.bQ, n: a.n, o: a.o};
	});
var author$project$Logic$Template$SaveLoad$TiledReader$validateAndUpdate = F3(
	function (_n0, newECS, newLayerECS) {
		var layerECS = _n0.a;
		var info = _n0.b;
		return _Utils_eq(layerECS, newLayerECS) ? _Utils_Tuple2(
			layerECS,
			_Utils_update(
				info,
				{am: newECS, K: info.K + 1})) : _Utils_Tuple2(
			newLayerECS,
			_Utils_update(
				info,
				{am: newECS, K: info.K + 1}));
	});
var author$project$Tiled$flippedDiagonalFlag = 536870912;
var author$project$Tiled$flippedHorizontalFlag = 2147483648;
var author$project$Tiled$flippedVerticalFlag = 1073741824;
var elm$core$Bitwise$complement = _Bitwise_complement;
var elm$core$Bitwise$or = _Bitwise_or;
var author$project$Tiled$cleanGid = function (globalTileId) {
	return globalTileId & (~(author$project$Tiled$flippedDiagonalFlag | (author$project$Tiled$flippedVerticalFlag | author$project$Tiled$flippedHorizontalFlag)));
};
var author$project$Tiled$flippedDiagonally = function (globalTileId) {
	return globalTileId & author$project$Tiled$flippedDiagonalFlag;
};
var author$project$Tiled$flippedHorizontally = function (globalTileId) {
	return globalTileId & author$project$Tiled$flippedHorizontalFlag;
};
var author$project$Tiled$flippedVertically = function (globalTileId) {
	return globalTileId & author$project$Tiled$flippedVerticalFlag;
};
var author$project$Tiled$gidInfo = function (gid) {
	return {
		bY: author$project$Tiled$flippedDiagonally(gid),
		bZ: author$project$Tiled$flippedHorizontally(gid),
		b_: author$project$Tiled$flippedVertically(gid),
		b$: author$project$Tiled$cleanGid(gid)
	};
};
var author$project$Logic$Template$SaveLoad$TiledReader$objectLayerParser = F5(
	function (fix, readers, info_, objectData, start) {
		var readFor = F3(
			function (f, args, _n4) {
				var layerECS = _n4.a;
				var acc = _n4.b;
				return A2(
					elm$core$Basics$composeR,
					A4(
						author$project$Logic$Template$SaveLoad$Internal$Reader$combineListInTask,
						f,
						args,
						readers,
						A2(author$project$Logic$Entity$create, acc.K, acc.am)),
					author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
						function (_n3) {
							var newECS = _n3.b;
							return A3(
								author$project$Logic$Template$SaveLoad$TiledReader$validateAndUpdate,
								_Utils_Tuple2(layerECS, acc),
								newECS,
								A2(author$project$Logic$Entity$create, acc.K, layerECS).b);
						}));
			});
		return A3(
			elm$core$Basics$composeR,
			A2(
				elm$core$List$foldl,
				function (obj) {
					var _n0 = fix(obj);
					switch (_n0.$) {
						case 0:
							var common = _n0.a;
							return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
								A2(
									readFor,
									function ($) {
										return $.bx;
									},
									A2(author$project$Logic$Template$SaveLoad$Internal$Reader$pointData, objectData, common)));
						case 1:
							var info = _n0.a;
							return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
								A2(
									readFor,
									function ($) {
										return $.bA;
									},
									A2(author$project$Logic$Template$SaveLoad$Internal$Reader$rectangleData, objectData, info)));
						case 2:
							var info = _n0.a;
							return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
								A2(
									readFor,
									function ($) {
										return $.bw;
									},
									A2(author$project$Logic$Template$SaveLoad$Internal$Reader$rectangleData, objectData, info)));
						case 3:
							var info = _n0.a;
							return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
								A2(
									readFor,
									function ($) {
										return $.bz;
									},
									A2(author$project$Logic$Template$SaveLoad$Internal$Reader$polygonData, objectData, info)));
						case 4:
							var info = _n0.a;
							return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
								A2(
									readFor,
									function ($) {
										return $.by;
									},
									A2(author$project$Logic$Template$SaveLoad$Internal$Reader$polygonData, objectData, info)));
						default:
							var data = _n0.a;
							return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
								function (_n1) {
									var layerECS = _n1.a;
									var info = _n1.b;
									var args = A4(
										author$project$Logic$Template$SaveLoad$Internal$Reader$tileArgs,
										objectData,
										data,
										author$project$Tiled$gidInfo(data.b$),
										author$project$Logic$Template$SaveLoad$Internal$Util$getTilesetByGid(info.z));
									return A3(
										readFor,
										function ($) {
											return $.e9;
										},
										args,
										_Utils_Tuple2(layerECS, info));
								});
					}
				},
				A2(
					author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed,
					_Utils_Tuple2(author$project$Logic$Component$empty, info_),
					start)),
			author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
				function (_n2) {
					var info = _n2.b;
					return info;
				}),
			objectData.dt);
	});
var author$project$Logic$Template$SaveLoad$TiledReader$parse = F4(
	function (emptyECS, readers, level, start) {
		var readFor = F3(
			function (f, args, acc) {
				return A2(
					elm$core$Basics$composeR,
					A4(
						author$project$Logic$Template$SaveLoad$Internal$Reader$combineListInTask,
						f,
						args,
						readers,
						_Utils_Tuple2(acc.K, acc.am)),
					author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
						function (_n3) {
							var idSource = _n3.a;
							var ecs = _n3.b;
							return _Utils_update(
								acc,
								{am: ecs, K: idSource});
						}));
			});
		var fix = author$project$Logic$Template$SaveLoad$Internal$Util$objFix(
			function (_n2) {
				var height = _n2.bm;
				var tileheight = _n2.af;
				return tileheight * height;
			}(
				author$project$Logic$Template$SaveLoad$Internal$Util$common(level)));
		var layersTask = A3(
			elm$core$List$foldl,
			F2(
				function (layer, acc) {
					switch (layer.$) {
						case 0:
							var imageData = layer.a;
							return A2(
								author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen,
								function (info) {
									return A3(
										readFor,
										function ($) {
											return $.bp;
										},
										imageData,
										info);
								},
								acc);
						case 2:
							var tileData = layer.a;
							return A2(
								author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen,
								function (info) {
									return A3(
										readFor,
										function ($) {
											return $.bs;
										},
										A2(
											author$project$Logic$Template$SaveLoad$Internal$Reader$tileDataWith,
											author$project$Logic$Template$SaveLoad$Internal$Util$getTilesetByGid(info.z),
											tileData),
										info);
								},
								acc);
						case 1:
							var objectData = layer.a;
							return A2(
								author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen,
								function (info) {
									return A4(author$project$Logic$Template$SaveLoad$TiledReader$objectLayerParser, fix, readers, info, objectData);
								},
								acc);
						default:
							var tileChunkedData = layer.a;
							return A2(
								author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen,
								A2(
									readFor,
									function ($) {
										return $.bq;
									},
									tileChunkedData),
								acc);
					}
				}),
			A2(
				author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen,
				A2(
					readFor,
					function ($) {
						return $.eQ;
					},
					level),
				A2(
					author$project$Logic$Template$SaveLoad$Internal$ResourceTask$succeed,
					{
						am: emptyECS,
						K: 0,
						z: author$project$Logic$Template$SaveLoad$Internal$Util$tilesets(level)
					},
					start)),
			author$project$Logic$Template$SaveLoad$Internal$Util$common(level).b3);
		return A2(
			author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map,
			function (_n0) {
				var ecs = _n0.am;
				return ecs;
			},
			layersTask);
	});
var author$project$Logic$Template$SaveLoad$loadTiledAndEncode = F5(
	function (url, world, read, encoders, lut) {
		return A2(
			author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map,
			function (_n0) {
				var textures = _n0.a;
				var w = _n0.b;
				var encodedWorld = A2(author$project$Logic$Template$SaveLoad$Internal$Encode$encoder, encoders, w);
				var encodedTextures = author$project$Logic$Template$SaveLoad$Internal$TexturesManager$encoder(textures);
				var bytes = elm$bytes$Bytes$Encode$encode(
					elm$bytes$Bytes$Encode$sequence(
						_List_fromArray(
							[encodedTextures, encodedWorld])));
				return _Utils_Tuple2(bytes, w);
			},
			A2(
				author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen,
				function (level) {
					return A2(
						elm$core$Basics$composeR,
						A3(author$project$Logic$Template$SaveLoad$TiledReader$parse, world, read, level),
						author$project$Logic$Template$SaveLoad$Internal$ResourceTask$andThen(
							function (w) {
								return A2(
									elm$core$Basics$composeR,
									A3(
										author$project$Logic$Template$SaveLoad$TiledReader$parse,
										author$project$Logic$Template$SaveLoad$Internal$TexturesManager$empty,
										_List_fromArray(
											[author$project$Logic$Template$SaveLoad$Internal$TexturesManager$read]),
										level),
									author$project$Logic$Template$SaveLoad$Internal$ResourceTask$map(
										function (textures) {
											return _Utils_Tuple2(
												A2(lut, w, textures),
												w);
										}));
							}));
				},
				A2(author$project$Logic$Template$SaveLoad$Internal$Loader$getLevel, url, author$project$Logic$Template$SaveLoad$Internal$ResourceTask$init)));
	});
var author$project$Logic$Template$SaveLoad$Internal$ResourceTask$toTask = elm$core$Task$map(elm$core$Tuple$first);
var author$project$Image$BMP$pixelData = F4(
	function (opt, w, h, data) {
		return A4(
			author$project$Image$BMP$pixelData_,
			opt,
			w,
			h,
			elm$bytes$Bytes$Encode$encode(
				elm$bytes$Bytes$Encode$sequence(
					A2(elm$core$List$map, author$project$Image$pixelInt24, data))));
	});
var author$project$Logic$Template$SaveLoad$Internal$TexturesManager$Lut_ = function (a) {
	return {$: 2, a: a};
};
var author$project$Logic$Template$SaveLoad$Internal$TexturesManager$setLut = F5(
	function (id, w, h, image, manager) {
		return A2(
			elm$core$List$cons,
			author$project$Logic$Template$SaveLoad$Internal$TexturesManager$Lut_(
				{c3: h, c8: id, b0: image, ed: w}),
			manager);
	});
var elm$core$Basics$round = _Basics_round;
var author$project$Logic$Template$SaveLoad$Layer$lutCollector = F2(
	function (_n0, t) {
		var layers = _n0.b3;
		return A3(
			elm$core$List$foldl,
			F2(
				function (layar, acc) {
					if (!layar.$) {
						var id = layar.a.c8;
						var data = layar.a.cR;
						var uLutSize = layar.a.aI;
						var imageOptions = function () {
							var opt = author$project$Image$defaultOptions;
							return _Utils_update(
								opt,
								{ff: 0});
						}();
						var _n2 = elm_explorations$linear_algebra$Math$Vector2$toRecord(uLutSize);
						var x = _n2.n;
						var y = _n2.o;
						var w = elm$core$Basics$round(x);
						var h = elm$core$Basics$round(y);
						var lut2 = A4(author$project$Image$BMP$pixelData, imageOptions, w, h, data);
						return A5(author$project$Logic$Template$SaveLoad$Internal$TexturesManager$setLut, id, w, h, lut2, acc);
					} else {
						return acc;
					}
				}),
			t,
			layers);
	});
var author$project$Logic$Template$Game$Platformer$encode = function (levelUrl) {
	return author$project$Logic$Template$SaveLoad$Internal$ResourceTask$toTask(
		A5(author$project$Logic$Template$SaveLoad$loadTiledAndEncode, levelUrl, author$project$Logic$Template$Game$Platformer$Common$empty, author$project$Logic$Template$Game$Platformer$Common$read, author$project$Logic$Template$Game$Platformer$Common$encoders, author$project$Logic$Template$SaveLoad$Layer$lutCollector));
};
var elm$core$Task$Perform = elm$core$Basics$identity;
var elm$core$Task$init = elm$core$Task$succeed(0);
var elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			elm$core$Task$andThen,
			function (a) {
				return A2(
					elm$core$Task$andThen,
					function (b) {
						return elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var elm$core$Task$sequence = function (tasks) {
	return A3(
		elm$core$List$foldr,
		elm$core$Task$map2(elm$core$List$cons),
		elm$core$Task$succeed(_List_Nil),
		tasks);
};
var elm$core$Task$spawnCmd = F2(
	function (router, _n0) {
		var task = _n0;
		return _Scheduler_spawn(
			A2(
				elm$core$Task$andThen,
				elm$core$Platform$sendToApp(router),
				task));
	});
var elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			elm$core$Task$map,
			function (_n0) {
				return 0;
			},
			elm$core$Task$sequence(
				A2(
					elm$core$List$map,
					elm$core$Task$spawnCmd(router),
					commands)));
	});
var elm$core$Task$onSelfMsg = F3(
	function (_n0, _n1, _n2) {
		return elm$core$Task$succeed(0);
	});
var elm$core$Task$cmdMap = F2(
	function (tagger, _n0) {
		var task = _n0;
		return A2(elm$core$Task$map, tagger, task);
	});
_Platform_effectManagers['Task'] = _Platform_createManager(elm$core$Task$init, elm$core$Task$onEffects, elm$core$Task$onSelfMsg, elm$core$Task$cmdMap);
var elm$core$Task$command = _Platform_leaf('Task');
var elm$core$Task$attempt = F2(
	function (resultToMessage, task) {
		return elm$core$Task$command(
			A2(
				elm$core$Task$onError,
				A2(
					elm$core$Basics$composeL,
					A2(elm$core$Basics$composeL, elm$core$Task$succeed, resultToMessage),
					elm$core$Result$Err),
				A2(
					elm$core$Task$andThen,
					A2(
						elm$core$Basics$composeL,
						A2(elm$core$Basics$composeL, elm$core$Task$succeed, resultToMessage),
						elm$core$Result$Ok),
					task)));
	});
var author$project$Build$init = function (flags) {
	var levelUrl = A2(
		elm$core$Result$withDefault,
		'default.json',
		A2(
			elm$json$Json$Decode$decodeValue,
			A2(elm$json$Json$Decode$field, 'levelUrl', elm$json$Json$Decode$string),
			flags));
	return function (cmd) {
		return _Utils_Tuple2(0, cmd);
	}(
		A2(
			elm$core$Task$attempt,
			function (a) {
				if (!a.$) {
					var good = a.a;
					return danfishgold$base64_bytes$Base64$fromBytes(good);
				} else {
					return elm$core$Maybe$Nothing;
				}
			},
			A2(
				elm$core$Task$map,
				elm$core$Tuple$first,
				author$project$Logic$Template$Game$Platformer$encode(levelUrl))));
};
var elm$json$Json$Encode$string = _Json_wrap;
var author$project$Build$bytes = _Platform_outgoingPort('bytes', elm$json$Json$Encode$string);
var elm$core$Platform$Cmd$batch = _Platform_batch;
var elm$core$Platform$Cmd$none = elm$core$Platform$Cmd$batch(_List_Nil);
var author$project$Build$update = F2(
	function (world, _n0) {
		return _Utils_Tuple2(
			0,
			A2(
				elm$core$Maybe$withDefault,
				elm$core$Platform$Cmd$none,
				A2(elm$core$Maybe$map, author$project$Build$bytes, world)));
	});
var elm$core$Platform$worker = _Platform_worker;
var elm$core$Platform$Sub$batch = _Platform_batch;
var elm$core$Platform$Sub$none = elm$core$Platform$Sub$batch(_List_Nil);
var author$project$Build$main = elm$core$Platform$worker(
	{
		eM: author$project$Build$init,
		fA: function (_n0) {
			return elm$core$Platform$Sub$none;
		},
		fF: author$project$Build$update
	});
_Platform_export({'Build':{'init':author$project$Build$main(elm$json$Json$Decode$value)(0)}});}(this));