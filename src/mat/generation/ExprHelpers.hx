package mat.generation;

#if macro

using mat.generation.ExprHelpers;

import haxe.macro.Expr;
using haxe.macro.ExprTools;

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
					if(v.name == "_") {
						v.name = name;
					} else if(doubleUnderscore != null && v.name == "__") {
						v.name = doubleUnderscore;
					}
					if(v.expr != null) {
						v.expr = replaceUnderscore(v.expr, name, doubleUnderscore);
					}
					return v;
				}))
			};
		}
		case _:
	}
	return e.map(_e -> replaceUnderscore(_e, name, doubleUnderscore));
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
