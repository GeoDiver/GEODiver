#!/usr/bin/Rsript
# ---------------------------------------------------------------------------
# Filename      : DGEA.R
# Authors       : IsmailM, Nazrath, Suresh, Marian, Anissa
# Description   : Retrieve individual gene expressions and convert to JSON
# Run           : Rscript dgea_expression.R  --rundir ~/Desktop/ --geneid LOC100288410
# ---------------------------------------------------------------------------

suppressMessages(library("argparser"))    # Argument passing
suppressMessages(library("jsonlite"))     # Convert R object to JSON format

#############################################################################
#                        Command Line Arguments                             #
#############################################################################
parser <- arg_parser("This parser contains the input arguments")
parser <- add_argument(parser, "--rundir", default = ".",
                       help = "Full path to the run directory")
parser <- add_argument(parser, "--geneid", help = "Row Id of the X matrix",
                       "LOC100288410")
argv   <- parse_args(parser)
options(bitmapType = "cairo") # Force R to use Cairo to create images

# Check if the run directory exists and if not, exit...
if (!dir.exists(file.path(argv$rundir))) {
  cat("ERROR: The run directory does not exist.", file = stderr())
  quit(save = "no", status = 1, runLast = FALSE)
}

#############################################################################
#                          Loading Saved Dataset                            #
#############################################################################
# check directory exists
filename <- file.path(argv$rundir, "dgea_toptable.RData")
if (file.exists(filename)) {
  load(file = filename)
} else {
  cat("ERROR: DGEA Toptable RData file not found.\n", file = stderr())
  quit(save = "no", status = 1, runLast = FALSE)
}

#############################################################################
#                          Retrieve Expression data                         #
#############################################################################
# Check availability of toptable expression data
if (!is.na(X.toptable)) {
  # get indexes of group 1 & 2
  index.group1 <- which( (expression_info["population"] == popname1) == TRUE)
  index.group2 <- which( (expression_info["population"] == popname2) == TRUE)

  # Group1 & 2 use indexes to get sample names (x) and expression data (y)
  d <- list(group1 = list(x = names(X.toptable[argv$geneid, index.group1]),
                          y = as.double(X.toptable[argv$geneid, index.group1])),
            group2 = list(x = names(X.toptable[argv$geneid, index.group2]),
                          y = as.double(X.toptable[argv$geneid, index.group2])),
            group1_name = popname1,
            group2_name = popname2)

  # write to a file
  file <- file.path(argv$rundir, paste("dgea_", argv$geneid, ".json", sep = ""))
  write(toJSON(d), file)
} else {
  cat("ERROR: Top table Data not found in the provided Rdata file.\n",
      file = stderr())
  quit(save = "no", status = 1, runLast = FALSE)
}
