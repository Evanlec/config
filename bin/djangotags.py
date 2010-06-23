#!/usr/bin/python
import sys
import os
import glob
import sys
import fnmatch
import os
import fnmatch
 
class GlobDirectoryWalker:
    # a forward iterator that traverses a directory tree
 
    def __init__(self, directory, pattern="*"):
        self.stack = [directory]
        self.pattern = pattern
        self.files = []
        self.index = 0
 
    def __getitem__(self, index):
        while 1:
            try:
                file = self.files[self.index]
                self.index = self.index + 1
            except IndexError:
                # pop next directory from stack
                self.directory = self.stack.pop()
                self.files = os.listdir(self.directory)
                self.index = 0
            else:
                # got a filename
                fullname = os.path.join(self.directory, file)
                if os.path.isdir(fullname) and not  os.path.islink(fullname):
                    self.stack.append(fullname)
                if fnmatch.fnmatch(file, self.pattern):
                    return fullname
 
try:
    os.unlink("tags")
except:
    pass
os.system("ctags -R --file-tags=yes *")
 
f = open("tags.temp", "w")
for line in open("tags"):
    if line.startswith("!_TAG_FILE_SORTED"):
        f.write("!_TAG_FILE_SORTED  0   /0=unsorted, 1=sorted, 2=foldcase/")
    else:
        f.write(line)
 
for file in GlobDirectoryWalker(".", "*.py"):
    comp = file.split("/")
    tag = comp[-2] + "." + comp[-1].split(".")[0]
    f.write(tag + "\t" + file + "\t1;\"\tF" + "\n")
 
f.close()
os.unlink("tags")
os.rename("tags.temp", "tags")
