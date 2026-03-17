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
#(you can see this by expanding the "flowset/frames" menus in the variables sidebar)As