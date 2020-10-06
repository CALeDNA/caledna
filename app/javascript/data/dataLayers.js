export const CSCI = "CSCI";
export const MMI = "MMI";
export const OE = "O/E";
export const D18 = "D18";
export const S2 = "S2";
export const H2O = "H20";
export const CRAM = "Overall CRAM Score";
export const BioticStructure = "Biotic Structure";
export const Buffer = "Buffer and Landscape Context";
export const Hydrology = "Hydrology";
export const PhysicalStructure = "Physical Structure";
export const Temperature = "Temperature (C°)";
export const Oxygen = "Dissolved Oxygen (mg/L)";
export const pH = "pH";
export const Salinity = "Salinity (ppt)";
export const SpecificConductivity = "Specific Conductivity (us/cm)";
export const Alkalinity = "Alkalinity as CaCO3 (mg/L)";
export const Hardness = "Hardness as CaCO3 (mg/L)";
export const Chloride = "Chloride (mg/L)";
export const Sulfate = "Sulfate (mg/L)";
export const TSS = "TSS (mg/L)";
export const Ammonia = "Ammonia as N (mg/L)";
export const Nitrate = "Nitrate as N (mg/L)";
export const Nitrite = "Nitrite as N (mg/L)";
export const NitrateNitrite = "Nitrate + Nitrite as N";
export const NitrogenTotal = "Nitrogen Total (mg/L)";
export const NitrogenTotalKjeldahl = "Nitrogen Total Kjeldahl";
export const OrthoPhosphate = "OrthoPhosphate as P (mg/L)";
export const Phosphorus = "Phosphorus as P (mg/L)";
export const DissolvedOrganicCarbon = "Dissolved Organic Carbon (mg/L)";
export const TotalOrganicCarbon = "Total Organic Carbon (mg/L)";
export const AFDM = "AFDM (mg/cm2)";
export const Chla = "Chl-a (ug/cm2)";
export const Arsenic = "Arsenic (ug/L)";
export const Cadmium = "Cadmium (ug/L)";
export const Chromium = "Chromium (ug/L)";
export const Copper = "Copper (ug/L)";
export const Iron = "Iron (ug/L)";
export const Lead = "Lead (ug/L)";
export const Mercury = "Mercury (ug/L)";
export const Nickel = "Nickel (ug/L)";
export const Selenium = "Selenium (ug/L)";
export const Zinc = "Zinc (ug/L)";
export const Eroded = "Eroded";
export const Stable = "Stable";
export const Vulnerable = "Vulnerable";
export const FastWater = "Fast Water (%)";
export const SlowWater = "Slow Water (%)";
export const ChannelAlteration = "Channel Alteration";
export const EpifaunalSubstrate = "Epifaunal Substrate";
export const SedimentDeposition = "Sediment Deposition";
export const MeanSlope = "Mean Slope (%)";
export const Discharge = "Discharge (m3/sec)";
export const WettedWidth = "Wetted Width (m)";
export const MicroalgaeThickness = "Microalgae Thickness (mm)";
export const Macrophytes = "Macrophytes (%)";
export const Macroalgae = "Macroalgae (%)";
export const Cover = "Cover (Densiometer) (%)";
export const CPOM = "CPOM (%)";
export const SandFines = "Sand and Fines (%)";
export const ConcreteAsphalt = "Concrete/Asphalt (%)";
export const CobbleGravel = "Cobble and Gravel (%)";
export const PouR = "Protecting Our River";
export const LARWMP = "Los Angeles River Watershed Monitoring Program (2018)";
export const BenthicMacroinvertebrates = "Benthic Macroinvertebrates";
export const AttachedAlgae = "Attached Algae";
export const RiparianHabitatScore = "Riparian Habitat Score";
export const AlgalBiomass = "Algal Biomass";
export const InSituMeasurements = "InSitu Measurements";
export const GeneralChemistry = "General Chemistry";
export const Nutrients = "Nutrients";
export const DissolvedMetals = "Dissolved Metals";
export const PhysicalHabitatAssessments = "Physical Habitat Assessments";

export const biodiversity = {
  eDNA: "eDNA",
  iNaturalist: "iNaturalist",
  eBird: "eBird",
};



export const locations = {
  [PouR]: `Protecting our River is collecting eDNA from sediment and water
  samples at 12 locations along the LA River and its tributaries in three
  separate rounds.`,
  [LARWMP]: `Starting in 2007, the Los Angeles River Watershed Monitoring
  Program (LARWMP) has conducted annual assessments of the rivers and streams
  throughout the Los Angeles River watershed. LARWMP is a joint program
  supported by LA Sanitation, City of Burbank, and Los Angeles County
  Department of Public Works, and managed by the Council for Watershed Health.
  To learn more about LARWMP and view the full reports, please visit the
  <a href='https://www.watershedhealth.org/larwmp'>LARWMP</a> page on the
  Council for Watershed site.`,
};

export const benthicMacroinvertebratesAnalytes = {
  [CSCI]: null,
  [MMI]: null,
  [OE]: null,
};

export const attachedAlgaeAnalytes = {
  [D18]: null,
  [S2]: null,
  [H2O]: null,
};

export const riparianHabitatScoreAnalytes = {
  [CRAM]: null,
  [BioticStructure]: null,
  [Buffer]: null,
  [Hydrology]: null,
  [PhysicalStructure]: null,
};

export const inSituMeasurementsAnalytes = {
  [Temperature]: null,
  [Oxygen]: null,
  [pH]: null,
  [Salinity]: null,
  [SpecificConductivity]: null,
};

export const generalChemistryAnalytes = {
  [Alkalinity]: null,
  [Hardness]: null,
  [Chloride]: null,
  [Sulfate]: null,
  [TSS]: null,
};

export const nutrientsAnalytes = {
  [Ammonia]: null,
  [Nitrate]: null,
  [Nitrite]: null,
  [NitrateNitrite]: null,
  [NitrogenTotal]: null,
  [NitrogenTotalKjeldahl]: null,
  [OrthoPhosphate]: null,
  [Phosphorus]: null,
  [DissolvedOrganicCarbon]: null,
  [TotalOrganicCarbon]: null,
};

export const algalBiomassAnalytes = {
  [AFDM]: null,
  [Chla]: null,
};

export const dissolvedMetalsAnalytes = {
  [Arsenic]: null,
  [Cadmium]: null,
  [Chromium]: null,
  [Copper]: null,
  [Iron]: null,
  [Lead]: null,
  [Mercury]: null,
  [Nickel]: null,
  [Selenium]: null,
  [Zinc]: null,
};

export const physicalHabitatAssessmentsAnalytes = {
  [Eroded]: null,
  [Stable]: null,
  [Vulnerable]: null,
  [FastWater]: null,
  [SlowWater]: null,
  [ChannelAlteration]: null,
  [EpifaunalSubstrate]: null,
  [SedimentDeposition]: null,
  [MeanSlope]: null,
  [Discharge]: null,
  [WettedWidth]: null,
  [MicroalgaeThickness]: null,
  [Macrophytes]: null,
  [Macroalgae]: null,
  [Cover]: null,
  [CPOM]: null,
  [SandFines]: null,
  [ConcreteAsphalt]: null,
  [CobbleGravel]: null,
};

export const analyteCategories = {
  [BenthicMacroinvertebrates]: null,
  [AttachedAlgae]: null,
  [RiparianHabitatScore]: null,
  [AlgalBiomass]: null,
  [InSituMeasurements]: null,
  [GeneralChemistry]: null,
  [Nutrients]: null,
  [DissolvedMetals]: null,
  [PhysicalHabitatAssessments]: null,
}

export const allAnalytes = {
  ...locations,
  ...benthicMacroinvertebratesAnalytes,
  ...attachedAlgaeAnalytes,
  ...riparianHabitatScoreAnalytes,
  ...inSituMeasurementsAnalytes,
  ...generalChemistryAnalytes,
  ...nutrientsAnalytes,
  ...algalBiomassAnalytes,
  ...dissolvedMetalsAnalytes,
  ...physicalHabitatAssessmentsAnalytes,
  ...analyteCategories
}


