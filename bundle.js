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
	if (region.dG.aq === region.bK.aq)
	{
		return 'on line ' + region.dG.aq;
	}
	return 'on lines ' + region.dG.aq + ' through ' + region.bK.aq;
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
	return Array.isArray(value) || (typeof FileList === 'function' && value instanceof FileList);
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
		impl.dh,
		impl.dP,
		impl.cQ,
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




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**/
	var node = args['node'];
	//*/
	/**_UNUSED/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS


function _VirtualDom_noScript(tag)
{
	return tag == 'script' ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return /^(on|formAction$)/i.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,'')) ? '' : value;
}

function _VirtualDom_noJavaScriptUri_UNUSED(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,''))
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value) ? '' : value;
}

function _VirtualDom_noJavaScriptOrHtmlUri_UNUSED(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value)
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2(elm$json$Json$Decode$map, func, handler.a)
				:
			A3(elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		N: func(record.N),
		bk: record.bk,
		be: record.be
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		((key !== 'value' && key !== 'checked') || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		typeof value !== 'undefined'
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		typeof value !== 'undefined'
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.N;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.bk;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.be) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		var newMatch = undefined;
		var oldMatch = undefined;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}




// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.dh,
		impl.dP,
		impl.cQ,
		function(sendToApp, initialModel) {
			var view = impl.cV;
			/**/
			var domNode = args['node'];
			//*/
			/**_UNUSED/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.dh,
		impl.dP,
		impl.cQ,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.at && impl.at(sendToApp)
			var view = impl.cV;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.a$);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.bt) && (_VirtualDom_doc.title = title = doc.bt);
			});
		}
	);
});



// ANIMATION


var _Browser_cancelAnimationFrame =
	typeof cancelAnimationFrame !== 'undefined'
		? cancelAnimationFrame
		: function(id) { clearTimeout(id); };

var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { return setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.dp;
	var onUrlRequest = impl.dq;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		at: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.hasAttribute('download'))
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.cA === next.cA
							&& curr.b_ === next.b_
							&& curr.cw.a === next.cw.a
						)
							? elm$browser$Browser$Internal(next)
							: elm$browser$Browser$External(href)
					));
				}
			});
		},
		dh: function(flags)
		{
			return A3(impl.dh, flags, _Browser_getUrl(), key);
		},
		cV: impl.cV,
		dP: impl.dP,
		cQ: impl.cQ
	});
}

function _Browser_getUrl()
{
	return elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return elm$core$Result$isOk(result) ? elm$core$Maybe$Just(result.a) : elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { df: 'hidden', c0: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { df: 'mozHidden', c0: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { df: 'msHidden', c0: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { df: 'webkitHidden', c0: 'webkitvisibilitychange' }
		: { df: 'hidden', c0: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = _Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			_Browser_cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail(elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		dC: _Browser_getScene(),
		cW: {
			by: _Browser_window.pageXOffset,
			bz: _Browser_window.pageYOffset,
			ak: _Browser_doc.documentElement.clientWidth,
			ae: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		ak: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		ae: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			dC: {
				ak: node.scrollWidth,
				ae: node.scrollHeight
			},
			cW: {
				by: node.scrollLeft,
				bz: node.scrollTop,
				ak: node.clientWidth,
				ae: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			dC: _Browser_getScene(),
			cW: {
				by: x,
				bz: y,
				ak: _Browser_doc.documentElement.clientWidth,
				ae: _Browser_doc.documentElement.clientHeight
			},
			c6: {
				by: x + rect.left,
				bz: y + rect.top,
				ak: rect.width,
				ae: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2(elm$core$Task$perform, elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}



// SEND REQUEST

var _Http_toTask = F3(function(router, toTask, request)
{
	return _Scheduler_binding(function(callback)
	{
		function done(response) {
			callback(toTask(request.s.a(response)));
		}

		var xhr = new XMLHttpRequest();
		xhr.addEventListener('error', function() { done(elm$http$Http$NetworkError_); });
		xhr.addEventListener('timeout', function() { done(elm$http$Http$Timeout_); });
		xhr.addEventListener('load', function() { done(_Http_toResponse(request.s.b, xhr)); });
		elm$core$Maybe$isJust(request.x) && _Http_track(router, xhr, request.x.a);

		try {
			xhr.open(request.dl, request.dQ, true);
		} catch (e) {
			return done(elm$http$Http$BadUrl_(request.dQ));
		}

		_Http_configureRequest(xhr, request);

		request.a$.a && xhr.setRequestHeader('Content-Type', request.a$.a);
		xhr.send(request.a$.b);

		return function() { xhr.c = true; xhr.abort(); };
	});
});


// CONFIGURE

function _Http_configureRequest(xhr, request)
{
	for (var headers = request.de; headers.b; headers = headers.b) // WHILE_CONS
	{
		xhr.setRequestHeader(headers.a.a, headers.a.b);
	}
	xhr.timeout = request.dN.a || 0;
	xhr.responseType = request.s.d;
	xhr.withCredentials = request._;
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
		dQ: xhr.responseURL,
		dJ: xhr.status,
		dK: xhr.statusText,
		de: _Http_parseHeaders(xhr.getAllResponseHeaders())
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
			dE: event.loaded,
			bj: event.total
		}))));
	});
	xhr.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2(elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, elm$http$Http$Receiving({
			dy: event.loaded,
			bj: event.lengthComputable ? elm$core$Maybe$Just(event.total) : elm$core$Maybe$Nothing
		}))));
	});
}

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
    return { by: a[0], bz: a[1] };
};

var _MJS_v2fromRecord = function(r) {
    return new Float64Array([r.by, r.bz]);
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
    return { by: a[0], bz: a[1], dV: a[2] };
};

var _MJS_v3fromRecord = function(r) {
    return new Float64Array([r.by, r.bz, r.dV]);
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
    return { by: a[0], bz: a[1], dV: a[2], cX: a[3] };
};

var _MJS_v4fromRecord = function(r) {
    return new Float64Array([r.by, r.bz, r.dV, r.cX]);
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
    m[0] = r.b4;
    m[1] = r.b8;
    m[2] = r.cc;
    m[3] = r.cg;
    m[4] = r.b5;
    m[5] = r.b9;
    m[6] = r.cd;
    m[7] = r.ch;
    m[8] = r.b6;
    m[9] = r.ca;
    m[10] = r.ce;
    m[11] = r.ci;
    m[12] = r.b7;
    m[13] = r.cb;
    m[14] = r.cf;
    m[15] = r.cj;
    return m;
};

var _MJS_m4x4toRecord = function(m) {
    return {
        b4: m[0], b8: m[1], cc: m[2], cg: m[3],
        b5: m[4], b9: m[5], cd: m[6], ch: m[7],
        b6: m[8], ca: m[9], ce: m[10], ci: m[11],
        b7: m[12], cb: m[13], cf: m[14], cj: m[15]
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


var _Texture_guid = 0;

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
          id: _Texture_guid++,
          bG: createTexture,
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
	return _Utils_Tuple2(offset + len, new DataView(bytes.buffer, offset, len));
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


function _WebGL_log(/* msg */) {
  // console.log(msg);
}

var _WebGL_guid = 0;

function _WebGL_listEach(fn, list) {
  for (; list.b; list = list.b) {
    fn(list.a);
  }
}

function _WebGL_listLength(list) {
  var length = 0;
  for (; list.b; list = list.b) {
    length++;
  }
  return length;
}

var _WebGL_rAF = typeof requestAnimationFrame !== 'undefined' ?
  requestAnimationFrame :
  function (cb) { setTimeout(cb, 1000 / 60); };

// eslint-disable-next-line no-unused-vars
var _WebGL_entity = F5(function (settings, vert, frag, mesh, uniforms) {

  if (!mesh.id) {
    mesh.id = _WebGL_guid++;
  }

  return {
    $: 0,
    a: settings,
    b: vert,
    c: frag,
    d: mesh,
    e: uniforms
  };

});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableBlend = F2(function (gl, setting) {
  gl.enable(gl.BLEND);
  // a   b   c   d   e   f   g h i j
  // eq1 f11 f12 eq2 f21 f22 r g b a
  gl.blendEquationSeparate(setting.a, setting.d);
  gl.blendFuncSeparate(setting.b, setting.c, setting.e, setting.f);
  gl.blendColor(setting.g, setting.h, setting.i, setting.j);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableDepthTest = F2(function (gl, setting) {
  gl.enable(gl.DEPTH_TEST);
  // a    b    c    d
  // func mask near far
  gl.depthFunc(setting.a);
  gl.depthMask(setting.b);
  gl.depthRange(setting.c, setting.d);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableStencilTest = F2(function (gl, setting) {
  gl.enable(gl.STENCIL_TEST);
  // a   b    c         d     e     f      g      h     i     j      k
  // ref mask writeMask test1 fail1 zfail1 zpass1 test2 fail2 zfail2 zpass2
  gl.stencilFuncSeparate(gl.FRONT, setting.d, setting.a, setting.b);
  gl.stencilOpSeparate(gl.FRONT, setting.e, setting.f, setting.g);
  gl.stencilMaskSeparate(gl.FRONT, setting.c);
  gl.stencilFuncSeparate(gl.BACK, setting.h, setting.a, setting.b);
  gl.stencilOpSeparate(gl.BACK, setting.i, setting.j, setting.k);
  gl.stencilMaskSeparate(gl.BACK, setting.c);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableScissor = F2(function (gl, setting) {
  gl.enable(gl.SCISSOR_TEST);
  gl.scissor(setting.a, setting.b, setting.c, setting.d);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableColorMask = F2(function (gl, setting) {
  gl.colorMask(setting.a, setting.b, setting.c, setting.d);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableCullFace = F2(function (gl, setting) {
  gl.enable(gl.CULL_FACE);
  gl.cullFace(setting.a);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enablePolygonOffset = F2(function (gl, setting) {
  gl.enable(gl.POLYGON_OFFSET_FILL);
  gl.polygonOffset(setting.a, setting.b);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableSampleCoverage = F2(function (gl, setting) {
  gl.enable(gl.SAMPLE_COVERAGE);
  gl.sampleCoverage(setting.a, setting.b);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableSampleAlphaToCoverage = F2(function (gl, setting) {
  gl.enable(gl.SAMPLE_ALPHA_TO_COVERAGE);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_disableBlend = function (gl) {
  gl.disable(gl.BLEND);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableDepthTest = function (gl) {
  gl.disable(gl.DEPTH_TEST);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableStencilTest = function (gl) {
  gl.disable(gl.STENCIL_TEST);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableScissor = function (gl) {
  gl.disable(gl.SCISSOR_TEST);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableColorMask = function (gl) {
  gl.colorMask(true, true, true, true);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableCullFace = function (gl) {
  gl.disable(gl.CULL_FACE);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disablePolygonOffset = function (gl) {
  gl.disable(gl.POLYGON_OFFSET_FILL);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableSampleCoverage = function (gl) {
  gl.disable(gl.SAMPLE_COVERAGE);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableSampleAlphaToCoverage = function (gl) {
  gl.disable(gl.SAMPLE_ALPHA_TO_COVERAGE);
};

function _WebGL_doCompile(gl, src, type) {

  var shader = gl.createShader(type);
  _WebGL_log('Created shader');

  gl.shaderSource(shader, src);
  gl.compileShader(shader);
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    throw gl.getShaderInfoLog(shader);
  }

  return shader;

}

function _WebGL_doLink(gl, vshader, fshader) {

  var program = gl.createProgram();
  _WebGL_log('Created program');

  gl.attachShader(program, vshader);
  gl.attachShader(program, fshader);
  gl.linkProgram(program);
  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    throw gl.getProgramInfoLog(program);
  }

  return program;

}

function _WebGL_getAttributeInfo(gl, type) {
  switch (type) {
    case gl.FLOAT:
      return { size: 1, type: Float32Array, baseType: gl.FLOAT };
    case gl.FLOAT_VEC2:
      return { size: 2, type: Float32Array, baseType: gl.FLOAT };
    case gl.FLOAT_VEC3:
      return { size: 3, type: Float32Array, baseType: gl.FLOAT };
    case gl.FLOAT_VEC4:
      return { size: 4, type: Float32Array, baseType: gl.FLOAT };
    case gl.INT:
      return { size: 1, type: Int32Array, baseType: gl.INT };
    case gl.INT_VEC2:
      return { size: 2, type: Int32Array, baseType: gl.INT };
    case gl.INT_VEC3:
      return { size: 3, type: Int32Array, baseType: gl.INT };
    case gl.INT_VEC4:
      return { size: 4, type: Int32Array, baseType: gl.INT };
  }
}

/**
 *  Form the buffer for a given attribute.
 *
 *  @param {WebGLRenderingContext} gl context
 *  @param {WebGLActiveInfo} attribute the attribute to bind to.
 *         We use its name to grab the record by name and also to know
 *         how many elements we need to grab.
 *  @param {Mesh} mesh The mesh coming in from Elm.
 *  @param {Object} attributes The mapping between the attribute names and Elm fields
 *  @return {WebGLBuffer}
 */
function _WebGL_doBindAttribute(gl, attribute, mesh, attributes) {
  // The length of the number of vertices that
  // complete one 'thing' based on the drawing mode.
  // ie, 2 for Lines, 3 for Triangles, etc.
  var elemSize = mesh.a.E;

  var idxKeys = [];
  for (var i = 0; i < elemSize; i++) {
    idxKeys.push(String.fromCharCode(97 + i));
  }

  function dataFill(data, cnt, fillOffset, elem, key) {
    var i;
    if (elemSize === 1) {
      for (i = 0; i < cnt; i++) {
        data[fillOffset++] = cnt === 1 ? elem[key] : elem[key][i];
      }
    } else {
      idxKeys.forEach(function (idx) {
        for (i = 0; i < cnt; i++) {
          data[fillOffset++] = cnt === 1 ? elem[idx][key] : elem[idx][key][i];
        }
      });
    }
  }

  var attributeInfo = _WebGL_getAttributeInfo(gl, attribute.type);

  if (attributeInfo === undefined) {
    throw new Error('No info available for: ' + attribute.type);
  }

  var dataIdx = 0;
  var array = new attributeInfo.type(_WebGL_listLength(mesh.b) * attributeInfo.size * elemSize);

  _WebGL_listEach(function (elem) {
    dataFill(array, attributeInfo.size, dataIdx, elem, attributes[attribute.name] || attribute.name);
    dataIdx += attributeInfo.size * elemSize;
  }, mesh.b);

  var buffer = gl.createBuffer();
  _WebGL_log('Created attribute buffer ' + attribute.name);

  gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
  gl.bufferData(gl.ARRAY_BUFFER, array, gl.STATIC_DRAW);
  return buffer;
}

/**
 *  This sets up the binding caching buffers.
 *
 *  We don't actually bind any buffers now except for the indices buffer.
 *  The problem with filling the buffers here is that it is possible to
 *  have a buffer shared between two webgl shaders;
 *  which could have different active attributes. If we bind it here against
 *  a particular program, we might not bind them all. That final bind is now
 *  done right before drawing.
 *
 *  @param {WebGLRenderingContext} gl context
 *  @param {Mesh} mesh a mesh object from Elm
 *  @return {Object} buffer - an object with the following properties
 *  @return {Number} buffer.numIndices
 *  @return {WebGLBuffer} buffer.indexBuffer
 *  @return {Object} buffer.buffers - will be used to buffer attributes
 */
function _WebGL_doBindSetup(gl, mesh) {
  _WebGL_log('Created index buffer');
  var indexBuffer = gl.createBuffer();
  var indices = (mesh.a.F === 0)
    ? _WebGL_makeSequentialBuffer(mesh.a.E * _WebGL_listLength(mesh.b))
    : _WebGL_makeIndexedBuffer(mesh.c, mesh.a.F);

  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
  gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);

  return {
    numIndices: indices.length,
    indexBuffer: indexBuffer,
    buffers: {}
  };
}

/**
 *  Create an indices array and fill it with 0..n
 *
 *  @param {Number} numIndices The number of indices
 *  @return {Uint16Array} indices
 */
function _WebGL_makeSequentialBuffer(numIndices) {
  var indices = new Uint16Array(numIndices);
  for (var i = 0; i < numIndices; i++) {
    indices[i] = i;
  }
  return indices;
}

/**
 *  Create an indices array and fill it from indices
 *  based on the size of the index
 *
 *  @param {List} indicesList the list of indices
 *  @param {Number} indexSize the size of the index
 *  @return {Uint16Array} indices
 */
function _WebGL_makeIndexedBuffer(indicesList, indexSize) {
  var indices = new Uint16Array(_WebGL_listLength(indicesList) * indexSize);
  var fillOffset = 0;
  var i;
  _WebGL_listEach(function (elem) {
    if (indexSize === 1) {
      indices[fillOffset++] = elem;
    } else {
      for (i = 0; i < indexSize; i++) {
        indices[fillOffset++] = elem[String.fromCharCode(97 + i)];
      }
    }
  }, indicesList);
  return indices;
}

function _WebGL_getProgID(vertID, fragID) {
  return vertID + '#' + fragID;
}

var _WebGL_drawGL = F2(function (model, domNode) {

  var gl = model.f.gl;

  if (!gl) {
    return domNode;
  }

  gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT | gl.STENCIL_BUFFER_BIT);
  _WebGL_log('Drawing');

  function drawEntity(entity) {
    if (!entity.d.b.b) {
      return; // Empty list
    }

    var progid;
    var program;
    if (entity.b.id && entity.c.id) {
      progid = _WebGL_getProgID(entity.b.id, entity.c.id);
      program = model.f.programs[progid];
    }

    if (!program) {

      var vshader;
      if (entity.b.id) {
        vshader = model.f.shaders[entity.b.id];
      } else {
        entity.b.id = _WebGL_guid++;
      }

      if (!vshader) {
        vshader = _WebGL_doCompile(gl, entity.b.src, gl.VERTEX_SHADER);
        model.f.shaders[entity.b.id] = vshader;
      }

      var fshader;
      if (entity.c.id) {
        fshader = model.f.shaders[entity.c.id];
      } else {
        entity.c.id = _WebGL_guid++;
      }

      if (!fshader) {
        fshader = _WebGL_doCompile(gl, entity.c.src, gl.FRAGMENT_SHADER);
        model.f.shaders[entity.c.id] = fshader;
      }

      var glProgram = _WebGL_doLink(gl, vshader, fshader);

      program = {
        glProgram: glProgram,
        attributes: Object.assign({}, entity.b.attributes, entity.c.attributes),
        uniformSetters: _WebGL_createUniformSetters(
          gl,
          model,
          glProgram,
          Object.assign({}, entity.b.uniforms, entity.c.uniforms)
        )
      };

      progid = _WebGL_getProgID(entity.b.id, entity.c.id);
      model.f.programs[progid] = program;

    }

    gl.useProgram(program.glProgram);

    _WebGL_setUniforms(program.uniformSetters, entity.e);

    var buffer = model.f.buffers[entity.d.id];

    if (!buffer) {
      buffer = _WebGL_doBindSetup(gl, entity.d);
      model.f.buffers[entity.d.id] = buffer;
    }

    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffer.indexBuffer);

    var numAttributes = gl.getProgramParameter(program.glProgram, gl.ACTIVE_ATTRIBUTES);

    for (var i = 0; i < numAttributes; i++) {
      var attribute = gl.getActiveAttrib(program.glProgram, i);

      var attribLocation = gl.getAttribLocation(program.glProgram, attribute.name);
      gl.enableVertexAttribArray(attribLocation);

      if (buffer.buffers[attribute.name] === undefined) {
        buffer.buffers[attribute.name] = _WebGL_doBindAttribute(gl, attribute, entity.d, program.attributes);
      }
      var attributeBuffer = buffer.buffers[attribute.name];
      var attributeInfo = _WebGL_getAttributeInfo(gl, attribute.type);

      gl.bindBuffer(gl.ARRAY_BUFFER, attributeBuffer);
      gl.vertexAttribPointer(attribLocation, attributeInfo.size, attributeInfo.baseType, false, 0, 0);
    }

    _WebGL_listEach(function (setting) {
      return A2(elm_explorations$webgl$WebGL$Internal$enableSetting, gl, setting);
    }, entity.a);

    gl.drawElements(entity.d.a.H, buffer.numIndices, gl.UNSIGNED_SHORT, 0);

    _WebGL_listEach(function (setting) {
      return A2(elm_explorations$webgl$WebGL$Internal$disableSetting, gl, setting);
    }, entity.a);

  }

  _WebGL_listEach(drawEntity, model.g);
  return domNode;
});

function _WebGL_createUniformSetters(gl, model, program, uniformsMap) {
  var textureCounter = 0;
  function createUniformSetter(program, uniform) {
    var uniformLocation = gl.getUniformLocation(program, uniform.name);
    switch (uniform.type) {
      case gl.INT:
        return function (value) {
          gl.uniform1i(uniformLocation, value);
        };
      case gl.FLOAT:
        return function (value) {
          gl.uniform1f(uniformLocation, value);
        };
      case gl.FLOAT_VEC2:
        return function (value) {
          gl.uniform2fv(uniformLocation, new Float32Array(value));
        };
      case gl.FLOAT_VEC3:
        return function (value) {
          gl.uniform3fv(uniformLocation, new Float32Array(value));
        };
      case gl.FLOAT_VEC4:
        return function (value) {
          gl.uniform4fv(uniformLocation, new Float32Array(value));
        };
      case gl.FLOAT_MAT4:
        return function (value) {
          gl.uniformMatrix4fv(uniformLocation, false, new Float32Array(value));
        };
      case gl.SAMPLER_2D:
        var currentTexture = textureCounter++;
        return function (texture) {
          gl.activeTexture(gl.TEXTURE0 + currentTexture);
          var tex = model.f.textures[texture.id];
          if (!tex) {
            _WebGL_log('Created texture');
            tex = texture.bG(gl);
            model.f.textures[texture.id] = tex;
          }
          gl.bindTexture(gl.TEXTURE_2D, tex);
          gl.uniform1i(uniformLocation, currentTexture);
        };
      case gl.BOOL:
        return function (value) {
          gl.uniform1i(uniformLocation, value);
        };
      default:
        _WebGL_log('Unsupported uniform type: ' + uniform.type);
        return function () {};
    }
  }

  var uniformSetters = {};
  var numUniforms = gl.getProgramParameter(program, gl.ACTIVE_UNIFORMS);
  for (var i = 0; i < numUniforms; i++) {
    var uniform = gl.getActiveUniform(program, i);
    uniformSetters[uniformsMap[uniform.name] || uniform.name] = createUniformSetter(program, uniform);
  }

  return uniformSetters;
}

function _WebGL_setUniforms(setters, values) {
  Object.keys(values).forEach(function (name) {
    var setter = setters[name];
    if (setter) {
      setter(values[name]);
    }
  });
}

// VIRTUAL-DOM WIDGET

// eslint-disable-next-line no-unused-vars
var _WebGL_toHtml = F3(function (options, factList, entities) {
  return _VirtualDom_custom(
    factList,
    {
      g: entities,
      f: {},
      h: options
    },
    _WebGL_render,
    _WebGL_diff
  );
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableAlpha = F2(function (options, option) {
  options.contextAttributes.alpha = true;
  options.contextAttributes.premultipliedAlpha = option.a;
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableDepth = F2(function (options, option) {
  options.contextAttributes.depth = true;
  options.sceneSettings.push(function (gl) {
    gl.clearDepth(option.a);
  });
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableStencil = F2(function (options, option) {
  options.contextAttributes.stencil = true;
  options.sceneSettings.push(function (gl) {
    gl.clearStencil(option.a);
  });
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableAntialias = F2(function (options, option) {
  options.contextAttributes.antialias = true;
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableClearColor = F2(function (options, option) {
  options.sceneSettings.push(function (gl) {
    gl.clearColor(option.a, option.b, option.c, option.d);
  });
});

/**
 *  Creates canvas and schedules initial _WebGL_drawGL
 *  @param {Object} model
 *  @param {Object} model.f that may contain the following properties:
           gl, shaders, programs, buffers, textures
 *  @param {List<Option>} model.h list of options coming from Elm
 *  @param {List<Entity>} model.g list of entities coming from Elm
 *  @return {HTMLElement} <canvas> if WebGL is supported, otherwise a <div>
 */
function _WebGL_render(model) {
  var options = {
    contextAttributes: {
      alpha: false,
      depth: false,
      stencil: false,
      antialias: false,
      premultipliedAlpha: false
    },
    sceneSettings: []
  };

  _WebGL_listEach(function (option) {
    return A2(elm_explorations$webgl$WebGL$Internal$enableOption, options, option);
  }, model.h);

  _WebGL_log('Render canvas');
  var canvas = _VirtualDom_doc.createElement('canvas');
  var gl = canvas.getContext && (
    canvas.getContext('webgl', options.contextAttributes) ||
    canvas.getContext('experimental-webgl', options.contextAttributes)
  );

  if (gl) {
    options.sceneSettings.forEach(function (sceneSetting) {
      sceneSetting(gl);
    });
  } else {
    canvas = _VirtualDom_doc.createElement('div');
    canvas.innerHTML = '<a href="https://get.webgl.org/">Enable WebGL</a> to see this content!';
  }

  model.f.gl = gl;
  model.f.shaders = [];
  model.f.programs = {};
  model.f.buffers = [];
  model.f.textures = [];

  // Render for the first time.
  // This has to be done in animation frame,
  // because the canvas is not in the DOM yet
  _WebGL_rAF(function () {
    return A2(_WebGL_drawGL, model, canvas);
  });

  return canvas;
}

function _WebGL_diff(oldModel, newModel) {
  newModel.f = oldModel.f;
  return _WebGL_drawGL(newModel);
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
var author$project$Environment$Resize = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var elm$browser$Browser$Events$Window = 1;
var elm$browser$Browser$Events$MySub = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var elm$browser$Browser$Events$State = F2(
	function (subs, pids) {
		return {cu: pids, cP: subs};
	});
var elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var elm$core$Dict$empty = elm$core$Dict$RBEmpty_elm_builtin;
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
var elm$core$Basics$EQ = 1;
var elm$core$Basics$LT = 0;
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
var elm$core$Task$succeed = _Scheduler_succeed;
var elm$browser$Browser$Events$init = elm$core$Task$succeed(
	A2(elm$browser$Browser$Events$State, _List_Nil, elm$core$Dict$empty));
var elm$browser$Browser$Events$nodeToKey = function (node) {
	if (!node) {
		return 'd_';
	} else {
		return 'w_';
	}
};
var elm$core$Basics$append = _Utils_append;
var elm$browser$Browser$Events$addKey = function (sub) {
	var node = sub.a;
	var name = sub.b;
	return _Utils_Tuple2(
		_Utils_ap(
			elm$browser$Browser$Events$nodeToKey(node),
			name),
		sub);
};
var elm$browser$Browser$Events$Event = F2(
	function (key, event) {
		return {bL: event, b1: key};
	});
var elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var elm$core$Basics$False = 1;
var elm$core$Basics$True = 0;
var elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var elm$core$Array$branchFactor = 32;
var elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var elm$core$Basics$ceiling = _Basics_ceiling;
var elm$core$Basics$fdiv = _Basics_fdiv;
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
var elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
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
var elm$core$Basics$floor = _Basics_floor;
var elm$core$Basics$gt = _Utils_gt;
var elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var elm$core$Basics$mul = _Basics_mul;
var elm$core$Basics$sub = _Basics_sub;
var elm$core$Elm$JsArray$length = _JsArray_length;
var elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.h) {
			return A4(
				elm$core$Array$Array_elm_builtin,
				elm$core$Elm$JsArray$length(builder.j),
				elm$core$Array$shiftStep,
				elm$core$Elm$JsArray$empty,
				builder.j);
		} else {
			var treeLen = builder.h * elm$core$Array$branchFactor;
			var depth = elm$core$Basics$floor(
				A2(elm$core$Basics$logBase, elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? elm$core$List$reverse(builder.k) : builder.k;
			var tree = A2(elm$core$Array$treeFromBuilder, correctNodeList, builder.h);
			return A4(
				elm$core$Array$Array_elm_builtin,
				elm$core$Elm$JsArray$length(builder.j) + treeLen,
				A2(elm$core$Basics$max, 5, depth * elm$core$Array$shiftStep),
				tree,
				builder.j);
		}
	});
var elm$core$Basics$idiv = _Basics_idiv;
var elm$core$Basics$lt = _Utils_lt;
var elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					elm$core$Array$builderToArray,
					false,
					{k: nodeList, h: (len / elm$core$Array$branchFactor) | 0, j: tail});
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
var elm$core$Platform$sendToSelf = _Platform_sendToSelf;
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
var elm$browser$Browser$External = function (a) {
	return {$: 1, a: a};
};
var elm$browser$Browser$Internal = function (a) {
	return {$: 0, a: a};
};
var elm$browser$Browser$Dom$NotFound = elm$core$Basics$identity;
var elm$core$Basics$never = function (_n0) {
	never:
	while (true) {
		var nvr = _n0;
		var $temp$_n0 = nvr;
		_n0 = $temp$_n0;
		continue never;
	}
};
var elm$core$Basics$identity = function (x) {
	return x;
};
var elm$core$Task$Perform = elm$core$Basics$identity;
var elm$core$Task$init = elm$core$Task$succeed(0);
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
var elm$core$Platform$sendToApp = _Platform_sendToApp;
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
var elm$core$Task$perform = F2(
	function (toMessage, task) {
		return elm$core$Task$command(
			A2(elm$core$Task$map, toMessage, task));
	});
var elm$json$Json$Decode$map = _Json_map1;
var elm$json$Json$Decode$map2 = _Json_map2;
var elm$json$Json$Decode$succeed = _Json_succeed;
var elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 0:
			return 0;
		case 1:
			return 1;
		case 2:
			return 2;
		default:
			return 3;
	}
};
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
var elm$url$Url$Http = 0;
var elm$url$Url$Https = 1;
var elm$core$String$indexes = _String_indexes;
var elm$core$String$isEmpty = function (string) {
	return string === '';
};
var elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3(elm$core$String$slice, 0, n, string);
	});
var elm$core$String$contains = _String_contains;
var elm$core$String$toInt = _String_toInt;
var elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {bR: fragment, b_: host, ct: path, cw: port_, cA: protocol, cB: query};
	});
var elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if (elm$core$String$isEmpty(str) || A2(elm$core$String$contains, '@', str)) {
			return elm$core$Maybe$Nothing;
		} else {
			var _n0 = A2(elm$core$String$indexes, ':', str);
			if (!_n0.b) {
				return elm$core$Maybe$Just(
					A6(elm$url$Url$Url, protocol, str, elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_n0.b.b) {
					var i = _n0.a;
					var _n1 = elm$core$String$toInt(
						A2(elm$core$String$dropLeft, i + 1, str));
					if (_n1.$ === 1) {
						return elm$core$Maybe$Nothing;
					} else {
						var port_ = _n1;
						return elm$core$Maybe$Just(
							A6(
								elm$url$Url$Url,
								protocol,
								A2(elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return elm$core$Maybe$Nothing;
				}
			}
		}
	});
var elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if (elm$core$String$isEmpty(str)) {
			return elm$core$Maybe$Nothing;
		} else {
			var _n0 = A2(elm$core$String$indexes, '/', str);
			if (!_n0.b) {
				return A5(elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _n0.a;
				return A5(
					elm$url$Url$chompBeforePath,
					protocol,
					A2(elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2(elm$core$String$left, i, str));
			}
		}
	});
var elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if (elm$core$String$isEmpty(str)) {
			return elm$core$Maybe$Nothing;
		} else {
			var _n0 = A2(elm$core$String$indexes, '?', str);
			if (!_n0.b) {
				return A4(elm$url$Url$chompBeforeQuery, protocol, elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _n0.a;
				return A4(
					elm$url$Url$chompBeforeQuery,
					protocol,
					elm$core$Maybe$Just(
						A2(elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2(elm$core$String$left, i, str));
			}
		}
	});
var elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if (elm$core$String$isEmpty(str)) {
			return elm$core$Maybe$Nothing;
		} else {
			var _n0 = A2(elm$core$String$indexes, '#', str);
			if (!_n0.b) {
				return A3(elm$url$Url$chompBeforeFragment, protocol, elm$core$Maybe$Nothing, str);
			} else {
				var i = _n0.a;
				return A3(
					elm$url$Url$chompBeforeFragment,
					protocol,
					elm$core$Maybe$Just(
						A2(elm$core$String$dropLeft, i + 1, str)),
					A2(elm$core$String$left, i, str));
			}
		}
	});
var elm$url$Url$fromString = function (str) {
	return A2(elm$core$String$startsWith, 'http://', str) ? A2(
		elm$url$Url$chompAfterProtocol,
		0,
		A2(elm$core$String$dropLeft, 7, str)) : (A2(elm$core$String$startsWith, 'https://', str) ? A2(
		elm$url$Url$chompAfterProtocol,
		1,
		A2(elm$core$String$dropLeft, 8, str)) : elm$core$Maybe$Nothing);
};
var elm$browser$Browser$Events$spawn = F3(
	function (router, key, _n0) {
		var node = _n0.a;
		var name = _n0.b;
		var actualNode = function () {
			if (!node) {
				return _Browser_doc;
			} else {
				return _Browser_window;
			}
		}();
		return A2(
			elm$core$Task$map,
			function (value) {
				return _Utils_Tuple2(key, value);
			},
			A3(
				_Browser_on,
				actualNode,
				name,
				function (event) {
					return A2(
						elm$core$Platform$sendToSelf,
						router,
						A2(elm$browser$Browser$Events$Event, key, event));
				}));
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
var elm$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _n0) {
				stepState:
				while (true) {
					var list = _n0.a;
					var result = _n0.b;
					if (!list.b) {
						return _Utils_Tuple2(
							list,
							A3(rightStep, rKey, rValue, result));
					} else {
						var _n2 = list.a;
						var lKey = _n2.a;
						var lValue = _n2.b;
						var rest = list.b;
						if (_Utils_cmp(lKey, rKey) < 0) {
							var $temp$rKey = rKey,
								$temp$rValue = rValue,
								$temp$_n0 = _Utils_Tuple2(
								rest,
								A3(leftStep, lKey, lValue, result));
							rKey = $temp$rKey;
							rValue = $temp$rValue;
							_n0 = $temp$_n0;
							continue stepState;
						} else {
							if (_Utils_cmp(lKey, rKey) > 0) {
								return _Utils_Tuple2(
									list,
									A3(rightStep, rKey, rValue, result));
							} else {
								return _Utils_Tuple2(
									rest,
									A4(bothStep, lKey, lValue, rValue, result));
							}
						}
					}
				}
			});
		var _n3 = A3(
			elm$core$Dict$foldl,
			stepState,
			_Utils_Tuple2(
				elm$core$Dict$toList(leftDict),
				initialResult),
			rightDict);
		var leftovers = _n3.a;
		var intermediateResult = _n3.b;
		return A3(
			elm$core$List$foldl,
			F2(
				function (_n4, result) {
					var k = _n4.a;
					var v = _n4.b;
					return A3(leftStep, k, v, result);
				}),
			intermediateResult,
			leftovers);
	});
var elm$core$Dict$union = F2(
	function (t1, t2) {
		return A3(elm$core$Dict$foldl, elm$core$Dict$insert, t2, t1);
	});
var elm$core$Process$kill = _Scheduler_kill;
var elm$browser$Browser$Events$onEffects = F3(
	function (router, subs, state) {
		var stepRight = F3(
			function (key, sub, _n6) {
				var deads = _n6.a;
				var lives = _n6.b;
				var news = _n6.c;
				return _Utils_Tuple3(
					deads,
					lives,
					A2(
						elm$core$List$cons,
						A3(elm$browser$Browser$Events$spawn, router, key, sub),
						news));
			});
		var stepLeft = F3(
			function (_n4, pid, _n5) {
				var deads = _n5.a;
				var lives = _n5.b;
				var news = _n5.c;
				return _Utils_Tuple3(
					A2(elm$core$List$cons, pid, deads),
					lives,
					news);
			});
		var stepBoth = F4(
			function (key, pid, _n2, _n3) {
				var deads = _n3.a;
				var lives = _n3.b;
				var news = _n3.c;
				return _Utils_Tuple3(
					deads,
					A3(elm$core$Dict$insert, key, pid, lives),
					news);
			});
		var newSubs = A2(elm$core$List$map, elm$browser$Browser$Events$addKey, subs);
		var _n0 = A6(
			elm$core$Dict$merge,
			stepLeft,
			stepBoth,
			stepRight,
			state.cu,
			elm$core$Dict$fromList(newSubs),
			_Utils_Tuple3(_List_Nil, elm$core$Dict$empty, _List_Nil));
		var deadPids = _n0.a;
		var livePids = _n0.b;
		var makeNewPids = _n0.c;
		return A2(
			elm$core$Task$andThen,
			function (pids) {
				return elm$core$Task$succeed(
					A2(
						elm$browser$Browser$Events$State,
						newSubs,
						A2(
							elm$core$Dict$union,
							livePids,
							elm$core$Dict$fromList(pids))));
			},
			A2(
				elm$core$Task$andThen,
				function (_n1) {
					return elm$core$Task$sequence(makeNewPids);
				},
				elm$core$Task$sequence(
					A2(elm$core$List$map, elm$core$Process$kill, deadPids))));
	});
var elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _n0 = f(mx);
		if (!_n0.$) {
			var x = _n0.a;
			return A2(elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			elm$core$List$foldr,
			elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var elm$browser$Browser$Events$onSelfMsg = F3(
	function (router, _n0, state) {
		var key = _n0.b1;
		var event = _n0.bL;
		var toMessage = function (_n2) {
			var subKey = _n2.a;
			var _n3 = _n2.b;
			var node = _n3.a;
			var name = _n3.b;
			var decoder = _n3.c;
			return _Utils_eq(subKey, key) ? A2(_Browser_decodeEvent, decoder, event) : elm$core$Maybe$Nothing;
		};
		var messages = A2(elm$core$List$filterMap, toMessage, state.cP);
		return A2(
			elm$core$Task$andThen,
			function (_n1) {
				return elm$core$Task$succeed(state);
			},
			elm$core$Task$sequence(
				A2(
					elm$core$List$map,
					elm$core$Platform$sendToApp(router),
					messages)));
	});
var elm$browser$Browser$Events$subMap = F2(
	function (func, _n0) {
		var node = _n0.a;
		var name = _n0.b;
		var decoder = _n0.c;
		return A3(
			elm$browser$Browser$Events$MySub,
			node,
			name,
			A2(elm$json$Json$Decode$map, func, decoder));
	});
_Platform_effectManagers['Browser.Events'] = _Platform_createManager(elm$browser$Browser$Events$init, elm$browser$Browser$Events$onEffects, elm$browser$Browser$Events$onSelfMsg, 0, elm$browser$Browser$Events$subMap);
var elm$browser$Browser$Events$subscription = _Platform_leaf('Browser.Events');
var elm$browser$Browser$Events$on = F3(
	function (node, name, decoder) {
		return elm$browser$Browser$Events$subscription(
			A3(elm$browser$Browser$Events$MySub, node, name, decoder));
	});
var elm$json$Json$Decode$field = _Json_decodeField;
var elm$json$Json$Decode$int = _Json_decodeInt;
var elm$browser$Browser$Events$onResize = function (func) {
	return A3(
		elm$browser$Browser$Events$on,
		1,
		'resize',
		A2(
			elm$json$Json$Decode$field,
			'target',
			A3(
				elm$json$Json$Decode$map2,
				func,
				A2(elm$json$Json$Decode$field, 'innerWidth', elm$json$Json$Decode$int),
				A2(elm$json$Json$Decode$field, 'innerHeight', elm$json$Json$Decode$int))));
};
var elm$core$Platform$Sub$batch = _Platform_batch;
var author$project$Environment$subscriptions = function (model) {
	return elm$core$Platform$Sub$batch(
		_List_fromArray(
			[
				elm$browser$Browser$Events$onResize(author$project$Environment$Resize)
			]));
};
var author$project$Game$Environment = function (a) {
	return {$: 0, a: a};
};
var author$project$Game$Frame = function (a) {
	return {$: 1, a: a};
};
var author$project$Game$Subscription = function (a) {
	return {$: 2, a: a};
};
var elm$browser$Browser$Dom$getViewport = _Browser_withWindow(_Browser_getViewport);
var elm$core$Basics$round = _Basics_round;
var author$project$Environment$requestWindowSize = A2(
	elm$core$Task$perform,
	function (_n0) {
		var scene = _n0.dC;
		return A2(
			author$project$Environment$Resize,
			elm$core$Basics$round(scene.ak),
			elm$core$Basics$round(scene.ae));
	},
	elm$browser$Browser$Dom$getViewport);
var elm$core$Result$withDefault = F2(
	function (def, result) {
		if (!result.$) {
			var a = result.a;
			return a;
		} else {
			return def;
		}
	});
var elm$json$Json$Decode$decodeValue = _Json_run;
var elm$json$Json$Decode$float = _Json_decodeFloat;
var author$project$Environment$init = function (flags) {
	return _Utils_Tuple2(
		{
			aE: A2(
				elm$core$Result$withDefault,
				1,
				A2(
					elm$json$Json$Decode$decodeValue,
					A2(elm$json$Json$Decode$field, 'devicePixelRatio', elm$json$Json$Decode$float),
					flags)),
			ae: 100,
			ak: 100,
			bw: 1
		},
		author$project$Environment$requestWindowSize);
};
var author$project$Error$Error = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var author$project$Game$Resource = function (a) {
	return {$: 3, a: a};
};
var author$project$ResourceTask$andThen = F2(
	function (f, task) {
		return A2(
			elm$core$Task$andThen,
			function (_n0) {
				var a = _n0.a;
				var dict = _n0.b;
				return A2(
					elm$core$Task$map,
					function (_n1) {
						var b = _n1.a;
						var dict2 = _n1.b;
						return _Utils_Tuple2(
							b,
							A2(elm$core$Dict$union, dict, dict2));
					},
					A2(
						f,
						a,
						elm$core$Task$succeed(dict)));
			},
			task);
	});
var elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var elm$core$Task$onError = _Scheduler_onError;
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
var author$project$ResourceTask$attempt = F2(
	function (f, task) {
		return A2(
			elm$core$Task$attempt,
			f,
			A2(elm$core$Task$map, elm$core$Tuple$first, task));
	});
var author$project$ResourceTask$Level = function (a) {
	return {$: 2, a: a};
};
var elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
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
		{_: false, a$: r.a$, s: r.dA, de: r.de, dl: r.dl, dN: r.dN, x: elm$core$Maybe$Nothing, dQ: r.dQ});
};
var elm$json$Json$Decode$decodeString = _Json_runOnString;
var author$project$ResourceTask$getJson = F2(
	function (url, decoder) {
		return elm$http$Http$task(
			{
				a$: elm$http$Http$emptyBody,
				de: _List_Nil,
				dl: 'GET',
				dA: elm$http$Http$stringResolver(
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
										author$project$Error$Error(4004)),
									A2(elm$json$Json$Decode$decodeString, decoder, body));
							case 0:
								var info = response.a;
								return elm$core$Result$Err(
									A2(author$project$Error$Error, 4000, info));
							case 1:
								return elm$core$Result$Err(
									A2(author$project$Error$Error, 4001, 'Timeout'));
							case 2:
								return elm$core$Result$Err(
									A2(author$project$Error$Error, 4002, 'NetworkError'));
							default:
								var statusCode = response.a.dJ;
								return elm$core$Result$Err(
									A2(
										author$project$Error$Error,
										4003,
										'BadStatus:' + elm$core$String$fromInt(statusCode)));
						}
					}),
				dN: elm$core$Maybe$Nothing,
				dQ: url
			});
	});
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
var NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom = elm$json$Json$Decode$map2(elm$core$Basics$apR);
var elm$json$Json$Decode$andThen = _Json_andThen;
var elm$json$Json$Decode$fail = _Json_fail;
var elm$json$Json$Decode$null = _Json_decodeNull;
var elm$json$Json$Decode$oneOf = _Json_oneOf;
var elm$json$Json$Decode$value = _Json_decodeValue;
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
		return {L: id, a3: image, O: name, Q: opacity, R: properties, dO: transparentcolor, U: visible, by: x, bz: y};
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
var elm$json$Json$Decode$bool = _Json_decodeBool;
var elm$json$Json$Decode$string = _Json_decodeString;
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
var elm$json$Json$Decode$list = _Json_decodeList;
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
										return {a0: color, bI: draworder, L: id, O: name, $7: objects, Q: opacity, R: properties, U: visible, by: x, bz: y};
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
var author$project$Tiled$Object$Ellipse = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var author$project$Tiled$Object$Point = function (a) {
	return {$: 0, a: a};
};
var author$project$Tiled$Object$PolyLine = F3(
	function (a, b, c) {
		return {$: 4, a: a, b: b, c: c};
	});
var author$project$Tiled$Object$Polygon = F3(
	function (a, b, c) {
		return {$: 3, a: a, b: b, c: c};
	});
var author$project$Tiled$Object$Rectangle = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var author$project$Tiled$Object$Tile = F3(
	function (a, b, c) {
		return {$: 5, a: a, b: b, c: c};
	});
var author$project$Tiled$Object$Common = F8(
	function (id, name, kind, visible, x, y, rotation, properties) {
		return {L: id, b2: kind, O: name, R: properties, cF: rotation, U: visible, by: x, bz: y};
	});
var author$project$Tiled$Object$decodeCommon = A4(
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
								elm$json$Json$Decode$succeed(author$project$Tiled$Object$Common)))))))));
var author$project$Tiled$Object$Dimension = F2(
	function (width, height) {
		return {ae: height, ak: width};
	});
var author$project$Tiled$Object$decodeDimension = A3(
	NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'height',
	elm$json$Json$Decode$float,
	A3(
		NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'width',
		elm$json$Json$Decode$float,
		elm$json$Json$Decode$succeed(author$project$Tiled$Object$Dimension)));
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
						return {by: x, bz: y};
					})))));
var elm$json$Json$Decode$map3 = _Json_map3;
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
		A4(elm$json$Json$Decode$map3, author$project$Tiled$Object$Tile, author$project$Tiled$Object$decodeCommon, author$project$Tiled$Object$decodeDimension, author$project$Tiled$Object$decodeGid));
	var rectangle = A3(elm$json$Json$Decode$map2, author$project$Tiled$Object$Rectangle, author$project$Tiled$Object$decodeCommon, author$project$Tiled$Object$decodeDimension);
	var polyline = A4(
		elm$json$Json$Decode$map3,
		author$project$Tiled$Object$PolyLine,
		author$project$Tiled$Object$decodeCommon,
		author$project$Tiled$Object$decodeDimension,
		A2(elm$json$Json$Decode$field, 'polyline', author$project$Tiled$Object$decodePolyPoints));
	var polygon = A4(
		elm$json$Json$Decode$map3,
		author$project$Tiled$Object$Polygon,
		author$project$Tiled$Object$decodeCommon,
		author$project$Tiled$Object$decodeDimension,
		A2(elm$json$Json$Decode$field, 'polygon', author$project$Tiled$Object$decodePolyPoints));
	var point = A3(
		elm_community$json_extra$Json$Decode$Extra$when,
		A2(elm$json$Json$Decode$field, 'point', elm$json$Json$Decode$bool),
		elm$core$Basics$eq(true),
		A2(elm$json$Json$Decode$map, author$project$Tiled$Object$Point, author$project$Tiled$Object$decodeCommon));
	var elipse = A3(
		elm_community$json_extra$Json$Decode$Extra$when,
		A2(elm$json$Json$Decode$field, 'ellipse', elm$json$Json$Decode$bool),
		elm$core$Basics$eq(true),
		A3(elm$json$Json$Decode$map2, author$project$Tiled$Object$Ellipse, author$project$Tiled$Object$decodeCommon, author$project$Tiled$Object$decodeDimension));
	return elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[point, elipse, tile, polygon, polyline, rectangle]));
}();
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
										return {aD: data, ae: height, L: id, O: name, Q: opacity, R: properties, U: visible, ak: width, by: x, bz: y};
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
var elm$core$Tuple$pair = F2(
	function (a, b) {
		return _Utils_Tuple2(a, b);
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
												return {bE: chunks, ae: height, L: id, O: name, Q: opacity, R: properties, dH: startx, dI: starty, U: visible, ak: width, by: x, bz: y};
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
		return {aD: data, ae: height, ak: width, by: x, bz: y};
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
														return {aC: columns, ac: firstgid, a3: image, aL: imageheight, aM: imagewidth, aP: margin, O: name, R: properties, aU: spacing, aV: tilecount, bq: tileheight, aW: tiles, bs: tilewidth, dO: transparentcolor};
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
		return {bJ: duration, cS: tileid};
	});
var author$project$Tiled$Tileset$decodeSpriteAnimation = A3(
	elm$json$Json$Decode$map2,
	author$project$Tiled$Tileset$SpriteAnimation,
	A2(elm$json$Json$Decode$field, 'duration', elm$json$Json$Decode$int),
	A2(elm$json$Json$Decode$field, 'tileid', elm$json$Json$Decode$int));
var author$project$Tiled$Tileset$TilesDataObjectgroup = F7(
	function (draworder, name, objects, opacity, visible, x, y) {
		return {bI: draworder, O: name, $7: objects, Q: opacity, U: visible, by: x, bz: y};
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
							return {aa: a, L: d, af: b, R: c};
						}))))));
var author$project$Tiled$Tileset$decodeTiles = A2(
	elm$json$Json$Decode$andThen,
	A2(
		elm$core$List$foldl,
		F2(
			function (_n0, acc) {
				var id = _n0.L;
				var objectgroup = _n0.af;
				var animation = _n0.aa;
				var properties = _n0.R;
				return A2(
					elm$json$Json$Decode$andThen,
					A2(
						elm$core$Basics$composeR,
						A2(
							elm$core$Dict$insert,
							id,
							{aa: animation, af: objectgroup, R: properties}),
						elm$json$Json$Decode$succeed),
					acc);
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
											return {aC: columns, ac: firstgid, bX: grid, aP: margin, O: name, R: properties, aU: spacing, aV: tilecount, bq: tileheight, aW: tiles, bs: tilewidth};
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
		return {ae: height, cs: orientation, ak: width};
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
												{aa: animation, a3: image, aL: imageheight, aM: imagewidth, af: objectgroup, R: properties});
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
var author$project$Tiled$Tileset$Source = function (a) {
	return {$: 0, a: a};
};
var author$project$Tiled$Tileset$SourceTileData = F2(
	function (firstgid, source) {
		return {ac: firstgid, cJ: source};
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
																											return {a_: backgroundcolor, ae: height, a4: infinite, aN: layers, bc: nextobjectid, R: props, bh: renderorder, bp: tiledversion, bq: tileheight, br: tilesets, bs: tilewidth, bv: version, ak: width};
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
																																	return {a_: backgroundcolor, ae: height, bZ: hexsidelength, a4: infinite, aN: layers, bc: nextobjectid, R: props, bh: renderorder, cM: staggeraxis, cN: staggerindex, bp: tiledversion, bq: tileheight, br: tilesets, bs: tilewidth, bv: version, ak: width};
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
var author$project$ResourceTask$getLevel = F2(
	function (url, cache) {
		return A2(
			elm$core$Task$map,
			function (_n1) {
				var resp = _n1.a;
				var dict = _n1.b;
				return _Utils_Tuple2(
					resp,
					A3(
						elm$core$Dict$insert,
						url,
						author$project$ResourceTask$Level(resp),
						dict));
			},
			A2(
				elm$core$Task$andThen,
				function (d) {
					var _n0 = A2(elm$core$Dict$get, url, d);
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
							A2(author$project$ResourceTask$getJson, url, author$project$Tiled$Level$decode));
					}
				},
				cache));
	});
var author$project$ResourceTask$init = elm$core$Task$succeed(elm$core$Dict$empty);
var author$project$Logic$GameFlow$Running = {$: 0};
var elm$core$Tuple$mapFirst = F2(
	function (func, _n0) {
		var x = _n0.a;
		var y = _n0.b;
		return _Utils_Tuple2(
			func(x),
			y);
	});
var author$project$ResourceTask$map = F2(
	function (f, task) {
		return A2(
			elm$core$Task$map,
			elm$core$Tuple$mapFirst(f),
			task);
	});
var author$project$ResourceTask$succeed = function (a) {
	return elm$core$Task$andThen(
		A2(
			elm$core$Basics$composeR,
			elm$core$Tuple$pair(a),
			elm$core$Task$succeed));
};
var author$project$Tiled$Util$common = function (level) {
	switch (level.$) {
		case 0:
			var info = level.a;
			return {a_: info.a_, ae: info.ae, a4: info.a4, aN: info.aN, bc: info.bc, R: info.R, bh: info.bh, bp: info.bp, bq: info.bq, br: info.br, bs: info.bs, bv: info.bv, ak: info.ak};
		case 1:
			var info = level.a;
			return {a_: info.a_, ae: info.ae, a4: info.a4, aN: info.aN, bc: info.bc, R: info.R, bh: info.bh, bp: info.bp, bq: info.bq, br: info.br, bs: info.bs, bv: info.bv, ak: info.ak};
		case 2:
			var info = level.a;
			return {a_: info.a_, ae: info.ae, a4: info.a4, aN: info.aN, bc: info.bc, R: info.R, bh: info.bh, bp: info.bp, bq: info.bq, br: info.br, bs: info.bs, bv: info.bv, ak: info.ak};
		default:
			var info = level.a;
			return {a_: info.a_, ae: info.ae, a4: info.a4, aN: info.aN, bc: info.bc, R: info.R, bh: info.bh, bp: info.bp, bq: info.bq, br: info.br, bs: info.bs, bv: info.bv, ak: info.ak};
	}
};
var author$project$Tiled$Util$tilesets = function (level) {
	switch (level.$) {
		case 0:
			var info = level.a;
			return info.br;
		case 1:
			var info = level.a;
			return info.br;
		case 2:
			var info = level.a;
			return info.br;
		default:
			var info = level.a;
			return info.br;
	}
};
var author$project$World$World = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
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
	var r = _n0.aR;
	var g = _n0.aJ;
	var b = _n0.g;
	var a = _n0.f;
	var color = _n0.a0;
	var alpha = _n0.aB;
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
				f: 0,
				aB: A2(elm_explorations$webgl$WebGL$Settings$Blend$customAdd, factor1, factor2),
				g: 0,
				a0: A2(elm_explorations$webgl$WebGL$Settings$Blend$customAdd, factor1, factor2),
				aJ: 0,
				aR: 0
			});
	});
var elm_explorations$webgl$WebGL$Settings$Blend$Factor = elm$core$Basics$identity;
var elm_explorations$webgl$WebGL$Settings$Blend$oneMinusSrcAlpha = 771;
var elm_explorations$webgl$WebGL$Settings$Blend$srcAlpha = 770;
var author$project$Defaults$entitySettings = _List_fromArray(
	[
		elm_explorations$webgl$WebGL$Settings$cullFace(elm_explorations$webgl$WebGL$Settings$front),
		A2(elm_explorations$webgl$WebGL$Settings$Blend$add, elm_explorations$webgl$WebGL$Settings$Blend$srcAlpha, elm_explorations$webgl$WebGL$Settings$Blend$oneMinusSrcAlpha),
		A4(elm_explorations$webgl$WebGL$Settings$colorMask, true, true, true, false)
	]);
var elm_explorations$webgl$WebGL$Texture$Resize = elm$core$Basics$identity;
var elm_explorations$webgl$WebGL$Texture$linear = 9729;
var elm_explorations$webgl$WebGL$Texture$Wrap = elm$core$Basics$identity;
var elm_explorations$webgl$WebGL$Texture$clampToEdge = 33071;
var elm_explorations$webgl$WebGL$Texture$nearest = 9728;
var elm_explorations$webgl$WebGL$Texture$nonPowerOfTwoOptions = {aH: true, aK: elm_explorations$webgl$WebGL$Texture$clampToEdge, dk: elm_explorations$webgl$WebGL$Texture$linear, dm: elm_explorations$webgl$WebGL$Texture$nearest, aX: elm_explorations$webgl$WebGL$Texture$clampToEdge};
var author$project$Defaults$textureOption = _Utils_update(
	elm_explorations$webgl$WebGL$Texture$nonPowerOfTwoOptions,
	{dk: elm_explorations$webgl$WebGL$Texture$linear, dm: elm_explorations$webgl$WebGL$Texture$linear});
var elm_explorations$webgl$WebGL$Internal$Alpha = function (a) {
	return {$: 0, a: a};
};
var elm_explorations$webgl$WebGL$alpha = elm_explorations$webgl$WebGL$Internal$Alpha;
var elm_explorations$webgl$WebGL$Internal$ClearColor = F4(
	function (a, b, c, d) {
		return {$: 4, a: a, b: b, c: c, d: d};
	});
var elm_explorations$webgl$WebGL$clearColor = elm_explorations$webgl$WebGL$Internal$ClearColor;
var elm_explorations$webgl$WebGL$Internal$Depth = function (a) {
	return {$: 1, a: a};
};
var elm_explorations$webgl$WebGL$depth = elm_explorations$webgl$WebGL$Internal$Depth;
var author$project$Defaults$webGLOption = _List_fromArray(
	[
		elm_explorations$webgl$WebGL$alpha(false),
		elm_explorations$webgl$WebGL$depth(1),
		A4(elm_explorations$webgl$WebGL$clearColor, 0, 0, 0, 1)
	]);
var elm_explorations$linear_algebra$Math$Vector2$vec2 = _MJS_v2;
var elm_explorations$linear_algebra$Math$Vector3$vec3 = _MJS_v3;
var author$project$Defaults$default = {
	c7: author$project$Defaults$entitySettings,
	dc: 60,
	dt: 160,
	dD: 1,
	dM: author$project$Defaults$textureOption,
	dO: A3(elm_explorations$linear_algebra$Math$Vector3$vec3, 0, 0, 0),
	dR: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0),
	dS: author$project$Defaults$webGLOption
};
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
var elm$core$Maybe$map3 = F4(
	function (func, ma, mb, mc) {
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
					return elm$core$Maybe$Just(
						A3(func, a, b, c));
				}
			}
		}
	});
var elm$core$String$fromList = _String_fromList;
var elm$core$String$foldr = _String_foldr;
var elm$core$String$toList = function (string) {
	return A3(elm$core$String$foldr, elm$core$List$cons, _List_Nil, string);
};
var author$project$Tiled$Util$hexColor2Vec3 = function (str) {
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
		var makeFloat = F2(
			function (a, b) {
				return A2(
					elm$core$Maybe$map,
					function (i) {
						return i / 255;
					},
					elm$core$String$toInt(
						elm$core$String$fromList(
							_List_fromArray(
								['0', 'x', a, b]))));
			});
		return A4(
			elm$core$Maybe$map3,
			elm_explorations$linear_algebra$Math$Vector3$vec3,
			A2(makeFloat, r1, r2),
			A2(makeFloat, g1, g2),
			A2(makeFloat, b1, b2));
	} else {
		return elm$core$Maybe$Nothing;
	}
};
var elm$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		if (!maybeValue.$) {
			var value = maybeValue.a;
			return callback(value);
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
var author$project$Tiled$Util$propWrap = F4(
	function (dict, parser, key, _default) {
		return A2(
			elm$core$Maybe$withDefault,
			_default,
			A2(
				elm$core$Maybe$andThen,
				parser,
				A2(elm$core$Dict$get, key, dict)));
	});
var author$project$Tiled$Util$properties = function (dict) {
	return {
		bC: A2(
			author$project$Tiled$Util$propWrap,
			dict.R,
			function (r) {
				if (!r.$) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		a0: A2(
			author$project$Tiled$Util$propWrap,
			dict.R,
			function (r) {
				if (r.$ === 4) {
					var i = r.a;
					return author$project$Tiled$Util$hexColor2Vec3(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		bP: A2(
			author$project$Tiled$Util$propWrap,
			dict.R,
			function (r) {
				if (r.$ === 5) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		ad: A2(
			author$project$Tiled$Util$propWrap,
			dict.R,
			function (r) {
				if (r.$ === 2) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		b$: A2(
			author$project$Tiled$Util$propWrap,
			dict.R,
			function (r) {
				if (r.$ === 1) {
					var i = r.a;
					return elm$core$Maybe$Just(i);
				} else {
					return elm$core$Maybe$Nothing;
				}
			}),
		cO: A2(
			author$project$Tiled$Util$propWrap,
			dict.R,
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
var author$project$Tiled$Util$levelProps = function (level) {
	switch (level.$) {
		case 0:
			var info = level.a;
			return author$project$Tiled$Util$properties(info);
		case 1:
			var info = level.a;
			return author$project$Tiled$Util$properties(info);
		case 2:
			var info = level.a;
			return author$project$Tiled$Util$properties(info);
		default:
			var info = level.a;
			return author$project$Tiled$Util$properties(info);
	}
};
var author$project$World$Camera$init = function (level) {
	return function (prop) {
		return {
			dt: A2(prop.ad, 'pixelsPerUnit', author$project$Defaults$default.dt),
			dR: author$project$Defaults$default.dR
		};
	}(
		author$project$Tiled$Util$levelProps(level));
};
var author$project$Layer$Image = function (a) {
	return {$: 5, a: a};
};
var author$project$Layer$ImageNo = function (a) {
	return {$: 4, a: a};
};
var author$project$Layer$ImageX = function (a) {
	return {$: 2, a: a};
};
var author$project$Layer$ImageY = function (a) {
	return {$: 3, a: a};
};
var author$project$ResourceTask$Texture = function (a) {
	return {$: 0, a: a};
};
var author$project$ResourceTask$textureError = function (e) {
	if (!e.$) {
		return A2(author$project$Error$Error, 4005, 'Texture.LoadError');
	} else {
		var a = e.a;
		var b = e.b;
		return A2(author$project$Error$Error, 4006, 'Texture.LoadError');
	}
};
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
		var magnify = _n0.dk;
		var minify = _n0.dm;
		var horizontalWrap = _n0.aK;
		var verticalWrap = _n0.aX;
		var flipY = _n0.aH;
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
var author$project$ResourceTask$getTexture = F2(
	function (url, cache) {
		return A2(
			elm$core$Task$map,
			function (_n1) {
				var resp = _n1.a;
				var dict = _n1.b;
				return _Utils_Tuple2(
					resp,
					A3(
						elm$core$Dict$insert,
						url,
						author$project$ResourceTask$Texture(resp),
						dict));
			},
			A2(
				elm$core$Task$andThen,
				function (d) {
					var _n0 = A2(elm$core$Dict$get, url, d);
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
								author$project$ResourceTask$textureError,
								A2(elm_explorations$webgl$WebGL$Texture$loadWith, author$project$Defaults$default.dM, url)));
					}
				},
				cache));
	});
var author$project$Tiled$Util$scrollRatio = F2(
	function (dual, props) {
		return dual ? A2(
			elm_explorations$linear_algebra$Math$Vector2$vec2,
			A2(props.ad, 'scrollRatio.x', author$project$Defaults$default.dD),
			A2(props.ad, 'scrollRatio.y', author$project$Defaults$default.dD)) : A2(
			elm_explorations$linear_algebra$Math$Vector2$vec2,
			A2(props.ad, 'scrollRatio', author$project$Defaults$default.dD),
			A2(props.ad, 'scrollRatio', author$project$Defaults$default.dD));
	});
var elm_explorations$webgl$WebGL$Texture$size = _Texture_size;
var author$project$World$Component$ImageLayer$imageLayer = function (imageData) {
	var props = author$project$Tiled$Util$properties(imageData);
	return A2(
		elm$core$Basics$composeR,
		author$project$ResourceTask$getTexture('/assets/' + imageData.a3),
		author$project$ResourceTask$map(
			function (t) {
				var _n0 = elm_explorations$webgl$WebGL$Texture$size(t);
				var width = _n0.a;
				var height = _n0.b;
				return function () {
					var _n1 = A2(props.cO, 'repeat', 'repeat');
					switch (_n1) {
						case 'repeat-x':
							return author$project$Layer$ImageX;
						case 'repeat-y':
							return author$project$Layer$ImageY;
						case 'no-repeat':
							return author$project$Layer$ImageNo;
						default:
							return author$project$Layer$Image;
					}
				}()(
					{
						a3: t,
						dD: A2(
							author$project$Tiled$Util$scrollRatio,
							_Utils_eq(
								A2(elm$core$Dict$get, 'scrollRatio', imageData.R),
								elm$core$Maybe$Nothing),
							props),
						bj: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, width, height),
						dO: A2(props.a0, 'transparentcolor', author$project$Defaults$default.dO)
					});
			}));
};
var author$project$Layer$Object = function (a) {
	return {$: 6, a: a};
};
var author$project$Logic$Component$empty = elm$core$Array$empty;
var author$project$Logic$Entity$create = F2(
	function (id, world) {
		return _Utils_Tuple2(id, world);
	});
var elm$core$Elm$JsArray$appendN = _JsArray_appendN;
var elm$core$Elm$JsArray$slice = _JsArray_slice;
var elm$core$Array$appendHelpBuilder = F2(
	function (tail, builder) {
		var tailLen = elm$core$Elm$JsArray$length(tail);
		var notAppended = (elm$core$Array$branchFactor - elm$core$Elm$JsArray$length(builder.j)) - tailLen;
		var appended = A3(elm$core$Elm$JsArray$appendN, elm$core$Array$branchFactor, builder.j, tail);
		return (notAppended < 0) ? {
			k: A2(
				elm$core$List$cons,
				elm$core$Array$Leaf(appended),
				builder.k),
			h: builder.h + 1,
			j: A3(elm$core$Elm$JsArray$slice, notAppended, tailLen, tail)
		} : ((!notAppended) ? {
			k: A2(
				elm$core$List$cons,
				elm$core$Array$Leaf(appended),
				builder.k),
			h: builder.h + 1,
			j: elm$core$Elm$JsArray$empty
		} : {k: builder.k, h: builder.h, j: appended});
	});
var elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var elm$core$Array$bitMask = 4294967295 >>> (32 - elm$core$Array$shiftStep);
var elm$core$Basics$ge = _Utils_ge;
var elm$core$Bitwise$and = _Bitwise_and;
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
var elm$core$Elm$JsArray$foldl = _JsArray_foldl;
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
		k: A3(elm$core$Elm$JsArray$foldl, helper, _List_Nil, tree),
		h: (len / elm$core$Array$branchFactor) | 0,
		j: tail
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
var author$project$Logic$Entity$setComponent = F3(
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
		var get = _n0.a.dd;
		var set = _n0.a.dF;
		var component = _n0.b;
		var mId = _n1.a;
		var world = _n1.b;
		var updatedComponents = A3(
			author$project$Logic$Entity$setComponent,
			mId,
			component,
			get(world));
		var updatedWorld = A2(set, updatedComponents, world);
		return _Utils_Tuple2(mId, updatedWorld);
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
		bN: author$project$Tiled$flippedDiagonally(gid),
		bO: author$project$Tiled$flippedHorizontally(gid),
		bT: author$project$Tiled$flippedVertically(gid),
		bV: author$project$Tiled$cleanGid(gid)
	};
};
var author$project$World$Component$Common$commonDimensionArgs = F2(
	function (a, b) {
		return {ae: b.ae, L: a.L, b2: a.b2, O: a.O, R: a.R, cF: a.cF, U: a.U, ak: b.ak, by: a.by, bz: a.bz};
	});
var author$project$World$Component$Common$commonDimensionPolyPointsArgs = F3(
	function (a, b, c) {
		return {ae: b.ae, L: a.L, b2: a.b2, O: a.O, cv: c, R: a.R, cF: a.cF, U: a.U, ak: b.ak, by: a.by, bz: a.bz};
	});
var author$project$World$Component$Common$tileArgs = F4(
	function (a, b, c, d) {
		return {bN: c.bN, bO: c.bO, bT: c.bT, bU: d, bV: c.bV, ae: b.ae, L: a.L, b2: a.b2, O: a.O, R: a.R, cF: a.cF, U: a.U, ak: b.ak, by: a.by, bz: a.bz};
	});
var author$project$World$Component$ObjetLayer$combine1 = F4(
	function (getKey, arg, readers, acc) {
		combine1:
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
						continue combine1;
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
						continue combine1;
					default:
						var f = _n1.a;
						return A2(
							elm$core$Basics$composeR,
							f(arg),
							author$project$ResourceTask$andThen(
								function (f1) {
									return A4(
										author$project$World$Component$ObjetLayer$combine1,
										getKey,
										arg,
										rest,
										f1(acc));
								}));
				}
			} else {
				var _n2 = acc;
				var newECS = _n2.b;
				return author$project$ResourceTask$succeed(newECS);
			}
		}
	});
var author$project$ResourceTask$fail = F2(
	function (e, _n0) {
		return elm$core$Task$fail(e);
	});
var author$project$ResourceTask$Tileset = function (a) {
	return {$: 1, a: a};
};
var NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded = A2(elm$core$Basics$composeR, elm$json$Json$Decode$succeed, NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom);
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
var author$project$ResourceTask$getTileset = F3(
	function (url, firstgid, cache) {
		return A2(
			elm$core$Task$map,
			function (_n1) {
				var resp = _n1.a;
				var dict = _n1.b;
				return _Utils_Tuple2(
					resp,
					A3(
						elm$core$Dict$insert,
						url,
						author$project$ResourceTask$Tileset(resp),
						dict));
			},
			A2(
				elm$core$Task$andThen,
				function (d) {
					var _n0 = A2(elm$core$Dict$get, url, d);
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
								author$project$ResourceTask$getJson,
								url,
								author$project$Tiled$Tileset$decodeFile(firstgid)));
					}
				},
				cache));
	});
var author$project$Tiled$Util$firstGid = function (item) {
	switch (item.$) {
		case 0:
			var info = item.a;
			return info.ac;
		case 1:
			var info = item.a;
			return info.ac;
		default:
			var info = item.a;
			return info.ac;
	}
};
var author$project$Tiled$Util$tilesetById = F2(
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
								var info = _n2.a.a;
								var _n3 = _n2.b;
								return true;
							} else {
								var info = _n2.a.a;
								var nextTileset = _n2.b.a;
								return (_Utils_cmp(id, info.ac) > -1) && (_Utils_cmp(
									id,
									author$project$Tiled$Util$firstGid(nextTileset)) < 0);
							}
						case 1:
							var info = _n2.a.a;
							return (_Utils_cmp(id, info.ac) > -1) && (_Utils_cmp(id, info.ac + info.aV) < 0);
						default:
							var info = _n2.a.a;
							return (_Utils_cmp(id, info.ac) > -1) && (_Utils_cmp(id, info.ac + info.aV) < 0);
					}
				}),
			tilesets_);
	});
var author$project$World$Component$ObjetLayer$getTilesetByGid = F2(
	function (tilesets, gid) {
		var _n0 = A2(author$project$Tiled$Util$tilesetById, tilesets, gid);
		if (!_n0.$) {
			if (!_n0.a.$) {
				var info = _n0.a.a;
				return A2(author$project$ResourceTask$getTileset, '/assets/' + info.cJ, info.ac);
			} else {
				var t = _n0.a;
				return author$project$ResourceTask$succeed(t);
			}
		} else {
			return author$project$ResourceTask$fail(
				A2(
					author$project$Error$Error,
					5001,
					'Not found Tileset for GID:' + elm$core$String$fromInt(gid)));
		}
	});
var author$project$World$Component$ObjetLayer$validateAndUpdate = F3(
	function (_n0, newECS, newLayerECS) {
		var layerECS = _n0.a;
		var info = _n0.b;
		var _n1 = _Utils_Tuple2(
			_Utils_eq(newECS, info.aF),
			_Utils_eq(layerECS, newLayerECS));
		if (_n1.a) {
			if (_n1.b) {
				return _Utils_Tuple2(layerECS, info);
			} else {
				return _Utils_Tuple2(
					newLayerECS,
					_Utils_update(
						info,
						{M: info.M + 1}));
			}
		} else {
			if (_n1.b) {
				return _Utils_Tuple2(
					layerECS,
					_Utils_update(
						info,
						{aF: newECS, M: info.M + 1}));
			} else {
				return _Utils_Tuple2(
					newLayerECS,
					_Utils_update(
						info,
						{aF: newECS, M: info.M + 1}));
			}
		}
	});
var elm$core$Tuple$second = function (_n0) {
	var y = _n0.b;
	return y;
};
var author$project$World$Component$ObjetLayer$objectLayer = F5(
	function (fix, readers, info_, objectData, start) {
		var spec = {
			dd: elm$core$Basics$identity,
			dF: F2(
				function (comps, _n4) {
					return comps;
				})
		};
		var readFor = F3(
			function (f, args, _n3) {
				var layerECS = _n3.a;
				var acc = _n3.b;
				return A2(
					elm$core$Basics$composeR,
					A4(
						author$project$World$Component$ObjetLayer$combine1,
						f,
						args,
						readers,
						A2(author$project$Logic$Entity$create, acc.M, acc.aF)),
					author$project$ResourceTask$map(
						function (newECS) {
							return A3(
								author$project$World$Component$ObjetLayer$validateAndUpdate,
								_Utils_Tuple2(layerECS, acc),
								newECS,
								A2(
									author$project$Logic$Entity$with,
									_Utils_Tuple2(spec, 0),
									A2(author$project$Logic$Entity$create, acc.M, layerECS)).b);
						}));
			});
		return A3(
			elm$core$Basics$composeR,
			A2(
				elm$core$List$foldr,
				function (obj) {
					var _n0 = fix(obj);
					switch (_n0.$) {
						case 0:
							var common = _n0.a;
							return author$project$ResourceTask$andThen(
								A2(
									readFor,
									function ($) {
										return $.cm;
									},
									common));
						case 1:
							var common = _n0.a;
							var dimension = _n0.b;
							return author$project$ResourceTask$andThen(
								A2(
									readFor,
									function ($) {
										return $.cp;
									},
									A2(author$project$World$Component$Common$commonDimensionArgs, common, dimension)));
						case 2:
							var common = _n0.a;
							var dimension = _n0.b;
							return author$project$ResourceTask$andThen(
								A2(
									readFor,
									function ($) {
										return $.cl;
									},
									A2(author$project$World$Component$Common$commonDimensionArgs, common, dimension)));
						case 3:
							var common = _n0.a;
							var dimension = _n0.b;
							var polyPoints = _n0.c;
							return author$project$ResourceTask$andThen(
								A2(
									readFor,
									function ($) {
										return $.co;
									},
									A3(author$project$World$Component$Common$commonDimensionPolyPointsArgs, common, dimension, polyPoints)));
						case 4:
							var common = _n0.a;
							var dimension = _n0.b;
							var polyPoints = _n0.c;
							return author$project$ResourceTask$andThen(
								A2(
									readFor,
									function ($) {
										return $.cn;
									},
									A3(author$project$World$Component$Common$commonDimensionPolyPointsArgs, common, dimension, polyPoints)));
						default:
							var common = _n0.a;
							var dimension = _n0.b;
							var gid = _n0.c;
							return author$project$ResourceTask$andThen(
								function (_n1) {
									var layerECS = _n1.a;
									var info = _n1.b;
									var args = A4(
										author$project$World$Component$Common$tileArgs,
										common,
										dimension,
										author$project$Tiled$gidInfo(gid),
										author$project$World$Component$ObjetLayer$getTilesetByGid(info.br));
									return A3(
										readFor,
										function ($) {
											return $.cq;
										},
										args,
										_Utils_Tuple2(layerECS, info));
								});
					}
				},
				A2(
					author$project$ResourceTask$succeed,
					_Utils_Tuple2(author$project$Logic$Component$empty, info_),
					start)),
			author$project$ResourceTask$map(
				function (_n2) {
					var layer = _n2.a;
					var info = _n2.b;
					return _Utils_update(
						info,
						{
							aN: A2(
								elm$core$List$cons,
								author$project$Layer$Object(layer),
								info.aN)
						});
				}),
			objectData.$7);
	});
var author$project$ResourceTask$sequence = F2(
	function (ltask, cache) {
		return A3(
			elm$core$List$foldr,
			F2(
				function (t, acc) {
					return A2(
						author$project$ResourceTask$andThen,
						F2(
							function (newList, t2) {
								return A2(
									author$project$ResourceTask$map,
									function (r) {
										return A2(elm$core$List$cons, r, newList);
									},
									t(t2));
							}),
						acc);
				}),
			A2(author$project$ResourceTask$succeed, _List_Nil, cache),
			ltask);
	});
var author$project$Tiled$Util$updateTileset = F4(
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
var author$project$Tiled$Util$animation = F2(
	function (_n0, id) {
		var tiles = _n0.aW;
		return A2(
			elm$core$Maybe$map,
			function ($) {
				return $.aa;
			},
			A2(elm$core$Dict$get, id, tiles));
	});
var author$project$World$Component$TileLayer$prepend = F2(
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
var author$project$World$Component$TileLayer$updateOthers = F2(
	function (f, k) {
		return elm$core$Dict$map(
			F2(
				function (k_, v) {
					return _Utils_eq(k_, k) ? v : f(v);
				}));
	});
var author$project$World$Component$TileLayer$others = author$project$World$Component$TileLayer$updateOthers(
	author$project$World$Component$TileLayer$prepend(0));
var author$project$World$Component$TileLayer$fillTiles = F3(
	function (tileId, info, acc) {
		var cache = acc.D;
		var _static = acc.w;
		var animated = acc.v;
		var _n0 = A2(elm$core$Dict$get, tileId, animated);
		if (!_n0.$) {
			var _n1 = _n0.a;
			var t_ = _n1.a;
			var v = _n1.b;
			return {
				v: A2(
					author$project$World$Component$TileLayer$others,
					tileId,
					A3(
						elm$core$Dict$insert,
						tileId,
						_Utils_Tuple2(
							t_,
							A2(elm$core$List$cons, 1, v)),
						animated)),
				D: A2(elm$core$List$cons, 0, cache),
				w: A2(author$project$World$Component$TileLayer$others, 0, _static)
			};
		} else {
			var _n2 = A2(author$project$Tiled$Util$animation, info, tileId - info.ac);
			if (!_n2.$) {
				var anim = _n2.a;
				return {
					v: A2(
						author$project$World$Component$TileLayer$others,
						tileId,
						A3(
							elm$core$Dict$insert,
							tileId,
							_Utils_Tuple2(
								_Utils_Tuple2(info, anim),
								A2(elm$core$List$cons, 1, cache)),
							animated)),
					D: A2(elm$core$List$cons, 0, cache),
					w: A2(author$project$World$Component$TileLayer$others, 0, _static)
				};
			} else {
				var relativeId = (tileId - info.ac) + 1;
				var _n3 = A2(elm$core$Dict$get, info.ac, _static);
				if (!_n3.$) {
					var _n4 = _n3.a;
					var t_ = _n4.a;
					var v = _n4.b;
					return {
						v: A2(author$project$World$Component$TileLayer$others, 0, animated),
						D: A2(elm$core$List$cons, 0, cache),
						w: A2(
							author$project$World$Component$TileLayer$others,
							info.ac,
							A3(
								elm$core$Dict$insert,
								info.ac,
								_Utils_Tuple2(
									t_,
									A2(elm$core$List$cons, relativeId, v)),
								_static))
					};
				} else {
					return {
						v: A2(author$project$World$Component$TileLayer$others, 0, animated),
						D: A2(elm$core$List$cons, 0, cache),
						w: A2(
							author$project$World$Component$TileLayer$others,
							info.ac,
							A3(
								elm$core$Dict$insert,
								info.ac,
								_Utils_Tuple2(
									info,
									A2(elm$core$List$cons, relativeId, cache)),
								_static))
					};
				}
			}
		}
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
var author$project$World$Component$TileLayer$splitTileLayerByTileSet = F3(
	function (tilesets, dataLeft, acc) {
		splitTileLayerByTileSet:
		while (true) {
			var cache = acc.D;
			var _static = acc.w;
			var animated = acc.v;
			if (dataLeft.b) {
				var gid = dataLeft.a;
				var rest = dataLeft.b;
				if (!gid) {
					var $temp$tilesets = tilesets,
						$temp$dataLeft = rest,
						$temp$acc = {
						v: A2(author$project$World$Component$TileLayer$others, 0, animated),
						D: A2(elm$core$List$cons, 0, cache),
						w: A2(author$project$World$Component$TileLayer$others, 0, _static)
					};
					tilesets = $temp$tilesets;
					dataLeft = $temp$dataLeft;
					acc = $temp$acc;
					continue splitTileLayerByTileSet;
				} else {
					var _n1 = A2(author$project$Tiled$Util$tilesetById, tilesets, gid);
					if (!_n1.$) {
						switch (_n1.a.$) {
							case 1:
								var info = _n1.a.a;
								var $temp$tilesets = tilesets,
									$temp$dataLeft = rest,
									$temp$acc = A3(author$project$World$Component$TileLayer$fillTiles, gid, info, acc);
								tilesets = $temp$tilesets;
								dataLeft = $temp$dataLeft;
								acc = $temp$acc;
								continue splitTileLayerByTileSet;
							case 0:
								var was = _n1.a;
								var firstgid = was.a.ac;
								var source = was.a.cJ;
								return A2(
									elm$core$Basics$composeR,
									A2(author$project$ResourceTask$getTileset, '/assets/' + source, firstgid),
									author$project$ResourceTask$andThen(
										function (tileset) {
											return A3(
												author$project$World$Component$TileLayer$splitTileLayerByTileSet,
												A4(author$project$Tiled$Util$updateTileset, was, tileset, tilesets, _List_Nil),
												dataLeft,
												acc);
										}));
							default:
								var info = _n1.a.a;
								var $temp$tilesets = tilesets,
									$temp$dataLeft = rest,
									$temp$acc = _Utils_update(
									acc,
									{
										D: A2(elm$core$List$cons, 0, cache)
									});
								tilesets = $temp$tilesets;
								dataLeft = $temp$dataLeft;
								acc = $temp$acc;
								continue splitTileLayerByTileSet;
						}
					} else {
						return author$project$ResourceTask$fail(
							A2(
								author$project$Error$Error,
								5000,
								'Not found Tileset for GID:' + elm$core$String$fromInt(gid)));
					}
				}
			} else {
				return author$project$ResourceTask$succeed(
					{
						v: elm$core$Dict$values(acc.v),
						w: elm$core$Dict$values(acc.w),
						br: tilesets
					});
			}
		}
	});
var author$project$Image$Bit24 = 0;
var author$project$Image$RightUp = 1;
var author$project$Image$defaultOptions = {c2: 16776960, c3: 0, ds: 1};
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
var elm$core$List$takeReverse = F3(
	function (n, list, kept) {
		takeReverse:
		while (true) {
			if (n <= 0) {
				return kept;
			} else {
				if (!list.b) {
					return kept;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs,
						$temp$kept = A2(elm$core$List$cons, x, kept);
					n = $temp$n;
					list = $temp$list;
					kept = $temp$kept;
					continue takeReverse;
				}
			}
		}
	});
var elm$core$List$takeTailRec = F2(
	function (n, list) {
		return elm$core$List$reverse(
			A3(elm$core$List$takeReverse, n, list, _List_Nil));
	});
var elm$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (n <= 0) {
			return _List_Nil;
		} else {
			var _n0 = _Utils_Tuple2(n, list);
			_n0$1:
			while (true) {
				_n0$5:
				while (true) {
					if (!_n0.b.b) {
						return list;
					} else {
						if (_n0.b.b.b) {
							switch (_n0.a) {
								case 1:
									break _n0$1;
								case 2:
									var _n2 = _n0.b;
									var x = _n2.a;
									var _n3 = _n2.b;
									var y = _n3.a;
									return _List_fromArray(
										[x, y]);
								case 3:
									if (_n0.b.b.b.b) {
										var _n4 = _n0.b;
										var x = _n4.a;
										var _n5 = _n4.b;
										var y = _n5.a;
										var _n6 = _n5.b;
										var z = _n6.a;
										return _List_fromArray(
											[x, y, z]);
									} else {
										break _n0$5;
									}
								default:
									if (_n0.b.b.b.b && _n0.b.b.b.b.b) {
										var _n7 = _n0.b;
										var x = _n7.a;
										var _n8 = _n7.b;
										var y = _n8.a;
										var _n9 = _n8.b;
										var z = _n9.a;
										var _n10 = _n9.b;
										var w = _n10.a;
										var tl = _n10.b;
										return (ctr > 1000) ? A2(
											elm$core$List$cons,
											x,
											A2(
												elm$core$List$cons,
												y,
												A2(
													elm$core$List$cons,
													z,
													A2(
														elm$core$List$cons,
														w,
														A2(elm$core$List$takeTailRec, n - 4, tl))))) : A2(
											elm$core$List$cons,
											x,
											A2(
												elm$core$List$cons,
												y,
												A2(
													elm$core$List$cons,
													z,
													A2(
														elm$core$List$cons,
														w,
														A3(elm$core$List$takeFast, ctr + 1, n - 4, tl)))));
									} else {
										break _n0$5;
									}
							}
						} else {
							if (_n0.a === 1) {
								break _n0$1;
							} else {
								break _n0$5;
							}
						}
					}
				}
				return list;
			}
			var _n1 = _n0.b;
			var x = _n1.a;
			return _List_fromArray(
				[x]);
		}
	});
var elm$core$List$take = F2(
	function (n, list) {
		return A3(elm$core$List$takeFast, 0, n, list);
	});
var author$project$Image$BMP$greedyGroupsOfWithStep = F5(
	function (f, acc, size, step, xs) {
		greedyGroupsOfWithStep:
		while (true) {
			var xs_ = A2(elm$core$List$drop, step, xs);
			var okayXs = elm$core$List$length(xs) > 0;
			var okayArgs = (size > 0) && (step > 0);
			if (okayArgs && okayXs) {
				var $temp$f = f,
					$temp$acc = A2(
					f,
					A2(elm$core$List$take, size, xs),
					acc),
					$temp$size = size,
					$temp$step = step,
					$temp$xs = xs_;
				f = $temp$f;
				acc = $temp$acc;
				size = $temp$size;
				step = $temp$step;
				xs = $temp$xs;
				continue greedyGroupsOfWithStep;
			} else {
				return acc;
			}
		}
	});
var elm$bytes$Bytes$LE = 0;
var elm$bytes$Bytes$Encode$Seq = F2(
	function (a, b) {
		return {$: 8, a: a, b: b};
	});
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
var elm$bytes$Bytes$Encode$U8 = function (a) {
	return {$: 3, a: a};
};
var elm$bytes$Bytes$Encode$unsignedInt8 = elm$bytes$Bytes$Encode$U8;
var elm$core$Bitwise$shiftRightBy = _Bitwise_shiftRightBy;
var author$project$Image$BMP$unsignedInt24 = F2(
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
var author$project$Image$BMP$lineFolder24 = F2(
	function (pixelInLineLeft, acc) {
		if (pixelInLineLeft.b) {
			if (pixelInLineLeft.b.b) {
				if (pixelInLineLeft.b.b.b) {
					if (pixelInLineLeft.b.b.b.b) {
						var e1 = pixelInLineLeft.a;
						var _n1 = pixelInLineLeft.b;
						var e2 = _n1.a;
						var _n2 = _n1.b;
						var e3 = _n2.a;
						var _n3 = _n2.b;
						var e4 = _n3.a;
						var rest = _n3.b;
						return A2(
							author$project$Image$BMP$lineFolder24,
							rest,
							_Utils_ap(
								acc,
								_List_fromArray(
									[
										A2(author$project$Image$BMP$unsignedInt24, 0, e1),
										A2(author$project$Image$BMP$unsignedInt24, 0, e2),
										A2(author$project$Image$BMP$unsignedInt24, 0, e3),
										A2(author$project$Image$BMP$unsignedInt24, 0, e4)
									])));
					} else {
						var e1 = pixelInLineLeft.a;
						var _n4 = pixelInLineLeft.b;
						var e2 = _n4.a;
						var _n5 = _n4.b;
						var e3 = _n5.a;
						return _Utils_ap(
							acc,
							_List_fromArray(
								[
									A2(author$project$Image$BMP$unsignedInt24, 0, e1),
									A2(author$project$Image$BMP$unsignedInt24, 0, e2),
									A2(author$project$Image$BMP$unsignedInt24, 0, e3),
									elm$bytes$Bytes$Encode$unsignedInt8(0),
									elm$bytes$Bytes$Encode$unsignedInt8(0),
									elm$bytes$Bytes$Encode$unsignedInt8(0)
								]));
					}
				} else {
					var e1 = pixelInLineLeft.a;
					var _n6 = pixelInLineLeft.b;
					var e2 = _n6.a;
					return _Utils_ap(
						acc,
						_List_fromArray(
							[
								A2(author$project$Image$BMP$unsignedInt24, 0, e1),
								A2(author$project$Image$BMP$unsignedInt24, 0, e2),
								elm$bytes$Bytes$Encode$unsignedInt8(0),
								elm$bytes$Bytes$Encode$unsignedInt8(0)
							]));
				}
			} else {
				var e1 = pixelInLineLeft.a;
				return _Utils_ap(
					acc,
					_List_fromArray(
						[
							A2(author$project$Image$BMP$unsignedInt24, 0, e1),
							elm$bytes$Bytes$Encode$unsignedInt8(0)
						]));
			}
		} else {
			return acc;
		}
	});
var author$project$Image$BMP$lineFolder24reverse = F2(
	function (pixelInLineLeft, acc) {
		if (pixelInLineLeft.b) {
			if (pixelInLineLeft.b.b) {
				if (pixelInLineLeft.b.b.b) {
					if (pixelInLineLeft.b.b.b.b) {
						var e1 = pixelInLineLeft.a;
						var _n1 = pixelInLineLeft.b;
						var e2 = _n1.a;
						var _n2 = _n1.b;
						var e3 = _n2.a;
						var _n3 = _n2.b;
						var e4 = _n3.a;
						var rest = _n3.b;
						return A2(
							author$project$Image$BMP$lineFolder24reverse,
							rest,
							A2(
								elm$core$List$cons,
								A2(author$project$Image$BMP$unsignedInt24, 0, e4),
								A2(
									elm$core$List$cons,
									A2(author$project$Image$BMP$unsignedInt24, 0, e3),
									A2(
										elm$core$List$cons,
										A2(author$project$Image$BMP$unsignedInt24, 0, e2),
										A2(
											elm$core$List$cons,
											A2(author$project$Image$BMP$unsignedInt24, 0, e1),
											acc)))));
					} else {
						var e1 = pixelInLineLeft.a;
						var _n4 = pixelInLineLeft.b;
						var e2 = _n4.a;
						var _n5 = _n4.b;
						var e3 = _n5.a;
						return A2(
							elm$core$List$cons,
							A2(author$project$Image$BMP$unsignedInt24, 0, e3),
							A2(
								elm$core$List$cons,
								A2(author$project$Image$BMP$unsignedInt24, 0, e2),
								A2(
									elm$core$List$cons,
									A2(author$project$Image$BMP$unsignedInt24, 0, e1),
									_Utils_ap(
										acc,
										_List_fromArray(
											[
												elm$bytes$Bytes$Encode$unsignedInt8(0),
												elm$bytes$Bytes$Encode$unsignedInt8(0),
												elm$bytes$Bytes$Encode$unsignedInt8(0)
											])))));
					}
				} else {
					var e1 = pixelInLineLeft.a;
					var _n6 = pixelInLineLeft.b;
					var e2 = _n6.a;
					return A2(
						elm$core$List$cons,
						A2(author$project$Image$BMP$unsignedInt24, 0, e2),
						A2(
							elm$core$List$cons,
							A2(author$project$Image$BMP$unsignedInt24, 0, e1),
							_Utils_ap(
								acc,
								_List_fromArray(
									[
										elm$bytes$Bytes$Encode$unsignedInt8(0),
										elm$bytes$Bytes$Encode$unsignedInt8(0)
									]))));
				}
			} else {
				var e1 = pixelInLineLeft.a;
				return A2(
					elm$core$List$cons,
					A2(author$project$Image$BMP$unsignedInt24, 0, e1),
					_Utils_ap(
						acc,
						_List_fromArray(
							[
								elm$bytes$Bytes$Encode$unsignedInt8(0)
							])));
			}
		} else {
			return acc;
		}
	});
var author$project$Image$BMP$encodeImageData = F3(
	function (w, _n0, pxs) {
		var depth = _n0.c3;
		var order = _n0.ds;
		var delme = F2(
			function (line, acc) {
				switch (order) {
					case 0:
						return _Utils_ap(
							A2(author$project$Image$BMP$lineFolder24, line, _List_Nil),
							acc);
					case 1:
						return _Utils_ap(
							acc,
							A2(author$project$Image$BMP$lineFolder24, line, _List_Nil));
					case 2:
						return _Utils_ap(
							A2(author$project$Image$BMP$lineFolder24reverse, line, _List_Nil),
							acc);
					default:
						return _Utils_ap(
							acc,
							A2(author$project$Image$BMP$lineFolder24reverse, line, _List_Nil));
				}
			});
		return elm$bytes$Bytes$Encode$sequence(
			A5(author$project$Image$BMP$greedyGroupsOfWithStep, delme, _List_Nil, w, w, pxs));
	});
var elm$bytes$Bytes$BE = 1;
var elm$bytes$Bytes$Encode$U16 = F2(
	function (a, b) {
		return {$: 4, a: a, b: b};
	});
var elm$bytes$Bytes$Encode$unsignedInt16 = elm$bytes$Bytes$Encode$U16;
var elm$bytes$Bytes$Encode$U32 = F2(
	function (a, b) {
		return {$: 5, a: a, b: b};
	});
var elm$bytes$Bytes$Encode$unsignedInt32 = elm$bytes$Bytes$Encode$U32;
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
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 16),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 2835),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 2835),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 0),
				A2(elm$bytes$Bytes$Encode$unsignedInt32, 0, 0)
			]);
	});
var elm$bytes$Bytes$Decode$Done = function (a) {
	return {$: 1, a: a};
};
var elm$bytes$Bytes$Decode$Loop = function (a) {
	return {$: 0, a: a};
};
var elm$bytes$Bytes$Decode$Decoder = elm$core$Basics$identity;
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
var elm$bytes$Bytes$width = _Bytes_width;
var elm$bytes$Bytes$Decode$decode = F2(
	function (_n0, bs) {
		var decoder = _n0;
		return A2(_Bytes_decode, decoder, bs);
	});
var danfishgold$base64_bytes$Decode$fromBytes = function (bytes) {
	return A2(
		elm$bytes$Bytes$Decode$decode,
		danfishgold$base64_bytes$Decode$decoder(
			elm$bytes$Bytes$width(bytes)),
		bytes);
};
var danfishgold$base64_bytes$Base64$fromBytes = danfishgold$base64_bytes$Decode$fromBytes;
var elm$bytes$Bytes$Encode$Bytes = function (a) {
	return {$: 10, a: a};
};
var elm$bytes$Bytes$Encode$bytes = elm$bytes$Bytes$Encode$Bytes;
var elm$bytes$Bytes$Encode$encode = _Bytes_encode;
var author$project$Image$BMP$encodeWith = F4(
	function (opt, w, h, pixels) {
		var pixels_ = elm$bytes$Bytes$Encode$encode(
			A3(author$project$Image$BMP$encodeImageData, w, opt, pixels));
		var result = _Utils_ap(
			A3(
				author$project$Image$BMP$header,
				w,
				h,
				elm$bytes$Bytes$width(pixels_)),
			_List_fromArray(
				[
					elm$bytes$Bytes$Encode$bytes(pixels_)
				]));
		var imageData = A2(
			elm$core$Maybe$withDefault,
			'',
			danfishgold$base64_bytes$Base64$fromBytes(
				elm$bytes$Bytes$Encode$encode(
					elm$bytes$Bytes$Encode$sequence(result))));
		return 'data:image/bmp;base64,' + imageData;
	});
var author$project$Layer$AbimatedTiles = function (a) {
	return {$: 1, a: a};
};
var elm$core$List$concatMap = F2(
	function (f, list) {
		return elm$core$List$concat(
			A2(elm$core$List$map, f, list));
	});
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
var author$project$World$Component$TileLayer$animationFraming = function (anim) {
	return A2(
		elm$core$List$concatMap,
		function (_n0) {
			var duration = _n0.bJ;
			var tileid = _n0.cS;
			return A2(
				elm$core$List$repeat,
				elm$core$Basics$floor((duration / 1000) * author$project$Defaults$default.dc),
				tileid);
		},
		anim);
};
var author$project$Image$LeftUp = 3;
var author$project$World$Component$TileLayer$imageOptions = function () {
	var opt = author$project$Image$defaultOptions;
	return _Utils_update(
		opt,
		{ds: 3});
}();
var author$project$World$Component$TileLayer$tileAnimatedLayerBuilder = function (layerData) {
	return elm$core$List$map(
		function (_n0) {
			var _n1 = _n0.a;
			var tileset = _n1.a;
			var anim = _n1.b;
			var data = _n0.b;
			var tilsetProps = author$project$Tiled$Util$properties(tileset);
			var layerProps = author$project$Tiled$Util$properties(layerData);
			var animLutData = author$project$World$Component$TileLayer$animationFraming(anim);
			var animLength = elm$core$List$length(animLutData);
			return A2(
				elm$core$Basics$composeR,
				author$project$ResourceTask$getTexture('/assets/' + tileset.a3),
				author$project$ResourceTask$andThen(
					function (tileSetImage) {
						return A2(
							elm$core$Basics$composeR,
							author$project$ResourceTask$getTexture(
								A4(author$project$Image$BMP$encodeWith, author$project$World$Component$TileLayer$imageOptions, layerData.ak, layerData.ae, data)),
							author$project$ResourceTask$andThen(
								function (lut) {
									return A2(
										elm$core$Basics$composeR,
										author$project$ResourceTask$getTexture(
											A4(author$project$Image$BMP$encodeWith, author$project$Image$defaultOptions, animLength, 1, animLutData)),
										author$project$ResourceTask$map(
											function (animLUT) {
												return author$project$Layer$AbimatedTiles(
													{
														aY: animLUT,
														aZ: animLength,
														a7: lut,
														a8: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, layerData.ak, layerData.ae),
														dD: A2(
															author$project$Tiled$Util$scrollRatio,
															_Utils_eq(
																A2(elm$core$Dict$get, 'scrollRatio', layerData.R),
																elm$core$Maybe$Nothing),
															layerProps),
														bm: tileSetImage,
														bn: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, tileset.aM, tileset.aL),
														bo: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, tileset.bs, tileset.bq),
														dO: A2(tilsetProps.a0, 'transparentcolor', author$project$Defaults$default.dO)
													});
											}));
								}));
					}));
		});
};
var author$project$Layer$Tiles = function (a) {
	return {$: 0, a: a};
};
var author$project$World$Component$TileLayer$tileStaticLayerBuilder = function (layerData) {
	return elm$core$List$map(
		function (_n0) {
			var tileset = _n0.a;
			var data = _n0.b;
			var tilsetProps = author$project$Tiled$Util$properties(tileset);
			var layerProps = author$project$Tiled$Util$properties(layerData);
			return A2(
				elm$core$Basics$composeR,
				author$project$ResourceTask$getTexture('/assets/' + tileset.a3),
				author$project$ResourceTask$andThen(
					function (tileSetImage) {
						return A2(
							elm$core$Basics$composeR,
							author$project$ResourceTask$getTexture(
								A4(author$project$Image$BMP$encodeWith, author$project$World$Component$TileLayer$imageOptions, layerData.ak, layerData.ae, data)),
							author$project$ResourceTask$map(
								function (lut) {
									return author$project$Layer$Tiles(
										{
											a7: lut,
											a8: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, layerData.ak, layerData.ae),
											dD: A2(
												author$project$Tiled$Util$scrollRatio,
												_Utils_eq(
													A2(elm$core$Dict$get, 'scrollRatio', layerData.R),
													elm$core$Maybe$Nothing),
												layerProps),
											bm: tileSetImage,
											bn: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, tileset.aM, tileset.aL),
											bo: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, tileset.bs, tileset.bq),
											dO: A2(tilsetProps.a0, 'transparentcolor', author$project$Defaults$default.dO)
										});
								}));
					}));
		});
};
var author$project$World$Component$TileLayer$tileLayer = F2(
	function (tilesets_, layerData) {
		var data = layerData.aD;
		return A2(
			elm$core$Basics$composeR,
			A3(
				author$project$World$Component$TileLayer$splitTileLayerByTileSet,
				tilesets_,
				data,
				{v: elm$core$Dict$empty, D: _List_Nil, w: elm$core$Dict$empty}),
			author$project$ResourceTask$andThen(
				function (_n0) {
					var tilesets = _n0.br;
					var animated = _n0.v;
					var _static = _n0.w;
					return A2(
						elm$core$Basics$composeR,
						author$project$ResourceTask$sequence(
							_Utils_ap(
								A2(author$project$World$Component$TileLayer$tileStaticLayerBuilder, layerData, _static),
								A2(author$project$World$Component$TileLayer$tileAnimatedLayerBuilder, layerData, animated))),
						author$project$ResourceTask$map(
							function (layers) {
								return _Utils_Tuple2(layers, tilesets);
							}));
				}));
	});
var author$project$World$Create$objFix = F2(
	function (levelHeight, obj) {
		switch (obj.$) {
			case 0:
				var common = obj.a;
				return obj;
			case 1:
				var common = obj.a;
				var dimension = obj.b;
				return obj;
			case 2:
				var common = obj.a;
				var dimension = obj.b;
				return obj;
			case 3:
				var common = obj.a;
				var dimension = obj.b;
				var polyPoints = obj.c;
				return obj;
			case 4:
				var common = obj.a;
				var dimension = obj.b;
				var polyPoints = obj.c;
				return obj;
			default:
				var common = obj.a;
				var dimension = obj.b;
				var gid = obj.c;
				return A3(
					author$project$Tiled$Object$Tile,
					_Utils_update(
						common,
						{by: common.by + (dimension.ak / 2), bz: (levelHeight - common.bz) + (dimension.ae / 2)}),
					dimension,
					gid);
		}
	});
var author$project$World$Create$init = F4(
	function (emptyECS, readers, level, start) {
		var fix = author$project$World$Create$objFix(
			function (_n3) {
				var height = _n3.ae;
				var tileheight = _n3.bq;
				return tileheight * height;
			}(
				author$project$Tiled$Util$common(level)));
		var layersTask = A3(
			elm$core$List$foldr,
			F2(
				function (layer, acc) {
					switch (layer.$) {
						case 0:
							var imageData = layer.a;
							return A2(
								author$project$ResourceTask$andThen,
								function (info) {
									return A2(
										elm$core$Basics$composeR,
										author$project$World$Component$ImageLayer$imageLayer(imageData),
										author$project$ResourceTask$map(
											function (l) {
												return _Utils_update(
													info,
													{
														aN: A2(elm$core$List$cons, l, info.aN)
													});
											}));
								},
								acc);
						case 2:
							var tileData = layer.a;
							return A2(
								author$project$ResourceTask$andThen,
								function (info) {
									return A2(
										elm$core$Basics$composeR,
										A2(author$project$World$Component$TileLayer$tileLayer, info.br, tileData),
										author$project$ResourceTask$map(
											function (_n2) {
												var l = _n2.a;
												var t = _n2.b;
												return _Utils_update(
													info,
													{
														aN: _Utils_ap(l, info.aN),
														br: t
													});
											}));
								},
								acc);
						case 1:
							var objectData = layer.a;
							return A2(
								author$project$ResourceTask$andThen,
								function (info) {
									return A4(author$project$World$Component$ObjetLayer$objectLayer, fix, readers, info, objectData);
								},
								acc);
						default:
							return acc;
					}
				}),
			A2(
				author$project$ResourceTask$succeed,
				{
					aF: emptyECS,
					M: 0,
					aN: _List_Nil,
					br: author$project$Tiled$Util$tilesets(level)
				},
				start),
			author$project$Tiled$Util$common(level).aN);
		var camera = author$project$World$Camera$init(level);
		return A2(
			author$project$ResourceTask$map,
			function (_n0) {
				var layers = _n0.aN;
				var ecs = _n0.aF;
				return A2(
					author$project$World$World,
					{c$: camera, bQ: author$project$Logic$GameFlow$Running, aI: 0, aN: layers, aT: 0},
					ecs);
			},
			layersTask);
	});
var elm$core$Platform$Cmd$batch = _Platform_batch;
var elm$core$Platform$Cmd$map = _Platform_map;
var author$project$Game$init_ = F3(
	function (empty, readers, flags) {
		var levelUrl = A2(
			elm$core$Result$withDefault,
			'default.json',
			A2(
				elm$json$Json$Decode$decodeValue,
				A2(elm$json$Json$Decode$field, 'levelUrl', elm$json$Json$Decode$string),
				flags));
		var resourceTask = A2(
			author$project$ResourceTask$andThen,
			A2(author$project$World$Create$init, empty, readers),
			A2(author$project$ResourceTask$getLevel, levelUrl, author$project$ResourceTask$init));
		var _n0 = author$project$Environment$init(flags);
		var env = _n0.a;
		var envMsg = _n0.b;
		return _Utils_Tuple2(
			{
				y: env,
				S: elm$core$Result$Err(
					A2(author$project$Error$Error, 0, 'Loading...'))
			},
			elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[
						A2(elm$core$Platform$Cmd$map, author$project$Game$Environment, envMsg),
						A2(author$project$ResourceTask$attempt, author$project$Game$Resource, resourceTask)
					])));
	});
var author$project$Environment$update = F2(
	function (msg, model) {
		var w = msg.a;
		var h = msg.b;
		return _Utils_update(
			model,
			{ae: h, ak: w, bw: w / h});
	});
var elm$json$Json$Encode$null = _Json_encodeNull;
var author$project$Game$start = _Platform_outgoingPort(
	'start',
	function ($) {
		return elm$json$Json$Encode$null;
	});
var author$project$Game$wrap = F2(
	function (m, data) {
		return _Utils_update(
			m,
			{
				S: elm$core$Result$Ok(
					function (_n0) {
						var a = _n0.a;
						var b = _n0.b;
						return A2(author$project$World$World, a, b);
					}(data))
			});
	});
var author$project$Logic$GameFlow$SlowMotion = function (a) {
	return {$: 2, a: a};
};
var author$project$Logic$GameFlow$default = {dc: 60};
var author$project$Logic$GameFlow$resetRuntime = F2(
	function (fps, frames) {
		return frames / fps;
	});
var elm$core$Basics$min = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) < 0) ? x : y;
	});
var author$project$Logic$GameFlow$updateRuntime = F3(
	function (_n0, delta, fps) {
		var world = _n0.a;
		var world2 = _n0.b;
		var thresholdTime = (1 / fps) * 12;
		var deltaSec = delta / 1000;
		var newRuntime = world.aT + A2(elm$core$Basics$min, deltaSec, thresholdTime);
		var countOfFrames = elm$core$Basics$round(
			A2(elm$core$Basics$min, fps * thresholdTime, (newRuntime * fps) - world.aI));
		return _Utils_Tuple2(
			_Utils_Tuple2(
				_Utils_update(
					world,
					{aT: newRuntime}),
				world2),
			countOfFrames);
	});
var author$project$Logic$GameFlow$worldUpdate = F3(
	function (system, framesLeft, model) {
		worldUpdate:
		while (true) {
			var world = model.a;
			var world2 = model.b;
			if (framesLeft < 1) {
				return model;
			} else {
				var _n0 = system(model);
				var newWorld = _n0.a;
				var newWorld2 = _n0.b;
				var $temp$system = system,
					$temp$framesLeft = framesLeft - 1,
					$temp$model = _Utils_Tuple2(
					_Utils_update(
						newWorld,
						{aI: newWorld.aI + 1}),
					newWorld2);
				system = $temp$system;
				framesLeft = $temp$framesLeft;
				model = $temp$model;
				continue worldUpdate;
			}
		}
	});
var author$project$Logic$GameFlow$updateWith = F3(
	function (systems, delta, model) {
		var world = model.a;
		var _n0 = function () {
			var _n1 = world.bQ;
			switch (_n1.$) {
				case 0:
					return A3(author$project$Logic$GameFlow$updateRuntime, model, delta, author$project$Logic$GameFlow$default.dc);
				case 1:
					return A3(author$project$Logic$GameFlow$updateRuntime, model, delta, 0);
				default:
					var current = _n1.a;
					var _n2 = A3(author$project$Logic$GameFlow$updateRuntime, model, delta, current.dc);
					var _n3 = _n2.a;
					var newWorld = _n3.a;
					var newWorld2 = _n3.b;
					var countOfFrames_ = _n2.b;
					var framesLeft = current.bS - countOfFrames_;
					var _n4 = (framesLeft < 0) ? _Utils_Tuple2(
						author$project$Logic$GameFlow$Running,
						A2(author$project$Logic$GameFlow$resetRuntime, author$project$Logic$GameFlow$default.dc, newWorld.aI)) : _Utils_Tuple2(
						author$project$Logic$GameFlow$SlowMotion(
							_Utils_update(
								current,
								{bS: framesLeft})),
						newWorld.aT);
					var flow = _n4.a;
					var runtime = _n4.b;
					return _Utils_Tuple2(
						_Utils_Tuple2(
							_Utils_update(
								newWorld,
								{bQ: flow, aT: runtime}),
							newWorld2),
						countOfFrames_);
			}
		}();
		var worldWithUpdatedRuntime = _n0.a;
		var countOfFrames = _n0.b;
		return ((countOfFrames > 0) ? A2(author$project$Logic$GameFlow$worldUpdate, systems, countOfFrames) : elm$core$Basics$identity)(worldWithUpdatedRuntime);
	});
var elm$core$Platform$Cmd$none = elm$core$Platform$Cmd$batch(_List_Nil);
var author$project$Game$update = F3(
	function (system, msg, model) {
		var _n0 = _Utils_Tuple2(msg, model.S);
		_n0$5:
		while (true) {
			switch (_n0.a.$) {
				case 1:
					if (!_n0.b.$) {
						var delta = _n0.a.a;
						var _n1 = _n0.b.a;
						var world = _n1.a;
						var ecs = _n1.b;
						return _Utils_Tuple2(
							A2(
								author$project$Game$wrap,
								model,
								A3(
									author$project$Logic$GameFlow$updateWith,
									system,
									delta,
									_Utils_Tuple2(world, ecs))),
							elm$core$Platform$Cmd$none);
					} else {
						break _n0$5;
					}
				case 2:
					if (!_n0.b.$) {
						var custom = _n0.a.a;
						var _n2 = _n0.b.a;
						var world = _n2.a;
						var ecs = _n2.b;
						return _Utils_Tuple2(
							A2(author$project$Game$wrap, model, custom),
							elm$core$Platform$Cmd$none);
					} else {
						break _n0$5;
					}
				case 0:
					var info = _n0.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								y: A2(author$project$Environment$update, info, model.y)
							}),
						elm$core$Platform$Cmd$none);
				default:
					if (!_n0.a.a.$) {
						var resource = _n0.a.a.a;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									S: elm$core$Result$Ok(resource)
								}),
							author$project$Game$start(0));
					} else {
						var resource = _n0.a.a;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{S: resource}),
							elm$core$Platform$Cmd$none);
					}
			}
		}
		return _Utils_Tuple2(model, elm$core$Platform$Cmd$none);
	});
var elm$virtual_dom$VirtualDom$attribute = F2(
	function (key, value) {
		return A2(
			_VirtualDom_attribute,
			_VirtualDom_noOnOrFormAction(key),
			_VirtualDom_noJavaScriptOrHtmlUri(value));
	});
var elm$virtual_dom$VirtualDom$style = _VirtualDom_style;
var author$project$Environment$style = function (env) {
	return _List_fromArray(
		[
			A2(
			elm$virtual_dom$VirtualDom$attribute,
			'width',
			elm$core$String$fromInt(
				elm$core$Basics$round(env.ak * env.aE))),
			A2(
			elm$virtual_dom$VirtualDom$attribute,
			'height',
			elm$core$String$fromInt(
				elm$core$Basics$round(env.ae * env.aE))),
			A2(elm$virtual_dom$VirtualDom$style, 'display', 'block'),
			A2(
			elm$virtual_dom$VirtualDom$style,
			'width',
			elm$core$String$fromInt(env.ak) + 'px'),
			A2(
			elm$virtual_dom$VirtualDom$style,
			'height',
			elm$core$String$fromInt(env.ae) + 'px')
		]);
};
var author$project$Layer$Common$Layer = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var author$project$Layer$Image$fragmentShaderRepeat = {
	src: '\n        precision mediump float;\n        varying vec2 vcoord;\n\n        uniform sampler2D image;\n        uniform vec3 transparentcolor;\n        uniform float pixelsPerUnit;\n        uniform vec2 viewportOffset;\n        uniform vec2 scrollRatio;\n        uniform vec2 size;\n\n        void main () {\n            //(2i + 1)/(2N) Pixel center\n            vec2 pixel = (floor(vcoord * pixelsPerUnit + viewportOffset * scrollRatio) + 0.5 ) / size;\n            gl_FragColor = texture2D(image, mod(pixel, 1.0));\n            gl_FragColor.rgb *= gl_FragColor.a;\n        }\n    ',
	attributes: {},
	uniforms: {image: 'a3', pixelsPerUnit: 'dt', scrollRatio: 'dD', size: 'bj', transparentcolor: 'dO', viewportOffset: 'dR'}
};
var author$project$Layer$Common$Vertex = function (position) {
	return {du: position};
};
var elm_explorations$webgl$WebGL$Mesh3 = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var elm_explorations$webgl$WebGL$triangles = elm_explorations$webgl$WebGL$Mesh3(
	{E: 3, F: 0, H: 4});
var author$project$Layer$Common$mesh = elm_explorations$webgl$WebGL$triangles(
	_List_fromArray(
		[
			_Utils_Tuple3(
			author$project$Layer$Common$Vertex(
				A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 1)),
			author$project$Layer$Common$Vertex(
				A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 1, 0)),
			author$project$Layer$Common$Vertex(
				A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0))),
			_Utils_Tuple3(
			author$project$Layer$Common$Vertex(
				A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 1)),
			author$project$Layer$Common$Vertex(
				A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 1, 1)),
			author$project$Layer$Common$Vertex(
				A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 1, 0)))
		]));
var author$project$Layer$Common$vertexShader = {
	src: '\n        attribute vec2 position;\n        uniform float widthRatio;\n\n        varying vec2 vcoord;\n        mat4 viewport = mat4(\n            (2.0 / widthRatio), 0, 0, 0,\n		 	                 0, 2, 0, 0,\n		 			         0, 0,-1, 0,\n		 			        -1,-1, 0, 1);\n        void main () {\n          vcoord = vec2(position.x * widthRatio, position.y);\n          gl_Position = viewport * vec4(vcoord, 0, 1.0);\n        }\n    ',
	attributes: {position: 'du'},
	uniforms: {widthRatio: 'bw'}
};
var elm_explorations$webgl$WebGL$Internal$disableSetting = F2(
	function (gl, setting) {
		switch (setting.$) {
			case 0:
				return _WebGL_disableBlend(gl);
			case 1:
				return _WebGL_disableDepthTest(gl);
			case 2:
				return _WebGL_disableStencilTest(gl);
			case 3:
				return _WebGL_disableScissor(gl);
			case 4:
				return _WebGL_disableColorMask(gl);
			case 5:
				return _WebGL_disableCullFace(gl);
			case 6:
				return _WebGL_disablePolygonOffset(gl);
			case 7:
				return _WebGL_disableSampleCoverage(gl);
			default:
				return _WebGL_disableSampleAlphaToCoverage(gl);
		}
	});
var elm_explorations$webgl$WebGL$Internal$enableOption = F2(
	function (ctx, option) {
		switch (option.$) {
			case 0:
				return A2(_WebGL_enableAlpha, ctx, option);
			case 1:
				return A2(_WebGL_enableDepth, ctx, option);
			case 2:
				return A2(_WebGL_enableStencil, ctx, option);
			case 3:
				return A2(_WebGL_enableAntialias, ctx, option);
			default:
				return A2(_WebGL_enableClearColor, ctx, option);
		}
	});
var elm_explorations$webgl$WebGL$Internal$enableSetting = F2(
	function (gl, setting) {
		switch (setting.$) {
			case 0:
				return A2(_WebGL_enableBlend, gl, setting);
			case 1:
				return A2(_WebGL_enableDepthTest, gl, setting);
			case 2:
				return A2(_WebGL_enableStencilTest, gl, setting);
			case 3:
				return A2(_WebGL_enableScissor, gl, setting);
			case 4:
				return A2(_WebGL_enableColorMask, gl, setting);
			case 5:
				return A2(_WebGL_enableCullFace, gl, setting);
			case 6:
				return A2(_WebGL_enablePolygonOffset, gl, setting);
			case 7:
				return A2(_WebGL_enableSampleCoverage, gl, setting);
			default:
				return A2(_WebGL_enableSampleAlphaToCoverage, gl, setting);
		}
	});
var elm_explorations$webgl$WebGL$entityWith = _WebGL_entity;
var author$project$Layer$Image$render_ = F2(
	function (fragmentShader, _n0) {
		var common = _n0.a;
		var individual = _n0.b;
		return A5(
			elm_explorations$webgl$WebGL$entityWith,
			author$project$Defaults$default.c7,
			author$project$Layer$Common$vertexShader,
			fragmentShader,
			author$project$Layer$Common$mesh,
			{a3: individual.a3, dt: common.dt, dD: individual.dD, bj: individual.bj, cT: common.cT, dO: individual.dO, dR: common.dR, bw: common.bw});
	});
var author$project$Layer$Image$render = author$project$Layer$Image$render_(author$project$Layer$Image$fragmentShaderRepeat);
var author$project$Layer$Image$fragmentShaderNoRepeat = {
	src: '\n        precision mediump float;\n        varying vec2 vcoord;\n\n        uniform sampler2D image;\n        uniform vec3 transparentcolor;\n        uniform float pixelsPerUnit;\n        uniform vec2 viewportOffset;\n        uniform vec2 scrollRatio;\n        uniform vec2 size;\n\n        void main () {\n            //(2i + 1)/(2N) Pixel center\n            vec2 pixel = (floor(vcoord * pixelsPerUnit + viewportOffset * scrollRatio) + 0.5 ) / size;\n            gl_FragColor = texture2D(image, mod(pixel, 1.0));\n            gl_FragColor.a *= float(pixel.x <= 1.0) * float(pixel.y <= 1.0);\n            gl_FragColor.rgb *= gl_FragColor.a;\n        }\n    ',
	attributes: {},
	uniforms: {image: 'a3', pixelsPerUnit: 'dt', scrollRatio: 'dD', size: 'bj', transparentcolor: 'dO', viewportOffset: 'dR'}
};
var author$project$Layer$Image$renderNo = author$project$Layer$Image$render_(author$project$Layer$Image$fragmentShaderNoRepeat);
var author$project$Layer$Image$fragmentShaderRepeatX = {
	src: '\n        precision mediump float;\n        varying vec2 vcoord;\n\n        uniform sampler2D image;\n        uniform vec3 transparentcolor;\n        uniform float pixelsPerUnit;\n        uniform vec2 viewportOffset;\n        uniform vec2 scrollRatio;\n        uniform vec2 size;\n\n        void main () {\n            //(2i + 1)/(2N) Pixel center\n            vec2 pixel = (floor(vcoord * pixelsPerUnit + viewportOffset * scrollRatio) + 0.5 ) / size;\n            gl_FragColor = texture2D(image, mod(pixel, 1.0));\n            gl_FragColor.a *= float(pixel.y <= 1.0);\n            gl_FragColor.rgb *= gl_FragColor.a;\n        }\n    ',
	attributes: {},
	uniforms: {image: 'a3', pixelsPerUnit: 'dt', scrollRatio: 'dD', size: 'bj', transparentcolor: 'dO', viewportOffset: 'dR'}
};
var author$project$Layer$Image$renderX = author$project$Layer$Image$render_(author$project$Layer$Image$fragmentShaderRepeatX);
var author$project$Layer$Image$fragmentShaderRepeatY = {
	src: '\n        precision mediump float;\n        varying vec2 vcoord;\n\n        uniform sampler2D image;\n        uniform vec3 transparentcolor;\n        uniform float pixelsPerUnit;\n        uniform vec2 viewportOffset;\n        uniform vec2 scrollRatio;\n        uniform vec2 size;\n\n        void main () {\n            //(2i + 1)/(2N) Pixel center\n            vec2 pixel = (floor(vcoord * pixelsPerUnit + viewportOffset * scrollRatio) + 0.5 ) / size;\n            gl_FragColor = texture2D(image, mod(pixel, 1.0));\n            gl_FragColor.a *= float(pixel.x <= 1.0);\n            gl_FragColor.rgb *= gl_FragColor.a;\n        }\n    ',
	attributes: {},
	uniforms: {image: 'a3', pixelsPerUnit: 'dt', scrollRatio: 'dD', size: 'bj', transparentcolor: 'dO', viewportOffset: 'dR'}
};
var author$project$Layer$Image$renderY = author$project$Layer$Image$render_(author$project$Layer$Image$fragmentShaderRepeatY);
var author$project$Layer$Tiles$fragmentShader = {
	src: '\n        precision mediump float;\n        varying vec2 vcoord;\n        uniform sampler2D tileSet;\n        uniform sampler2D lut;\n        uniform vec3 transparentcolor;\n        uniform vec2 lutSize;\n        uniform vec2 tileSetSize;\n        uniform float pixelsPerUnit;\n        uniform vec2 tileSize;\n        uniform vec2 viewportOffset;\n        uniform vec2 scrollRatio;\n\n\n        vec2 tilesPerUnit = pixelsPerUnit / tileSize;\n        //float px = 1.0 / pixelsPerUnit;\n\n        float color2float(vec4 c) {\n            return c.z * 255.0\n            + c.y * 256.0 * 255.0\n            + c.x * 256.0 * 256.0 * 255.0\n            ;\n        }\n\n        float modI(float a, float b) {\n            float m = a - floor((a + 0.5) / b) * b;\n            return floor(m + 0.5);\n        }\n\n        void main () {\n            vec2 point = ((vcoord / (1.0 / tilesPerUnit))) + (viewportOffset / tileSize) * scrollRatio;\n            vec2 look = floor(point);\n\n            //(2i + 1)/(2N) Pixel center\n            vec2 coordinate = (look + 0.5) / lutSize;\n            float tileIndex = color2float(texture2D(lut, coordinate));\n\n            float magic = tileIndex / tileIndex;\n\n            tileIndex = tileIndex - 1.; // tile indexes in tileset starts from zero, but in lut zero is used for "none" placeholder\n            vec2 grid = tileSetSize / tileSize;\n            vec2 tile = vec2(modI(tileIndex, grid.x), floor(tileIndex / grid.x));\n            // inverting reading botom to top\n            tile.y = grid.y - tile.y - 1.;\n\n            vec2 fragmentOffsetPx = floor((point - look) * tileSize);\n\n            //(2i + 1)/(2N) Pixel center\n            vec2 pixel = (floor(tile * tileSize + fragmentOffsetPx) + 0.5) / tileSetSize;\n            gl_FragColor = texture2D(tileSet, pixel);\n\n            gl_FragColor.a *= magic;\n            gl_FragColor.rgb *= gl_FragColor.a;\n        }\n    ',
	attributes: {},
	uniforms: {lut: 'a7', lutSize: 'a8', pixelsPerUnit: 'dt', scrollRatio: 'dD', tileSet: 'bm', tileSetSize: 'bn', tileSize: 'bo', transparentcolor: 'dO', viewportOffset: 'dR'}
};
var author$project$Layer$Tiles$render = function (_n0) {
	var common = _n0.a;
	var individual = _n0.b;
	return A5(
		elm_explorations$webgl$WebGL$entityWith,
		author$project$Defaults$default.c7,
		author$project$Layer$Common$vertexShader,
		author$project$Layer$Tiles$fragmentShader,
		author$project$Layer$Common$mesh,
		{a7: individual.a7, a8: individual.a8, dt: common.dt, dD: individual.dD, bm: individual.bm, bn: individual.bn, bo: individual.bo, cT: common.cT, dO: individual.dO, dR: common.dR, bw: common.bw});
};
var author$project$Layer$Tiles$Animated$fragmentShader = {
	src: '\n        precision mediump float;\n        varying vec2 vcoord;\n        uniform sampler2D tileSet;\n        uniform sampler2D lut;\n        uniform vec3 transparentcolor;\n        uniform vec2 lutSize;\n        uniform vec2 tileSetSize;\n        uniform float pixelsPerUnit;\n        uniform vec2 tileSize;\n        uniform vec2 viewportOffset;\n        uniform vec2 scrollRatio;\n        uniform sampler2D animLUT;\n        uniform int animLength;\n        uniform int time;\n        float animLength_ = float(animLength);\n        float time_ = float(time);\n\n        vec2 tilesPerUnit = pixelsPerUnit / tileSize;\n        //float px = 1.0 / pixelsPerUnit;\n\n        float color2float(vec4 c) {\n            return c.z * 255.0\n            + c.y * 256.0 * 255.0\n            + c.x * 256.0 * 256.0 * 255.0\n            ;\n        }\n\n        float modI(float a, float b) {\n            float m = a - floor((a + 0.5) / b) * b;\n            return floor(m + 0.5);\n        }\n\n        void main () {\n            vec2 point = ((vcoord / (1.0 / tilesPerUnit))) + (viewportOffset / tileSize) * scrollRatio;\n            vec2 look = floor(point);\n\n            //(2i + 1)/(2N) Pixel center\n            vec2 coordinate = (look + 0.5) / lutSize;\n            float currentFrame = modI(time_, animLength_);\n            float newIndex = color2float(texture2D(animLUT, vec2(currentFrame / animLength_, 0.5 ))) + 1.;\n            float tileIndex = color2float(texture2D(lut, coordinate)) * newIndex;\n            float magic = tileIndex / tileIndex;\n            tileIndex = tileIndex - 1.; // tile indexes in tileset starts from zero, but in lut zero is used for "none" placeholder\n            vec2 grid = tileSetSize / tileSize;\n            vec2 tile = vec2(modI(tileIndex, grid.x), floor(tileIndex / grid.x));\n            // inverting reading botom to top\n            tile.y = grid.y - tile.y - 1.;\n\n            vec2 fragmentOffsetPx = floor((point - look) * tileSize);\n\n            //(2i + 1)/(2N) Pixel center\n            vec2 pixel = (floor(tile * tileSize + fragmentOffsetPx) + 0.5) / tileSetSize;\n            gl_FragColor = texture2D(tileSet, pixel);\n\n            gl_FragColor.a *= magic;\n            gl_FragColor.rgb *= gl_FragColor.a;\n\n        }\n    ',
	attributes: {},
	uniforms: {animLUT: 'aY', animLength: 'aZ', lut: 'a7', lutSize: 'a8', pixelsPerUnit: 'dt', scrollRatio: 'dD', tileSet: 'bm', tileSetSize: 'bn', tileSize: 'bo', time: 'cT', transparentcolor: 'dO', viewportOffset: 'dR'}
};
var author$project$Layer$Tiles$Animated$render = function (_n0) {
	var common = _n0.a;
	var individual = _n0.b;
	return A5(
		elm_explorations$webgl$WebGL$entityWith,
		author$project$Defaults$default.c7,
		author$project$Layer$Common$vertexShader,
		author$project$Layer$Tiles$Animated$fragmentShader,
		author$project$Layer$Common$mesh,
		{aY: individual.aY, aZ: individual.aZ, a7: individual.a7, a8: individual.a8, dt: common.dt, dD: individual.dD, bm: individual.bm, bn: individual.bn, bo: individual.bo, cT: common.cT, dO: individual.dO, dR: common.dR, bw: common.bw});
};
var author$project$World$Render$view = F4(
	function (objRender, env, world, ecs) {
		var camera = world.c$;
		var layers = world.aN;
		var frame = world.aI;
		var common = {dt: camera.dt, cT: frame, dR: camera.dR, bw: env.bw};
		return A2(
			elm$core$List$concatMap,
			function (income) {
				switch (income.$) {
					case 0:
						var info = income.a;
						return _List_fromArray(
							[
								author$project$Layer$Tiles$render(
								A2(author$project$Layer$Common$Layer, common, info))
							]);
					case 1:
						var info = income.a;
						return _List_fromArray(
							[
								author$project$Layer$Tiles$Animated$render(
								A2(author$project$Layer$Common$Layer, common, info))
							]);
					case 5:
						var info = income.a;
						return _List_fromArray(
							[
								author$project$Layer$Image$render(
								A2(author$project$Layer$Common$Layer, common, info))
							]);
					case 2:
						var info = income.a;
						return _List_fromArray(
							[
								author$project$Layer$Image$renderX(
								A2(author$project$Layer$Common$Layer, common, info))
							]);
					case 3:
						var info = income.a;
						return _List_fromArray(
							[
								author$project$Layer$Image$renderY(
								A2(author$project$Layer$Common$Layer, common, info))
							]);
					case 4:
						var info = income.a;
						return _List_fromArray(
							[
								author$project$Layer$Image$renderNo(
								A2(author$project$Layer$Common$Layer, common, info))
							]);
					default:
						var info = income.a;
						return A2(
							objRender,
							common,
							_Utils_Tuple2(ecs, info));
				}
			},
			layers);
	});
var elm_explorations$webgl$WebGL$toHtmlWith = F3(
	function (options, attributes, entities) {
		return A3(_WebGL_toHtml, options, attributes, entities);
	});
var author$project$Game$view_ = F2(
	function (objRender, model) {
		var _n0 = model.S;
		if (!_n0.$) {
			var _n1 = _n0.a;
			var world = _n1.a;
			var ecs = _n1.b;
			return {
				a$: _List_fromArray(
					[
						A3(
						elm_explorations$webgl$WebGL$toHtmlWith,
						author$project$Defaults$default.dS,
						author$project$Environment$style(model.y),
						A4(author$project$World$Render$view, objRender, model.y, world, ecs))
					]),
				bt: 'Success'
			};
		} else {
			if (!_n0.a.a) {
				var _n2 = _n0.a;
				var t = _n2.b;
				return {
					a$: _List_fromArray(
						[
							A3(
							elm_explorations$webgl$WebGL$toHtmlWith,
							author$project$Defaults$default.dS,
							author$project$Environment$style(model.y),
							_List_Nil)
						]),
					bt: t
				};
			} else {
				var _n3 = _n0.a;
				var code = _n3.a;
				var e = _n3.b;
				return {
					a$: _List_fromArray(
						[
							A3(
							elm_explorations$webgl$WebGL$toHtmlWith,
							author$project$Defaults$default.dS,
							author$project$Environment$style(model.y),
							_List_Nil)
						]),
					bt: 'Failure:' + elm$core$String$fromInt(code)
				};
			}
		}
	});
var elm$browser$Browser$document = _Browser_document;
var elm$browser$Browser$AnimationManager$Delta = function (a) {
	return {$: 1, a: a};
};
var elm$browser$Browser$AnimationManager$State = F3(
	function (subs, request, oldTime) {
		return {bd: oldTime, cE: request, cP: subs};
	});
var elm$browser$Browser$AnimationManager$init = elm$core$Task$succeed(
	A3(elm$browser$Browser$AnimationManager$State, _List_Nil, elm$core$Maybe$Nothing, 0));
var elm$browser$Browser$AnimationManager$now = _Browser_now(0);
var elm$browser$Browser$AnimationManager$rAF = _Browser_rAF(0);
var elm$core$Process$spawn = _Scheduler_spawn;
var elm$browser$Browser$AnimationManager$onEffects = F3(
	function (router, subs, _n0) {
		var request = _n0.cE;
		var oldTime = _n0.bd;
		var _n1 = _Utils_Tuple2(request, subs);
		if (_n1.a.$ === 1) {
			if (!_n1.b.b) {
				var _n2 = _n1.a;
				return elm$browser$Browser$AnimationManager$init;
			} else {
				var _n4 = _n1.a;
				return A2(
					elm$core$Task$andThen,
					function (pid) {
						return A2(
							elm$core$Task$andThen,
							function (time) {
								return elm$core$Task$succeed(
									A3(
										elm$browser$Browser$AnimationManager$State,
										subs,
										elm$core$Maybe$Just(pid),
										time));
							},
							elm$browser$Browser$AnimationManager$now);
					},
					elm$core$Process$spawn(
						A2(
							elm$core$Task$andThen,
							elm$core$Platform$sendToSelf(router),
							elm$browser$Browser$AnimationManager$rAF)));
			}
		} else {
			if (!_n1.b.b) {
				var pid = _n1.a.a;
				return A2(
					elm$core$Task$andThen,
					function (_n3) {
						return elm$browser$Browser$AnimationManager$init;
					},
					elm$core$Process$kill(pid));
			} else {
				return elm$core$Task$succeed(
					A3(elm$browser$Browser$AnimationManager$State, subs, request, oldTime));
			}
		}
	});
var elm$time$Time$Posix = elm$core$Basics$identity;
var elm$time$Time$millisToPosix = elm$core$Basics$identity;
var elm$browser$Browser$AnimationManager$onSelfMsg = F3(
	function (router, newTime, _n0) {
		var subs = _n0.cP;
		var oldTime = _n0.bd;
		var send = function (sub) {
			if (!sub.$) {
				var tagger = sub.a;
				return A2(
					elm$core$Platform$sendToApp,
					router,
					tagger(
						elm$time$Time$millisToPosix(newTime)));
			} else {
				var tagger = sub.a;
				return A2(
					elm$core$Platform$sendToApp,
					router,
					tagger(newTime - oldTime));
			}
		};
		return A2(
			elm$core$Task$andThen,
			function (pid) {
				return A2(
					elm$core$Task$andThen,
					function (_n1) {
						return elm$core$Task$succeed(
							A3(
								elm$browser$Browser$AnimationManager$State,
								subs,
								elm$core$Maybe$Just(pid),
								newTime));
					},
					elm$core$Task$sequence(
						A2(elm$core$List$map, send, subs)));
			},
			elm$core$Process$spawn(
				A2(
					elm$core$Task$andThen,
					elm$core$Platform$sendToSelf(router),
					elm$browser$Browser$AnimationManager$rAF)));
	});
var elm$browser$Browser$AnimationManager$Time = function (a) {
	return {$: 0, a: a};
};
var elm$browser$Browser$AnimationManager$subMap = F2(
	function (func, sub) {
		if (!sub.$) {
			var tagger = sub.a;
			return elm$browser$Browser$AnimationManager$Time(
				A2(elm$core$Basics$composeL, func, tagger));
		} else {
			var tagger = sub.a;
			return elm$browser$Browser$AnimationManager$Delta(
				A2(elm$core$Basics$composeL, func, tagger));
		}
	});
_Platform_effectManagers['Browser.AnimationManager'] = _Platform_createManager(elm$browser$Browser$AnimationManager$init, elm$browser$Browser$AnimationManager$onEffects, elm$browser$Browser$AnimationManager$onSelfMsg, 0, elm$browser$Browser$AnimationManager$subMap);
var elm$browser$Browser$AnimationManager$subscription = _Platform_leaf('Browser.AnimationManager');
var elm$browser$Browser$AnimationManager$onAnimationFrameDelta = function (tagger) {
	return elm$browser$Browser$AnimationManager$subscription(
		elm$browser$Browser$AnimationManager$Delta(tagger));
};
var elm$browser$Browser$Events$onAnimationFrameDelta = elm$browser$Browser$AnimationManager$onAnimationFrameDelta;
var elm$core$Platform$Sub$map = _Platform_map;
var author$project$Game$document = function (_n0) {
	var world = _n0.dT;
	var system = _n0.dL;
	var read = _n0.dx;
	var view = _n0.cV;
	var subscriptions = _n0.cQ;
	return elm$browser$Browser$document(
		{
			dh: A2(author$project$Game$init_, world, read),
			cQ: function (model_) {
				var _n1 = model_.S;
				if (!_n1.$) {
					var _n2 = _n1.a;
					var world1 = _n2.a;
					var world2 = _n2.b;
					return elm$core$Platform$Sub$batch(
						_List_fromArray(
							[
								A2(
								elm$core$Platform$Sub$map,
								author$project$Game$Environment,
								author$project$Environment$subscriptions(model_.y)),
								elm$browser$Browser$Events$onAnimationFrameDelta(author$project$Game$Frame),
								A2(
								elm$core$Platform$Sub$map,
								author$project$Game$Subscription,
								subscriptions(
									_Utils_Tuple2(world1, world2)))
							]));
				} else {
					return A2(
						elm$core$Platform$Sub$map,
						author$project$Game$Environment,
						author$project$Environment$subscriptions(model_.y));
				}
			},
			dP: author$project$Game$update(system),
			cV: author$project$Game$view_(view)
		});
};
var author$project$World$Component$Common$Sync = function (a) {
	return {$: 0, a: a};
};
var author$project$World$Component$Common$None = {$: 2};
var author$project$World$Component$Common$defaultRead = {cl: author$project$World$Component$Common$None, cm: author$project$World$Component$Common$None, cn: author$project$World$Component$Common$None, co: author$project$World$Component$Common$None, cp: author$project$World$Component$Common$None, cq: author$project$World$Component$Common$None};
var author$project$World$Component$dimensions = function () {
	var spec = {
		dd: function ($) {
			return $.c4;
		},
		dF: F2(
			function (comps, world) {
				return _Utils_update(
					world,
					{c4: comps});
			})
	};
	return {
		aG: author$project$Logic$Component$empty,
		dx: _Utils_update(
			author$project$World$Component$Common$defaultRead,
			{
				cq: author$project$World$Component$Common$Sync(
					function (_n0) {
						var height = _n0.ae;
						var width = _n0.ak;
						return author$project$Logic$Entity$with(
							_Utils_Tuple2(
								spec,
								A2(elm_explorations$linear_algebra$Math$Vector2$vec2, width, height)));
					})
			}),
		cL: spec
	};
}();
var elm$core$Set$Set_elm_builtin = elm$core$Basics$identity;
var elm$core$Set$empty = elm$core$Dict$empty;
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
		return {bF: col, c1: contextStack, cx: problem, cG: row};
	});
var elm$parser$Parser$Advanced$Empty = {$: 0};
var elm$parser$Parser$Advanced$fromState = F2(
	function (s, x) {
		return A2(
			elm$parser$Parser$Advanced$AddRight,
			elm$parser$Parser$Advanced$Empty,
			A4(elm$parser$Parser$Advanced$DeadEnd, s.cG, s.bF, x, s.d));
	});
var elm$parser$Parser$Advanced$end = function (x) {
	return function (s) {
		return _Utils_eq(
			elm$core$String$length(s.a),
			s.b) ? A3(elm$parser$Parser$Advanced$Good, false, 0, s) : A2(
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
var elm$core$Basics$negate = function (n) {
	return -n;
};
var elm$core$Basics$not = _Basics_not;
var elm$parser$Parser$Advanced$isSubChar = _Parser_isSubChar;
var elm$parser$Parser$Advanced$isSubString = _Parser_isSubString;
var elm$parser$Parser$Advanced$keyword = function (_n0) {
	var kwd = _n0.a;
	var expecting = _n0.b;
	var progress = !elm$core$String$isEmpty(kwd);
	return function (s) {
		var _n1 = A5(elm$parser$Parser$Advanced$isSubString, kwd, s.b, s.cG, s.bF, s.a);
		var newOffset = _n1.a;
		var newRow = _n1.b;
		var newCol = _n1.c;
		return (_Utils_eq(newOffset, -1) || (0 <= A3(
			elm$parser$Parser$Advanced$isSubChar,
			function (c) {
				return elm$core$Char$isAlphaNum(c) || (c === '_');
			},
			newOffset,
			s.a))) ? A2(
			elm$parser$Parser$Advanced$Bad,
			false,
			A2(elm$parser$Parser$Advanced$fromState, s, expecting)) : A3(
			elm$parser$Parser$Advanced$Good,
			progress,
			0,
			{bF: newCol, d: s.d, e: s.e, b: newOffset, cG: newRow, a: s.a});
	};
};
var elm$parser$Parser$keyword = function (kwd) {
	return elm$parser$Parser$Advanced$keyword(
		A2(
			elm$parser$Parser$Advanced$Token,
			kwd,
			elm$parser$Parser$ExpectingKeyword(kwd)));
};
var elm$parser$Parser$DeadEnd = F3(
	function (row, col, problem) {
		return {bF: col, cx: problem, cG: row};
	});
var elm$parser$Parser$problemToDeadEnd = function (p) {
	return A3(elm$parser$Parser$DeadEnd, p.cG, p.bF, p.cx);
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
			{bF: 1, d: _List_Nil, e: 1, b: 0, cG: 1, a: src});
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
		var _n1 = A5(elm$parser$Parser$Advanced$isSubString, str, s.b, s.cG, s.bF, s.a);
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
			{bF: newCol, d: s.d, e: s.e, b: newOffset, cG: newRow, a: s.a});
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
				return {bF: col, d: context, e: indent, b: offset, cG: row, a: src};
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
		var firstOffset = A3(elm$parser$Parser$Advanced$isSubChar, i.dG, s.b, s.a);
		if (_Utils_eq(firstOffset, -1)) {
			return A2(
				elm$parser$Parser$Advanced$Bad,
				false,
				A2(elm$parser$Parser$Advanced$fromState, s, i.bM));
		} else {
			var s1 = _Utils_eq(firstOffset, -2) ? A7(elm$parser$Parser$Advanced$varHelp, i.di, s.b + 1, s.cG + 1, 1, s.a, s.e, s.d) : A7(elm$parser$Parser$Advanced$varHelp, i.di, firstOffset, s.cG, s.bF + 1, s.a, s.e, s.d);
			var name = A3(elm$core$String$slice, s.b, s1.b, s.a);
			return A2(elm$core$Set$member, name, i.dz) ? A2(
				elm$parser$Parser$Advanced$Bad,
				false,
				A2(elm$parser$Parser$Advanced$fromState, s, i.bM)) : A3(elm$parser$Parser$Advanced$Good, true, name, s1);
		}
	};
};
var elm$parser$Parser$variable = function (i) {
	return elm$parser$Parser$Advanced$variable(
		{bM: elm$parser$Parser$ExpectingVariable, di: i.di, dz: i.dz, dG: i.dG});
};
var author$project$World$Component$Direction$direction = function () {
	var spec = {
		dd: A2(
			elm$core$Basics$composeR,
			function ($) {
				return $.c5;
			},
			function ($) {
				return $.a1;
			}),
		dF: F2(
			function (comps, world) {
				var dir = world.c5;
				return _Utils_update(
					world,
					{
						c5: _Utils_update(
							dir,
							{a1: comps})
					});
			})
	};
	var setKey = F3(
		function (comp, dir, key) {
			_n5$4:
			while (true) {
				if (dir.$ === 3) {
					switch (dir.a) {
						case 'Move.south':
							return _Utils_update(
								comp,
								{a2: key});
						case 'Move.west':
							return _Utils_update(
								comp,
								{a6: key});
						case 'Move.east':
							return _Utils_update(
								comp,
								{bi: key});
						case 'Move.north':
							return _Utils_update(
								comp,
								{bu: key});
						default:
							break _n5$4;
					}
				} else {
					break _n5$4;
				}
			}
			return comp;
		});
	var filterKeys = F2(
		function (props, _n4) {
			var entityId = _n4.a;
			var registered = _n4.b;
			var typeVar = elm$parser$Parser$variable(
				{
					di: function (c) {
						return elm$core$Char$isAlphaNum(c) || (c === '_');
					},
					dz: elm$core$Set$empty,
					dG: elm$core$Char$isAlphaNum
				});
			var onKey = A2(
				elm$parser$Parser$keeper,
				A2(
					elm$parser$Parser$keeper,
					elm$parser$Parser$succeed(
						F2(
							function (a, b) {
								return b;
							})),
					A2(
						elm$parser$Parser$ignorer,
						elm$parser$Parser$keyword('onKey'),
						elm$parser$Parser$symbol('['))),
				A2(
					elm$parser$Parser$ignorer,
					A2(
						elm$parser$Parser$ignorer,
						typeVar,
						elm$parser$Parser$symbol(']')),
					elm$parser$Parser$end));
			var emptyComp = {a2: '', a6: '', bi: '', bu: '', by: 0, bz: 0};
			return A3(
				elm$core$Dict$foldl,
				F3(
					function (k, v, _n3) {
						var comp = _n3.a;
						var registered_ = _n3.b;
						return A2(
							elm$core$Result$withDefault,
							_Utils_Tuple2(comp, registered_),
							A2(
								elm$core$Result$map,
								function (key) {
									return _Utils_Tuple2(
										A3(setKey, comp, v, key),
										A3(elm$core$Dict$insert, key, entityId, registered_));
								},
								A2(elm$parser$Parser$run, onKey, k)));
					}),
				_Utils_Tuple2(emptyComp, registered),
				props);
		});
	return {
		aG: {a1: author$project$Logic$Component$empty, dw: elm$core$Set$empty, bg: elm$core$Dict$empty},
		dx: _Utils_update(
			author$project$World$Component$Common$defaultRead,
			{
				cq: author$project$World$Component$Common$Sync(
					F2(
						function (_n0, _n1) {
							var x = _n0.by;
							var y = _n0.bz;
							var properties = _n0.R;
							var entityId = _n1.a;
							var world = _n1.b;
							var dir = world.c5;
							var _n2 = A2(
								filterKeys,
								properties,
								_Utils_Tuple2(entityId, world.c5.bg));
							var comp = _n2.a;
							var registered = _n2.b;
							return A2(
								author$project$Logic$Entity$with,
								_Utils_Tuple2(spec, comp),
								_Utils_Tuple2(
									entityId,
									_Utils_update(
										world,
										{
											c5: _Utils_update(
												dir,
												{bg: registered})
										})));
						}))
			}),
		cL: spec
	};
}();
var author$project$World$Component$direction = author$project$World$Component$Direction$direction;
var author$project$World$Component$Common$Async = function (a) {
	return {$: 1, a: a};
};
var author$project$World$Component$Object$Animated = function (a) {
	return {$: 3, a: a};
};
var author$project$World$Component$Object$Tile = function (a) {
	return {$: 2, a: a};
};
var author$project$World$Component$Object$boolToFloat = function (bool) {
	return bool ? 1 : 0;
};
var author$project$World$Component$Object$objects = function () {
	var spec = {
		dd: function ($) {
			return $.$7;
		},
		dF: F2(
			function (comps, world) {
				return _Utils_update(
					world,
					{$7: comps});
			})
	};
	return {
		aG: author$project$Logic$Component$empty,
		dx: _Utils_update(
			author$project$World$Component$Common$defaultRead,
			{
				cq: author$project$World$Component$Common$Async(
					function (_n0) {
						var x = _n0.by;
						var y = _n0.bz;
						var width = _n0.ak;
						var height = _n0.ae;
						var gid = _n0.bV;
						var fh = _n0.bO;
						var fv = _n0.bT;
						var getTilesetByGid = _n0.bU;
						return A2(
							elm$core$Basics$composeR,
							getTilesetByGid(gid),
							author$project$ResourceTask$andThen(
								function (t_) {
									if (t_.$ === 1) {
										var t = t_.a;
										var tileIndex = gid - t.ac;
										var _n2 = A2(author$project$Tiled$Util$animation, t, tileIndex);
										if (!_n2.$) {
											var anim = _n2.a;
											return A2(
												elm$core$Basics$composeR,
												author$project$ResourceTask$getTexture('/assets/' + t.a3),
												author$project$ResourceTask$map(
													function (tileSetImage) {
														var tilsetProps = author$project$Tiled$Util$properties(t);
														var obj = author$project$World$Component$Object$Animated(
															{
																ae: height,
																bb: A2(
																	elm_explorations$linear_algebra$Math$Vector2$vec2,
																	author$project$World$Component$Object$boolToFloat(fh),
																	author$project$World$Component$Object$boolToFloat(fv)),
																dD: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 1, 1),
																bl: tileIndex,
																bm: tileSetImage,
																bn: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, t.aM, t.aL),
																bo: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, t.bs, t.bq),
																dO: A2(tilsetProps.a0, 'transparentcolor', author$project$Defaults$default.dO),
																ak: width,
																by: x,
																bz: y
															});
														return author$project$Logic$Entity$with(
															_Utils_Tuple2(spec, obj));
													}));
										} else {
											return A2(
												elm$core$Basics$composeR,
												author$project$ResourceTask$getTexture('/assets/' + t.a3),
												author$project$ResourceTask$map(
													function (tileSetImage) {
														var tilsetProps = author$project$Tiled$Util$properties(t);
														var obj = author$project$World$Component$Object$Tile(
															{
																ae: height,
																bb: A2(
																	elm_explorations$linear_algebra$Math$Vector2$vec2,
																	author$project$World$Component$Object$boolToFloat(fh),
																	author$project$World$Component$Object$boolToFloat(fv)),
																dD: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 1, 1),
																bl: tileIndex,
																bm: tileSetImage,
																bn: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, t.aM, t.aL),
																bo: A2(elm_explorations$linear_algebra$Math$Vector2$vec2, t.bs, t.bq),
																dO: A2(tilsetProps.a0, 'transparentcolor', author$project$Defaults$default.dO),
																ak: width,
																by: x,
																bz: y
															});
														return author$project$Logic$Entity$with(
															_Utils_Tuple2(spec, obj));
													}));
										}
									} else {
										return author$project$ResourceTask$fail(
											A2(author$project$Error$Error, 6002, 'object tile readers works only with single image tilesets'));
									}
								}));
					})
			}),
		cL: spec
	};
}();
var author$project$World$Component$objects = author$project$World$Component$Object$objects;
var author$project$World$Component$positions = function () {
	var spec = {
		dd: function ($) {
			return $.dv;
		},
		dF: F2(
			function (comps, world) {
				return _Utils_update(
					world,
					{dv: comps});
			})
	};
	return {
		aG: author$project$Logic$Component$empty,
		dx: _Utils_update(
			author$project$World$Component$Common$defaultRead,
			{
				cq: author$project$World$Component$Common$Sync(
					function (_n0) {
						var x = _n0.by;
						var y = _n0.bz;
						return author$project$Logic$Entity$with(
							_Utils_Tuple2(
								spec,
								A2(elm_explorations$linear_algebra$Math$Vector2$vec2, x, y)));
					})
			}),
		cL: spec
	};
}();
var author$project$Main$read = _List_fromArray(
	[author$project$World$Component$positions.dx, author$project$World$Component$dimensions.dx, author$project$World$Component$objects.dx, author$project$World$Component$direction.dx]);
var elm$core$Basics$sin = _Basics_sin;
var elm_explorations$linear_algebra$Math$Vector2$add = _MJS_v2add;
var elm_explorations$linear_algebra$Math$Vector2$scale = _MJS_v2scale;
var elm_explorations$linear_algebra$Math$Vector2$sub = _MJS_v2sub;
var author$project$World$System$autoScrollCamera = F3(
	function (speed, rand, _n0) {
		var common = _n0.a;
		var ecs = _n0.b;
		var rand_ = A2(
			elm_explorations$linear_algebra$Math$Vector2$sub,
			A2(
				elm_explorations$linear_algebra$Math$Vector2$scale,
				elm$core$Basics$sin((common.aI - 1) / 30),
				rand),
			A2(
				elm_explorations$linear_algebra$Math$Vector2$scale,
				elm$core$Basics$sin(common.aI / 30),
				rand));
		var camera = common.c$;
		var newPos = A2(
			elm_explorations$linear_algebra$Math$Vector2$add,
			rand_,
			A2(elm_explorations$linear_algebra$Math$Vector2$add, speed, camera.dR));
		return _Utils_Tuple2(
			_Utils_update(
				common,
				{
					c$: _Utils_update(
						camera,
						{dR: newPos})
				}),
			ecs);
	});
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
var author$project$Logic$System$applyIf = F3(
	function (bool, f, world) {
		return bool ? f(world) : world;
	});
var elm$core$Array$getHelp = F3(
	function (shift, index, tree) {
		getHelp:
		while (true) {
			var pos = elm$core$Array$bitMask & (index >>> shift);
			var _n0 = A2(elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (!_n0.$) {
				var subTree = _n0.a;
				var $temp$shift = shift - elm$core$Array$shiftStep,
					$temp$index = index,
					$temp$tree = subTree;
				shift = $temp$shift;
				index = $temp$index;
				tree = $temp$tree;
				continue getHelp;
			} else {
				var values = _n0.a;
				return A2(elm$core$Elm$JsArray$unsafeGet, elm$core$Array$bitMask & index, values);
			}
		}
	});
var elm$core$Array$get = F2(
	function (index, _n0) {
		var len = _n0.a;
		var startShift = _n0.b;
		var tree = _n0.c;
		var tail = _n0.d;
		return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? elm$core$Maybe$Nothing : ((_Utils_cmp(
			index,
			elm$core$Array$tailIndex(len)) > -1) ? elm$core$Maybe$Just(
			A2(elm$core$Elm$JsArray$unsafeGet, elm$core$Array$bitMask & index, tail)) : elm$core$Maybe$Just(
			A3(elm$core$Array$getHelp, startShift, index, tree)));
	});
var author$project$Logic$System$step2 = F4(
	function (f, spec1, spec2, world) {
		var set2 = F3(
			function (i, b, acc) {
				return _Utils_update(
					acc,
					{
						g: A3(
							elm$core$Array$set,
							i,
							elm$core$Maybe$Just(b),
							acc.g)
					});
			});
		var set1 = F3(
			function (i, a, acc) {
				return _Utils_update(
					acc,
					{
						f: A3(
							elm$core$Array$set,
							i,
							elm$core$Maybe$Just(a),
							acc.f)
					});
			});
		var combined = {
			f: spec1.dd(world),
			g: spec2.dd(world)
		};
		var result = A3(
			author$project$Logic$Internal$indexedFoldlArray,
			F3(
				function (n, value1, acc) {
					return A2(
						elm$core$Maybe$withDefault,
						acc,
						A2(
							elm$core$Maybe$andThen,
							function (a) {
								return A2(
									A2(elm$core$Basics$composeR, elm$core$Maybe$map, elm$core$Maybe$andThen),
									function (b) {
										return A3(
											f,
											_Utils_Tuple2(
												a,
												set1(n)),
											_Utils_Tuple2(
												b,
												set2(n)),
											acc);
									},
									A2(elm$core$Array$get, n, acc.g));
							},
							value1));
				}),
			combined,
			combined.f);
		return A3(
			author$project$Logic$System$applyIf,
			!_Utils_eq(result.g, combined.g),
			spec2.dF(result.g),
			A3(
				author$project$Logic$System$applyIf,
				!_Utils_eq(result.f, combined.f),
				spec1.dF(result.f),
				world));
	});
var author$project$World$System$linearMovement = F3(
	function (posSpec, dirSpec, _n0) {
		var common = _n0.a;
		var ecs = _n0.b;
		var speed = 3;
		var newEcs = A4(
			author$project$Logic$System$step2,
			F3(
				function (_n1, _n2, acc) {
					var pos = _n1.a;
					var setPos = _n1.b;
					var x = _n2.a.by;
					var y = _n2.a.bz;
					return A3(
						elm$core$Basics$apR,
						A2(
							elm_explorations$linear_algebra$Math$Vector2$add,
							pos,
							A2(elm_explorations$linear_algebra$Math$Vector2$vec2, x * speed, y * speed)),
						setPos,
						acc);
				}),
			posSpec,
			dirSpec,
			ecs);
		return _Utils_Tuple2(common, newEcs);
	});
var author$project$Main$system = function (world_) {
	return A3(
		author$project$World$System$linearMovement,
		author$project$World$Component$positions.cL,
		author$project$World$Component$direction.cL,
		A3(
			author$project$World$System$autoScrollCamera,
			A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 2, 0),
			A2(elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 5),
			world_));
};
var author$project$Logic$System$foldl3 = F5(
	function (f, comp1, comp2, comp3, acc_) {
		return A3(
			author$project$Logic$Internal$indexedFoldlArray,
			F3(
				function (n, value1, acc) {
					return A2(
						elm$core$Maybe$withDefault,
						acc,
						A2(
							elm$core$Maybe$andThen,
							function (a) {
								return A2(
									A2(elm$core$Basics$composeR, elm$core$Maybe$andThen, elm$core$Maybe$andThen),
									function (b) {
										return A2(
											A2(elm$core$Basics$composeR, elm$core$Maybe$map, elm$core$Maybe$andThen),
											function (c) {
												return A4(f, a, b, c, acc);
											},
											A2(elm$core$Array$get, n, comp3));
									},
									A2(elm$core$Array$get, n, comp2));
							},
							value1));
				}),
			acc_,
			comp1);
	});
var author$project$Layer$Object$Animated$fragmentShader = {
	src: '\n        precision mediump float;\n        varying vec2 vcoord;\n        //uniform vec3 transparentcolor;\n        uniform sampler2D tileSet;\n        uniform vec2 tileSetSize;\n        //uniform float pixelsPerUnit;\n        uniform vec2 tileSize;\n        uniform vec2 mirror;\n        uniform vec2 viewportOffset;\n        uniform vec2 scrollRatio;\n        uniform float tileIndex;\n\n        float color2float(vec4 c) {\n            return c.z * 255.0\n            + c.y * 256.0 * 255.0\n            + c.x * 256.0 * 256.0 * 255.0\n            ;\n        }\n\n        float modI(float a, float b) {\n            float m = a - floor((a + 0.5) / b) * b;\n            return floor(m + 0.5);\n        }\n\n        void main () {\n            vec2 point = vcoord + (viewportOffset / tileSize) * scrollRatio;\n            vec2 grid = tileSetSize / tileSize;\n            vec2 tile = vec2(modI(tileIndex, grid.x), floor(tileIndex / grid.x));\n\n            // inverting reading botom to top\n            tile.y = grid.y - tile.y - 1.;\n            vec2 fragmentOffsetPx = floor((point) * tileSize);\n\n\n            //vec2 fragmentOffsetPx = floor(point * tileSize);\n            fragmentOffsetPx.x = abs(((tileSize.x - 1.) * mirror.x ) - fragmentOffsetPx.x);\n            fragmentOffsetPx.y = abs(((tileSize.y - 1.)  * mirror.y ) - fragmentOffsetPx.y);\n\n            //(2i + 1)/(2N) Pixel center\n            vec2 pixel = (floor(tile * tileSize + fragmentOffsetPx) + 0.5) / tileSetSize;\n\n            //gl_FragColor = texture2D(tileSet, pixel);\n            gl_FragColor = texture2D(tileSet, pixel);\n            gl_FragColor.r += 0.3;\n            gl_FragColor.rgb *= gl_FragColor.a;\n        }\n    ',
	attributes: {},
	uniforms: {mirror: 'bb', scrollRatio: 'dD', tileIndex: 'bl', tileSet: 'bm', tileSetSize: 'bn', tileSize: 'bo', viewportOffset: 'dR'}
};
var author$project$Layer$Object$Common$vertexShader = {
	src: '\n        precision mediump float;\n        attribute vec2 position;\n        uniform float widthRatio;\n        uniform float pixelsPerUnit;\n        uniform float x;\n        uniform float y;\n        uniform float height;\n        uniform float width;\n        uniform vec2 viewportOffset;\n        uniform vec2 scrollRatio;\n        varying vec2 vcoord;\n\n        float px = 1.0 / pixelsPerUnit;\n        //https://gist.github.com/patriciogonzalezvivo/986341af1560138dde52\n        mat4 translate(float x, float y, float z) {\n            return mat4(\n                vec4(1.0, 0.0, 0.0, 0.0),\n                vec4(0.0, 1.0, 0.0, 0.0),\n                vec4(0.0, 0.0, 1.0, 0.0),\n                vec4(x,   y,   z,   1.0)\n            );\n        }\n\n        mat4 viewport = mat4(\n            (2.0 / widthRatio), 0, 0, 0,\n		 	                 0, 2, 0, 0,\n		 			         0, 0,-1, 0,\n		 			        -1,-1, 0, 1);\n        void main () {\n            vcoord = position;\n            vec2 fullScreen = vec2(position.x * widthRatio, position.y);\n            vec2 sized = vec2(position * vec2(width * px, height * px));\n            mat4 move = translate(\n                (x - viewportOffset.x * scrollRatio.x - width / 2.) * px,\n                (y - viewportOffset.y * scrollRatio.y - height / 2.) * px,\n                0.0\n            );\n            gl_Position = viewport * move * vec4(sized, 0, 1.0);\n        }\n    ',
	attributes: {position: 'du'},
	uniforms: {height: 'ae', pixelsPerUnit: 'dt', scrollRatio: 'dD', viewportOffset: 'dR', width: 'ak', widthRatio: 'bw', x: 'by', y: 'bz'}
};
var author$project$Layer$Object$Animated$render = function (_n0) {
	var common = _n0.a;
	var individual = _n0.b;
	return A5(
		elm_explorations$webgl$WebGL$entityWith,
		author$project$Defaults$default.c7,
		author$project$Layer$Object$Common$vertexShader,
		author$project$Layer$Object$Animated$fragmentShader,
		author$project$Layer$Common$mesh,
		{ae: individual.ae, bb: individual.bb, dt: common.dt, dD: individual.dD, bl: individual.bl, bm: individual.bm, bn: individual.bn, bo: individual.bo, cT: common.cT, dO: individual.dO, dR: common.dR, ak: individual.ak, bw: common.bw, by: individual.by, bz: individual.bz});
};
var author$project$Layer$Object$Ellipse$fragmentShader = {
	src: '\n        precision mediump float;\n        varying vec2 vcoord;\n        uniform vec4 color;\n        uniform float width;\n        uniform float height;\n        vec2 px = vec2( 1.0 / width, 1.0 / height );\n        void main () {\n            gl_FragColor = color;\n            vec2 delme = vcoord * 2. - 1.;\n            float result = dot(delme, delme);\n            gl_FragColor.a = float(result < 1.0);\n            gl_FragColor.a -= float(result < .85) * .75;\n        }\n    ',
	attributes: {},
	uniforms: {color: 'a0', height: 'ae', width: 'ak'}
};
var author$project$Layer$Object$Ellipse$render = function (_n0) {
	var common = _n0.a;
	var individual = _n0.b;
	return A5(
		elm_explorations$webgl$WebGL$entityWith,
		author$project$Defaults$default.c7,
		author$project$Layer$Object$Common$vertexShader,
		author$project$Layer$Object$Ellipse$fragmentShader,
		author$project$Layer$Common$mesh,
		{a0: individual.a0, ae: individual.ae, dt: common.dt, dD: individual.dD, cT: common.cT, dO: individual.dO, dR: common.dR, ak: individual.ak, bw: common.bw, by: individual.by, bz: individual.bz});
};
var author$project$Layer$Object$Rectangle$fragmentShader = {
	src: '\n        precision mediump float;\n        varying vec2 vcoord;\n        uniform vec4 color;\n        uniform float width;\n        uniform float height;\n        float widthPx =  1.0 / width;\n        float heightPx =  1.0 / height;\n        void main () {\n            gl_FragColor = color;\n            if (vcoord.x < 1.0 - widthPx\n                && vcoord.x > widthPx\n                && vcoord.y < 1.0 - heightPx\n                && vcoord.y > heightPx\n                ) {\n                 gl_FragColor.a = 0.25;\n            }\n        }\n    ',
	attributes: {},
	uniforms: {color: 'a0', height: 'ae', width: 'ak'}
};
var author$project$Layer$Object$Rectangle$render = function (_n0) {
	var common = _n0.a;
	var individual = _n0.b;
	return A5(
		elm_explorations$webgl$WebGL$entityWith,
		author$project$Defaults$default.c7,
		author$project$Layer$Object$Common$vertexShader,
		author$project$Layer$Object$Rectangle$fragmentShader,
		author$project$Layer$Common$mesh,
		{a0: individual.a0, ae: individual.ae, dt: common.dt, dD: individual.dD, cT: common.cT, dO: individual.dO, dR: common.dR, ak: individual.ak, bw: common.bw, by: individual.by, bz: individual.bz});
};
var author$project$Layer$Object$Tile$fragmentShader = {
	src: '\n        precision mediump float;\n        varying vec2 vcoord;\n        //uniform vec3 transparentcolor;\n        uniform sampler2D tileSet;\n        uniform vec2 tileSetSize;\n        //uniform float pixelsPerUnit;\n        uniform vec2 tileSize;\n        uniform vec2 mirror;\n        uniform vec2 viewportOffset;\n        uniform vec2 scrollRatio;\n        uniform float tileIndex;\n\n        float color2float(vec4 c) {\n            return c.z * 255.0\n            + c.y * 256.0 * 255.0\n            + c.x * 256.0 * 256.0 * 255.0\n            ;\n        }\n\n        float modI(float a, float b) {\n            float m = a - floor((a + 0.5) / b) * b;\n            return floor(m + 0.5);\n        }\n\n        void main () {\n            vec2 point = vcoord + (viewportOffset / tileSize) * scrollRatio;\n            vec2 grid = tileSetSize / tileSize;\n            vec2 tile = vec2(modI(tileIndex, grid.x), floor(tileIndex / grid.x));\n\n            // inverting reading botom to top\n            tile.y = grid.y - tile.y - 1.;\n            vec2 fragmentOffsetPx = floor((point) * tileSize);\n\n\n            fragmentOffsetPx.x = abs(((tileSize.x - 1.) * mirror.x ) - fragmentOffsetPx.x);\n            fragmentOffsetPx.y = abs(((tileSize.y - 1.)  * mirror.y ) - fragmentOffsetPx.y);\n\n            //(2i + 1)/(2N) Pixel center\n            vec2 pixel = (floor(tile * tileSize + fragmentOffsetPx) + 0.5) / tileSetSize;\n\n            gl_FragColor = texture2D(tileSet, pixel);\n            gl_FragColor.rgb *= gl_FragColor.a;\n        }\n    ',
	attributes: {},
	uniforms: {mirror: 'bb', scrollRatio: 'dD', tileIndex: 'bl', tileSet: 'bm', tileSetSize: 'bn', tileSize: 'bo', viewportOffset: 'dR'}
};
var author$project$Layer$Object$Tile$render = function (_n0) {
	var common = _n0.a;
	var individual = _n0.b;
	return A5(
		elm_explorations$webgl$WebGL$entityWith,
		author$project$Defaults$default.c7,
		author$project$Layer$Object$Common$vertexShader,
		author$project$Layer$Object$Tile$fragmentShader,
		author$project$Layer$Common$mesh,
		{ae: individual.ae, bb: individual.bb, dt: common.dt, dD: individual.dD, bl: individual.bl, bm: individual.bm, bn: individual.bn, bo: individual.bo, cT: common.cT, dO: individual.dO, dR: common.dR, ak: individual.ak, bw: common.bw, by: individual.by, bz: individual.bz});
};
var elm_explorations$linear_algebra$Math$Vector2$getX = _MJS_v2getX;
var elm_explorations$linear_algebra$Math$Vector2$getY = _MJS_v2getY;
var author$project$World$RenderSystem$render = F5(
	function (common, _n0, obj, pos, acc) {
		switch (obj.$) {
			case 2:
				var info = obj.a;
				return A2(
					elm$core$List$cons,
					author$project$Layer$Object$Tile$render(
						A2(
							author$project$Layer$Common$Layer,
							common,
							_Utils_update(
								info,
								{
									by: elm_explorations$linear_algebra$Math$Vector2$getX(pos),
									bz: elm_explorations$linear_algebra$Math$Vector2$getY(pos)
								}))),
					acc);
			case 3:
				var info = obj.a;
				return A2(
					elm$core$List$cons,
					author$project$Layer$Object$Animated$render(
						A2(
							author$project$Layer$Common$Layer,
							common,
							_Utils_update(
								info,
								{
									by: elm_explorations$linear_algebra$Math$Vector2$getX(pos),
									bz: elm_explorations$linear_algebra$Math$Vector2$getY(pos)
								}))),
					acc);
			case 0:
				var info = obj.a;
				return A2(
					elm$core$List$cons,
					author$project$Layer$Object$Rectangle$render(
						A2(
							author$project$Layer$Common$Layer,
							common,
							_Utils_update(
								info,
								{
									by: elm_explorations$linear_algebra$Math$Vector2$getX(pos),
									bz: elm_explorations$linear_algebra$Math$Vector2$getY(pos)
								}))),
					acc);
			default:
				var info = obj.a;
				return A2(
					elm$core$List$cons,
					author$project$Layer$Object$Ellipse$render(
						A2(author$project$Layer$Common$Layer, common, info)),
					acc);
		}
	});
var author$project$World$RenderSystem$preview = F2(
	function (common, _n0) {
		var ecs = _n0.a;
		var inLayer = _n0.b;
		return A5(
			author$project$Logic$System$foldl3,
			author$project$World$RenderSystem$render(common),
			inLayer,
			author$project$World$Component$objects.cL.dd(ecs),
			author$project$World$Component$positions.cL.dd(ecs),
			_List_Nil);
	});
var author$project$Main$view = F2(
	function (common, _n0) {
		var ecs = _n0.a;
		var objLayer = _n0.b;
		return A2(
			author$project$World$RenderSystem$preview,
			common,
			_Utils_Tuple2(ecs, objLayer));
	});
var author$project$Main$world = {c4: author$project$World$Component$dimensions.aG, c5: author$project$World$Component$direction.aG, $7: author$project$World$Component$objects.aG, dv: author$project$World$Component$positions.aG};
var author$project$World$Subscription$isRegistered = F2(
	function (direction, key) {
		return A2(elm$core$Dict$member, key, direction.bg) ? elm$json$Json$Decode$succeed(key) : elm$json$Json$Decode$fail('not registered key');
	});
var author$project$World$Subscription$boolToInt = function (bool) {
	return bool ? 1 : 0;
};
var author$project$World$Subscription$keyToInt = function (key) {
	return A2(
		elm$core$Basics$composeR,
		elm$core$Set$member(key),
		author$project$World$Subscription$boolToInt);
};
var author$project$World$Subscription$arrows = F2(
	function (_n0, keys) {
		var up = _n0.bu;
		var right = _n0.bi;
		var down = _n0.a2;
		var left = _n0.a6;
		var y = A2(author$project$World$Subscription$keyToInt, up, keys) - A2(author$project$World$Subscription$keyToInt, down, keys);
		var x = A2(author$project$World$Subscription$keyToInt, right, keys) - A2(author$project$World$Subscription$keyToInt, left, keys);
		return {by: x, bz: y};
	});
var author$project$World$Subscription$updateKeys = F3(
	function (keyChanged, _n0, pressed) {
		var world1 = _n0.a;
		var world2 = _n0.b;
		var direction = world2.c5;
		if (_Utils_eq(world2.c5.dw, pressed)) {
			return elm$json$Json$Decode$fail('nothing chnaged');
		} else {
			var newComps = A2(
				elm$core$Maybe$withDefault,
				direction.a1,
				A2(
					elm$core$Maybe$andThen,
					function (id) {
						return A2(
							elm$core$Maybe$map,
							function (comp) {
								var _n1 = A2(author$project$World$Subscription$arrows, comp, pressed);
								var x = _n1.by;
								var y = _n1.bz;
								return A3(
									author$project$Logic$Entity$setComponent,
									id,
									_Utils_update(
										comp,
										{by: x, bz: y}),
									direction.a1);
							},
							A2(
								elm$core$Maybe$andThen,
								elm$core$Basics$identity,
								A2(elm$core$Array$get, id, direction.a1)));
					},
					A2(elm$core$Dict$get, keyChanged, direction.bg)));
			var updatedDirection = _Utils_update(
				direction,
				{a1: newComps});
			return elm$json$Json$Decode$succeed(
				_Utils_Tuple2(
					world1,
					_Utils_update(
						world2,
						{
							c5: _Utils_update(
								updatedDirection,
								{dw: pressed})
						})));
		}
	});
var elm$core$Set$insert = F2(
	function (key, _n0) {
		var dict = _n0;
		return A3(elm$core$Dict$insert, key, 0, dict);
	});
var author$project$World$Subscription$onKeyDown = function (_n0) {
	var world1 = _n0.a;
	var world2 = _n0.b;
	var direction = world2.c5;
	return A2(
		elm$json$Json$Decode$andThen,
		function (key) {
			return A3(
				author$project$World$Subscription$updateKeys,
				key,
				_Utils_Tuple2(world1, world2),
				A2(elm$core$Set$insert, key, direction.dw));
		},
		A2(
			elm$json$Json$Decode$andThen,
			author$project$World$Subscription$isRegistered(direction),
			A2(elm$json$Json$Decode$field, 'key', elm$json$Json$Decode$string)));
};
var elm$core$Set$remove = F2(
	function (key, _n0) {
		var dict = _n0;
		return A2(elm$core$Dict$remove, key, dict);
	});
var author$project$World$Subscription$onKeyUp = function (_n0) {
	var world1 = _n0.a;
	var world2 = _n0.b;
	var direction = world2.c5;
	return A2(
		elm$json$Json$Decode$andThen,
		function (key) {
			return A3(
				author$project$World$Subscription$updateKeys,
				key,
				_Utils_Tuple2(world1, world2),
				A2(elm$core$Set$remove, key, direction.dw));
		},
		A2(
			elm$json$Json$Decode$andThen,
			author$project$World$Subscription$isRegistered(direction),
			A2(elm$json$Json$Decode$field, 'key', elm$json$Json$Decode$string)));
};
var elm$browser$Browser$Events$Document = 0;
var elm$browser$Browser$Events$onKeyDown = A2(elm$browser$Browser$Events$on, 0, 'keydown');
var elm$browser$Browser$Events$onKeyUp = A2(elm$browser$Browser$Events$on, 0, 'keyup');
var author$project$World$Subscription$keyboard = function (world) {
	return elm$core$Platform$Sub$batch(
		_List_fromArray(
			[
				elm$browser$Browser$Events$onKeyDown(
				author$project$World$Subscription$onKeyDown(world)),
				elm$browser$Browser$Events$onKeyUp(
				author$project$World$Subscription$onKeyUp(world))
			]));
};
var author$project$Main$main = author$project$Game$document(
	{dx: author$project$Main$read, cQ: author$project$World$Subscription$keyboard, dL: author$project$Main$system, cV: author$project$Main$view, dT: author$project$Main$world});
_Platform_export({'Main':{'init':author$project$Main$main(elm$json$Json$Decode$value)(0)}});}(this));