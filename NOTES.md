# random thoughts
## build process is similar to MapReduce
 - Map step: take all C files and in parallel transform them to .o
  - Reduce step: take all (really, some) .o files and link into a library, shared library, executable, etc
 - Map step: take all shared libraries, executables, docs
  - Reduce step: zip together
 - map step: take all zips and publish
  - reduce step: mark all published as latest

## file represented by a tuple
 - file is uniquely identified by (canonical absolute/(relative?) path, filename, creation time, modified time, content)
  - links (symbolic and hard) make it difficult to find canonical path
  - can use inode (or equivalent, eg NTFS guids) as canonical path
  - or open_by_handle_at on Linux