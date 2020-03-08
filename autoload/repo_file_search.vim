" Check if our current path lives in an svn/hg/git repository
" Add a delay for robustness
function! repo_file_search#check_for_repo_delayed(time)
    call timer_start(a:time, function('repo_file_search#check_for_repo'))
endfunction

function! repo_file_search#check_for_repo(__unused_timer__)
    let b:repo_file_search_root = '.'
    let b:repo_file_search_type = 'none'

    " Subversion
    call s:run_and_add_to_path('svn', 'svn info --show-item wc-root')

    " Mercurial
    call s:run_and_add_to_path("hg", 'hg root')

    " Git
    call s:run_and_add_to_path('git', 'git rev-parse --show-toplevel')

    " Update statusline variable
    call s:update_display()
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

" Helper for generating a human-readable 'path to current file' value, and
" assigning b:repo_file_search_display to it
function! s:update_display()
    " Get a full path to the current file
    let l:full_path = expand("%:p")

    " Chop off the filename
    let l:full_path = l:full_path[:-len(expand("%:t")) - 2]

    " Generate path to our file relative to our repository root
    let l:repo_path = l:full_path
    let l:repo_root = get(b:, 'repo_file_search_root')
    if len(l:repo_root) > 0
        " Generate a path relative to our repository root's parent
        let l:repo_head = fnamemodify(fnamemodify(l:repo_root, ':h'), ':h')
        if l:full_path[:len(l:repo_head)-1] ==# l:repo_head
            let l:repo_path = ".../" . l:full_path[len(l:repo_head) + 1:]
        endif
    endif

    " Generate a path relative to our home directory
    let l:home_path = l:full_path
    if l:full_path[:len($HOME)-1] ==# $HOME
        let l:home_path = "~" . l:full_path[len($HOME):]
    endif

    " Return shorter option
    if len(l:repo_path) < len(l:home_path)
        let b:repo_file_search_display = l:repo_path
    else
        let b:repo_file_search_display = l:home_path
    endif
endfunction
