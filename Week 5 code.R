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

#cytoset also has a flowSet equivilant: 
cytoset <- load_cytoset_from_fcs(fcs_files, truncate_max_range = FALSE, transformation = FALSE)

cytoset

#you'll see less information when you run str(), since things aren't loaded in yet (see slides for more info)

#size comparison

obj_size(flowFrame)
obj_size(cytoframe)

#interconverting - some packages don't recognize cytoframe/set objects. So you can convert

ConvertedToCytoframe <- flowFrame_to_cytoframe(flowFrame)
ConvertedToCytoframe

ConvertedToFlowframe <- flowWorkspace::cytoframe_to_flowFrame(cytoframe)
ConvertedToFlowframe

ConvertedToCytoset <- flowSet_to_cytoset(flowSet)
ConvertedToCytoset

ConvertedToFlowset <- cytoset_to_flowSet(flowSet)
ConvertedToFlowset

#regardless of what you use, the next step is using gating (with GatingSet) -also gatingsets are s4 objects too

GatingSet1 <- GatingSet(flowSet)
GatingSet1 

GatingSet2 <- GatingSet(cytoset)
GatingSet2

#we're building gating sets over the next three weeks. For now we're bringing in dataset with gates
#you can bring in data from Flowjo, diva, and cytobank workspaces:

# BiocManager::install("CytoML") #Bioconductor
library(CytoML)

#The .wsp files within this week’s data where created via Floreada.io. 
# The main difference between the two files is one is a copy of the original that was opened within FlowJo, 
# and subsequently swtiched from logicle to bi-exponential transformation.

#you need to set up a file path. You can do this by looking first using list.files to find flowjo workspaces:

FlowJoWsp <- list.files(path = Folder, pattern = ".wsp", full = TRUE)
FlowJoWsp

#and now we're using str_detect to look for files that are "Opened" - whatever that means in flowjo

ThisWorkspace <- FlowJoWsp[stringr::str_detect(FlowJoWsp, "Opened")]
ThisWorkspace

#found one. Now you can  set up the intermediate object using open_flowjo_xml()
ws <- open_flowjo_xml(ThisWorkspace)
ws

#now you have the intermeidate object, which you can then make into a gating object using flowjo_to_gatingset():

#PAUSE. He fucked it up:

#However, due to how I named the original .fcs files 
# (“GROUPNAME” being individual specimens, “TUBENAME” being either Ctrl or SEB), 
# and downsampled to the same number of cells, we will encounter the following error

#gs <- flowjo_to_gatingset(ws=ws, name=1, path = Folder)
#gs
#! object 'gs' not found

#he looked at help: ?flowjo_to_gatingset

#And he fixed it using additional.keys:

gs <- flowjo_to_gatingset(ws=ws, name=1, path = Folder, additional.keys="GROUPNAME")
gs

class(gs)

#uuuuggghhhh he will never talk about gating will he. Here is how you FIND OUT HOW LONG A COMMAND TAKES TO RUN

system.time({

flowjo_to_gatingset(ws=ws, name=1, path = Folder, additional.keys="GROUPNAME")

})

#AND HERE'S ANOTHER PACKAGE TO DO THAT:

# install.packages("bench") # CRAN
library(bench)

mark(
  Test <- flowjo_to_gatingset(ws=ws, name=1, path = Folder, additional.keys="GROUPNAME"),
  iterations= 5
  )

#FINALLY, SOME GATES

#going back to the gs object, you can create a gate logic flowchart/"plot"

plot(gs) #oh, gs = gating strategy?

#or spit it out in text:
gs_get_pop_paths(gs)

#to get cell counts in gates:

Data <- gs_pop_get_count_fast(gs)
head(Data, 5)

#maybe you want to subset them based on metadata. To get that metadata:

pData(gs)

#here's using that to create an alternate gating strategy - this is not explained, will be covered in the future:

AlternateGS <- flowjo_to_gatingset(ws=ws, name=1, path = Folder,
 additional.keys="GROUPNAME",
 keywords=c("$DATE", "$CYT", "GROUPNAME"))
pData(AlternateGS)

#to visualize all this we can use ggcyto
# note though - ggplot2 recently had a major version change, with significant internal changes occuring. 
# As a consequence of these changes, ggcyto functions that relied on the old ggplot2 functions broke and had 
# to be updated.

#Any updates to CRAN packages are reflected immediately. By contrast, Bioconductor is on a twice yearly 
# release cycle, so to take advantage of the ggcyto “fixes” that allow it to interact with the new version of 
# ggplot2, we will need to make sure we have the “developmental” version installed.

#so need to check versions:
packageVersion("ggplot2")
packageVersion("ggcyto")

#mine are too old. So removing them:

#remove.packages("ggplot2")
#remove.packages("ggcyto")

#Then close/reopen positron

#installing ggplot version:
#install.packages("ggplot2")

#installing the dev version of ggcyto:
#remotes::install_github("RGLab/ggcyto")

#and loading
library(ggplot2)
library(ggcyto)

#The function responsible for plotting is the ggcyto() function. 
# The first argument (“gs[1]”) is designating which .fcs file in our GatingSet we are trying to visualize.

#The second argument (“subset”) corresponds to which gating node we want to visualize.
#  In this case, when set to “root”, we are seeing all cells present in the .fcs file. If we however wanted to
#  visualize the cells within the CD4+ gate, we would swap the value provided to this argument.

#The next argument “aes” stands for aesthetics (more on this next week).
#  You will notice it has its own set of parenthesis, in which we designate the markers/fluorophores
#  we want to visualize on the x and y axis.

#The final argument (“+ geom_hex(bins=100)”) specifies we want to generate a flow cytometry style plot,
#  with it’s bin arguments value setting the resolution.

ggcyto(gs[1], subset="CD4+", aes(x="FSC-A", y="SSC-A")) + geom_hex(bins=100) 

#alternative visualization (IFNg and TFNa)
ggcyto(gs[1], subset="CD8+", aes(x="IFNg", y="TNFa")) + geom_hex(bins=100) 

#you can also specifiy the flourophore instead of marker:
ggcyto(gs[1], subset="CD8+", aes(x="BV750-A", y="PE-Dazzle594-A")) + geom_hex(bins=100) 

#and tcell subset
ggcyto(gs[6], subset="Tcells", aes(x="CD4", y="CD8")) + geom_hex(bins=100)

