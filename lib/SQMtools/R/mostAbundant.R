#' Get the N most abundant rows from a numeric table
#'
#' Return a subset of an input matrix or data frame, containing only the N most abundant rows, sorted. Alternatively, a custom set of rows can be returned.
#' @param data numeric matrix or data frame
#' @param N integer Number of rows to return (default \code{10}).
#' @param items Character vector. Custom row names to return. If provided, it will override \code{N} (default \code{NULL}).
#' @param others logical. If \code{TRUE}, an extra row will be returned containing the aggregated abundances of the elements not selected with \code{N} or \code{items} (default \code{FALSE}).
#' @param rescale logical. Scale result to percentages column-wise (default \code{FALSE}).
#' @return A matrix or data frame (same as input) with the selected rows.
#' @examples
#' data(Hadza)
#' Hadza.carb = subsetFun(Hadza, "Carbohydrate metabolism")
#' # Which are the 20 most abundant KEGG functions in the ORFs related to carbohydrate metabolism?
#' topCarb = mostAbundant(Hadza.carb$functions$KEGG$tpm, N=20)
#' # Now print them with nice names
#' rownames(topCarb) = paste(rownames(topCarb), Hadza.carb$misc$KEGG_names[rownames(topCarb)], sep="; ")
#' topCarb
#' We can pass this to any R function
#' heatmap(topCarb)
#' But for convenience we provide wrappers for plotting ggplot2 heatmaps and barplots
#' plotHeatmap(topCarb, label_y="TPM")
#' plotBars(topCarb, label_y="TPM")
#' @export
mostAbundant = function(data, N = 10, items = NULL, others = F, rescale = F)
    {
    if (!is.data.frame(data) & !is.matrix(data)) { stop('The first argument must be a matrix or a data frame') }
    type = typeof(data)

    if(!is.null(items))  # User selects custom data.
        {
        # Check that items selection is possible and user have not ask for unknown things!
        if(any(!items %in% rownames(data)))
            {
            stop('At least one of your custom items is not in the rows')
            }
        } else
        {
        total_items = nrow(data)
        if (N <= total_items) # Do we have at least N items?
            { # Do we have at least N items?
            if (N <= 0)
                {
                stop('N<=0 and no vector of items items was supplied. There is nothing to return')
                }
            } else
                { # User asks for sth impossible
                warning(sprintf('N=%s but only %s items exist. Returning %s items', N, total_items, total_items))
                N = total_items
            }
        items = names(sort(rowSums(data), decreasing = T)[1:N])
        }
    other_items = colSums(data[!rownames(data) %in% items,, drop = F])
    data = data[items, ,drop = F]
    # Sum the abundances of the non-selected taxa
    if (others)
        {
        data = as.data.frame(rbind('Other' = other_items, data))
        }
    if (rescale)
        {
        data = 100 * t(t(data) / colSums(data))
        }
    if(type!='list')
        {
        data = as.matrix(data)
    }else
        {
        data = as.data.frame(data)
        }
    return(data)
    }

