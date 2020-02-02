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
    " Called with a delay to prevent some display artifacts :(
    autocmd VimEnter * call repo_file_search#check_for_repo_delayed(100)

    " Search for repo after new file is opened
    " Called with a delay to prevent some display artifacts :(
    autocmd BufReadPost * call repo_file_search#check_for_repo_delayed(100)

    " Also run in NERDTree windows
    autocmd FileType nerdtree call repo_file_search#check_for_repo(0)
augroup END