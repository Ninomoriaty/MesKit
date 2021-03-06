#' @title pathwayTree
#' @description Perform pathway enrichment analysis of trunk/branch mutations of a phylogenetic tree.
#' 
#' 
#' @param phyloTree a phyloTree object generated by getPhyloTree function.
#' @param pathway.type one of "KEGG" or "Reactome". Default type="KEGG"
#' @param pval cutoff value of pvalue. Default pval=0.05
#' @param qval cutoff value of qvalue. Default qval=0.2
#' @param pAdjustMethod one of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none". Default pAdjustMethod="BH"
#' @param plotType one of "dot", "bar"
#' @param showCategory category numbers
#' 
#' @examples
#' pathwayTree(phyloTree, pathway.type = "KEGG")
#' @return pathway enrichment results
#' @importFrom ReactomePA enrichPathway
#' @importFrom clusterProfiler enrichKEGG
#' @export Pathway.phyloTree

#Pathway analysis
pathwayTree <- function(phyloTree, pathway.type="KEGG", pval=0.05, pAdjustMethod="BH",
                           qval=0.2,  plotType="dot", showCategory=5){
  branches <- phyloTree@mut_branches
  patientID <- phyloTree@patientID
  
  Pathway.branch.result <- data.frame()
  all.genes <- c()
  pathPlot.list <- list()
  pathResult.list <- list()
  plot.branchNames <- c()
  result.branchNames <- c()

  x <- 1
  y <- 1 
  for (i in 1:length(branches)){
    branch <- branches[[i]]
    branchID <- names(branches)[i]
    #split the gene symbol by ","
    geneSymbol <- unique(unlist(strsplit(as.character(branch$Hugo_Symbol), split = ",")))
    all.genes <- unique(c(all.genes, geneSymbol))
    
    message(paste("Processing branch: ", branchID, sep = ""))
    Pathway.branch <- Pathway_analysis(geneSymbol, pathway.type, pval, pAdjustMethod,
                                qval, patientID, branchID)
    if(!is.null(Pathway.branch)){
      pathResult.list[[x]] <- Pathway.branch@result
      result.branchNames <- c(result.branchNames, branchID)
      x <- x+1
      if(min(Pathway.branch@result$p.adjust) > pval | min(Pathway.branch@result$qvalue, na.rm = T) > qval){
        message(paste("0 enriched pathway found for branch ", branchID, sep = ""))
      }else{
        plot.branchNames <- c(plot.branchNames, branchID)
        if (plotType == "dot"){
          path.plot <- dotplot(Pathway.branch, showCategory = showCategory) + ggtitle(branchID)
        }else if (plotType == "bar"){
          path.plot <- barplot(Pathway.branch, showCategory = showCategory) + ggtitle(branchID)
        }
        pathPlot.list[[y]] <- path.plot
        y <- y+1
      }      
    }

  }  
  Pathway.all <- Pathway_analysis(all.genes, pathway.type, pval, pAdjustMethod,
                                     qval, patientID, Name = "All")
  Pathway.all.result <- Pathway.all@result
  pathResult.list[[x]] <- Pathway.all.result
  result.branchNames <- c(result.branchNames, "All")
  if(min(Pathway.all.result$p.adjust) > pval | min(Pathway.all.result$qvalue, na.rm = T) > qval){
      message(paste("0 enriched pathway found in ", patientID, sep = ""))
  }else{
    plot.branchNames <- c(plot.branchNames, "All")
    if (plotType == "dot"){
      path.plot <- dotplot(Pathway.all, showCategory = showCategory) + ggtitle(Pathway.all$Case)
    }else if (plotType == "bar"){
      path.plot <- barplot(Pathway.all, showCategory = showCategory) + ggtitle(Pathway.all$Case)
    }
    pathPlot.list[[y]] <- path.plot
}

  names(pathResult.list) <- result.branchNames
  names(pathPlot.list) <- plot.branchNames


  pathway <- list(pathResult.list, pathPlot.list)
  names(pathway) <- c("pathway.category", "pathway.plot")

  return(pathway)

}


Pathway_analysis <- function(genes = NULL, pathway.type = pathway.type, pval = pval, pAdjustMethod = "BH", qval = qval, 
                             patientID = patientID, Name = Name){
    
    trans = suppressMessages(bitr(genes, fromType="SYMBOL", toType=c("ENTREZID"), OrgDb="org.Hs.eg.db"))
    
    pathway.type <- toupper(pathway.type)
    pathway.type <- match.arg(pathway.type, c("KEGG", "REACTOME"))
    
    if (pathway.type == "KEGG"){
        pathway <- enrichKEGG(
            gene          = trans$ENTREZID,                      
            organism      = 'hsa',
            keyType       = 'kegg',                    
            pvalueCutoff  = pval,
            pAdjustMethod = pAdjustMethod,
            qvalueCutoff  = qval,
        )
    }
    else{
        pathway <- enrichPathway(
            gene          = trans$ENTREZID,                              
            organism      = 'human',                              
            pvalueCutoff  = pval,
            pAdjustMethod = pAdjustMethod,
            qvalueCutoff  = qval,
        )
        
    }
    
    
    if (!is.null(pathway) && nrow(pathway@result) > 0){     
        if(Name == "All"){
            pathway@result$Case <- patientID
        }
        else{
            pathway@result$branch <- Name
        }
    } 
    return(pathway)
}  
