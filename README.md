# git_filetag
Tag files with category information using Notes and PowerShell

## Synopsys
How you ever wished that you could list files in a git folder by category or by tags?
Well I have. I wan't a "SharePoint" solution based on Git.

You could work with meta files in the Git structure, but then the meta files would also be part of the Git commits 
(which actually might be what you are looking for). But by using `git notes` you can keep the meta information 
outside of any commits.

## Requirements
* A Git repo that supports Notes.
* PowerShell

## Usage overview
* Download the PowerShell module (just a script at the moment that you need to . source).
* Build the `$FileTag` variable and save it as a compressed JSON structure in Notes
* Dice and slice the `FileTags` variable :)

**WARNING!** Current implementation will replace all file names in the git folder with GUIDs to make sure 
the tags really stays with the correct files.  
Don't apply to production data until you now how to work with git_filetag
