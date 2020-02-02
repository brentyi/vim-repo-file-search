" Check if our current path lives in an svn/hg/git repository
" Add a delay for robustness
function! repo_file_search#check_for_repo_delayed(time)
    call timer_start(a:time, function('repo_file_search#check_for_repo'))
endfunction

function! repo_file_search#check_for_repo(__unused_timer__)
    let b:repo_file_search_root = '.'
    let b:repo_file_search_type = 'none'

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
    let b:repo_file_search_root = s:repo_path
    let b:repo_file_search_type = a:type

    " Exit if path has already been added
    if &path =~ ',' . s:repo_path . '\(/\*\*9\)'
        return
    endif

    " We made it :)
    let &path .= ',' . s:repo_path . '/**9'
endfunction

