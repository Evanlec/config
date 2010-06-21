" Syntax Abrreviations.
"
" Abbreviate as long as you aren't in a  syntax group that is a comment!
" Author: Michael Geddes
" Version: 0.1
" History:
"
"
" Synabbrev to To
" Synabbrev <buffer> from From

fun! s:CommentSyntaxAbbrev( cmd, ...)
    let buffer=""
    if a:0 == 3 && a:1 == '<buffer>'
        let buffer=a:1.' '
        let orig=a:2
        let new=a:3
    elseif a:0 > 2 
        echoerr 'Too many arguments ('.a:3.')'
        return
    else
        let orig=a:1
        let new=a:2
    endif
    exe a:cmd.' '.buffer.orig." <c-r>=<SID>DoAbbrev( '".orig."','".new."')<CR>"
endfun

com! -nargs=+ -bang -bar Synabbreviate call <SID>CommentSyntaxAbbrev("iabbrev<bang>", <f-args>)

fun! s:DoAbbrev( oldval, newval)
    if synIDattr(synID(line('.'),col('.')-1,1), "name") =~? 'comment$'
        return a:oldval
    else
        return a:newval
    endif
endfun


