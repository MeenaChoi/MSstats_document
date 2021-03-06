setwd("/Users/Meena/Dropbox/MSstats_GitHub_document/MSstats_v3")

library(MSstats)

DDA2009.superhirn <- read.csv("RawData.DDA.csv")

head(DDA2009.superhirn)

DDA2009.TMP <- dataProcess(raw = DDA2009.superhirn,  fillIncompleteRows = TRUE,
                           normalization = 'equalizeMedians',
                           summaryMethod = 'TMP',
                           censoredInt = "NA", cutoffCensored = "minFeature",
                           MBimpute = TRUE)

names(DDA2009.TMP)

# the data after reformatting and normalization
head(DDA2009.TMP$ProcessedData) 
# run-level summarized data
head(DDA2009.TMP$RunlevelData)
# Since this is not model-based, no model summary (here DDAskyline.quant$ModelQC=NULL).
# Only with 'summaryMethod="linear"'
head(DDA2009.TMP$ModelQC) 
# here 'TMP'
head(DDA2009.TMP$SummaryMethod) 
# predict values by AFT with 'MBimpute=TRUE'. 
# These values are matching with rownames of DDA2009.TMP$ProcessedData
head(DDA2009.TMP$PredictBySurvival) 

# no action for missing values.
DDA2009.TMP.random <- dataProcess(raw = DDA2009.superhirn, fillIncompleteRows = TRUE,
                                  normalization = 'equalizeMedians',
                                  summaryMethod = 'TMP',
                                  censoredInt=NULL)

# linear mixed model (lm or lmer) with run and feature
DDA2009.linear <- dataProcess(raw = DDA2009.superhirn, 
                              summaryMethod = "linear", censoredInt = NULL)

# accerated failure model with left-censored. NA intensities are assumed as censored
DDA2009.linear.censored <- dataProcess(raw = DDA2009.superhirn,
                                       summaryMethod = "linear", censoredInt = "NA")


dataProcessPlots(data = DDA2009.TMP, type="QCplot", ylimUp=35)

dataProcessPlots(data = DDA2009.TMP, type="QCplot", ylimUp=35,
                 which.Protein="yeast", address="yeast_eqmedians_")

dataProcessPlots(data = DDA2009.TMP, type="Profileplot",  ylimUp=35,
                 featureName="NA", width=7, height=7, address="DDA2009_TMP_")

dataProcessPlots(data = DDA2009.TMP.random, type="Profileplot",  ylimUp=35,
                 featureName="NA", width=7, height=7, 
                 originalPlot=FALSE, summaryPlot=TRUE, address="DDA2009_TMP_random_")


# select features
DDA2009.TMP.featureselection <- dataProcess(raw = DDA2009.superhirn,  fillIncompleteRows = TRUE,
                                            normalization = 'equalizeMedians',
                                            featureSubset = 'highQuality',
                                            remove_proteins_with_interference = FALSE,
                                            summaryMethod = 'TMP',
                                            censoredInt = "NA", cutoffCensored = "minFeature",
                                            MBimpute = TRUE)


dataProcessPlots(data = DDA2009.TMP.featureselection, type="QCplot", ylimUp=35, address="DDA2009_feature_selection_")


dataProcessPlots(data = DDA2009.TMP.featureselection, type="Profileplot",  ylimUp=35,
                 featureName="NA", width=7, height=7, address="DDA2009_feature_selection_1_")


# testing
levels(DDA2009.TMP$ProcessedData$GROUP_ORIGINAL)

comparison1<-matrix(c(-1,1,0,0,0,0),nrow=1)
comparison2<-matrix(c(0,-1,1,0,0,0),nrow=1)
comparison3<-matrix(c(0,0,-1,1,0,0),nrow=1)
comparison4<-matrix(c(0,0,0,-1,1,0),nrow=1)
comparison5<-matrix(c(0,0,0,0,-1,1),nrow=1)
comparison6<-matrix(c(1,0,0,0,0,-1),nrow=1)

comparison<-rbind(comparison1,comparison2,comparison3,comparison4,comparison5,comparison6)
row.names(comparison)<-c("C2-C1","C3-C2","C4-C3","C5-C4","C6-C5","C1-C6")

DDA2009.comparisons <- groupComparison(contrast.matrix = comparison, data = DDA2009.TMP)

names(DDA2009.comparisons)

names(DDA2009.comparisons$ComparisonResult) 

SignificantProteins <- with(DDA2009.comparisons, ComparisonResult[ComparisonResult$adj.pvalue < 0.05, ])
nrow(SignificantProteins)

groupComparisonPlots(data = DDA2009.comparisons$ComparisonResult, type = 'VolcanoPlot', width=8, height=8)

groupComparisonPlots(data = DDA2009.comparisons$ComparisonResult, type = 'Heatmap')

