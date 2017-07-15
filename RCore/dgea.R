#!/usr/bin/Rsript
# ---------------------------------------------------------#
# Filename      : DGEA.R                                   #
# Authors       : IsmailM, Nazrath, Suresh, Marian, Anisa  #
# Description   : Differential Gene Expression Analysis    #
# Rscript dgea.R --dbrdata ~/Desktop/GDS5093.rData --rundir ~/Desktop/ --factor "disease.state" --pop_a "Dengue Hemorrhagic Fever,Convalescent,Dengue Fever" --pop_b "healthy control" --popname1 "Dengue" --popname2 "Normal" --analyse "Volcano,PCA,Heatmap" --topgenecount 250 --foldchange 0.0 --thresholdvalue 0.005 --distance "euclidean" --clustering "average" --clusterby "Complete" --heatmaprows 100 --dendrow --dendcol --adjmethod fdr --dev
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
suppressMessages(library("limma"))         # differential analysis
suppressMessages(library("pheatmap"))      # Heatmap Generating
suppressMessages(library("plyr"))          # Splitting/Applying/Combining Data
suppressMessages(library("RColorBrewer"))  # Import Colour Pallete
suppressMessages(library("reshape2"))      # Prepare dataset for ggplot
suppressMessages(library("squash"))        # Clustering Dendogram

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

##
# Calculate Outliers Probabilities/ Dissimilarities
outlier.probability <- function(X, dist.method = "euclidean",
                                clust.method = "average", isdev) {
  # Rank outliers using distance and clustering parameters
  o <- outliers.ranking(t(X), test.data = NULL, method.pars = NULL,
                        method = "sizeDiff", # Outlier finding method
                        clus = list(dist = dist.method, alg = "hclust",
                                    meth = clust.method))
  if (isdev) cat("DGEA: Outliers have been identified\n")
  return(o$prob.outliers)
}

##
# Bonferroni cut-off would be used as the default thresold value (not
# implemented) - fold.change and threshold value would have been used to find
# significant gene.
# function(... , fold.change, threshold.value = 0.05 / length(gene.names), ...)
# Currently, all points in the top table are highlighted...
# (these will have had the bonferroni (or chosen) adjustment applied onto them)
volcanoplot <- function(toptable, dir, topgene.count, isdev) {
  # Select only genes which are in toptable
  toptable$Significant <- c(rep(TRUE, topgene.count),
                            rep(FALSE, length(toptable$ID) - topgene.count))

  # Construct the plot object
  vol <- ggplot(data = toptable, aes(x = toptable$logFC,
                                     y = -log10(toptable$P.Value),
                                     colour = Significant))
  vol <- vol + geom_point(alpha = 0.4, size = 1.75)
  vol <- vol + xlim(c(-max(toptable$logFC) - 0.1, max(toptable$logFC) + 0.1))
  vol <- vol + ylim(c(0, max(-log10(toptable$P.Value)) + 0.5))
  vol <- vol + xlab("log2 fold change") + ylab("-log10 p-value")

  ggsave(file.path(dir, "dgea_volcano.png"), plot = vol, height = 6, width = 6)

  if (isdev) cat(paste("DGEA: Volcanoplot has been produced.\n"))
}

#
get.volcanodata <- function(toptable) {
  vol.list <- list(genes = toptable$ID, logFC = round(toptable$logFC, 3),
                   pVal  = -log10(toptable$P.Value))
  return(vol.list)
}

find.toptable <- function(X, newpclass, toptable.sortby, topgene.count,
                          adj.method, popname1, popname2, isdev) {
  design  <- model.matrix(~0 + newpclass)  # creates a design (or model) matrix
  # plots linear model for each gene and estimate fold changes + standard errors
  fit     <- lmFit(X, design)

  # set contrasts for two groups
  name <- paste("newpclass", popname1, "-", "newpclass", popname2, sep = "")
  contrasts <- makeContrasts(contrasts = name, levels = design)
  fit <- contrasts.fit(fit, contrasts)
  fit <- eBayes(fit, proportion = 0.01) # empirical bayes smoothing to std errs
  toptable <- topTable(fit, adjust.method = adj.method,
                       sort.by = toptable.sortby, number = topgene.count)
  if (isdev) {
    cat(paste("DGEA: TopTable has been produced", "for", topgene.count,
           "genes with the cut-off method:", adj.method, "\n"))
  }
  return(toptable)
}

# Heatmap
heatmap <- function(X.matrix, X, exp, heatmap.rows = 100, dendogram.row,
                    dendogram.col, dist.method, clust.method, path, cluster.by,
                    factor.type, popname1, isdev) {
  col.pal <- colorRampPalette(rev(RColorBrewer::brewer.pal(11, "RdYlGn")))(100)

  # Annotation column for samples
  ann.col <- data.frame(Population = exp[, "population"])

   # If there are only few factor levels, then only show colour annotations
  if (length(levels(exp[, "factor.type"])) < 10) {
    ann.col$Factor    <- exp[, "factor.type"]
    colnames(ann.col) <- c("Population", factor.type)
  }

  # Clustering based on complete dataset or only toptable data
  if (cluster.by == "Complete") {
    exp.data <- X
  } else {
    exp.data <- X.matrix
  }

  # Column dendogram
  if (dendogram.col != TRUE) {
    hc <- FALSE
    # Keep a gap between two groups
    column.gap <- length( (which(ann.col[, "Population"] == popname1) == T) )
  } else {
    # calculate heirachical clustering
    hc <- hclust(dist(t(exp.data), method = dist.method), method = clust.method)
    # Find outlier ranking/ probability
    outliers <- outlier.probability(exp.data, dist.method, clust.method, isdev)
    # Add dissimilarity annotation to the samples annotation
    ann.col$Dissimilarity <- outliers
    column.gap <- 0
  }
  rownames(ann.col) <- exp[, "Sample"]
  # Limit no of heatmap rows
  if (nrow(X.matrix) < heatmap.rows) {
    hdata <- X.matrix
  } else {
    hdata <- X.matrix[1:heatmap.rows, ]
  }

  CairoSVG(file = file.path(path, "dgea_heatmap.svg"))

  pheatmap(hdata, cluster_row = dendogram.row, cluster_cols = hc,
           annotation_col = ann.col, legend = TRUE, color = col.pal,
           fontsize = 6.5, fontsize_row = 3.0, fontsize_col = 3.5,
           gaps_col = column.gap)
  dev.off()

  if (isdev) {
    cat(paste("DGEA: Heatmap has been created\n"))
    if (dendogram.row == TRUE) cat("DGEA: with a dendogram for rows\n")
    if (dendogram.col == TRUE) cat("DGEA: and a dendogram for columns\n")
  }
}


#############################################################################
#                        Command Line Arguments                             #
#############################################################################
parser <- arg_parser("This parser contains the input arguments")
parser <- add_argument(parser, "--rundir", default = ".",
                       help = "The outout directory where graphs get saved")
parser <- add_argument(parser, "--dbrdata", default = "GDS5093.RData",
                       help = "Downloaded GEO dataset full path")
parser <- add_argument(parser, "--analyse", nargs = "+",
                       default = "Toptable,Heatmap,Volcano",
                       help = "List of analysis to be performed")
parser <- add_argument(parser, "--dev", flag = TRUE, short = "-d",
                       default = FALSE, help = "verbose version")
# Sample Parameters
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
# Toptable
parser <- add_argument(parser, "--topgenecount", default = "250",
                       help = "Number of top genes to be used")
parser <- add_argument(parser, "--adjmethod", default = "fdr",
                       help = "Adjust P-values for Multiple Comparisons")
# Heatmap
parser <- add_argument(parser, "--heatmaprows", default = "100",
                       help = "Number of genes show in the heatmap")
parser <- add_argument(parser, "--dendrow", flag = TRUE, default = FALSE,
                       help = "Flag to display dendogram for Genes")
parser <- add_argument(parser, "--dendcol", flag = TRUE, default = FALSE,
                       help = "Flag to display dendogram for Samples")
parser <- add_argument(parser, "--clusterby", default = "Complete",
                       help = "Cluster by complete dataset or toptable")
# Clustering
parser <- add_argument(parser, "--distance", default = "euclidean",
                       help = "Distance measurement methods")
parser <- add_argument(parser, "--clustering", default = "Complete",
                       help = "HCA clustering methods")
argv   <- parse_args(parser)

options(bitmapType = "cairo") # Force R to use Cairo to create images
argv$analyse        <- split_arg(argv$analyse)
argv$pop_a          <- split_arg(argv$pop_a)
argv$pop_b          <- split_arg(argv$pop_b)
argv$topgenecount   <- as.numeric(argv$topgenecount)
argv$heatmaprows    <- as.numeric(argv$heatmaprows)
argv$dendrow        <- as.logical(argv$dendrow)
argv$dendcol        <- as.logical(argv$dendcol)

adjmethods      <- c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY",
                     "fdr", "none")
argv$adjmethod  <- ifelse(argv$adjmethod %in% adjmethods, argv$adjmethod, "fdr")

dist            <- c("euclidean", "maximum", "manhattan", "canberra", "binary",
                     "minkowski")
argv$distance   <- ifelse(argv$distance %in% dist, argv$distance, "euclidean")

clust_opt       <- c("ward.D", "ward.D2", "single", "complete", "average",
                     "mcquitty", "median", "centroid")
argv$clustering <- ifelse(argv$clustering %in% clust_opt, argv$clustering,
                          "average")

#############################################################################
#                        Load GEO Dataset to Start Analysis                 #
#############################################################################

if (file.exists(argv$dbrdata)) {
  if (argv$dev) cat("DGEA: Loading Database data.\n")
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

if (argv$dev) cat("DGEA: Factors and Populations have been set\n")

#############################################################################
#                        Function Calling                                   #
#############################################################################
json.list <- list()

# Created a new Phenotype class
newpclass        <- expression_info$population
names(newpclass) <- expression_info$Sample
toptable.sortby <- "p"

# Toptable
toptable <- find.toptable(X, newpclass, toptable.sortby, argv$topgenecount,
                          argv$adjmethod, argv$popname1, argv$popname2,
                          argv$dev)

# Adding to JSON file
temp.toptable <- toptable
names(temp.toptable) <- NULL
json.list <- append(json.list, list(tops = temp.toptable))

# Filter toptable data from X
X.toptable <- X[as.numeric(rownames(toptable)), ]

# save toptable expression data
filename <- file.path(argv$rundir, "dgea_toptable.RData")
popname1 <- argv$popname1
popname2 <- argv$popname2
save(X.toptable, expression_info, popname1, popname2, file = filename)

# save tab delimited
filename <- file.path(argv$rundir, "dgea_toptable.tsv")
write.table(toptable, filename, col.names = NA, sep = "\t" )

if (argv$dev) cat(paste("DGEA: Analysis to be performed:", argv$analyse, "\n"))

if ("Volcano" %in% argv$analyse) {
  # Get data for volcanoplot
  toptable.all <- find.toptable(X, newpclass, toptable.sortby,
                                length(gene.names), argv$adjmethod,
                                argv$popname1, argv$popname2, argv$dev)
  # Draw volcano plit
  volcanoplot(toptable.all, argv$rundir, argv$topgenecount, argv$dev)

  # save volcanoplot top data as JSON
  volcanoplot.data <- get.volcanodata(toptable)
  json.list        <- append(json.list, list(vol = volcanoplot.data))
}

if ("Heatmap" %in% argv$analyse) {
  heatmap(X.toptable, X, expression_info, argv$heatmaprows,
          argv$dendrow, argv$dendcol, argv$distance, argv$clustering,
          argv$rundir, argv$clusterby, argv$factor, argv$popname1, argv$dev)
}

if (length(json.list) != 0) {
  filename <- file.path(argv$rundir, "dgea_data.json")
  write(toJSON(json.list, digits = I(4)), filename) # 4 decimal places
}
