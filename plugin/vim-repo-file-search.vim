""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Short utility for magically adding git/hg repository roots to `&path` when
" we open version-controlled files.
" This makes `gf`, `sfind`, `find`, etc in vim actually work for various
" relative paths (particularly those in #include statements).
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Helper for running a 'repo locate' shell command and adding its output to
" &path if it's a valid & unique directory
function! s:run_and_add_to_path(command)
    " Run command & strip out control sequences (\r, \n, etc)
    let s:repo_path=substitute(system(a:command), '[[:cntrl:]]', '', 'g')

    " Exit if shell command failed
    if v:shell_error > 0
        return
    endif

    " Exit if output is not a valid path
    if s:repo_path !~? '^/\([A-z0-9-_+./]\)\+$'
        return
    endif

    " Exit if path has already been added
    if &path =~ s:repo_path
        return
    endif

    " We made it :)
    let &path .= "," . s:repo_path . "/**9"
endfunction

" Function to call every time we open a file
function! s:check_for_repo()
    "" Git
    call <SID>run_and_add_to_path("git rev-parse --show-toplevel")

    "" Mercurial
    call <SID>run_and_add_to_path("hg root")
endfunction

augroup RepoFileSearch
    autocmd!
    autocmd BufEnter * call <SID>check_for_repo()
augroup END
