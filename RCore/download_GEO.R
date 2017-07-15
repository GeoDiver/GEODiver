#!/usr/bin/Rsript
# ---------------------------------------------------------
# Filename      : DGEA.R
# Authors       : IsmailM, Nazrath, Suresh, Marian, Anissa
# Description   : Differential Gene Expression Analysis
# Run           : Rscript download_GEO.R --accession GDS5093 --outrdata ~/Desktop/GDS5093.RData
# ---------------------------------------------------------

#############################################################################
#                        Gene Expression  Analysis                          #
#############################################################################

suppressMessages(library("argparser"))
suppressMessages(library("GEOquery"))
suppressMessages(library("impute"))
suppressMessages(library("pathview")) # for the id2eg function
# Species database
suppressMessages(library("org.Ag.eg.db")) # "Anopheles" "aga" "eg"
suppressMessages(library("org.At.tair.db")) # "Arabidopsis" "ath" "tair"
suppressMessages(library("org.Bt.eg.db")) # "Bovine" "bta" "eg"
suppressMessages(library("org.Ce.eg.db")) # "Worm" "cel" "eg"
suppressMessages(library("org.Cf.eg.db")) # "Canine" "cfa" "eg"
suppressMessages(library("org.Dm.eg.db")) # "Fly" "dme" "eg"
suppressMessages(library("org.Dr.eg.db")) # "Zebrafish" "dre" "eg"
suppressMessages(library("org.EcK12.eg.db")) # "E coli strain K12" "eco" "eg"
suppressMessages(library("org.EcSakai.eg.db")) # "E coli strain Sakai" "ecs" "eg"
suppressMessages(library("org.Gg.eg.db")) # "Chicken" "gga" "eg"
suppressMessages(library("org.Hs.eg.db")) # "Human" "hsa" "eg"
suppressMessages(library("org.Mm.eg.db")) # "Mouse" "mmu" "eg"
suppressMessages(library("org.Mmu.eg.db")) # "Rhesus" "mcc" "eg"
suppressMessages(library("org.Pf.plasmo.db")) # "Malaria" "pfa" "orf"
suppressMessages(library("org.Pt.eg.db")) # "Chimp" "ptr" "eg"
suppressMessages(library("org.Rn.eg.db")) # "Rat" "rno" "eg"
suppressMessages(library("org.Sc.sgd.db")) # "Yeast" "sce" "orf"
suppressMessages(library("org.Ss.eg.db")) # "Pig" "ssc" "eg"
suppressMessages(library("org.Xl.eg.db")) # "Xenopus" "xla" "eg"
data(korg)
data(bods)

#############################################################################
#                        Command Line Arguments                             #
#############################################################################

parser <- arg_parser("Input GEO Dataset")
parser <- add_argument(parser, "--accession", default = "GSE55252",
                       help = "Accession Number of the GEO Database")
parser <- add_argument(parser, "--outrdata", default = "GSE55252.RData",
                       help = "Full path to the output rData file")
parser <- add_argument(parser, "--geodbDir", default = ".",
                       help = "Full path to the database directory")
argv   <- parse_args(parser)

#############################################################################
#                          Load Functions                                   #
#############################################################################

# auto-detect if data is log transformed
scalable <- function(X) {
  #  produce sample quantiles corresponding to the given probabilities
  qx <- as.numeric(quantile(X, c(0.0, 0.25, 0.5, 0.75, 0.99, 1.0), na.rm = T))
  logc <- (qx[5] > 100) ||
      (qx[6] - qx[1] > 50 && qx[2] > 0) ||
      (qx[2] > 0 && qx[2] < 1 && qx[4] > 1 && qx[4] < 2)
  return (logc)
}

#############################################################################
#                        GEO Input                                          #
#############################################################################
tryCatch({
  gset <- getGEO(argv$accession, GSEMatrix = TRUE, destdir=argv$geodbDir)
}, error = function(error) {
  # Try downloading again from scratch...
  tryCatch({
    gset <- getGEO(argv$accession, GSEMatrix = TRUE )
  }, error=function(e) {
    cat("ERROR: Unable to generate gset", file=stderr())
    cat(e, file=stderr())
    quit(save = "no", status = 2, runLast = FALSE)
  })
})

if (grepl('^GDS', argv$accession)) {
  eset           <- GDS2eSet(gset, do.log2 = FALSE)
  gene.names     <- as.character(gset@dataTable@table$IDENTIFIER)
  organism       <- as.character(Meta(gset)$sample_organism)
  gpl            <- getGEO(Meta(gset)$platform, destdir=argv$geodbDir)
  featureData    <- gpl@dataTable@table
} else if (grepl('^GSE', argv$accession)) {
  if (length(gset) > 1) idx <- grep(gset@annotation, attr(gset, "names")) else idx <- 1
  tryCatch({
    eset           <- gset[[1]]
  }, error=function(e) {
    cat("ERROR: Unable to generate Eset File.", file=stderr())
    cat(e, file=stderr())
    quit(save = "no", status = 3, runLast = FALSE)
  })
  tryCatch({
    featureData    <- eset@featureData@data
  }, error=function(e) {
    cat("ERROR: Unable to extract feature Data.", file=stderr())
    cat(e, file=stderr())
    quit(save = "no", status = 4, runLast = FALSE)
  })
  if ("Gene Symbol" %in% colnames(featureData)) {
    gene.names   <- as.character(featureData[, "Gene Symbol"])
  } else if ("Symbol" %in% colnames(featureData)) {
    gene.names   <- as.character(featureData[, "Symbol"])
  } else if ("PLATE_ID" %in% colnames(featureData)) {
    gene.names   <- as.character(featureData[, "PLATE_ID"])
  } else {
    cat("ERROR: Bad dataset: Unable to find Symbol in the featureData object", file=stderr())
    quit(save = "no", status = 5, runLast = FALSE)
  }
  if ("Species Scientific Name" %in% colnames(featureData)) {
    organism     <- as.character(featureData[, "Species Scientific Name"][1])
  } else if ("Species" %in% colnames(featureData)) {
    organism     <- as.character(featureData[, "Species"][1])
  } else {
    cat("ERROR: Bad dataset: Unable to find Species in the featureData object", file=stderr())
    quit(save = "no", status = 6, runLast = FALSE)
  }
}

X           <- exprs(eset) # Get Expression Data
pData       <- pData(eset)
rownames(X) <- gene.names

# KNN imputation
if (ncol(X) == 2) {
  X <- X[complete.cases(X), ] # KNN does not work when there are only 2 samples
} else {
  X <- X[rowSums(is.na(X)) != ncol(X), ] # remove rows with missing data
}

# remove all zeros
X <- X[rowSums(X != 0) != 0,]

# Replace missing value with calculated KNN value
tryCatch({
  imputation <- impute.knn(X)
  X          <- imputation$data
}, error=function(e) {
  cat("ERROR: Bad dataset: Unable to run KNN imputation on the dataset.", file=stderr())
  quit(save = "no", status = 7, runLast = FALSE)
})

# If not log transformed, do the log2 transformed
if (scalable(X)) {
  X[which(X <= 0)] <- NaN # not possible to log transform negative numbers
  X <- log2(X)
}

# TODO - what happens if species isn't in the korg/ bods db..
organism.scientific.name <-as.character(korg[which(korg[, "scientific.name"] == organism), "kegg.code"])
organism.common.name <- as.character(bods[which(bods[, "kegg code"] == organism.scientific.name), "species"])

#  Convert Gene Symbols to Entrez IDs (For GAGE Script)
entrez.gene.id <- tryCatch({
  if (c('ENTREZ_GENE_ID') %in% names(featureData)) {
    featureData[, 'ENTREZ_GENE_ID']
  } else if (c('Entrez_Gene_ID') %in% names(featureData)) {
    featureData[, 'Entrez_Gene_ID']
  } else {
    package <-as.character(bods[which(bods[, "kegg code"] == organism.scientific.name), "package"])
    # Create two column table containing entrez IDs for geodataset
    entrez.id <- id2eg(ids = gene.names, category = "SYMBOL", pkg.name = package,
                       org = as.character(organism.scientific.name))
    entrez.id[,2]
  }
}, warning = function(warning) {
  cat("# Warning ID2EG: ", file=stderr())
  cat(warning$message, file=stderr())
}, error = function(error) {
  cat("# ERROR ID2EG: ", file=stderr())
  cat(error$message, file=stderr())
  cat("\n", file=stderr())
  cat("## This may be because ID2EG does not support this organism: ", file=stderr())
  cat(paste("(", organism.common.name, ", ", organism.scientific.name, ")\n"), file=stderr())
  return (c('FAILED') )
})

if (! is.na(argv$outrdata)) {
  save(X, pData, gene.names, organism, organism.common.name, organism.scientific.name, entrez.gene.id, file = argv$outrdata)
}
