" Short utility for magically adding git/hg repository roots to `&path` when we open version-controlled files.
" This makes `gf`, `sfind`, `find`, etc in vim actually work for various relative paths (particularly those in #include statements).

function! s:check_for_repo()

    " Git
    let s:git_path=system("git rev-parse --show-toplevel | tr -d '\\n'")
    if strlen(s:git_path) > 0 && s:git_path !~ "\^fatal" && s:git_path !~ "command not found" && &path !~ s:git_path
        let &path .= "," . s:git_path . "/**9"
    endif

    " Mercurial
    let s:hg_path=system("hg root | tr -d '\\n'")
    if strlen(s:hg_path) > 0 && s:hg_path !~ "\^abort" && s:hg_path !~ "command not found" && &path !~ s:hg_path
        let &path .= "," . s:hg_path . "/**9"
    endif

endfunction

augroup RepoFileSearch
    autocmd!
    autocmd BufEnter * call <SID>check_for_repo()
augroup END
