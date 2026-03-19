#attaching the flowCore package to the local environment. This will let us use read.FCS() to read .fcs files in R
# if not installed: BiocManager::install("flowCore") - this is from Bioconductor
library(flowCore)

#setting up some file path shortcuts to make working with data from a few locations easier:
# folder <- file.path("course", "05_GatingSets", "data") # For Testing

Folder <- file.path("data") # For quarto rendering
#can I change the "data" part to include a path to the week_05 folder and the data inside? What about making it recursive to look in folders?
fcs_files <-list.files(Folder, patter=".fcs", full.names=TRUE)

fcs_files[1] #looking at the first file

flowFrame <-read.FCS(filename=fcs_files[1], truncate_max_range = FALSE, transformation = FALSE) 
#making the information read into the object called flowFrame

flowFrame

#some notes about what you can do with read.FCS()
#let's say you're passing that entire list of files, instead of providing an index number to specify one:

# read.FCS(filename=fcs_files, truncate_max_range = FALSE, transformation = FALSE) 

#doesn't work. Gets you a "filename must be character scalar" error
#the function is expecting a single value (scalar), but the combined vector(fcs_files) contains multiple values

#so if you want multiple .fcs files, use read.flowSet()

flowSet<-read.flowSet(files=fcs_files, truncate_max_range = FALSE, transformation = FALSE) 

flowSet

#can also designated specific files within "fcs_files" by concatonating them. This is for 1, 3, and 4:

read.flowSet(files=fcs_files[c(1, 3:4)],
truncate_max_range = FALSE, transformation = FALSE)

#checking the flowSet object class:

class(flowSet)

#it's a flowset object, which is part of the flowcore package
#this is a bioconductor S4-type object that within its frame slot contains "flowFrames" 
#(you can see this by expanding the "flowset/frames" menus in the variables sidebar)
#essentially, the flowset is a container of more containers

str(flowSet) # this will also get you information, it's just a bunch of text in the console window. 
#some of this text you can see represent how many folders/levels deep something is

#you can also access some of the subfolders (and files inside them) using @, as from week 3

#note about memory and flowFrame/Set:
#the .fcs files are read into your RAM. You can exceed it with big enough files.

#checking how much memory is being used by specific variables/objects:
#using lobstr R package's obj_size() function (not to be confused with base R's object.size())

# Base R
object.size(flowFrame)

#install.packages("lobstr") #this is from CRAN

#using lobstr
library(lobstr)
obj_size(flowFrame)

#and looking at flowset (it's bigger)
obj_size(flowSet)

#to look at total memory:

mem_used()

#to see what's available for the pc:

#install - install.packages("ps")
library(ps)
ps_system_memory()

Memory <- ps::ps_system_memory()
message("Total GB ", round(Memory$total / 1024^3, 2))
message("Free GB ", round(Memory$free / 1024^3, 2))

#and to look at your system info/name and give memory info (and get complicated with conditionals)

OperatingSystem <- Sys.info()[["sysname"]]

if (OperatingSystem == "Windows") { # Windows
  # install.packages("ps") # CRAN
   Memory <- ps::ps_system_memory()
   message("Total GB ", round(Memory$total / 1024^3, 2))
   message("Free GB ", round(Memory$free / 1024^3, 2))

  } else if (OperatingSystem == "Darwin") { # MacOS
    system("top -l 1 | grep PhysMem")

  } else if (OperatingSystem == "Linux") { # Linux
    system("free -h")

  } else {message("A wild FreeBSD-User appears")}

#another R package that reduces the memory load (gets around overhead using "pointers") - flowWorkspace
#pointers doesn't load things in until they're needed - that reduces background memory usage

# BiocManager::install("flowWorkspace") #Bioconductor
library(flowWorkspace)

#similar abilities and object types to flowFrame/flowSet:

cytoframe <- load_cytoframe_from_fcs(fcs_files[1], truncate_max_range=FALSE)
cytoframe