#!/usr/bin/Rsript
# ---------------------------------------------------------#
# Filename      : DGEA.R                                   #
# Authors       : IsmailM, Nazrath, Suresh, Marian, Anisa  #
# Description   : GSEA Interaction Network Pathways        #
# Rscript gage_interaction_networks.R --rundir ~/Desktop/ --pathid "hsa00480"
# ---------------------------------------------------------#

#############################################################################
#                        Import Libraries                                   #
#############################################################################

# load required libraries and silence library loading messages on command line
suppressMessages(library("argparser"))     # Argument passing
suppressMessages(library("Cairo"))         # Plots saving
suppressMessages(library("gage"))          # Does the analysis
suppressMessages(library("gageData"))      # Lets data be used by gage
suppressMessages(library("GEOquery"))      # GEO dataset Retrieval
suppressMessages(library("GO.db"))         # Loads GO database
suppressMessages(library("pathview"))      # Interaction networks & ENTREZ IDs

#############################################################################
#                        Command Line Arguments                             #
#############################################################################
parser <- arg_parser("Interaction Network parameters:")
parser <- add_argument(parser, "--rundir", default = ".",
                       help = "The output directory where graphs get saved")
parser <- add_argument(parser, "--pathid", default = "hsa00480",
                       help = "Interaction Network Path ID")
argv <- parse_args(parser)
options(bitmapType = "cairo") # Force R to use Cairo to create images

# Check if the run directory exists and if not, exit...
if (!dir.exists(file.path(argv$rundir))) {
  cat("ERROR: The Run Directory does not exist.\n", file = stderr())
  quit(save = "no", status = 1, runLast = FALSE)
}

#############################################################################
#                          Loading Saved Dataset                            #
#############################################################################
filename <- file.path(argv$rundir, "gage.RData")
if (file.exists(filename)) {
  load(file = filename)
  if (genesettype != "KEGG") {
    cat("ERROR: Interaction Network only possible using the KEGG Database.\n",
        file = stderr())
    quit(save = "no", status = 1, runLast = FALSE)
  }
} else {
  cat("ERROR: GAGE Rdata file not found.\n", file = stderr())
  quit(save = "no", status = 1, runLast = FALSE)
}

#############################################################################
#                          Interaction Networks                             #
#############################################################################
if (comparisontype == "ExpVsCtrl") {
    # Find expression change between experimental group and control
    GEOdataset.diff <- X[, Group1] - rowMeans(X[, Group2])
    # Save png and xml files in current working directory
    pathview(gene.data = GEOdataset.diff[, 1:2], pathway.id = argv$pathid,
             species = organism.scientific.name, same.layer = F,
             out.suffix = "gage_pathway")
} else if (comparisontype == "ExpVsExp") {
    # Interaction pathways for experimental group 1
    pathview(gene.data = X[, Group1names][, 1:2], same.layer = F,
             pathway.id = argv$pathid, species = organism.scientific.name,
             out.suffix = "gage_pathway_group1")
    # Interaction pathways for experimental group 2
    pathview(gene.data = X[, Group2names][, 1:2], same.layer = F,
             pathway.id = argv$pathid, species = organism.scientific.name,
             out.suffix = "gage_pathway_group2")
}
