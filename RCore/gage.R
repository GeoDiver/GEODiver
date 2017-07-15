#!/usr/bin/Rsript
# ---------------------------------------------------------#
# Filename      : GAGE.R                                   #
# Authors       : IsmailM, Nazrath, Suresh, Marian, Anisa  #
# Description   : Gene Set Enrichment Analysis             #
# Rscript gage.R --accession GDS5093 --dbrdata ~/Desktop/GDS5093.RData --rundir ~/Desktop/ --factor "disease.state" --pop_a "Dengue Hemorrhagic Fever,Convalescent,Dengue Fever" --pop_b "healthy control"  --comparisontype ExpVsCtrl --genesettype KEGG --distance "euclidean" --clustering "average" --clusterby "Complete" --heatmaprows 100 --dendrow TRUE --dendcol TRUE --dev TRUE
# ---------------------------------------------------------#

#############################################################################
#                        Import Libraries                                   #
#############################################################################

# load required libraries and silence library loading messages on command line
suppressMessages(library("argparser"))     # Argument passing
suppressMessages(library("Cairo"))         # Plots saving
suppressMessages(library("DMwR"))          # Outlier Prediction for clustering
suppressMessages(library("gage"))          # Does the analysis
suppressMessages(library("gageData"))      # Lets data be used by gage
suppressMessages(library("GEOquery"))      # GEO dataset Retrieval
suppressMessages(library("GO.db"))         # Loads GO database
suppressMessages(library("jsonlite"))      # Convert R object to JSON format
suppressMessages(library("pathview"))      # Interaction networks & ENTREZ IDs
suppressMessages(library("pheatmap"))      # Used to create heatmap
suppressMessages(library("RColorBrewer"))  # Color palette for heatmap
suppressMessages(library("org.Mm.eg.db"))  # Species database

#############################################################################
#                          Load Functions                                   #
#############################################################################
##
# a function to split arguments
split_arg <- function(vector_arg) {
  pos  <- unlist(gregexpr("[^\\\\],", vector_arg, perl = TRUE))
  vect <- substring(vector_arg, c(1, pos + 2), c(pos, nchar(vector_arg)))
  vect <- gsub("\\\\,", ",", vect) # replace \\, with ,
  vect <- gsub("\\\"", '"', vect) # replace \" with "
  vect <- gsub('\\\\-', "-", vect) # replace \\- with -
  return (vect)
}

##
# Check if the run directory exists and if not, create directory...
assert_run_dir_present <- function(run_dir) {
  if (!dir.exists(file.path(run_dir))) {
    dir.create(file.path(run_dir))
  }
}

generate_toptable <- function(gage_analysis, run_dir) {
  # Returns number of two-direction significantly enriched gene sets
  analysis_sig     <- as.data.frame(sigGeneSet(gage_analysis))
  analysis_results <- gage_analysis$greater
  # Remove gene sets without zero enrichments
  analysis_results <- analysis_results[complete.cases(analysis_results), ]

  # Extract Pathway ID and Names
  m <- regmatches(rownames(analysis_results),
                  regexpr(" ", rownames(analysis_results)), invert = TRUE)
  # take each path, split into two and unlist them
  pathway.id   <- unlist(lapply(1:length(m), function(n) split(m[[n]][1], " ")))
  pathway.name <- unlist(lapply(1:length(m), function(n) split(m[[n]][2], " ")))

  # Create top table
  toptable <- data.frame(pathway.id, pathway.name, analysis_results[, 1:5])
  toptable <- toptable[order(toptable$p.val), ]
  rownames(toptable) <- NULL
  colnames(toptable) <- NULL

  # save "Toptable"
  filename <- file.path(run_dir, "gage_data.json")
  write(toJSON(list(tops = toptable), digits = I(4)), filename)

  # save toptable to a tab delimited file
  colnames(toptable) <- c("PathwayID", "Pathway", "PGeomean", "StatMean",
                          "PValue", "QValue", "SetSize")
  filename <- file.path(run_dir, "gage_toptable.tsv")
  write.table(toptable, filename, col.names = NA, sep = "\t" )
  return (analysis_sig)
}

# Calculate Outliers Probabilities/ Dissimilarities
# Used from within `generate_heatmap()`
outlier_probability <- function(X, dist.method = "euclidean",
                                clust.method = "average", isdev) {
  # Rank outliers using distance and clustering parameters
  o <- outliers.ranking(t(X), test.data = NULL, method.pars = NULL,
                        method = "sizeDiff", # Outlier finding method
                        clus = list(dist = dist.method, alg = "hclust",
                                    meth = clust.method))
  if (isdev) cat("GAGE: Outliers have been identified\n")
  return(o$prob.outliers)
}

# Used from within generate_heatmap()`
reformat_analysis_stats <- function(analysis_sig) {
  analysis_stats <- analysis_sig[, grep("^stats.GSM", names(analysis_sig),
                                        value = TRUE)]
  # Split each pathway names into pathway ID and pathway name
  m <- regmatches(rownames(analysis_sig),
                  regexpr(" ", rownames(analysis_sig)), invert = TRUE)
  # take each path, split into two
  pathway.id <- unlist(lapply(1:length(m), function(n) split(m[[n]][1], " ")))
  rownames(analysis_stats) <- pathway.id
  colnames(analysis_stats) <- gsub("(stats.)", "", colnames(analysis_stats))
  return (analysis_stats)
}

generate_heatmap <- function(X, analysis_sig, analysis_type, expression_info,
                             heatmap_rows, Group1, popname1, factor_type,
                             run_dir, dendcol, dendrow, dist_method,
                             clust_method, isdev) {
  if (analysis_type == "ExpVsCtrl") {
   # Remove control group (Group 2)
    X_mat    <- X[, Group1]
    exp_info <- expression_info[expression_info[, "population"] == popname1, ]
  } else {
    X_mat    <- X
    exp_info <- expression_info
  }

  # Column dendogram
  if (dendcol == TRUE) {
    # calculate heirachical clustering
    hc <- hclust(dist(t(X_mat), method = dist_method), method = clust_method)
    # Find outlier ranking/ probability
    outliers <- outlier_probability(X_mat, dist_method, clust_method, isdev)
    # Annotation columns
    ann_col <- data.frame(Population = exp_info[, "population"],
                          Factor = exp_info[, "factor.type"],
                          Dissimilarity = outliers)
    colnames(ann_col) <- c("Population", factor_type, "Dissimilarity")
  } else {
    hc <- FALSE
    # Annotation columns
    ann_col <- data.frame(Population = exp_info[, "population"],
                          Factor = exp_info[, "factor.type"])
    colnames(ann_col) <- c("Population", factor_type)
  }

  analysis_stats <- reformat_analysis_stats(analysis_sig)
  if (nrow(analysis_stats) < heatmap_rows) {
    hdata <- analysis_stats                    # Show all
  } else {
    hdata <- analysis_stats[1:heatmap_rows, ]  # Limit to user specified limit
  }

  col_pal <- colorRampPalette(rev(RColorBrewer::brewer.pal(11, "RdYlGn")))(100)

  CairoSVG(file = file.path(run_dir, "gage_heatmap.svg"))
  pheatmap(hdata, cluster_row = dendrow, cluster_cols = hc,
           annotation_col = ann_col, color = col_pal, fontsize = 6.5,
           fontsize_row = 3.0, fontsize_col = 3.5)
  dev.off()

  if (isdev) cat(paste("GAGE: Saved heatmap\n"))
}

#############################################################################
#                        Command Line Arguments                             #
#############################################################################
parser <- arg_parser("Generally Applicable Gene-set Analysis parameters:")
parser <- add_argument(parser, "--rundir", default = ".",
                       help = "The outout directory where graphs get saved")
parser <- add_argument(parser, "--dbrdata", default = "GDS5093.RData",
                       help = "Downloaded GEO dataset full path")
parser <- add_argument(parser, "--dev", flag = TRUE, short = "-d",
                       default = FALSE, help = "verbose version")

parser <- add_argument(parser, "--factor", default = "infection",
                       help = "Factor type to be classified by")
parser <- add_argument(parser, "--pop_a", nargs = "+", default = "Dengue virus",
                       help = "Selected Group A phenotypes (at least one)")
parser <- add_argument(parser, "--pop_b", nargs = "+", default = "control",
                       help = "Selected Group B phenotypes (at least one)")
parser <- add_argument(parser, "--popname1", default = "GroupA",
                       help = "name for Group A")
parser <- add_argument(parser, "--popname2", default = "GroupB",
                       help = "name for Group B")
# Gage Parameters
parser <- add_argument(parser, "--comparisontype", default = "ExpVsCtrl",
                       help = "ExpVsCtrl or ExpVsExp")
parser <- add_argument(parser, "--genesettype", default = "KEGG",
                       help = "KEGG (KEGG DB) or BP (GO Biological Process) or
                       MF (GO molecular function) or CC (Cellular Component)")
# Heatmap
parser <- add_argument(parser, "--heatmaprows", default = "100",
                       help = "Number of genes show in the heatmap")
parser <- add_argument(parser, "--dendrow", flag = TRUE, default = FALSE,
                       help = "Flag to display dendogram for Genes")
parser <- add_argument(parser, "--dendcol", flag = TRUE, default = FALSE,
                       help = "Flag to display dendogram for Samples")
parser <- add_argument(parser, "--clusterby", default = "Complete",
                       help = "Cluster based complete dataset or toptable")
# Clustering
parser <- add_argument(parser, "--distance", default = "euclidean",
                       help = "Distance measurement methods")
parser <- add_argument(parser, "--clustering", default = "average",
                       help = "HCA clustering methods")
argv <- parse_args(parser)

options(bitmapType = "cairo") # Force R to use Cairo to create images
argv$pop_a       <- split_arg(argv$pop_a)
argv$pop_b       <- split_arg(argv$pop_b)
argv$factor      <- as.character(argv$factor)
argv$heatmaprows <- as.numeric(argv$heatmaprows)
argv$dendrow     <- as.logical(argv$dendrow)
argv$dendcol     <- as.logical(argv$dendcol)
dist.opt         <- c("euclidean", "maximum", "manhattan", "canberra", "binary",
                   "minkowski")
argv$distance <- ifelse(argv$distance %in% dist.opt, argv$distance, "euclidean")
clust.opt        <- c("ward.D", "ward.D2", "single", "complete", "average",
                      "mcquitty", "median", "centroid")
argv$clustering  <- ifelse(argv$clustering %in% clust.opt, argv$clustering,
                          "complete")

#############################################################################
#                        Load GEO Dataset to Start Analysis                 #
#############################################################################

if (file.exists(argv$dbrdata)) {
  if (argv$dev) cat("GAGE: Loading Database data.\n")
  load(file = argv$dbrdata)
} else {
  cat("ERROR: Data input error. Provide valid GDS dataset!\n", file = stderr())
  quit(save = "no", status = 200, runLast = FALSE)
}

assert_run_dir_present(argv$rundir)

#############################################################################
#                        Two Population Preparation                         #
#############################################################################
# Phenotype Selection
pclass           <- pData[argv$factor]
colnames(pclass) <- "factor.type"

# Create a data frame with the factors
expression_info  <- data.frame(pclass, Sample = rownames(pclass),
                               row.names = rownames(pclass))
# Introduce: a column for the two groups/populations, NA for unselected samples
expression_info <- within(expression_info, {
  population <- ifelse(factor.type %in% argv$pop_a, argv$popname1,
                       ifelse(factor.type %in% argv$pop_b, argv$popname2, NA))
})
expression_info$population <- as.factor(expression_info$population)
# Remove samples that are not belongs to two populations
expression_info <- expression_info[complete.cases(expression_info), ]
X <- X[, (colnames(X) %in% rownames(expression_info))]

#############################################################################
#                            Data Preparation                               #
#############################################################################
# Get sample indexes and sample names
Group1      <-  which(expression_info[, "population"] == argv$popname1)
Group2      <-  which(expression_info[, "population"] == argv$popname2)
Group1names <- expression_info[Group1, "Sample"]
Group2names <- expression_info[Group2, "Sample"]

rownames(X) <- entrez.gene.id

# Loading data on kegg packages and species
if (argv$genesettype == "KEGG") {
  data(kegg.gs)
  kg.org <- kegg.gsets(organism) # picks out orgamism gene sets
  dbdata <- kg.org$kg.sets[kg.org$sigmet.idx]
} else {
  # GO Datasets
  go.hs <- go.gsets(species = organism.common.name) # use species column of bods
  if (argv$genesettype == "BP") {
    dbdata <- go.hs$go.sets[go.hs$go.subs$BP]
  } else if (argv$genesettype == "MF") {
    dbdata <- go.hs$go.sets[go.hs$go.subs$MF]
  } else if (argv$genesettype == "CC") {
    dbdata <- go.hs$go.sets[go.hs$go.subs$CC]
  }
}

if (argv$dev) cat("GAGE: Data Preparation completed\n")
#############################################################################
#                        Function Calling                                   #
#############################################################################
if (argv$dev) cat("GAGE: GAGE analysis starting...")
compare.option <- ifelse(argv$comparisontype == "ExpVsCtrl", "unpaired",
                         "paired")
if (argv$comparisontype != "ExpVsCtrl") {
  Group1 <- NULL
  Group2 <- NULL
}

gage_analysis <- gage(X, gsets = dbdata, ref = Group2, samp = Group1,
                 same.dir = FALSE, compare = compare.option)

if (nrow(gage_analysis$greater) < 0) {
  cat("ERROR: No Significant Results Found!\n", file = stderr())
  quit(save = "no", status = 1, runLast = FALSE)
}

analysis_sig <- generate_toptable(gage_analysis, argv$rundir)

generate_heatmap(X, analysis_sig, argv$comparisontype, expression_info,
                 argv$heatmaprows, Group1, argv$popname1, argv$factor,
                 argv$rundir, argv$dendcol, argv$dendrow, argv$distance,
                 argv$clustering, argv$dev)

filename <- file.path(argv$rundir, "gage.RData")
comparisontype <- argv$comparisontype
genesettype <- argv$genesettype
save(comparisontype, X, gage_analysis, genesettype, Group1, Group1names,
     Group2, Group2names, organism.scientific.name, file = filename)
