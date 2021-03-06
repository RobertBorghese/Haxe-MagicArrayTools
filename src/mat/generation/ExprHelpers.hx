package mat.generation;

#if macro

using mat.generation.ExprHelpers;

import haxe.macro.Expr;
using haxe.macro.ExprTools;

// If the expression is EMeta, and the meta's name matched the provided name,
// the internal expression is returned.
// Otherwisde, null is returned.
function isMeta(e: Expr, metaName: String): Expr {
	switch(e.expr) {
		case EMeta(s, e): {
			if(s.name == metaName) {
				return e;
			}
		}
		case _:
	}
	return null;
}

// If the expression is EReturn, the internal expression is returned.
// Otherwise, null is returned.
function isReturn(e: Expr): Null<Expr> {
	return switch(e.expr) {
		case EReturn(ex): ex;
		case EBlock(exprs): {
			if(exprs.length == 1) {
				isReturn(exprs[0]);
			} else {
				null;
			}
		}
		case EMeta(m, ex): {
			return {
				pos: e.pos,
				expr: EMeta(m, isReturn(ex))
			};
		}
		case _: null;
	}
}

function isBoolLiteral(e: Expr): Null<Bool> {
	return switch(e.expr) {
		case EConst(c): {
			switch(c) {
				case CIdent(s): {
					if(s == "true") true;
					else if(s == "false") false;
					else null;
				}
				case _: null;
			}
		}
		case _: null;
	}
}

function isZero(e: Expr): Bool {
	return switch(e.expr) {
		case EConst(c): {
			switch(c) {
				case CInt(s): s == "0";
				case _: false;
			}
		}
		case _: false;
	}
}

function isFunction(e: Expr, argCount: Int): Bool {
	return switch(e.expr) {
		case EFunction(k, f): {
			f.args != null && f.args.length == argCount;
		}
		case _: false;
	}
}

// For functions like "indexOf", where the argument should be an object,
// it's likely an operation expression may be passed (function call, array access, etc.).
// If it's an operation, I want to store it in variable instead of inlining in the for-loop.
// This function checks to see if the operation has a runtime cost beyond variable access.
function isCostly(e: Expr) {
	return switch(e.expr) {
		case EConst(c): {
			switch(c) {
				// if single-quotes, there could be an expression in it?
				case CString(_, SingleQuotes): true;
				// regexp converts to object creation on most platforms?
				case CRegexp(_, _): true;
				case _: false;
			}
		}
		case EParenthesis(e2): isCostly(e2);
		case EMeta(_, e2): isCostly(e2);
		case _: true;
	}
}

function replaceUnderscore(e: Expr, name: String, doubleUnderscore: Null<String> = null): Expr {
	switch(e.expr) {
		case EConst(c): {
			switch(c) {
				case CIdent(str): {
					if(str == "_") {
						return { expr: EConst(CIdent(name)), pos: e.pos };
					} else if(doubleUnderscore != null && str == "__") {
						return { expr: EConst(CIdent(doubleUnderscore)), pos: e.pos };
					}
				}
				case _:
			}
		}
		case EVars(vars): {
			return {
				pos: e.pos,
				expr: EVars(vars.map(function(v) {
					return {
						name: (if(v.name == "_") {
							name;
						} else if(doubleUnderscore != null && v.name == "__") {
							doubleUnderscore;
						} else {
							v.name;
						}),
						expr: (if(v.expr != null) {
							replaceUnderscore(v.expr, name, doubleUnderscore);
						} else {
							null;
						}),
						meta: v.meta,
						isFinal: v.isFinal,
						type: v.type
					};
				}))
			};
		}
		case _:
	}
	return e.map(_e -> replaceUnderscore(_e, name, doubleUnderscore));
}

function replaceIdentWithUnderscore(e: Expr, name: String): Expr {
	switch(e.expr) {
		case EConst(c): {
			switch(c) {
				case CIdent(str): {
					if(str == name) {
						return { expr: EConst(CIdent("_")), pos: e.pos };
					}
				}
				case _:
			}
		}
		case _:
	}
	return e.map(_e -> replaceIdentWithUnderscore(_e, name));
}

function stripImplicitReturnMetadata(e: Expr) {
	switch(e.expr) {
		case EMeta(m, e): {
			if(m.name == ":implicitReturn") {
				return e.map(stripImplicitReturnMetadata);
			}
		}
		case _:
	}
	return e.map(stripImplicitReturnMetadata);
}

function removeMergeBlocks(e: Expr): Expr {
	final newExprDef = switch(e.expr) {
		case EBlock(exprs): {
			EBlock(removeMergeBlocksFromArray(exprs));
		}
		case _: e.expr;
	}
	final newExpr = { expr: newExprDef, pos: e.pos };
	return newExpr.map(removeMergeBlocks);
}

function removeMergeBlocksFromArray(exprs: Array<Expr>): Array<Expr> {
	final result = [];
	for(e in exprs) {
		switch(e.expr) {
			case EMeta(s, me): {
				if(s.name == ":mergeBlock") {
					switch(me.expr) {
						case EBlock(blockExprs): {
							final newBlockExprs = removeMergeBlocksFromArray(blockExprs);
							for(be in newBlockExprs) {
								result.push(be);
							}
						}
						case _: result.push(me);
					}
				} else {
					result.push(e);
				}
			}
			case _: result.push(e);
		}
	}
	return result;
}

#end
