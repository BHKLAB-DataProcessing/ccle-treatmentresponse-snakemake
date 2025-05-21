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
        file.path("resources", paste0(snakemake@rule, ".RData"))
    )
}

# NOTE: required libraries:
# library(data.table)

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

## 0. read annotation data
## -------------------------------
sampleDT <- data.table::fread(INPUT$sampleAnnotation)

# fread into treatmentDT and convert column names to safe names
treatmentDT <- data.table::fread(
    input = INPUT$treatmentAnnotation,
    encoding = "Latin-1"
)

## 1.0 clean sample annotation data
## -------------------------------
sampleDT <-
    sampleDT[,
        .(
            CCLE.sampleid = `CCLE_ID`,
            CCLE.name = `Name`,
            CCLE.depMapID = `depMapID`,
            CCLE.site_Primary = `Site_Primary`,
            CCLE.site_Subtype1 = `Site_Subtype1`,
            CCLE.site_Subtype2 = `Site_Subtype2`,
            CCLE.site_Subtype3 = `Site_Subtype3`,
            CCLE.histology = `Histology`,
            CCLE.histology_Subtype1 = `Hist_Subtype1`,
            CCLE.histology_Subtype2 = `Hist_Subtype2`,
            CCLE.histology_Subtype3 = `Hist_Subtype3`,
            CCLE.gender = `Gender`,
            CCLE.age = `Age`,
            CCLE.race = `Race`,
            CCLE.disease = `Disease`,
            CCLE.type = `type`
        )
    ]


## 2.0 clean treatment annotation data
## -------------------------------
# update column names to safe names
treatmentMetadata <-
    treatmentDT[,
        .(
            CCLE.raw_treatmentid = `Compound (code or generic name)`,
            CCLE.target = `Target(s)`,
            CCLE.mechanismOfAction = `Mechanism of action`,
            CCLE.class = `Class`,
            CCLE.highestClinicalTrialPhase = `Highest Phase`,
            CCLE.treatmentSourceOrganization = `Organization`
        )
    ]

treatmentMetadata[,
    CCLE.treatmentid := cleanCharacterStrings(CCLE.raw_treatmentid)
]

## 3.0 write out cleaned data
## -------------------------------

message("Saving sampleMetadata to ", OUTPUT[["sampleMetadata"]])
data.table::fwrite(
    sampleDT,
    file = OUTPUT[["sampleMetadata"]],
    quote = FALSE,
    sep = "\t"
)

message("Saving treatmentMetadata to ", OUTPUT[["treatmentMetadata"]])
data.table::fwrite(
    treatmentMetadata,
    file = OUTPUT[["treatmentMetadata"]],
    quote = FALSE,
    sep = "\t"
)
