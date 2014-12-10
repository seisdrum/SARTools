#' Summarize DESeq2 analysis
#'
#' Summarize DESeq2 analysis: diagnotic plots, dispersions plot, summary of the independent filtering, export results...
#'
#' @param out.DESeq2 the result of \code{run.DESeq2()}
#' @param group factor vector of the condition from which each sample belongs
#' @param independentFiltering \code{TRUE} or \code{FALSE} to perform the independent filtering or not
#' @param cooksCutoff Cook's distance threshold for detecting outliers (\code{Inf}
#' to disable the detection, \code{NULL} to keep DESeq2 threshold)
#' @param alpha significance threshold to apply to the adjusted p-values
#' @param col colors for the plots
#' @return A list containing: (i) a list of \code{data.frames} from \code{exportResults.DESeq2()}, (ii) the table summarizing the independent filtering procedure and (iii) a table summarizing the number of differentially expressed features
#' @author Hugo Varet

summarizeResults.DESeq2 <- function(out.DESeq2, group, independentFiltering=TRUE, cooksCutoff=NULL,
                                    alpha=0.05, col=c("lightblue","orange","MediumVioletRed","SpringGreen")){
  # create the figures/tables directory if does not exist
  if (!I("figures" %in% dir())) dir.create("figures", showWarnings=FALSE)
  if (!I("tables" %in% dir())) dir.create("tables", showWarnings=FALSE)
  
  dds <- out.DESeq2$dds
  results <- out.DESeq2$results
  
  # diagnostic of the size factors
  diagSizeFactorsPlots(dds=dds)
  
  # boxplots before and after normalisation
  countsBoxplots(dds, group=group, col=col)
  
  # dispersions plot
  dispersionsPlot(dds=dds)
  
  # results of the independent filtering
  if (independentFiltering){
    tabIndepFiltering <- tabIndepFiltering(results)
    cat("Number of features discarded by the independent filtering:\n")
    print(tabIndepFiltering, quote=FALSE)
  } else{
    tabIndepFiltering <- NULL
  }
  
  # exporting results of the differential analysis
  complete <- exportResults.DESeq2(out.DESeq2, group=group, cooksCutoff=cooksCutoff, alpha=alpha)
  
  # small table with number of differentially expressed features
  nDiffTotal <- nDiffTotal(complete=complete, alpha=alpha)
  cat("\nNumber of features down/up and total:\n")
  print(nDiffTotal, quote=FALSE)
  
  # histograms of raw p-values
  rawpHist(complete=complete)
  
  # MA-plots
  MAPlot(complete=complete, alpha=alpha)
  
  return(list(complete=complete, tabIndepFiltering=tabIndepFiltering, nDiffTotal=nDiffTotal))
}
