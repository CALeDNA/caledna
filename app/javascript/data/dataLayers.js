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
export const LARWMP = "Los Angeles River Watershed Monitoring Program (2019)";
export const BenthicMacroinvertebrates = "Benthic Macroinvertebrates";
export const AttachedAlgae = "Attached Algae (So CA IBI)";
export const RiparianHabitatScore = "Riparian Habitat Score (CRAM)";
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
  [CSCI]: "California Stream Condition Index (CSCI): a biological scoring tool that measures how healthy a stream is based on what benthic macroinvertebrates are present. Uses MMI and O/E indices.",
  [MMI]: "Multi-metric index (MMI): measures ecological structure and function. Values that fall within expected range imply high biological integrity, while values lower than observed suggest biological degradation.",
  [OE]: "Observed-to-expected index (O/E): measures taxonomic completeness by looking at the ratio of predicted taxa to those observed. Values near 1 imply high biological integrity while values below 1 suggest biological degradation.",
};

export const attachedAlgaeAnalytes = {
  [D18]: "Aiatom-only algal IBI measuring stress.",
  [S2]: "Soft-algae only IBI measuring stress.",
  [H2O]: "Scores for attached algae.",
};

export const riparianHabitatScoreAnalytes = {
  [CRAM]: "California Rapid Assessment Methods (CRAM): developed by USEPA and modified by SWAMP to use in California, assesses wetland conditions of buffer and landscape, hydrologic connectivity, physical structure, and biotic structure. The greater the CRAM score, the better the biotic, physical, hydrologic, and buffer zone condition of the habitat. Scores are often used as a surrogate for abiotic stress.",
  [BioticStructure]: "The way organisms interact within an ecosystem, commonly described as producers, consumers, and decomposers.",
  [Buffer]: "Describes the transitional change in habitat from the river to its surroundings.",
  [Hydrology]: "The flow of the river.",
  [PhysicalStructure]: "The non-living components that make up the river.",
};

export const inSituMeasurementsAnalytes = {
  [Temperature]: "The temperature of the site in Celsius.",
  [Oxygen]: "The amount of oxygen present in the water.",
  [pH]: "Expresses the relative acidity or alkalinity of a solution. A value closer to 0 is acidic, a value closer to 14 is more alkaline, while 7 is neutral.",
  [Salinity]: "The amount of dissolved salts present in the water, measured in parts per thousand (ppt). In seawater, the predominant ions are sodium and chloride (NaCl or salt).",
  [SpecificConductivity]: "An indirect measure of the concentration of dissolved ions in a solution measured in microsiemens per centimeter.",
};

export const generalChemistryAnalytes = {
  [Alkalinity]: "Measures the acid neutralizing capacity using calcium carbonite (CaCO3), with anthropogenic sources from agricultural runoff and other landscapes where 'lime' has been applied.",
  [Hardness]: "Measures the amount of calcium carbonate (CaCO3) present in the water. High levels of CaCO3 can cause mineral buildup in plumbing, water heaters, and fixtures.",
  [Chloride]: "A major component of dissolved solids, high levels can negatively impact vegetation and some forms of aquatic life.",
  [Sulfate]: "A component of dissolved solids, high concentrations can lead to toxic environments for wildlife and vegetation, bioaccomulation of toxic metals, and enhance biodegradation of organic soils.",
  [TSS]: "Total suspended solids (TSS): the dry-weight of suspended non-dissolved particles, listed as a conventional pollutant in the US Clean Water Act.",
};

export const nutrientsAnalytes = {
  [Ammonia]: "A common and natural biological degradation product from protein, but in high levels can be toxic for aquatic life.",
  [Nitrate]: "A common and natural byproduct of biogeochemical cycles, anthropogenic sources include fertilizer runoff and burning of fossil fuels. In high levels can be toxic to aquatic life.",
  [Nitrite]: "A common and natural byproduct of biological degradation, high levels can negatively impact aquatic life.",
  [NitrateNitrite]: null,
  [NitrogenTotal]: "The sum total of reactive nitrogen including ammonia, nitrate, and nitrite.",
  [NitrogenTotalKjeldahl]: "The total concentration of organic nonreactive nitrogen, ammonia, and ammonium. This measurement is a required parameter at treatment plants.",
  [OrthoPhosphate]: "Formed by natural processes, has beneficial uses to humans but in high quantities can cause rapid algal growth and impact aquatic life.",
  [Phosphorus]: "The sum total of reactive phosphorus including orthophosphate.",
  [DissolvedOrganicCarbon]: "Organic matter that can pass through a filter (~0.7 - 0.22 um) and acts as primary food sources for aquatic food webs.",
  [TotalOrganicCarbon]: "The sum total of organic carbon including dissolved organic carbon and particulate organic carbon.",
};

export const algalBiomassAnalytes = {
  [AFDM]: "Ash free dry mass (AFDM): the portion, by mass, of a dried sample represented by organic matter, often used as a surrogate for algal biomass.",
  [Chla]: "Chlorophyll-a (Chl-a): the photosynthetic material in plants; measured to estimate how much algae is present.",
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
  [Eroded]: "Worn down riverine habitat from the presence and flow of water.",
  [Stable]: "River banks that have not been worn down from the river's movement.",
  [Vulnerable]: "Areas that are susceptible to being worn down from the river's flow.",
  [FastWater]: "A quicker flow of water that can move larger particles of sediment.",
  [SlowWater]: "A steadier flow of water that can move small-grained sediment.",
  [ChannelAlteration]: "The amount the river/its flow have been modified such as in depth or width.",
  [EpifaunalSubstrate]: "Structures on the streambed where wildlife can live including cobbles, boulders, logs, and the crevices within each.",
  [SedimentDeposition]: "Soil disturbance that forms islands, point bars, and pools of a variety of sediment sizes such as sand and gravel.",
  [MeanSlope]: "The average incline of the sections and lengths of the river that are being sampled.",
  [Discharge]: "The volume of water flowing through a river channel.",
  [WettedWidth]: "The surface of the channel bottom and sides in contact with the water, highly variable on flow stage of river.",
  [MicroalgaeThickness]: "The depth of microscopic algae growing on the surface of the river.",
  [Macrophytes]: "Aquatic plants that are large enough to be seen with the naked eye.",
  [Macroalgae]: "Algae that are large enough to be seen with the naked eye.",
  [Cover]: "The amount that encompasses the ground as measured by a densiometer: a handheld compass-shaped device used to estimate the percent cover of a given site.",
  [CPOM]: "Coarse particulate organic matter (CPOM): any organic particle larger than 1mm in size.",
  [SandFines]: "Small-grained sediment particles accumulated on the stream bottom.",
  [ConcreteAsphalt]: "A combination of hard-packed gravel and sand that lines a large portion of the LA River.",
  [CobbleGravel]: "Larger sized sediment particles that can accumulate on the stream bottom.",
};

export const analyteCategories = {
  [BenthicMacroinvertebrates]: "Bentic Macroinvertebrates (BMIs): small animals that live along bodies of water, aquatic plants, stones, and logs that are visible with the naked eye (macro) and have no backbone (invertebrate).",
  [AttachedAlgae]: "Southern California Algal Index of Biotic Integrity (So Ca IBI): a multi-metric index measuring attached algae to understand stream community response to stress. Attached algae are collected from aquatic substrates such as logs and rocks.",
  [RiparianHabitatScore]: "An indication of riparian health using the California Rapid Assessment Method (CRAM).",
  [AlgalBiomass]: null,
  [InSituMeasurements]: "Measurements taken at a specific time; not estimates or hypothesized.",
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


