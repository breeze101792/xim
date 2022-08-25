
" Set 'background' back to the default.  The value can't always be estimated
" and is then guessed.
set background=light

" Remove all existing highlighting and set the defaults.
hi clear

" already done by hi clear
" Load the syntax highlighting defaults, if it's enabled.
" if exists("syntax_on")
"   syntax reset
" endif

hi! link Boolean Constant
hi! link Character Constant
hi ColorColumn cterm=none ctermfg=none ctermbg=224
hi Comment cterm=none ctermfg=4 ctermbg=none
hi Conceal cterm=none ctermfg=7 ctermbg=242
hi! link Conditional Statement
hi Constant cterm=none ctermfg=1 ctermbg=none
hi! link CurSearch Search
hi CursorColumn cterm=none ctermfg=none ctermbg=7
hi CursorLine cterm=underline ctermfg=none ctermbg=none
hi! link CursorLineFold FoldColumn
hi CursorLineNr cterm=underline ctermfg=130 ctermbg=none
hi! link CursorLineSign SignColumn
hi! link Debug Special
hi! link Define PreProc
hi! link Delimiter Special
hi DiffAdd cterm=none ctermfg=none ctermbg=81
hi DiffChange cterm=none ctermfg=none ctermbg=225
hi DiffDelete cterm=none ctermfg=12 ctermbg=159
hi DiffText cterm=bold ctermfg=none ctermbg=9
hi Directory cterm=none ctermfg=4 ctermbg=none
hi! link EndOfBuffer NonText
hi Error cterm=none ctermfg=15 ctermbg=9
hi ErrorMsg cterm=none ctermfg=15 ctermbg=1
hi! link Exception Statement
hi! link Float Constant
hi FoldColumn cterm=none ctermfg=4 ctermbg=248
hi Folded cterm=none ctermfg=4 ctermbg=248
hi! link Function Identifier
hi Identifier cterm=none ctermfg=6 ctermbg=none
hi Ignore cterm=none ctermfg=15 ctermbg=none
hi IncSearch cterm=reverse ctermfg=none ctermbg=none
hi! link Include PreProc
hi! link Keyword Statement
hi! link Label Statement
hi LineNr cterm=none ctermfg=130 ctermbg=none
hi! link Macro PreProc
hi MatchParen cterm=none ctermfg=none ctermbg=14
hi ModeMsg cterm=bold ctermfg=none ctermbg=none
hi MoreMsg cterm=none ctermfg=2 ctermbg=none
hi NONE cterm=none ctermfg=none ctermbg=none
hi NonText cterm=none ctermfg=12 ctermbg=none
hi Normal cterm=none ctermfg=none ctermbg=none
hi! link Number Constant
hi! link Operator Statement
hi Pmenu cterm=none ctermfg=0 ctermbg=225
hi PmenuSbar cterm=none ctermfg=none ctermbg=248
hi PmenuSel cterm=none ctermfg=0 ctermbg=7
hi PmenuThumb cterm=none ctermfg=none ctermbg=0
hi! link PreCondit PreProc
hi PreProc cterm=none ctermfg=5 ctermbg=none
hi Question cterm=none ctermfg=2 ctermbg=none
hi! link QuickFixLine Search
hi! link Repeat Statement
hi Search cterm=none ctermfg=none ctermbg=11
hi SignColumn cterm=none ctermfg=4 ctermbg=248
hi Special cterm=none ctermfg=5 ctermbg=none
hi! link SpecialChar Special
hi! link SpecialComment Special
hi SpecialKey cterm=none ctermfg=4 ctermbg=none
hi SpellBad cterm=none ctermfg=none ctermbg=224
hi SpellCap cterm=none ctermfg=none ctermbg=81
hi SpellLocal cterm=none ctermfg=none ctermbg=14
hi SpellRare cterm=none ctermfg=none ctermbg=225
hi Statement cterm=none ctermfg=130 ctermbg=none
hi StatusLine cterm=bold ctermfg=none ctermbg=none
hi StatusLineNC cterm=reverse ctermfg=none ctermbg=none
hi StatusLineTerm cterm=bold ctermfg=15 ctermbg=2
hi StatusLineTermNC cterm=none ctermfg=15 ctermbg=2
hi! link StorageClass Type
hi! link String Constant
hi! link Structure Type
hi TabLine cterm=underline ctermfg=0 ctermbg=7
hi TabLineFill cterm=reverse ctermfg=none ctermbg=none
hi TabLineSel cterm=bold ctermfg=none ctermbg=none
hi! link Tag Special
hi Title cterm=none ctermfg=5 ctermbg=none
hi Todo cterm=none ctermfg=0 ctermbg=11
hi ToolbarButton cterm=bold ctermfg=15 ctermbg=242
hi ToolbarLine cterm=none ctermfg=none ctermbg=7
hi Type cterm=none ctermfg=2 ctermbg=none
hi! link Typedef Type
hi Underlined cterm=underline ctermfg=5 ctermbg=none
hi VertSplit cterm=reverse ctermfg=none ctermbg=none
hi Visual cterm=none ctermfg=none ctermbg=7
hi WarningMsg cterm=none ctermfg=1 ctermbg=none
hi WildMenu cterm=none ctermfg=0 ctermbg=11
hi luaBlock cterm=none ctermfg=none ctermbg=none
hi! link luaBraceError Error
hi! link luaComment Comment
hi! link luaCond Statement
hi! link luaConstant Constant
hi! link luaElse Statement
hi luaElseifThen cterm=none ctermfg=none ctermbg=none
hi! link luaError Error
hi! link luaFor Statement
hi! link luaFunc Identifier
hi! link luaFunction Identifier
hi luaFunctionBlock cterm=none ctermfg=none ctermbg=none
hi luaIfThen cterm=none ctermfg=none ctermbg=none
hi! link luaIn Statement
hi luaInnerComment cterm=none ctermfg=none ctermbg=none
hi! link luaLabel Statement
hi luaLoopBlock cterm=none ctermfg=none ctermbg=none
hi! link luaNumber Constant
hi! link luaOperator Statement
hi luaParen cterm=none ctermfg=none ctermbg=none
hi! link luaParenError Error
hi! link luaRepeat Statement
hi! link luaSpecial Special
hi! link luaStatement Statement
hi! link luaString Constant
hi! link luaString2 Constant
hi! link luaTable Type
hi luaTableBlock cterm=none ctermfg=none ctermbg=none
hi luaThenEnd cterm=none ctermfg=none ctermbg=none
hi! link luaTodo Todo
hi! link perlAnglesDQ Constant
hi! link perlAnglesSQ Constant
hi! link perlArrow Identifier
hi perlBraces cterm=none ctermfg=none ctermbg=none
hi! link perlBracesDQ Constant
hi! link perlBracesSQ Constant
hi! link perlBracketsDQ Constant
hi! link perlBracketsSQ Constant
hi! link perlCharacter Constant
hi! link perlComment Comment
hi! link perlConditional Statement
hi! link perlControl PreProc
hi! link perlDATA Comment
hi! link perlDATAStart Comment
hi perlDoBlockDeclaration cterm=none ctermfg=none ctermbg=none
hi! link perlEND Comment
hi! link perlENDStart Comment
hi! link perlElseIfError Error
hi perlFakeGroup cterm=none ctermfg=none ctermbg=none
hi! link perlFiledescRead Identifier
hi! link perlFiledescStatement Identifier
hi perlFiledescStatementComma cterm=none ctermfg=none ctermbg=none
hi perlFiledescStatementNocomma cterm=none ctermfg=none ctermbg=none
hi! link perlFloat Constant
hi perlFormat cterm=none ctermfg=none ctermbg=none
hi! link perlFormatField Constant
hi! link perlFormatName Identifier
hi! link perlFunction Statement
hi! link perlFunctionName Identifier
hi! link perlFunctionPRef Type
hi! link perlHereDoc Constant
hi perlHereDocStart cterm=none ctermfg=none ctermbg=none
hi! link perlIdentifier Identifier
hi! link perlInclude PreProc
hi! link perlIndentedHereDoc Constant
hi perlIndentedHereDocStart cterm=none ctermfg=none ctermbg=none
hi! link perlLabel Statement
hi! link perlList Statement
hi! link perlMatch Constant
hi! link perlMatchModifiers Statement
hi! link perlMatchStartEnd Statement
hi! link perlMethod Identifier
hi! link perlMisc Statement
hi! link perlNotEmptyLine Error
hi! link perlNumber Constant
hi! link perlOperator Statement
hi perlPOD cterm=none ctermfg=none ctermbg=none
hi perlPackageConst cterm=none ctermfg=none ctermbg=none
hi! link perlPackageDecl Type
hi! link perlPackageRef Type
hi! link perlParensDQ Constant
hi! link perlParensSQ Constant
hi! link perlPostDeref Identifier
hi! link perlQ Constant
hi! link perlQQ Constant
hi! link perlQR Constant
hi! link perlQRModifiers Constant
hi! link perlQW Constant
hi! link perlRepeat Statement
hi! link perlSharpBang PreProc
hi! link perlShellCommand Constant
hi! link perlSpecial Special
hi! link perlSpecialAscii Special
hi! link perlSpecialDollar Special
hi! link perlSpecialMatch Special
hi! link perlSpecialString Special
hi! link perlSpecialStringU Special
hi! link perlSpecialStringU2 Constant
hi! link perlStatement Statement
hi! link perlStatementControl Statement
hi! link perlStatementFiledesc Statement
hi! link perlStatementFiles Statement
hi! link perlStatementFlow Statement
hi! link perlStatementHash Statement
hi! link perlStatementIOfunc Statement
hi! link perlStatementIPC Statement
hi! link perlStatementInclude Statement
hi! link perlStatementIndirObj Statement
hi perlStatementIndirObjWrap cterm=none ctermfg=none ctermbg=none
hi! link perlStatementList Statement
hi! link perlStatementMisc Statement
hi! link perlStatementNetwork Statement
hi! link perlStatementNumeric Statement
hi! link perlStatementPackage Statement
hi! link perlStatementProc Statement
hi! link perlStatementPword Statement
hi! link perlStatementRegexp Statement
hi! link perlStatementScalar Statement
hi! link perlStatementSocket Statement
hi! link perlStatementStorage Statement
hi! link perlStatementTime Statement
hi! link perlStatementVector Statement
hi! link perlStorageClass Type
hi! link perlString Constant
hi! link perlStringStartEnd Constant
hi! link perlStringUnexpanded Constant
hi! link perlSubAttribute PreProc
hi perlSubDeclaration cterm=none ctermfg=none ctermbg=none
hi! link perlSubName Identifier
hi! link perlSubPrototype Type
hi! link perlSubSignature Type
hi! link perlSubstitutionGQQ Constant
hi! link perlSubstitutionModifiers Statement
hi! link perlSubstitutionSQ Constant
hi perlSync cterm=none ctermfg=none ctermbg=none
hi perlSyncPOD cterm=none ctermfg=none ctermbg=none
hi! link perlTodo Todo
hi! link perlTranslationGQ Constant
hi! link perlTranslationModifiers Statement
hi! link perlType Type
hi! link perlVStringV Constant
hi perlVarBlock cterm=none ctermfg=none ctermbg=none
hi perlVarBlock2 cterm=none ctermfg=none ctermbg=none
hi perlVarMember cterm=none ctermfg=none ctermbg=none
hi! link perlVarNotInMatches Identifier
hi! link perlVarPlain Identifier
hi! link perlVarPlain2 Identifier
hi! link perlVarSimpleMember Identifier
hi! link perlVarSimpleMemberName Constant
hi! link perlVarSlash Identifier
hi! link podBeginComment Comment
hi podBold cterm=none ctermfg=none ctermbg=none
hi podBoldAlternativeDelim cterm=none ctermfg=none ctermbg=none
hi podBoldAlternativeDelimOpen cterm=none ctermfg=none ctermbg=none
hi podBoldItalic cterm=none ctermfg=none ctermbg=none
hi podBoldOpen cterm=none ctermfg=none ctermbg=none
hi! link podCmdText Constant
hi! link podCommand Statement
hi! link podEncoding Constant
hi! link podEscape Constant
hi! link podEscape2 Constant
hi! link podForComment Comment
hi! link podForKeywd Identifier
hi! link podFormat Identifier
hi! link podFormatDelimiter Identifier
hi! link podFormatError Error
hi podIndexAlternativeDelimOpen cterm=none ctermfg=none ctermbg=none
hi podIndexOpen cterm=none ctermfg=none ctermbg=none
hi podItalic cterm=none ctermfg=none ctermbg=none
hi podItalicAlternativeDelim cterm=none ctermfg=none ctermbg=none
hi podItalicAlternativeDelimOpen cterm=none ctermfg=none ctermbg=none
hi podItalicBold cterm=none ctermfg=none ctermbg=none
hi podItalicOpen cterm=none ctermfg=none ctermbg=none
hi podNoSpaceAlternativeDelimOpen cterm=none ctermfg=none ctermbg=none
hi podNoSpaceOpen cterm=none ctermfg=none ctermbg=none
hi! link podNonPod Comment
hi podOrdinary cterm=none ctermfg=none ctermbg=none
hi! link podOverIndent Constant
hi! link podSpecial Identifier
hi! link podTodo Todo
hi! link podVerbatim PreProc
hi! link pythonAsync Statement
hi pythonAttribute cterm=none ctermfg=none ctermbg=none
hi! link pythonBuiltin Identifier
hi! link pythonComment Comment
hi! link pythonConditional Statement
hi! link pythonDecorator PreProc
hi! link pythonDecoratorName Identifier
hi! link pythonDoctest Special
hi! link pythonDoctestValue PreProc
hi! link pythonEscape Special
hi! link pythonException Statement
hi! link pythonExceptions Type
hi! link pythonFunction Identifier
hi! link pythonInclude PreProc
hi pythonMatrixMultiply cterm=none ctermfg=none ctermbg=none
hi! link pythonNumber Constant
hi! link pythonOperator Statement
hi! link pythonQuotes Constant
hi! link pythonRawString Constant
hi! link pythonRepeat Statement
hi pythonSpaceError cterm=none ctermfg=none ctermbg=none
hi! link pythonStatement Statement
hi! link pythonString Constant
hi pythonSync cterm=none ctermfg=none ctermbg=none
hi! link pythonTodo Todo
hi! link pythonTripleQuotes Constant
hi! link vim9Comment Comment
hi! link vim9LineComment Comment
hi! link vimAbb Statement
hi! link vimAddress Constant
hi! link vimAuHighlight Statement
hi vimAuSyntax cterm=none ctermfg=none ctermbg=none
hi vimAugroup cterm=none ctermfg=none ctermbg=none
hi! link vimAugroupError Error
hi! link vimAugroupKey Statement
hi vimAugroupSyncA cterm=none ctermfg=none ctermbg=none
hi! link vimAutoCmd Statement
hi! link vimAutoCmdMod Special
hi! link vimAutoCmdOpt PreProc
hi vimAutoCmdSfxList cterm=none ctermfg=none ctermbg=none
hi vimAutoCmdSpace cterm=none ctermfg=none ctermbg=none
hi! link vimAutoEvent Type
hi vimAutoEventList cterm=none ctermfg=none ctermbg=none
hi! link vimAutoSet Statement
hi! link vimBehave Statement
hi! link vimBehaveError Error
hi! link vimBehaveModel Statement
hi! link vimBracket Special
hi! link vimBufnrWarn WarningMsg
hi vimClusterName cterm=none ctermfg=none ctermbg=none
hi vimCmdSep cterm=none ctermfg=none ctermbg=none
hi! link vimCmplxRepeat Special
hi vimCollClass cterm=none ctermfg=none ctermbg=none
hi! link vimCollClassErr Error
hi vimCollection cterm=none ctermfg=none ctermbg=none
hi vimComFilter cterm=none ctermfg=none ctermbg=none
hi! link vimCommand Statement
hi! link vimComment Comment
hi! link vimCommentString Constant
hi! link vimCommentTitle PreProc
hi vimCommentTitleLeader cterm=none ctermfg=none ctermbg=none
hi! link vimCondHL Statement
hi! link vimContinue Special
hi! link vimCtrlChar Special
hi vimEcho cterm=none ctermfg=none ctermbg=none
hi! link vimEchoHL Statement
hi! link vimEchoHLNone Type
hi! link vimElseIfErr Error
hi! link vimElseif Statement
hi! link vimEmbedError Error
hi! link vimEnvvar PreProc
hi! link vimErrSetting Error
hi! link vimError Error
hi! link vimEscape Special
hi vimEscapeBrace cterm=none ctermfg=none ctermbg=none
hi vimExecute cterm=none ctermfg=none ctermbg=none
hi vimExtCmd cterm=none ctermfg=none ctermbg=none
hi! link vimFBVar Identifier
hi! link vimFTCmd Statement
hi! link vimFTError Error
hi! link vimFTOption Type
hi! link vimFgBgAttrib PreProc
hi vimFiletype cterm=none ctermfg=none ctermbg=none
hi vimFilter cterm=none ctermfg=none ctermbg=none
hi! link vimFold Folded
hi! link vimFunc Error
hi vimFuncBlank cterm=none ctermfg=none ctermbg=none
hi vimFuncBody cterm=none ctermfg=none ctermbg=none
hi! link vimFuncEcho Statement
hi! link vimFuncKey Statement
hi! link vimFuncName Identifier
hi! link vimFuncSID Special
hi! link vimFuncVar Identifier
hi vimFunction cterm=none ctermfg=none ctermbg=none
hi! link vimFunctionError Error
hi vimGlobal cterm=none ctermfg=none ctermbg=none
hi! link vimGroup Type
hi! link vimGroupAdd Special
hi vimGroupList cterm=none ctermfg=none ctermbg=none
hi! link vimGroupName Type
hi! link vimGroupRem Special
hi! link vimGroupSpecial Special
hi! link vimHLGroup Type
hi! link vimHLMod PreProc
hi! link vimHiAttrib PreProc
hi! link vimHiAttribList Error
hi vimHiBang cterm=none ctermfg=none ctermbg=none
hi! link vimHiCTerm Type
hi! link vimHiClear Statement
hi vimHiCtermColor cterm=none ctermfg=none ctermbg=none
hi! link vimHiCtermError Error
hi! link vimHiCtermFgBg Type
hi! link vimHiCtermul Type
hi vimHiFontname cterm=none ctermfg=none ctermbg=none
hi! link vimHiGroup Type
hi! link vimHiGui Type
hi! link vimHiGuiFgBg Type
hi! link vimHiGuiFont Type
hi vimHiGuiFontname cterm=none ctermfg=none ctermbg=none
hi! link vimHiGuiRgb Constant
hi! link vimHiKeyError Error
hi vimHiKeyList cterm=none ctermfg=none ctermbg=none
hi vimHiLink cterm=none ctermfg=none ctermbg=none
hi! link vimHiNmbr Constant
hi! link vimHiStartStop Type
hi! link vimHiTerm Type
hi vimHiTermcap cterm=none ctermfg=none ctermbg=none
hi! link vimHighlight Statement
hi! link vimInsert Constant
hi vimIsCommand cterm=none ctermfg=none ctermbg=none
hi vimIskList cterm=none ctermfg=none ctermbg=none
hi! link vimIskSep Special
hi! link vimKeyCode Identifier
hi! link vimKeyCodeError Error
hi! link vimKeyword Statement
hi! link vimLet Statement
hi! link vimLetHereDoc Constant
hi! link vimLetHereDocStart Special
hi! link vimLetHereDocStop Special
hi! link vimLineComment Comment
hi vimLuaRegion cterm=none ctermfg=none ctermbg=none
hi! link vimMap Statement
hi! link vimMapBang Statement
hi vimMapLhs cterm=none ctermfg=none ctermbg=none
hi! link vimMapMod Special
hi! link vimMapModErr Error
hi! link vimMapModKey Special
hi vimMapRhs cterm=none ctermfg=none ctermbg=none
hi vimMapRhsExtend cterm=none ctermfg=none ctermbg=none
hi! link vimMark Constant
hi! link vimMarkNumber Constant
hi vimMenuBang cterm=none ctermfg=none ctermbg=none
hi vimMenuMap cterm=none ctermfg=none ctermbg=none
hi! link vimMenuMod Special
hi! link vimMenuName PreProc
hi! link vimMenuNameMore PreProc
hi vimMenuPriority cterm=none ctermfg=none ctermbg=none
hi vimMenuRhs cterm=none ctermfg=none ctermbg=none
hi! link vimMtchComment Comment
hi! link vimNorm Statement
hi vimNormCmds cterm=none ctermfg=none ctermbg=none
hi! link vimNotFunc Statement
hi! link vimNotPatSep Constant
hi! link vimNotation Special
hi! link vimNumber Constant
hi! link vimOper Statement
hi! link vimOperError Error
hi vimOperParen cterm=none ctermfg=none ctermbg=none
hi! link vimOption PreProc
hi! link vimParenSep Special
hi vimPatRegion cterm=none ctermfg=none ctermbg=none
hi! link vimPatSep Special
hi! link vimPatSepErr Error
hi! link vimPatSepR Special
hi! link vimPatSepZ Special
hi! link vimPatSepZone Constant
hi! link vimPattern Type
hi vimPerlRegion cterm=none ctermfg=none ctermbg=none
hi! link vimPlainMark Constant
hi! link vimPlainRegister Special
hi vimPythonRegion cterm=none ctermfg=none ctermbg=none
hi vimRange cterm=none ctermfg=none ctermbg=none
hi vimRegion cterm=none ctermfg=none ctermbg=none
hi! link vimRegister Special
hi! link vimScriptDelim Comment
hi! link vimSearch Constant
hi! link vimSearchDelim Statement
hi! link vimSep Special
hi vimSet cterm=none ctermfg=none ctermbg=none
hi vimSetEqual cterm=none ctermfg=none ctermbg=none
hi! link vimSetMod PreProc
hi! link vimSetSep Statement
hi! link vimSetString Constant
hi! link vimSpecFile Identifier
hi! link vimSpecFileMod Identifier
hi! link vimSpecial Type
hi! link vimStatement Statement
hi vimStdPlugin cterm=none ctermfg=none ctermbg=none
hi! link vimString Constant
hi! link vimStringCont Constant
hi! link vimStringEnd Constant
hi! link vimSubst Statement
hi! link vimSubst1 Statement
hi vimSubst2 cterm=none ctermfg=none ctermbg=none
hi! link vimSubstDelim Special
hi! link vimSubstFlagErr Error
hi! link vimSubstFlags Special
hi vimSubstPat cterm=none ctermfg=none ctermbg=none
hi vimSubstRange cterm=none ctermfg=none ctermbg=none
hi vimSubstRep cterm=none ctermfg=none ctermbg=none
hi vimSubstRep4 cterm=none ctermfg=none ctermbg=none
hi! link vimSubstSubstr Special
hi! link vimSubstTwoBS Constant
hi! link vimSynCase Type
hi! link vimSynCaseError Error
hi! link vimSynContains Special
hi! link vimSynError Error
hi! link vimSynKeyContainedin Special
hi! link vimSynKeyOpt Special
hi vimSynKeyRegion cterm=none ctermfg=none ctermbg=none
hi vimSynLine cterm=none ctermfg=none ctermbg=none
hi vimSynMatchRegion cterm=none ctermfg=none ctermbg=none
hi vimSynMtchCchar cterm=none ctermfg=none ctermbg=none
hi vimSynMtchGroup cterm=none ctermfg=none ctermbg=none
hi! link vimSynMtchGrp Special
hi! link vimSynMtchOpt Special
hi! link vimSynNextgroup Special
hi! link vimSynNotPatRange Constant
hi! link vimSynOption Special
hi vimSynPatMod cterm=none ctermfg=none ctermbg=none
hi! link vimSynPatRange Constant
hi! link vimSynReg Type
hi! link vimSynRegOpt Special
hi! link vimSynRegPat Constant
hi vimSynRegion cterm=none ctermfg=none ctermbg=none
hi! link vimSynType Type
hi! link vimSyncC Type
hi! link vimSyncError Error
hi! link vimSyncGroup Type
hi! link vimSyncGroupName Type
hi! link vimSyncKey Type
hi vimSyncLinebreak cterm=none ctermfg=none ctermbg=none
hi vimSyncLinecont cterm=none ctermfg=none ctermbg=none
hi vimSyncLines cterm=none ctermfg=none ctermbg=none
hi vimSyncMatch cterm=none ctermfg=none ctermbg=none
hi! link vimSyncNone Type
hi vimSyncRegion cterm=none ctermfg=none ctermbg=none
hi! link vimSyntax Statement
hi! link vimTodo Todo
hi! link vimType Type
hi! link vimUnmap Statement
hi! link vimUserAttrb Type
hi! link vimUserAttrbCmplt Type
hi! link vimUserAttrbCmpltFunc Special
hi! link vimUserAttrbError Error
hi! link vimUserAttrbKey PreProc
hi vimUserCmd cterm=none ctermfg=none ctermbg=none
hi! link vimUserCmdError Error
hi! link vimUserCommand Statement
hi! link vimUserFunc Normal
hi vimUsrCmd cterm=none ctermfg=none ctermbg=none
hi! link vimVar Identifier
hi! link vimWarn WarningMsg
hi! link vimoperStar Statement

let g:colors_name = 'vimdefault'
