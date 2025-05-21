# Changelog

## [0.5.0](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/compare/v0.4.0...v0.5.0) (2025-05-21)


### Features

* move docker stuff to release ([fa856a6](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/fa856a6d55965b9649b30c5a68af72efb42f32cc))

## [0.4.0](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/compare/v0.3.2...v0.4.0) (2025-05-21)


### Features

* add step to disable apparmor namespace restrictions for apptainer on Linux ([4e64168](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/4e641683c5fe1f130fa5e84ce246eb04312760c1))
* trying to force this ([6f93732](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/6f937321b478b57c5a6559dbd770ac0428795216))


### Bug Fixes

* add eWaterCycle/setup-apptainer action to workflow ([ebb63a3](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/ebb63a391de1e81537be22d0beaa0e85af597e64))
* simplify snakemake pipeline command by removing unnecessary apptainer arguments ([570a13a](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/570a13af04c57345d6d567b231a0c327092ce9b0))

## [0.3.2](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/compare/v0.3.1...v0.3.2) (2025-05-21)


### Bug Fixes

* rename to yaml ([d63eb62](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/d63eb62543d83922e55a37ffc5e5ff490b8d110b))

## [0.3.1](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/compare/v0.3.0...v0.3.1) (2025-05-21)


### Bug Fixes

* make github container package public ([60f6b43](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/60f6b43ae49f9412619f65b49d6750cd31b00a32))
* update docker-publish workflow to trigger on releases instead of tags ([dee21dc](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/dee21dc45faa7f95291516055cf5d919cfea2b4b))

## [0.3.0](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/compare/v0.2.0...v0.3.0) (2025-05-21)


### Features

* Add Apptainer dependency and update Snakefile with container specifications ([d63092f](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/d63092fd8b0dad097b93b32a60fdf521d451cc84))
* allow for workflow dispatch ([16d5068](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/16d506868862baa6fc15fb2896ded1793983a9ea))


### Bug Fixes

* update build action ([43733ad](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/43733adb5f8a1cbce209fc06ff791b17b66fe5d6))

## [0.2.0](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/compare/v0.1.0...v0.2.0) (2025-05-21)


### Features

* add Docker workflow for building and pushing images ([dba042a](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/dba042ac87f7b721333a2b0235ebfc8800dd2e46))
* main pipeline works, requires R and packages to be installed on system for nwo ([5ca8c8a](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/5ca8c8a8bb4991672c9279104392022d264f38ea))
* setup config and snakefile ([d46915f](https://github.com/BHKLAB-DataProcessing/ccle-treatmentresponse-snakemake/commit/d46915fe690c371d6cdf73091dd32617270547de))
