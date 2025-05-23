## ------------------- Parse Snakemake Object ------------------- ##
# Check if the "snakemake" object exists
if (exists("snakemake")) {
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads

    # setup logger if log file is provided
    if (length(snakemake@log) > 0)
        sink(snakemake@log[[1]], FALSE, c("output", "message"), TRUE)

    save.image(
        file.path("resources/", paste0(snakemake@rule, ".RData"))
    )
}
cleanCharacterStrings <- function(name) {
    # # make sure name is a string
    name <- as.character(name)

    # if there is a colon like in "Cisplatin: 1 mg/mL (1.5 mM); 5 mM in DMSO"
    # remove everything after the colon
    name <- gsub(":.*", "", name)

    # remove ,  ;  -  +  *  $  %  #  ^  _  as well as any spaces
    name <- gsub("[\\,\\;\\-\\+\\*\\$\\%\\#\\^\\_\\s]", "", name, perl = TRUE)

    # remove hyphen
    name <- gsub("-", "", name)

    # # remove substring of round brackets and contents
    name <- gsub("\\s*\\(.*\\)", "", name)

    # # remove substring of square brackets and contents
    name <- gsub("\\s*\\[.*\\]", "", name)

    # # remove substring of curly brackets and contents
    name <- gsub("\\s*\\{.*\\}", "", name)

    # # convert entire string to uppercase
    name <- toupper(name)

    # dealing with unicode characters
    name <- gsub(
        "Unicode",
        "",
        iconv(name, "LATIN1", "ASCII", "Unicode"),
        perl = TRUE
    )

    name
}
# 0.1 Startup
# -----------
# load data.table, suppressPackageStartupMessages unless there is an error
message("Loading libraries...")
suppressPackageStartupMessages(library(data.table, quietly = TRUE))
suppressPackageStartupMessages(library(dplyr, quietly = TRUE))


# # TODO:: convert this to a container!
# install.packages(
#     "pak",
#     repos = sprintf(
#         "https://r-lib.github.io/p/pak/stable/%s/%s/%s",
#         .Platform$pkgType,
#         R.Version()$os,
#         R.Version()$arch
#     )
# )

# # Check if required packages are installed, otherwise install from bhklab repos

# message("Installing CoreGx & PharmacoGx from GitHub...")
# pak::pkg_install(
#     c("bhklab/CoreGx", "bhklab/PharmacoGx"),
#     dependencies = TRUE,
#     upgrade = TRUE,
#     ask = FALSE,
# )

suppressPackageStartupMessages(library(CoreGx, quietly = TRUE))
suppressPackageStartupMessages(library(PharmacoGx, quietly = TRUE))

(rawdata <- data.table::fread(INPUT$rawdata, check.names = T))


# calculate maximum number of doses used in an experiment
# some experiments use less doses so this is necessary to keep dimensions consistent
concentrations.no <- max(sapply(
    rawdata$"Doses..uM.",
    function(x) length(unlist(strsplit(x, split = ",")))
))

#' This function processes treatment response data by converting it into a data.table format.
#'
#' @param values A list containing the treatment response data.
#' @return A data.table containing the processed treatment response data.
#'
#' @details The function takes a list of treatment response data and converts it into a data.table format.
#' It extracts the necessary columns from the input data and performs additional processing steps to
#' transform the data into the desired format. The function also handles missing values by filling them
#' with NA. The resulting data.table contains columns for sample ID, treatment ID, dose, viability,
#' EC50, IC50, Amax, and ActArea.
fnExperiment <- function(values) {
    # TODO:: dose1...dose8 should correspond exactly to
    # ".0025,.0080,.025,.080,.25,.80,2.53,8"
    # Fill each empty value with NA
    dt <- data.table(
        sampleid = values[["CCLE.Cell.Line.Name"]],
        # CCLE.Cell.Line.Name = values[["CCLE.Cell.Line.Name"]],
        # sampleid = values[["Primary.Cell.Line.Name"]],
        treatmentid = values[["Compound"]],
        dose = values[["Doses..uM."]],
        viability = values[["Activity.Data..median."]],
        EC50 = values[["EC50..uM."]],
        IC50 = values[["IC50..uM."]],
        Amax = values[["Amax"]],
        ActArea = values[["ActArea"]]
    )
    # get the doses for a given experiment into the dt
    dt[,
        paste0("dose", 1:concentrations.no) := {
            doses <- tstrsplit(`dose`, split = ",")
            if (length(doses) < concentrations.no) {
                doses <- c(doses, rep(NA, concentrations.no - length(doses)))
            }
            lapply(doses, function(x) as.numeric(x))
        }
    ]

    # get the responses for a given experiment into the dt
    dt[,
        paste0("viability", 1:concentrations.no) := {
            responses <- tstrsplit(`viability`, split = ",")
            if (length(responses) < concentrations.no) {
                responses <- c(
                    responses,
                    rep(NA, concentrations.no - length(responses))
                )
            }
            lapply(responses, function(x) as.numeric(x) + 100)
        }
    ]

    # return dt without the original doses and responses columns
    dt[, c("dose", "viability") := NULL]

    return(dt)
}

dt <- rbindlist(
    BiocParallel::bplapply(
        1:nrow(rawdata),
        function(rowNum) fnExperiment(rawdata[rowNum, ]),
        BPPARAM = BiocParallel::MulticoreParam(workers = THREADS)
    )
)

# ######################################################
# clean up the treatmentid and sampleid columns

# # Extracting columns for the first data.table
published_profiles <- dt[, .(sampleid, treatmentid, EC50, IC50, Amax, ActArea)]

# # Extracting columns for the second data.table
raw <- dt[, c(
    "sampleid",
    "treatmentid",
    c(paste0("dose", 1:8), paste0("viability", 1:8))
)]

raw_long <- data.table::melt(
    raw,
    id.vars = c("sampleid", "treatmentid"),
    measure.vars = patterns("^dose", "^viability"),
    variable.name = "Dose",
    value.name = c("dose", "viability")
)

raw_long <- raw_long[!is.na(dose), ][, Dose := NULL][]

# Write the processed data frames to the output files
data.table::fwrite(
    raw_long,
    file = OUTPUT$preprocessed_raw,
    sep = ",",
    quote = FALSE
)
message("Saved raw data to ", OUTPUT$preprocessed_raw)
data.table::fwrite(
    published_profiles,
    file = OUTPUT$preprocessed_profiles,
    sep = ",",
    quote = FALSE
)
message("Saved profiles data to ", OUTPUT$preprocessed_profiles)

# ######################################################
# (sampleMetadata <- data.table::fread(INPUT$sampleMetadata, check.names = T))
# (treatmentMetadata <- data.table::fread(
#     INPUT$treatmentMetadata,
#     check.names = T,
#     encoding = "Latin-1"
# ))
# # CONSTRUCT THE TREDataMapper OBJECT
# message("Constructing the treatment response experiment object...")
# tdm <- CoreGx::TREDataMapper(rawdata=raw)

# CoreGx::rowDataMap(tdm) <- list(
#     id_columns = c("treatmentid", "dose"),
#     mapped_columns = c()
# )

# CoreGx::colDataMap(tdm) <- list(
#     id_columns = c("sampleid"),
#     mapped_columns = c()
# )

# CoreGx::assayMap(tdm) <- list(
#     sensitivity = list(
#         id_columns = c("treatmentid", "sampleid", "dose"),
#         mapped_columns = c("viability")
#     )
# )

# (ccle_tre <- CoreGx::metaConstruct(tdm))
# ccle_tre$sensitivity

# ######################################################
# # Compute on the sensitivity assay
# message("Computing the profiles assay...")
# tre_fit <- ccle_tre |> CoreGx::endoaggregate(
#     {  # the entire code block is evaluated for each group in our group by
#         # 1. fit a log logistic curve over the dose range
#         fit <- PharmacoGx::logLogisticRegression(dose, viability,
#             viability_as_pct=TRUE)
#         # 2. compute curve summary metrics
#         ic50 <- PharmacoGx::computeIC50(dose, Hill_fit=fit)
#         aac <- PharmacoGx::computeAUC(dose, Hill_fit=fit)
#         # 3. assemble the results into a list, each item will become a
#         #   column in the target assay.
#         list(
#             HS=fit[["HS"]],
#             E_inf = fit[["E_inf"]],
#             EC50 = fit[["EC50"]],
#             Rsq=as.numeric(unlist(attributes(fit))),
#             aac_recomputed=aac,
#             ic50_recomputed=ic50
#         )
#     },
#     assay="sensitivity",
#     target="profiles",
#     enlist=FALSE,  # this option enables the use of a code block for aggregation
#     by=c("treatmentid", "sampleid"),
#     nthread=THREADS  # parallelize over multiple cores to speed up the computation
# )
# show(tre_fit)

# old_names <- c("EC50", "IC50", "Amax", "ActArea")
# data.table::setnames(published_profiles, old_names, paste0("published_", old_names))

# ######################################################
# # use the profiles from tre_fit, merge the published profiles into the profiles
# # and assign to the ccle_tre
# # this is done to ensure that the published profiles are included in the final object
# # probably shouldnt have two objects with the same data...
# CoreGx::assay(ccle_tre, "profiles") <-
#     tre_fit$profiles[
#         published_profiles,
#         on = c("treatmentid", "sampleid"),
#         c(paste0("published_", old_names)) := mget(paste0("i.published_", old_names))][]

# ######################################################
# # Add metadata
# CoreGx::metadata(ccle_tre) <- list(
#     data_source = snakemake@config$treatmentResponse,
#     filename = basename(unique(INPUT$rawdata)),
#     annotation = "treatmentResponse",
#     date = Sys.Date(),
#     sessionInfo = capture.output(sessionInfo())
# )
# show(ccle_tre)
# show(ccle_tre$profiles)

# ######################################################
# # Save the object
# message("Saving the treatment response experiment object to ", OUTPUT$tre)
# saveRDS(ccle_tre, file = OUTPUT$tre)

# message("Saving the sensitivity info to ", OUTPUT$raw)
# data.table::fwrite(ccle_tre$sensitivity, file = OUTPUT$raw, sep = "\t", quote = F, row.names = F)

# message("Saving the profile data to ", OUTPUT$profiles)
# data.table::fwrite(ccle_tre$profiles, file = OUTPUT$profiles, sep = "\t", quote = F, row.names = F)

# sink()
