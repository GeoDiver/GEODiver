#!/usr/bin/Rsript
# ---------------------------------------------------------#
# Filename      : DGEA.R                                   #
# Authors       : IsmailM, Nazrath, Suresh, Marian, Anisa  #
# Description   : Differential Gene Expression Analysis    #
# Usage         : Rscript overview.R --accession GDS5093 --dbrdata ~/Desktop/GDS5093.rData --rundir ~/Desktop/dgea/ --factor "disease.state" --pop_a "Dengue Hemorrhagic Fever,Convalescent,Dengue Fever" --pop_b "healthy control" --popname1 "Dengue" --popname2 "Normal" --analyse "Boxplot,PCA" --dev TRUE
# ---------------------------------------------------------#

#############################################################################
#                        Import Libraries                                   #
#############################################################################
# load required libraries and silence library loading messages on command line
suppressMessages(library("argparser"))     # Argument passing
suppressMessages(library("Cairo"))         # Plots saving
suppressMessages(library("dendextend"))    # Dendogram extended functionalities
suppressMessages(library("DMwR"))          # Outlier Prediction for clustering
suppressMessages(library("GEOquery"))      # GEO dataset Retrieval
suppressMessages(library("ggplot2"))       # Graphs designing
suppressMessages(library("jsonlite"))      # Convert R object to JSON format
suppressMessages(library("plyr"))          # Splitting/Applying/Combining Data
suppressMessages(library("RColorBrewer"))  # Import Colour Pallete
suppressMessages(library("reshape2"))      # Prepare dataset for ggplot
suppressMessages(library("squash"))        # Clustering Dendogram

#############################################################################
#                          Load Functions                                   #
#############################################################################
# a function to split arguments
split_arg <- function(vector_arg) {
  pos  <- unlist(gregexpr("[^\\\\],", vector_arg, perl = TRUE))
  vect <- substring(vector_arg, c(1, pos + 2), c(pos, nchar(vector_arg)))
  vect <- gsub("\\\\,", ",", vect) # replace \\, with ,
  vect <- gsub("\\\"", '"', vect) # replace \" with "
  vect <- gsub('\\\\-', "-", vect) # replace \\- with -
  return (vect)
}

# Check if the run directory exists and if not, create directory...
assert_run_dir_present <- function(run_dir) {
  if (!dir.exists(file.path(run_dir))) {
    dir.create(file.path(run_dir))
  }
}

# Generate the boxplot
generate_boxplot <- function(data, pop_colours, pop_names, dir_path, isdebug) {
  # compute lower and upper whiskers to set the y axis margin
  ylim1 <- boxplot.stats(data$value)$stats[c(1, 5)]
  b <- ggplot(data)
  b <- b + geom_boxplot(aes(x = Var2, y = value, colour = Groups),
                        outlier.shape = NA)
  b <- b + theme(axis.text.x = element_text(angle = 70, hjust = 1),
                 legend.position = "right")
  b <- b + scale_color_manual(name = "Groups", values = pop_colours,
                              labels = pop_names)
  b <- b + labs(x = "Samples", y = "Expression Levels")
  boxplot  <- b + coord_cartesian(ylim = ylim1 * 1.05) # set y limits with ylim1
  filename <- file.path(dir_path, "boxplot.png")
  ggsave(filename, plot = boxplot, width = 8, height = 4)
  if (isdebug) cat("Overview: Boxplot has been produced\n")
}

# Principal Component Analysis
run_pca <- function(X, population_names, popname1, popname2, isdebug) {
  Xpca         <- prcomp(t(X))
  raw_pca      <- get_pca_raw_data(Xpca)
  pc_plot_data <- get_pc_plotdata(Xpca, population_names, popname1, popname2,
                                  isdebug)
  pca_json     <- list(pc = raw_pca, pcdata = pc_plot_data)
  return(pca_json)
}

get_pca_raw_data <- function(Xpca) {
  s              <- summary(Xpca)
  exp_var        <- s$importance[2, ] * 100 # percentages Explained Variance
  cum_var        <- s$importance[3, ] * 100 # percentage Cumulative Variance
  pcnames        <- names(exp_var)          # PC names
  names(exp_var) <- NULL
  names(cum_var) <- NULL
  pca            <- list(pcnames = pcnames, expVar = exp_var, cumVar = cum_var)
  return (pca)
}

get_pc_plotdata <- function(Xpca, populations, popname1, popname2, isdebug) {
  Xscores           <- Xpca$x
  sample_names      <- rownames(Xscores)
  rownames(Xscores) <- NULL
  cols              <- colnames(Xscores)
  # Take each column of Xscore (temp variable y) & split based on the population
  Xscores           <- lapply(1:nrow(Xscores), function(y) {
    split(Xscores[, y], populations)
  })
  names(Xscores)    <- cols
  pc                <- unlist(Xscores, recursive = FALSE)
  # Split sample names by population and add to the final list
  complete.data  <- c(split(sample_names, populations), pc)
  # add the pop_names to the json list
  pop_names      <- list(group1 = popname1, group2 = popname2)
  complete.data  <- append(complete.data, pop_names)
  if (isdebug) cat("Overview: PCA has been calculated\n")
  return(complete.data)
}

#############################################################################
#                        Command Line Arguments                             #
#############################################################################
parser <- arg_parser("This parser contains the input arguments")
parser <- add_argument(parser, "--rundir", default = ".",
                       help = "The outout directory where graphs get saved")
parser <- add_argument(parser, "--dbrdata", default = "GDS5093.RData",
                       help = "Full path GEO dataset ")
parser <- add_argument(parser, "--analyse", nargs = "+",
                       default = "Boxplot,PCA",
                       help = "List of analysis to be performed")
parser <- add_argument(parser, "--dev", flag = TRUE, short = "-d",
                       default = FALSE, help = "verbose version")
# Sample Parameters
parser <- add_argument(parser, "--factor", help = "Factor type to classify by")
parser <- add_argument(parser, "--pop_a", nargs = "+",
                       help = "Group A selected phenotypes (required)")
parser <- add_argument(parser, "--pop_b", nargs = "+",
                       help = "Group B selected phenotypes (required)")
parser <- add_argument(parser, "--popname1", default = "Group A",
                       help = "name for Group A")
parser <- add_argument(parser, "--popname2", default = "Group B",
                       help = "name for Group B")
parser <- add_argument(parser, "--pop_a_col", default = "#e199ff",
                      help = "colour to use for Group A (Default: Purple")
parser <- add_argument(parser, "--pop_b_col", default = "#96ca00",
                      help = "colour to use for Group B (Default: Green")
argv   <- parse_args(parser)

options(bitmapType = "cairo") # Force R to use Cairo to create images
argv$analyse <- split_arg(argv$analyse)
argv$pop_a   <- split_arg(argv$pop_a)
argv$pop_b   <- split_arg(argv$pop_b)

#############################################################################
#                        Load GEO Dataset to Start Analysis                 #
#############################################################################

if (file.exists(argv$dbrdata)) {
  if (argv$dev) cat("Overview: Loading Database data.\n")
  load(file = argv$dbrdata)
} else {
  cat("ERROR: Data input error. Provide valid GDS dataset!\n", file = stderr())
  quit(save = "no", status = 8, runLast = FALSE)
}

assert_run_dir_present(argv$rundir)

#############################################################################
#                        Two Population Preparation                         #
#############################################################################
# Phenotype selection
pclass           <- pData[argv$factor]
colnames(pclass) <- "factor_type"
samples          <- rownames(pclass)
# Create a data frame with the factors
expression_info  <- data.frame(pclass, Sample = samples, row.names = samples)

# add population_colour column to expression_info - colour for each groups
expression_info <- within(expression_info, {
  population <- ifelse(factor_type %in% argv$pop_a, argv$popname1,
                       ifelse(factor_type %in% argv$pop_b, argv$popname2, NA))
})
expression_info$population <- as.factor(expression_info$population)

# Remove samples that are not belongs to two populations
expression_info <- expression_info[complete.cases(expression_info), ]
X               <- X[, (colnames(X) %in% rownames(expression_info))]

# Data preparation for ggplot-Boxplot (Var2 is generated by melt(X))
data <- within(melt(X), {
  phenotypes <- expression_info[Var2, "factor_type"]
  Groups     <- expression_info[Var2, "population"]
})

if (argv$dev) cat("Overview: Factors and Populations have been set\n")

#############################################################################
#                        Function Calling                                 #
#############################################################################

if ("Boxplot" %in% argv$analyse) {
  tryCatch({
    generate_boxplot(data, c(argv$pop_b_col, argv$pop_a_col),
                     c(argv$popname1, argv$popname2), argv$rundir, argv$dev)
  },
  error = function(e) {
    cat("ERROR: Unable to generate boxplot\n", file = stderr())
    cat(e, file = stderr())
    quit(save = "no", status = 9, runLast = FALSE)
  })
}
if ("PCA" %in% argv$analyse) {
  tryCatch({
    pca_json <- run_pca(X, expression_info[, "population"], argv$popname1,
                        argv$popname2, argv$dev)
  },
  error = function(e) {
    cat("ERROR: Unable to generate run PCA analysis\n", file = stderr())
    cat(e, file = stderr())
    quit(save = "no", status = 10, runLast = FALSE)
  })
}

if (length(pca_json) != 0) {
  # Write to a json file with 4 decimal places
  filename <- file.path(argv$rundir, "pca_data.json")
  write(toJSON(pca_json, digits = I(4)), filename)
}
