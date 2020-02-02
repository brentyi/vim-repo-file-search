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
    autocmd VimEnter * call repo_file_search#check_for_repo_delayed(200)

    " Search for repo after new file is opened
    " (Hacky) Makes a redundant, 0-delay call to fix issues with fzf... :(
    autocmd BufReadPost * call repo_file_search#check_for_repo(0)
    autocmd BufReadPost * call repo_file_search#check_for_repo_delayed(0)

    " Also run in NERDTree windows
    autocmd FileType nerdtree call repo_file_search#check_for_repo(0)
augroup END
