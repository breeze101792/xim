" Vim syntax file
" Language:	Log
" Maintainer:	Shaowu Tseng <breeze101792@gmail.com>
" Last Change:	2022 Aug 27

" quit when a syntax file was already loaded.
if exists("b:current_syntax")
  finish
endif

" We need nocompatible mode in order to continue lines with backslashes.
" Original setting will be restored.
let s:cpo_save = &cpo
set cpo&vim

"=============================================================================== match

" syn match noteBlock /^*.*/
" syn match logError /\c[^a-zA-Z]err\(or\)\?/
" syn match logError /\c^err\(or\)\?/
syn match logError /\cerr\(or\)\?/

" syn match logError /\c[^a-zA-Z]fail\(ed\)\?/
" syn match logError /\c^fail\(ed\)\?/
syn match logError /\c^fail\(ed\)\?/

syn match logWarning /\cwarn\(ing\)\?/

syn match logDebug /\c\(dbg\|debug\)/

"=============================================================================== keyword
" syn keyword logStatement	False None True
" syn keyword logStatement	as assert break continue del exec global

"=============================================================================== link
" The default highlight links.  Can be overridden later.

hi def link logError		Error
hi def link logWarning		WarningMsg
hi def link logDebug		Debug

" hi def link logAsync		Statement
" hi def link logComment	Comment
" hi def link logConditional	Conditional
" hi def link logDecorator	Define
" hi def link logDecoratorName	Function
" hi def link logEscape		Special
" hi def link logException	Exception
" hi def link logFunction	Function
" hi def link logInclude	Include
" hi def link logOperator	Operator
" hi def link logQuotes		String
" hi def link logRawString	String
" hi def link logRepeat		Repeat
" hi def link logStatement	Statement
" hi def link logString		String
" hi def link logTodo		Todo


let b:current_syntax = "log"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2 ts=8 noet:
