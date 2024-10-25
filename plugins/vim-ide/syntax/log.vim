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

" Operators
"---------------------------------------------------------------------------
syn match logOperator display '[;,\?\:\.\<=\>\~\/\@\&\!$\%\&\+\-\|\^(){}\*#]'
syn match logBrackets display '[\[\]]'
syn match logEmptyLines display '-\{3,}'
syn match logEmptyLines display '\*\{3,}'
syn match logEmptyLines display '=\{3,}'
syn match logEmptyLines display '- - '

" Constants
"---------------------------------------------------------------------------
syn match logNumber       '\<-\?\d\+\>'
syn match logHexNumber    '\<0[xX]\x\+\>'
syn match logHexNumber    '\<\d\x\+\>'
syn match logBinaryNumber '\<0[bB][01]\+\>'
syn match logFloatNumber  '\<\d.\d\+[eE]\?\>'

syn keyword logBoolean    TRUE FALSE True False true false
syn keyword logNull       NULL Null null

syn region logString      start=/"/ end=/"/ end=/$/ skip=/\\./
" Quoted strings, but no match on quotes like "don't", "plurals' elements"
syn region logString      start=/'\(s \|t \| \w\)\@!/ end=/'/ end=/$/ end=/s / skip=/\\./


" Dates and Times
"---------------------------------------------------------------------------
" Match the date: dd/mm/yyyy hh:mm:ss
syn match logDate 'd{2}/d{2}/d{4}s*d{2}:d{2}:d{2}'

" Matches 2018-03-12T or 12/03/2018 or 12/Mar/2018
syn match logDate '\d\{2,4}[-\/]\(\d\{2}\|Jan\|Feb\|Mar\|Apr\|May\|Jun\|Jul\|Aug\|Sep\|Oct\|Nov\|Dec\)[-\/]\d\{2,4}T\?'
" Matches 8 digit numbers at start of line starting with 20
syn match logDate '^20\d\{6}'
" Matches Fri Jan 09 or Feb 11 or Apr  3
syn match logDate '\(\(Mon\|Tue\|Wed\|Thu\|Fri\|Sat\|Sun\) \)\?\(Jan\|Feb\|Mar\|Apr\|May\|Jun\|Jul\|Aug\|Sep\|Oct\|Nov\|Dec\) [0-9 ]\d'

" Matches Wed Jan 30 00:43:34 2019
syn match logDate '\v(Mon|Tue|Wed|Thu|Fri|Sat|Sun) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d\d \d\d:\d\d:\d\d \d\d\d\d'

" Matches 12:09:38 or 00:03:38.129Z or 01:32:12.102938 +0700
syn match logTime '\d\{2}:\d\{2}:\d\{2}\(\.\d\{2,6}\)\?\(\s\?[-+]\d\{2,4}\|Z\)\?\>' nextgroup=logTimeZone,logSysColumns skipwhite

" Follows logTime, matches UTC or PDT 2019 or 2019 EDT
syn match logTimeZone '\(UTC\|PDT\|EDT\|GMT\|EST\|KST\)\( \d\{4}\)\?' contained
syn match logTimeZone '\d\{4} \(UTC\|PDT\|EDT\|GMT\|EST\|KST\)' contained

" Syslog Columns
"---------------------------------------------------------------------------
" Syslog hostname, program and process number columns
syn match logSysColumns '\w\(\w\|\.\|-\)\+ \(\w\|\.\|-\)\+\(\[\d\+\]\)\?:' contains=logOperator,logSysProcess contained
syn match logSysProcess '\(\w\|\.\|-\)\+\(\[\d\+\]\)\?:' contains=logOperator,logNumber,logBrackets contained

" Levels
"---------------------------------------------------------------------------
syn keyword logLevelEmergency emergency Emergency EMERGENCY EMERG
syn keyword logLevelAlert ALERT
syn keyword logLevelCritical CRITICAL CRIT fatal Fatal FATAL
syn keyword logLevelError Error error Error Error ERROR ERR fail Fail failed Failed FAILED fails failure Failure FAILURE SEVERE Unable
syn keyword logLevelWarning warning Warning WARNING warn Warn WARN
syn keyword logLevelNotice NOTICE
syn keyword logLevelInfo info Info INFO
syn keyword logLevelDebug DEBUG FINE
syn keyword logLevelTrace TRACE FINER FINEST

" Highlight links
"---------------------------------------------------------------------------
hi def link logNumber Number
hi def link logHexNumber Number
hi def link logBinaryNumber Number
hi def link logFloatNumber Float
hi def link logBoolean Boolean
hi def link logNull Constant
hi def link logString String

hi def link logDate Function
hi def link logTime Function
hi def link logTimeZone Function

hi def link logSysColumns Conditional
hi def link logSysProcess Include

hi def link logOperator Operator
hi def link logBrackets Comment
hi def link logEmptyLines Comment

hi def link logLevelEmergency ErrorMsg
hi def link logLevelAlert ErrorMsg
hi def link logLevelCritical ErrorMsg
hi def link logLevelError ErrorMsg
hi def link logLevelWarning WarningMsg
hi def link logLevelNotice Character
hi def link logLevelInfo Repeat
hi def link logLevelDebug Debug
hi def link logLevelTrace Comment




let b:current_syntax = "log"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2 ts=8 noet:
