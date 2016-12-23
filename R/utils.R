################################################################################
##                                                                            ##
##  Author: Christoph Burow                                                   ##
##  Date: 2016-05-06                                                          ##
##                                                                            ##
##                                                                            ##
################################################################################

## MAIN ----
# This function is regularly called by projectBrowserAddin() and returns the
# (un)sorted project list.
get_Projects <- function(sortName, sortDate, decreasing, meta) {

  projects <- read_ProjList()

  if (is.null(projects))
    return("Please add projects using the 'Add' button")

  names <- gsub(".*\\/(.*)\\.Rproj$", "\\1", projects)
  last.access <- sapply(projects, function(x) format(file.info(x)$mtime))
  names(projects) <- names

  if (sortName)
    projects <- projects[order(names, decreasing = decreasing)]

  if (sortDate)
    projects <- projects[order(as.Date(last.access), decreasing = decreasing)]


  return(projects)
}

## READ FILE ----
# If the temporary project file at ~[Rlib]/projBrowser/proj/projects.txt
# does not exists, it creates a file via write_ProjFile()
read_ProjList <- function() {

  pkg.dir <- paste0(find.package("projBrowser"), "/proj")
  projFile <- paste0(pkg.dir, "/projects.txt")

  if (!file.exists(projFile))
    write_ProjList()

  file <- file(projFile, open = "r+b")
  entries <- readLines(file)
  if (length(entries) == 0)
    entries <- NULL
  close.connection(file)

  return(entries)
}

## FIND PROJECT FILES ----
# This function searches for .Rproj files recursively and returns a vector
# of file paths
find_Proj <- function(dir) {

  if (is.na(dir))
    print("dir na")

  files <- list.files(dir, pattern = "*.Rproj$", recursive = TRUE, full.names = TRUE)

  if (length(files) == 0)
    return(NULL)
  else
    return(files)
}

## ADD PROJECT ENTRIES ----
# This function adds new entries to an already existing projects file, or creates
# one first if needed
add_Proj <- function(entries) {

  if (missing(entries))
    return(NULL)

  pkg.dir <- paste0(find.package("projBrowser"), "/proj")
  projFile <- paste0(pkg.dir, "/projects.txt")

  if (!file.exists(projFile))
    write_ProjList()

  entries.old <- read_ProjList()

  file <- file(projFile, open = "r+b")

  entries.new <- unique(c(entries.old, entries))

  writeLines(entries.new, file)

  on.exit(closeAllConnections())
}

## CREATE FILE ----
write_ProjList <- function() {

  pkg.dir <- paste0(find.package("projBrowser"), "/proj")
  projFile <- paste0(pkg.dir, "/projects.txt")

  if (!dir.exists(pkg.dir))
    dir.create(pkg.dir)

  if (!file.exists(projFile))
    file.create(projFile)
}

## VALIDATE FILE ----
# This function reads the project file and checks for duplicate entries and
# verifies that all files exist. Duplicate and missing files are silently
# removed from the list
validate_ProjList <- function() {

  pkg.dir <- paste0(find.package("projBrowser"), "/proj")
  projFile <- paste0(pkg.dir, "/projects.txt")

  if (!file.exists(projFile))
    return(NULL)

  file <- file(projFile, open = "r+b")

  entries.old <- readLines(file)
  valid <- sapply(entries.old, file.exists)

  if (length(valid) != 0)
    entries.new <- entries.old[valid]
  else
    entries.new <- ""

  close.connection(file)
  file.remove(projFile)

  # create new file
  file.create(projFile)

  file <- file(projFile, open = "r+b")

  writeLines(unique(entries.new), file)

  on.exit(closeAllConnections())
}


# DELETE FILE ----
# This removes all entries by deleting and re-creating the file
clean_ProjList <- function() {

  pkg.dir <- paste0(find.package("projBrowser"), "/proj")
  projFile <- paste0(pkg.dir, "/projects.txt")

  if (file.exists(projFile)) {
    file.remove(projFile)
    file.create(projFile)
  }

}
