suppressMessages(library("argparser"))
suppressMessages(library("GEOquery"))
suppressMessages(library("impute"))

# auto-detect if data is log transformed
scalable <- function(X) {
  #  produce sample quantiles corresponding to the given probabilities
  qx <- as.numeric(quantile(X, c(0.0, 0.25, 0.5, 0.75, 0.99, 1.0), na.rm = T))
  logc <- (qx[5] > 100) ||
      (qx[6] - qx[1] > 50 && qx[2] > 0) ||
      (qx[2] > 0 && qx[2] < 1 && qx[4] > 1 && qx[4] < 2)
  return (logc)
}

geodbpath <- '/Users/ismailm/.geodiver/DBs/GSE3541/GSE3541_series_matrix.txt.gz'

gset <- getGEO(filename = geodbpath, GSEMatrix = TRUE, AnnotGPL=TRUE)
gset <- getGEO('GSE3541', GSEMatrix = TRUE, AnnotGPL=TRUE)

eset        <- gset
gpl         <- getGEO(annotation(gset))
featureData <- gpl@dataTable@table
gene.names  <- featureData[, "Gene Symbol"]
organism    <- as.character(featureData[, "Species Scientific Name"][1])

X           <- exprs(gset) # Get Expression Data
rownames(X) <- gene.names








pData       <- pData(gset)
# KNN imputation
if (ncol(X) == 2) {
  X <- X[complete.cases(X), ] # KNN does not work when there are only 2 samples
} else {
  X <- X[rowSums(is.na(X)) != ncol(X), ] # remove rows with missing data
}

# Replace missing value with calculated KNN value
tryCatch({
  imputation <- impute.knn(X)
  X          <- imputation$data
}, error=function(e) {
  cat("ERROR: Bad dataset: Unable to run KNN imputation on the dataset.", file=stderr())
  quit(save = "no", status = 1, runLast = FALSE)
})

# If not log transformed, do the log2 transformed
if (scalable(X)) {
  X[which(X <= 0)] <- NaN # not possible to log transform negative numbers
  X <- log2(X)
}


### Overview Script

# Running CMD: Rscript /Volumes/Data/project/geodiver/geodiver/RCore/overview.R --dbrdata /Users/ismailm/.geodiver/DBs/GSE3541/GSE3541.RData --rundir '/Users/ismailm/.geodiver/Users/geodiver/GSE3541/2016-11-20_14-34-08_494-494322000/' --analyse 'Boxplot,PCA' --factor "Cells" --popA "Type II epithelial cells" --popB "Type II epithelial " --popname1 'Group1' --popname2 'Group2' --dev
#############################################################################
#                        Two Population Preparation                         #
#############################################################################
# Phenotype selection
# Factor.type = characteristics_ch1.4
str(pData)

pclass           <- pData['characteristics_ch1.4']
colnames(pclass) <- "factor.type"

# Create a data frame with the factors
expression.info  <- data.frame(pclass, Sample = rownames(pclass),
                               row.names = rownames(pclass))

# Introduce two columns to expression.info :
#   1. population - new two groups, if not NA
#   2. population.colour - colour for two new two groups, if not black colour
expression.info <- within(expression.info, {
  population        <- ifelse(factor.type %in% population1, "Group1",
                         ifelse(factor.type %in% population2, "Group2", NA))
  population.colour <- ifelse(factor.type %in% population1, pop.colour1,
                        ifelse(factor.type %in% population2, pop.colour2,
                        "#000000"))
})

# Convert population column to a factor
expression.info$population <- as.factor(expression.info$population)

# Remove samples that are not belongs to two populations
expression.info <- expression.info[complete.cases(expression.info), ]
X <- X[, (colnames(X) %in% rownames(expression.info))]

# Data preparation for ggplot-Boxplot
data <- within(melt(X), {
  phenotypes <- expression.info[Var2, "factor.type"]
  Groups     <- expression.info[Var2, "population.colour"]
})

if (isdebug) print("Overview: Factors and Populations have been set")
