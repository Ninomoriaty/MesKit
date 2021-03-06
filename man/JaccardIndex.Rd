% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/JaccardIndex.R
\name{JaccardIndex}
\alias{JaccardIndex}
\title{JaccardIndex}
\usage{
JaccardIndex(maf, type = "full")
}
\arguments{
\item{maf}{a Maf object generated by readMaf function}

\item{character, }{"full" (default), "upper" or "lower", display full matrix, lower triangular or upper triangular matrix.}
}
\value{
the graphical display of correlation matrix via Jaccard similarity coefficient method
}
\description{
The Jaccard similarity coefficient is defined as the ratio of shared variants to all 
(shared plus discordant) variants for two samples.
}
\examples{
JaccardIndex(maf)
}
