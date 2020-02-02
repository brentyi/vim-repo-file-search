""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Short utility for magically adding git/hg/svn repository roots to `&path` when
" we open version-controlled files.
" This makes `gf`, `sfind`, `find`, etc in vim actually work for various
" relative paths (particularly those in #include statements).
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup RepoFileSearch
    autocmd!

    " Search for repo when vim is opened
    " This is called with a longer delay to prevent some display artifacts
    autocmd VimEnter * call s:check_for_repo_delayed(200)

    " Search for repo after new file is opened
    " (Hacky) Makes a redundant, 0-delay call to fix issues with fzf... :(
    autocmd BufReadPost * call s:check_for_repo(0)
    autocmd BufReadPost * call s:check_for_repo_delayed(0)

    " Also run in NERDTree windows
    autocmd FileType nerdtree call s:check_for_repo(0)
augroup END

" Check if our current path lives in an svn/hg/git repository
" Add a delay for robustness
function! s:check_for_repo_delayed(time)
    call timer_start(a:time, function('s:check_for_repo'))
endfunction

function! s:check_for_repo(__unused_timer__)
    " Do nothing if we've already found a repo
    if get(b:, 'vim_repo_file_search_repo_type', 'none') != 'none'
        return
    endif

    let b:vim_repo_file_search_repo_root = '.'
    let b:vim_repo_file_search_repo_type = 'none'

    "" Subversion
    call s:run_and_add_to_path('svn', 'svn info --show-item wc-root')

    "" Mercurial
    call s:run_and_add_to_path("hg", 'hg root')

    "" Git
    call s:run_and_add_to_path('git', 'git rev-parse --show-toplevel')
endfunction

" Helper for running a 'repo locate' shell command and adding its output to
" &path if it's a valid & unique directory
function! s:run_and_add_to_path(type, command)
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

    " Set buffer repo root path
    let b:vim_repo_file_search_repo_root = s:repo_path
    let b:vim_repo_file_search_repo_type = a:type

    " Exit if path has already been added
    if &path =~ ',' . s:repo_path . '\(/\*\*9\)'
        return
    endif

    " We made it :)
    let &path .= ',' . s:repo_path . '/**9'
endfunction

