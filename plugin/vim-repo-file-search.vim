""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Short utility for magically adding git/hg/svn repository roots to `&path` when
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
    if &path =~ ',' . s:repo_path . '\(/\*\*9\)'
        return
    endif

    " We made it :)
    let &path .= ',' . s:repo_path . '/**9'
    let w:vim_repo_file_search_repo_root = s:repo_path
endfunction

" Function to call every time we open a file
function! s:check_for_repo()
    let w:vim_repo_file_search_repo_root = "."

    "" Subversion
    call <SID>run_and_add_to_path('svn info --show-item wc-root')

    "" Mercurial
    call <SID>run_and_add_to_path('hg root')

    "" Git
    call <SID>run_and_add_to_path('git rev-parse --show-toplevel')
endfunction

augroup RepoFileSearch
    autocmd!
    autocmd BufReadPost * call <SID>check_for_repo()
augroup END
