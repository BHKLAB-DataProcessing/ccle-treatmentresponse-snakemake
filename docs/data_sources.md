# Data Sources

## Cancer Cell Line Encyclopedia (CCLE) Dataset

### Overview

The Cancer Cell Line Encyclopedia (CCLE) is a comprehensive resource containing genomic and pharmacological profiles of human cancer cell lines. This project focuses specifically on the treatment response data from CCLE, which includes drug sensitivity measurements across multiple cancer cell lines.

### External Data Sources

#### Cell Line Annotations

- **Name**: CCLE Cell Line Annotations
- **Version/Date**: December 26, 2018
- **URL**: https://data.broadinstitute.org/ccle/Cell_lines_annotations_20181226.txt
- **Access Method**: Direct download
- **Data Format**: Tab-separated values (TSV) but saved as '.txt'
- **Citation**: Barretina, J., Caponigro, G., Stransky, N., et al. (2012). The Cancer Cell Line Encyclopedia enables predictive modelling of anticancer drug sensitivity. Nature, 483(7391), 603-607. https://doi.org/10.1038/nature11003
- **License**: [Broad Institute Terms of Use](https://www.broadinstitute.org/terms-use)

#### Treatment Annotation

- **Name**: CCLE NP24.2009 Profiling
- **Version/Date**: February 20, 2012
- **URL**: https://data.broadinstitute.org/ccle_legacy_data/pharmacological_profiling/CCLE_NP24.2009_profiling_2012.02.20.csv
- **Access Method**: Direct download
- **Data Format**: Comma-separated values (CSV)
- **Citation**: Same as cell line annotations
- **License**: [Broad Institute Terms of Use](https://www.broadinstitute.org/terms-use)

#### Drug Response Data

- **Name**: CCLE NP24.2009 Drug Data
- **Version/Date**: February 24, 2015
- **URL**: https://data.broadinstitute.org/ccle_legacy_data/pharmacological_profiling/CCLE_NP24.2009_Drug_data_2015.02.24.csv
- **Access Method**: Direct download
- **Data Format**: Comma-separated values (CSV)
- **Citation**: Same as cell line annotations
- **License**: [Broad Institute Terms of Use](https://www.broadinstitute.org/terms-use)

### Processed Data

### Sample Metadata (sampleMetadata.tsv)

- **Name**: Preprocessed Sample Metadata
- **Input Data**: CCLE Cell Line Annotations
- **Processing Scripts**: `workflow/scripts/R/preprocessMetadata.R`
- **Output Location**: `data/metadata/sampleMetadata.tsv`

| Column Name             | Description                         | Example Values                                |
|-------------------------|-------------------------------------|-----------------------------------------------|
| CCLE.sampleid           | Unique identifier for the cell line | DMS53_LUNG                                    |
| CCLE.name               | Name of the cell line               | DMS 53                                        |
| CCLE.depMapID           | DepMap identifier                   | ACH-000698                                    |
| CCLE.site_Primary       | Primary site of origin              | lung, breast, kidney                          |
| CCLE.site_Subtype1      | Subtype of the primary site         | colon, skin, NS (Not Specified)               |
| CCLE.histology          | Histological classification         | carcinoma, lymphoid_neoplasm                  |
| CCLE.histology_Subtype1 | Subtype of histology                | small_cell_carcinoma, adenocarcinoma          |
| CCLE.gender             | Gender of the patient               | male, female                                  |
| CCLE.age                | Age of the patient                  | 54, 73, 7                                     |
| CCLE.race               | Race of the patient                 | caucasian, african_american, asian            |
| CCLE.disease            | Associated disease                  | lung_cancer, Burkitts lymphoma                |
| CCLE.type               | Cancer type                         | lung_small_cell, colorectal, lymphoma_Burkitt |

#### Treatment Metadata (treatmentMetadata.tsv)

- **Name**: Preprocessed Treatment Metadata
- **Input Data**: CCLE NP24.2009 Profiling
- **Processing Scripts**: `workflow/scripts/R/preprocessMetadata.R`
- **Output Location**: `data/metadata/treatmentMetadata.tsv`

| Column Name                      | Description                          | Example Values                       |
|----------------------------------|--------------------------------------|--------------------------------------|
| CCLE.raw_treatmentid             | Original treatment name              | Erlotinib, Lapatinib                 |
| CCLE.target                      | Molecular target of the drug         | EGFR, c-MET, ALK                     |
| CCLE.mechanismOfAction           | Mechanism of action                  | EGFR Inhibitor, c-MET Inhibitor      |
| CCLE.class                       | Drug class                           | Kinase inhibitor, Cytotoxic          |
| CCLE.highestClinicalTrialPhase   | Highest clinical trial phase reached | Launched-2004, Preclinical, Phase II |
| CCLE.treatmentSourceOrganization | Organization that developed the drug | Genentech, Pfizer, Novartis          |
| CCLE.treatmentid                 | Standardized treatment ID            | ERLOTINIB, LAPATINIB                 |

#### Treatment Response: Profiles

- **Name**: Preprocessed Treatment Response Profiles
- **Input Data**: CCLE NP24.2009 Drug Data
- **Processing Scripts**: `workflow/scripts/R/preprocessTreatmentResponse.R`
- **Output Location**: `data/procdata/preprocessed_TreatmentResponse_profiles.csv`

| Column Name | Description                           | Units/Notes                                     |
|-------------|---------------------------------------|-------------------------------------------------|
| sampleid    | Cell line identifier                  | Same as `CCLE.sampleid`                         |
| treatmentid | Drug identifier                       | Same as `CCLE.treatmentid`                      |
| EC50        | Half maximal effective concentration  | μM (micromolar)                                 |
| IC50        | Half maximal inhibitory concentration | μM (micromolar)                                 |
| Amax        | Maximum activity/effect level         | Percentage, negative values indicate inhibition |
| ActArea     | Activity area                         | Area under the dose-response curve              |

#### Treatment Response: Raw

After extracting the treatment response data from the `CCLE NP24.2009 Drug Data`,
we create a long table format of the data for ingestion.

- **Name**: Preprocessed Raw Treatment Response
- **Input Data**: CCLE NP24.2009 Drug Data
- **Processing Scripts**: `workflow/scripts/R/preprocessTreatmentResponse.R`
- **Output Location**: `data/procdata/preprocessed_TreatmentResponse_raw.csv`

| Column Name | Description                  | Units/Notes                                                                  |
|-------------|------------------------------|------------------------------------------------------------------------------|
| sampleid    | Cell line identifier         | Same as `CCLE.sampleid`                                                      |
| treatmentid | Drug identifier              | Same as `CCLE.treatmentid`                                                   |
| dose        | Drug concentration           | μM (micromolar)                                                              |
| viability   | Cell viability at given dose | Percentage, values > 100 indicate growth, < 100 indicate inhibition (median) |