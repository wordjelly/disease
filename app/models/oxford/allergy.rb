class Oxford::Allergy < Oxford::Oxford
	def self.get_allergy_contents(allergy_book_file_path_and_name,contents_file_path_and_name)
		titles = []
		## first manage the character conversion to utf 8.
		s = IO.read(allergy_book_file_path_and_name)
		s.force_encoding('UTF-8')
		s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
		s.split(/\r|\n|\t/).each do |line|
			
			line.strip.scan(/^(?<title>[A-Z][a-z][0-9A-Za-z\)\(\-\,\:\s]*)\s+\d+/) do |title|
				
				titles << title
			end
		end
		IO.write(contents_file_path_and_name,JSON.generate(titles.flatten.uniq.compact.map{|c| c.gsub(/\d+/,'').strip}))
	end

	def topics
		["Part","Introduction","Classication of immunodeciency","Clinical features of immunodeciency","Investigation of immunodeciency","Laboratory investigation","Major B-lymphocyte disorders","Rare antibody deciency syndromes","Common variable immunodeciency (CVID)","Selective IgA deciency","IgG subclass deciency","Autosomal hyper-IgM syndromes","Transient hypogammaglobulinaemia of infancy (THI)","Hyper-IgE syndrome (Jobs syndrome)","Severe combined immunodeciency (SCID)","Artemis deciency","Chapter","Disorders with predominant T-cell disorder","DiGeorge (q deletion complex) syndrome","Ataxia telangiectasia","Other chromosomal instability disorders","Chronic mucocutaneous candidiasis (CMC) syndromes","Canale-Smith syndrome)","Cartilage-hair hypoplasia (CHH) syndrome","Mendelian susceptibility to mycobacterial disease (MSMD)","Toll-like receptor (TLR) defects","Phagocytic cell defects","Chronic granulomatous disease","Other phagocytic cell defects","Cyclic neutropenia","Other neutrophil defects","Disorders of pigmentation and immune deciency","Immunodeciency in association with other rare syndromes","Immunodeciency with generalized growth retardation","Skin disease and immunodeciency","Immunodeciency with metabolic abnormalities","Hypercatabolism of immunoglobulin","Splenic disorders","Complement deciencies","Hereditary angioedema and C-binding protein deciency","Miscellaneous host defence disorders","Websites","Secondary (see Chapter","Two major or one major and recurrent minor in","Neonatal tetany:","Mental retardation:","Measurement of specic components and receptors (see Chapter","Usually early in childhood, after","Prompt antibiotic therapy (course of","Prophylactic azithromycin","Abnormalities of","In immunization programmes for hepatitis B, about","Children under the age of","First step should be prophylactic antibiotics (azithromycin","Overall mortality was","Survival is only","Overall survival is now","Survival after HSCT with good immune reconstitution is","Type","It may last up to","This accounts for","Accounts for","Gene is located at","Mutations in the ADA gene on chromosome","Disease is rare (about","Presentation is usually early (rst","Actin-regulating protein coronin","Coronin  (COROA,","Dedicator of cytokinesis","Microdeletions at","Other mutations, including","Hypocalcaemic tetany, often occurring in rst","Patients with an identied","Gene therapy is undergoing clinical trials, and","Ataxia-ocular apraxia type","Gene has been identied on chromosome","Gene located at","Caused by abnormalities of chromosomes , , and","Occurs in","Fas (TNFRSF, CD, APO-), chromosome","Caspase  and Caspase","Abnormal apoptosis assays (see Chapter","Autosomal recessive and linked to chromosome","Carrier frequency is  in","Deciency of CXCR chemokine receptor for stromal-derived factor","Interferon regulatory factor  (IRF,","Glucose","Neutrophil oxidative metabolism is abnormal (see Part","The gene is located at","This deciency is not uncommon (the gene is located at","The prevalence is between  in  and  in","The cycle is usually","Symptoms usually occur if the count drops below","Hermansky-Pudlak syndrome type","Hermansky-Pudlak syndrome, types  and","One family showed linkage to a region of chromosome","This is due to trisomy","Chromosome","Ring chromosome  and deletions of the long and short arms of chromosome","Caused by deletions on chromosome","Rare autosmosomal recessive skin disorder with high susceptibility to papillomavirus infection (typically HPV types  and","Prophylactic penicillin (phenoxymethylpenicillin (penicillin V)","It has been estimated that up to","Subcutaneous treatment with","Prophylaxis may be obtained with modied androgens (danazol","See Chapter","Classication of secondary immunodeciency","Human immunodeciency virus  and","Epstein-Barr virus","Other viral infections","Acute bacterial infections","Chronic bacterial sepsis","Bronchiectasis","Fungal and parasitic infections","Malignancy","Myeloma","Lymphoma: Hodgkins disease","Non-Hodgkins lymphoma","Chronic lymphocytic leukaemia (CLL)","Acute leukaemias","Bone marrow and stem cell transplantation","Extremes of age: prematurity","Extremes of age: the elderly","Transfusion therapy","Chronic renal disease (nephrotic syndrome and uraemia)","Protein-losing enteropathy and liver disease (cirrhosis)","Metabolic disorders","Diabetes mellitus","Iron deciency and nutritional status","Asplenia","Drugs and toxins","Burns","Thoracic duct drainage","Cardiac surgery in children","Physical and environmental factors","Proteus syndrome","Yellow nail syndrome","Cilial dyskinesia (Kartageners syndrome)","Youngs syndrome","Cystic brosis (CF)","Alpha--antitrypsin deciency (A-AT deciency)","Amyloidosis (see Chapter","Human immunodeciency virus  and","May be seen in immune deciencies (see Chapter","Irritant agents such as","See Table","Prophylactic azithromycin, -mg","Table","Found in","IgG, IgA paraproteins account for","Acquired angioedema (AAE) (see Chapter","Chromosomal abnormalities are common: trisomy","Monthly treatment is usually adequate (dose","Following birth, infants are dependent for the rst","Lymphocytes may be viable for up to","Risk appears to be lifelong and is not limited to the rst","In addition to the drugs discussed in Chapter","Loss of the circulating lymphocyte pool occurs within","Associated with bronchiectasis in","Genetics complex:","Anaphylaxis","Management of anaphylaxis","Anaphylactoid reactions","Angioedema","Urticaria","Urticaria : treatment","Urticarial vasculitis","Mastocytosis","Histamine intolerance","Asthma","Asthma : treatment","Sulphite sensitivity","Aspirin sensitivity","Allergic rhinitis","Allergic conjunctivitis","Sinusitis","Secretory otitis media (glue ear)","Atopic eczema (dermatitis)","Contact dermatitis (hypersensitivity)","Itch (pruritus)","Food allergy","Food allergy","Contact allergy to food","Oral allergy syndrome","Latex allergy","Drug allergy : penicillin, other antibiotics, and insulin","Drug allergy","Vaccine reactions","Venom allergy","Extrinsic allergic alveolitis (EAA)","Allergic bronchopulmonary aspergillosis (ABPA)","Other pulmonary eosinophilic syndromes","Allergic renal disease","Hyper-eosinophilic syndromes (HES)","Allergic diseases are common: it has been estimated that","Not all symptoms will be present during an attack and only","Reactions may recur after","Immunological diagnosis (see Box","Box","Antihistamine should be given intravenously (chlorphenamine","Desensitization is possible (see Chapter","Anapen is available in a","Hereditary C-esterase inhibitor or CBP deciency (see Chapter","Diagnosis (see Box","Differential is wide (see Table","Control may be helped with antibrinolytics (tranexamic acid,","Angioedema associated with cyclic weight gain (up to","Urticaria","Urticaria is common, affecting","Urticaria may be acute or chronic (duration more than","Other diagnostic tests (see Box","The condition is discussed in more detail in Chapter","Exclude carcinoid by measurement of","Reduced DAO may be seen in association with drugs (see Box","Asthma","The loci involved are controversial, with loci on chromosome","This should be supplemented by patch testing (see Part","The use of recombinant allergens (see Table","Knowledge of the cross-reacting families is helful (see Table","Current specic IgE tests (RAST) identify only","Recombinant allergens are now available (see Box","Penicillin allergy is very common, perhaps occurring in up to","Up to","Guidance on testing is detailed in Chapter","Mortality up to","Risk of severe reactions returns to baseline anyway over","About","Causes are numerous (see Table","Classication of autoimmune thyroid disease","Graves disease","Hashimotos thyroiditis","Subacute thyroiditis syndromes","Primary hypothyroidism and sporadic goitre","Thyroid disease and other symptoms","Classication of diabetes mellitus","Type I diabetes (insulin-dependent)","Immunological complications of insulin therapy","Classication of adrenal insufciency","Addisons disease","Type II APS (Schmidts syndrome) and type III APS","Cushings syndrome","Pernicious anaemia","Pituitary autoimmunity","Parathyroid autoimmunity","Vitiligo and alopecia","Antibodies to thyroid peroxidase (present in","Anti-thyroid peroxidase antibodies will be present in","Post-partum thyroiditis usually occurs within","Twin concordance for IDDM is only","Major susceptibility gene is in HLA region, accounting for","At least","Primary target in type Ia diabetes appears to be the","Insulinoma-associated protein","Antibodies are present in","Heat-shock protein","As noted in Chapter","Oral antihistamines and the inclusion of","Autoantibodies to OH,","Peak age of onset is","The presence of antibodies to","Progression to overt pernicious anaemia may span","Intrinsic factor antibodies are found in approximately","Affects","Steroid cell antibodies are directed at","Another target enzyme appears to be","The target antigens are","Steroid-cell antibodies are found in","Infertile women may have anti-oocyte antibodies (approximately","Myasthenia gravis (MG)","Lambert-Eaton myasthenic syndrome (LEMS)","Morvans syndrome","Rasmussen encephalitis","Paraneoplastic autoimmune neurological syndromes","Demyelinating diseases : multiple sclerosis (MS)","Demyelinating diseases","Vasculitic neuropathy and Degoss disease","Neuropathy associated with Sjgrens syndrome (SS)","Autoimmune encephalopathies","Primary angiitis of the central nervous system (PACNS)","Prevalence is","IgG anti-ACh-receptor (AChRAb) is detected in","In approximately","Purkinje cells and recognizing two antigens of molecular weights","It affects any age, but predominantly the young, and has a","Monozygotic twin concordance is only","Natalizumab (Tysabri) is an MAb against","Demyelination may progress for up to","Antibodies to GQb are present in","Autoantibodies to aquaporin","Investigation should follow the guidance in Chapter","Cardiac disease : myocarditis and cardiomyopathy","Cardiac disease : eosinophilic syndromes","Cardiac disease","Cardiac disease : rheumatic fever","Respiratory disease","Respiratory disease : eosinophilic lung syndromes","Respiratory disease : other respiratory diseases","Renal disease : glomerulonephritisan overview","Renal disease : necrotizing crescentic glomerulonephritis","Renal disease : immune complex glomerulonephritis","Renal disease","Renal disease : Idiopathic membranous nephropathy","Anti-cardiac antibodies are also found in","This is (myo-)pericarditis occurring","RhF is found in","Investigations (see Box","Normally, the C level will return to normal within","Male:female ratio is","Autoantibody may be","Autoimmune enteropathy","Achalasia","Eosinophilic gastroenteritis (including oesophagitis)","Crohns disease","Ulcerative colitis (UC)","Whipples disease","Coeliac disease","Sclerosing mesenteritis","Autoimmune pancreatitis","Irritable bowel syndrome (IBS)","Association with hypereosinophilic syndromes (see Chapter","Strong association with NOD- (CARD) gene on chromosome","Over","Treatment is with steroids, azathioprine,","Also associated with allele","Particularly common in western Ireland (prevalence  in","In the UK occurs in  in","Primary biliary cirrhosis (PBC)","Autoimmune hepatitis","Primary sclerosing cholangitis","Primary antigen is the large multimeric","Autoimmune hepatitis type","In AIH-,","Strongly associated with inammatory bowel disease (see Chapter","Immune thrombocytopenia (ITP)","Autoimmune haemolytic anaemia","Autoimmune neutropenia","Paroxysmal nocturnal haemoglobinuria (PNH)","Aplastic anaemia (AA) and pure red cell aplasia","Anti-factor VIII antibodies (acquired haemophilia)","Heparin-induced thrombocytopenia (HIT)","Anti-phospholipid syndrome (Hughes syndrome)","Overview","Bullous pemphigoid","Herpes gestationis and cicatricial pemphigoid","Pemphigus vulgaris","Pemphigus foliaceus","Paraneoplastic pemphigus","Epidermolysis bullosa acquisita","Dermatitis herpetiformis (DH) and linear IgA disease","Erythema multiforme (EM)","Sweets syndrome (acute febrile neutrophilic dermatosis)","Lichen planus (LP)","Alopecia areata","Vitiligo","Psoriasis","Website","Rate of positivity in DIF is up to","Autoantigen is the","Autoantigen is now known to be a","Autoantigen is different from that in PV and is a","Multiple susceptibility genes (at least","Uveitis","Tubulointerstitial nephritis and uveitis (TINU)","Vogt-Koyanagi-Harada disease (VKH)","Cancer-associated retinopathy and uveitis","Birdshot retinopathy","Scleritis","Ocular cicatricial pemphigoid","Sympathetic ophthalmitis","Idiopathic orbital inammation (orbital pseudo-tumour)","Investigation (see Box","Patients require regular monitoring of therapy (see Chapter","Autoantibodies to a","Juvenile chronic arthritis (JCA) and Stills disease","Adult Stills disease","Psoriatic arthritis","Reactive arthritis (including Reiters syndrome)","Systemic lupus erythematosus (SLE) and variants","Drug-related lupus (DRL)","Sjgrens syndrome","IgG-related chronic sclerosing dacryoadenitis","Undifferentiated connective tissue disease","Mixed connective tissue disease (MCTD)","Overlap syndromes","Systemic sclerosis (SSc): CREST and limited variants","Scleroderma mimics","Eosinophilic fasciitis (Shulmans syndrome)","Anti-phospholipid syndrome (APS)","Raynauds phenomenon","Livedo reticularis","Rheumatic fever","Fibromyalgia","Immunological tests (see Box","Rheumatoid factors (RhF) are found in","Rheumatoid factors are not diagnostic tests for RhA (see Part","Disease-modifying anti-rheumatic drugs (DMARDs) (see Chapter","European guidance suggests that three positive tests over a","Usual age of onset is - years, with a","Antibodies to retinal S-antigen may also be found (in","More than","Peripheral arthritis is seen in","Clinical features (see Table","Complete heart block occurs in the children of  in","It is worth rechecking full serology every so often (every","As the half-life of antibodies is about","Immunological testing (see Box","RhF will be found in","Interval measurement of ENA antibodies is helpful (every","Trigeminal neuropathy may occur in","RhF is positive in","Autoantibodies have been detected against brillin","Anti-nucleolar antibodies are common (see Box","Scl- (topoisomerase I)","Arthritis in","Symptomatic patients should be warfarinized for life with INR","Steroids may be used in carditis (prednisolone","Long-term prophylactic penicillin V mg bd for at least","Causes of vasculitis","Diagnostic tests","Henoch-Schnlein purpura (HSP)","IgA nephropathy (Bergers disease)","Buergers disease (thromboangiitis obliterans)","Hypersensitivity (allergic) vasculitis","Microscopic polyarteritis (MPA)","Primary angiitis of the CNS (PACNS)","Behets disease","Polyarteritis nodosa (PAN)","Churg-Strauss syndrome (CSS)","Cogans syndrome","Wegeners granulomatosis","Wegeners granulomatosis : diagnosis and treatment","Lymphomatoid granulomatosis","Takayasus disease (aortic arch syndrome)","Erythema elevatum diutinum","Degoss syndrome","Erythema nodosum","Weber-Christian disease (relapsing febrile panniculitis)","Relapsing polychondritis","Cystic brosis","Infection as a trigger of vasculitis","Malignancy-associated vasculitis","Drug-related vasculitis","Cryoglobulinaemia and cryobrinogenaemia","Atrial myxoma and serum sickness","Aetiology and immunopathogenesis (see Box","Renal disease with nephritis occurs in","Fever in","Raised IgA in only","IgA antibodies to the","Amyloidosis is a long-term complication (see Chapter","Interferon-aa (-mU","It is not an uncommon disease, with a prevalence of","Mononeuritis multiplex is common (up to","Reovirus III major core protein","Characterized by a high spiking fever for more than","Wegeners granulomatosis","Major target antigen is proteinase","Approximately","Rheumatoid factors are detectable in about","Ciclosporin (up to","Female predominance of","Disease may burn out after","Drug-related vasculitis accounts for","Sjgrens syndrome is associated with vasculitis in","Mixed essential mixed cryoglobulinaemia (type II) (see Part","Some patients with glomerulonephritis have an antibody to a","It may be idiopathic or associated with malignancy (see Part","Sarcoidosis","Amyloidosis","Other acquired amyloidoses","Familial Mediterranean fever (FMF)","Hibernian fever)","Hyper-IgD syndrome","Muckle-Wells and related syndromes","Schnitzlers syndrome","Blau syndrome","Deciency of the IL- receptor antagonist (DIRA)","Xanthogranulomatosis","Kikuchis syndrome","Satoyoshi syndrome (Komura-Guerri syndrome)","Castlemans syndrome","Chronic fatigue syndrome (CFS)","Idiopathic oedema","Macrophagic myofasciitis","Burning mouth syndrome","Postural orthostatic tachycardia syndrome (POTS)","Sports immunology","Sports immunology : over-training syndrome","Depression and immune function","Immunology of infection","Immunological diseases of pregnancy","Immunological diseases of pregnancy","Macrophages are activated and release enzymes and","Raised ACE levels in about","Attacks usually begin before the age of","Typical attacks last","Colchicine in a daily dose of","Attacks last","Episodic symptoms lasting up to","Evolves into lymphoma or Waldenstrms macroglobulinaemia in","Mutations identied in CD binding protein","Chronic fatigue syndrome (CFS)","In hospital practice, up to","For","Female to male ratio","It has been estimated that there may be as many as","Fighting Fatigue (Pemberton and Berry","Most patients show signicant improvement over","Cure rate is probably","If there is no improvement by","Sports immunology","The window may last up to","Similar to that for chronic fatigue (see CFS","Stem cell transplantation (HSCT)","Gene therapy","Graft-versus-host disease (GvHD)","Acute GvHD (aGvHD)","Chronic GvHD (cGvHD)","Graft-versus-tumour (GvT) effect","Graft failure","Solid organ transplantation","Solid organ transplantation : immunology of rejection","Solid organ transplantation","Solid organ transplantation : laboratory tests","Severe combined immunodeciency (SCID): all types (see Chapter","Stem cells sourced from peripheral blood have","Matching procedures (see Chapter","Neutropenia post-BMT may last between  and","Neutropenia beyond","Complete regeneration takes up to","Thereafter numbers increase to a plateau at","Recovery of normal B-cell numbers and function will take at least","IgM normalizes by","IgG normalizes by","IgA normalizes by","Live vaccines should not be given any earlier than","In the best centres, over","Manifestations of aGvHD may occur after day","Classic chronic GvHD (cGvHD) may be present before day","Treatment is reduced to two drugs after an initial period of up to","This is a problem mainly in those transplanted under the age of","Passive immunization","Active immunization","Replacement therapy","Immune stimulation","Anti-CD agents","Photopheresis","Plasmapheresis","Immunoadsorption","Allergy interventions: drugs","Adoptive immunotherapy","This is used for treatment of primary and some secondary immune deciencies (see Table","Most manufacturers are moving to","Where there is doubt, a","Treatment should provide","Pre-treatment of the patient with antibiotics for","Start slowly and increase rate in steps every","Monitor liver function (alternate infusions, minimum every","It is administered via a syringe driver in a weekly dose of","Usual maximum tolerated dose is","Trough levels tend to run approximately","Dose is","It is administered as a subcutaneous injection of","Dose is usually","Doses of over","Low-dose steroids for RhA (prednisolone","Higher doses (up to","Azathioprine is converted in vivo to","Initial dose should not exceed","Deciency alleles for TPMT are present in  in","If it is tolerated, the dose can be increased to","Chlorambucil is used orally in doses of","Initial dose is","Ciclosporin (CyA) interacts with cyclophilin, a","Dosage for CyA depends on the circumstances, but","Tacrolimus dosage is","Sirolimus dosage is mg as a stat dose followed by","Dosage is g twice daily, increased to maximum of","Myfortic is given in a dose of","Dose is mg daily for  days, and then","Dosage is mg daily increased to","Regular monitoring (every","Starting dose for hydroxychloroquine is","Dosage is","It comprises sulphapyridine coupled to","Usual dose is up to","It inhibits the catalytic site of the","Dosage regimes range from","My own practice is to start all high-dose regimes on the","Dosage depends on batch but is usually within the range","Dose","Dose is -mg twice weekly by subcutaneous injection for","If there is no response by","Muckle-Wells syndrome, and NOMID (see Chapter","Administered monthly in a dose of","Dose is mg  hours before transplant and mg","It is administered subcutaneously every","Short course ( or","Course is repeated annually for","Peak ow should be monitored before and","All patients must stay for at least","Techniques","Amyloid proteins","Avian precipitins","Bence-Jones proteins","Caeruloplasmin","Complement allotypes","Complement factors H and I","Cryoglobulins","Cryobrinogen","Fungal precipitins","Haptoglobin","Anti-IgA antibodies","IgA subclasses and IgD","Immunoglobulins (total serum)","IgG subclasses","Immune complexes","Immunoxation","Isohaemagglutinins","Mannose-binding lectin (MBL)","Neopterin and orosomucoid","Pyroglobulins","Transferrin","Urine free light chains","Viral antibodies","Viscosity","Normal adult range:","It rises rapidly during an acute-phase response (within","The gene for A-AT is located on chromosome","In the UK, deciency alleles occur with an incidence of about","Post-immunization samples should be taken at","Some patients lose specic antibody rapidly, within","Normal range:","It has a molecular weight of","Levels below","Indications for testing (see Table","Type I (common,","Type II (rare,","Normal range, adults","Normal range, adults:","The temperature of the hand is approximately","Interpretation (see Table","IgG,","Patients with chronic mucocutaneous candidiasis (Chapter","Risk of adverse reactions in IgA-decient individuals is estimated at","IgA,","IgM (males),","IgM (females),","IgG,","IgG,","IgG,","IgG,","Titres are very low in small infants aged under","Random urine is usually satisfactory, but a","The correction is to multiply the nephelometric result by","Techniques: overview","Particle agglutination assays","Immunoprecipitation assays","Indirect immunouorescence","Direct immunouorescence","Radio-immunoassay (RIA)","Immunoblotting","Actin antibodies","Amphiphysin antibodies","Aquaporin antibodies","Auerbachs plexus antibodies","Cardiac antibodies","Cartilage antibodies","Centriole antibodies","Cold agglutinins","Endomysial antibodies (EMA)","Endothelial antibodies","Erythrocyte antibodies","Ganglioside antibodies","Gliadin antibodies (AGA)","Gut (enterocyte) antibodies","Heterophile antibodies","Histone antibodies","Hsp- antibodies","Hu antibodies","Inner ear antibodies","Insulin antibodies (IAA)","Intrinsic factor antibodies","Islet cell antibodies (ICA)","Ki and Ku antibodies","La (SS-B) antibodies","Ma antibodies","Mi- antibodies","Mitochondrial M antibodies","MuSK antibodies","Multiple nuclear dot antibody","Nephritic factors","Neutrophil antibodies","Nuclear antibodies (ANA)","Nuclear matrix antibodies","Nuclear pore antibodies","Nucleolar antibodies","Ovarian antibodies","Parathyroid antibodies","Pituitary gland antibodies","Platelet antibodies","Purkinje cell antibodies","Recoverin antibodies","Reticulin antibodies","Rheumatoid factor (RhF)","Ri antibodies","Ro (SS-A) antibodies","Salivary gland antibodies","Scl- antibodies","Sm (Smith) antibodies","Sperm antibodies","Steroid cell antibodies","Striated muscle antibodies","Thyroglobulin antibodies","Thyroid orbital antibodies","Tr antibodies","Vimentin antibodies","Yo antibodies","Zic antibodies","They will usually disappear after","The process is slow and may take up to","Ratio of uorescein molecule to protein needs to be between","Levels above","Levels of","In ocular myasthenia, about","Antibodies persist in","IgG antibodies to aquaporin","Antigens are , , and","Associated with small cell lung cancer (SCLC) in","Specicity for RhA is said to be","Antibodies to cytokeratin","Because the antibodies have a circulating half-life of","Where a high-titre speckled ANA is seen but the","IgA-EMA will be positive in","IgA deciency increases risk of coeliac disease","On DIF up to","On IIF of serum only","IgG deposition is seen on DIF in only","Also seen in SLE (up to","Antibodies to the","Antibodies recognize a","Prevalence in rst-degree relatives is","Ki antibodies recognize a","Occur in","Ku antibodies recognize  and","Antibodies to the ENA La recognize a","Conrm with immunoblot against","Patients with type","Specicity for PBC approaches","Nsp-: pattern of","Nsp-: pattern of - dots (up to","These antibodies react with a","Proteinase","Topoisomerase","Cytokeratin","Antibodies to a","Nor-, a","To, a kDa protein complexed to S or","Antibodies to","Antigen is a","It is seen in about","Antibodies recognize a cytoplasmic","Target antigen appears to be a complex of","These antibodies to the","They react with a","IgA-R-reticulin antibodies are reported to have a specicity of","Antibodies recognize kDa and","Antibodies to the ENA antigen Ro recognize two proteins of","The antigen is a","High-titre SMA antibodies against F-actin are seen in type","Predominant marker for type","May be the only autoantibody in up to","Present in","These antibodies occur in up to","Allergen-specic IgE","Allergen-specic IgG antibodies","Basophil activation test","Challenge tests","Drug allergy testing","Eosinophil cationic protein (ECP)","Eosinophil count","Flow-CAST and CAST-ELISA","Histamine-release assays","Immunoglobulin E (total IgE)","IgG to food allergens","Mast-cell tryptase","Omalizumab monitoring by basophil-bound IgE","Patch testing","Thromboxanes and prostaglandins","Unvalidated tests","Urinary methyl histamine","Venom-specic IgE and IgG","The techniques used for allergy diagnosis in vitro are those already discussed in Chapters  and","The important clinical implication is that the detection of a grade","Reduction of","If a","Late reactions may occur","Steps are: food on lip (may be omitted),","Over the course of the challenge,","Over the period of the challenge,","Units: cells","Children","Buckleys syndrome) where levels frequently exceed","Serum, preferably on several occasions within a","Levels may be signicantly raised for","By","Chambers are left in place for","The sites should be re-read at","False-positive reactions at","Duplicates of each allergen are applied, and after","Grades","Short-acting antihistamines should be stopped at least","Long-acting antihistamines should be stopped for at least","Tests are read at","Positive control should give a response of at least","Positive test results require that it is at least","Flow cytometry","Tissue culture","Proliferation assays","Immunohistology","Cytokine, chemokine, soluble protein assays","Apoptosis assays","Adhesion markers","Bronchoalveolar lavage (BAL) studies","Complement membrane regulatory factors","Cytokine and cytokine receptor measurement","Cytotoxic T cells","Genetic and protein studies","Leukaemia phenotyping","Lymphocyte subsets","Lymphoma diagnosis","Neutrophil function testing","Perforin expression","Toll-like receptors (TLRs)","There are detectors for forward and","Culture is carried out in a","Suspected leucocyte adhesion molecule deciency (see Chapter","In IPF, a neutrophilia in excess of","Investigation of suspected IPEX syndrome (see Chapter","Flow cytometry, which can detect one leukaemic cell in","Assays for bacterial antibodies are poor with CVs of","IgG, IgA, and IgM production can be measured at","At","Normally all bacteria will be killed within","Patients with FHLH due to Munc - and Syntaxin","Only","All","Mixed lymphocyte reaction (MLR)","Tissue typing: serological methods","Molecular HLA typing","Human anti-animal antibodies","Chimerism studies","Useful websites","Performing tests at","The proliferation assay takes","The KIR receptor family (killer inhibitory receptor) comprises","The relative risk of developing AS is","Structure of the NHS and the NHS plan","Clinical Pathology Accreditation (CPA)","Quality management system (QMS)","Concepts of quality assurance in the laboratory","Quality control (internal)","Quality control (external) : EQA schemes","Quality control (external) : benchmarking and CE marking","Clinical standards and audit","Health and safety","Laboratory and clinical organization","Training","Writing a business case","Applying for a consultant post","Consultant contract and private practice","In","Below the Secretary of State for Health there were","They were required to spend","These have been established (in shadow in","Established in April","However, in","New standards were introduced in April","The PAC is a single advisory committee with","The nal report is issued to the laboratory some","Re-inspection currently takes place every","An interim inspection takes place every","An analyte should be repeatedly assayed on at least","Quality control (external)","If, in a quantitative scheme,","On  April","These changes were set out by the DoH in the","From  April","Modernising pathology services, published by the DoH in February","It recognizes the key role of pathology in up to","After","Agenda for Change was rolled out nationally in December","Old Grade C scientists are mostly band  or occasionally band","All NHS trusts are required to submit annual plans outlining the organizations plans over the next","Start looking in the British Medical Journal at least","This will include","Actemra","Agenda for Change","Alzheimers disease","Fanconi","Anapen","Antova","Arcalyst","Arzerra","Avastin","Blooms syndrome","Bosatria","Brutons disease","Buergers disease","Barth syndrome","Behets disease -,","Benlysta","Bergers disease","Berinert","Commission","CellCept","Stills disease","Cimzia","Cinryze","Accreditation","Cockayne syndrome","Cohen syndrome","Cusum chart","Dariers sign","Degos syndrome ,","Health","Devics syndrome","DiGeorge syndrome","Digibind","Down syndrome","Dresslers syndrome","Dubowitz syndrome","Duncans syndrome","Dy","Enbrel","EpiPen","Epstein-Barr virus ,","IgG","Fanconi anaemia","Fc receptor","Feltys syndrome ,","Firazyr","Flow-CAST","Freunds adjuvant","Glivec","Goods syndrome","Graves disease -,","Grazax","Griscelli syndrome","Executive","Heiners syndrome","Hodgkins disease","Hughes syndrome","HuMax-CD","Humax-CD","Humira","Waldenstrm","IgA)","IgA nephropathy ,","IgD","Ilaris","Immukin","Isaacs disease","Jak- kinase deciency","Jext","Jo- antibodies","Jobs syndrome","Kawasaki syndrome","Ki antibodies","Kineret","Kostmanns syndrome","Ku antibodies","Kveim test","La antibodies","Lefers syndrome","Lfgrens syndrome","Luminex","LymphoStat-B","MabCampath","MabThera","Authority (MHRA)","Monday morning fever","Monospot","MyD deciency","Myfortic","Mylotarg","Netherton syndrome","Nezelofs syndrome","Nikolskys sign","Nulojix","Omenns syndrome","Orencia","Phadia systems","Pollinex","Rac- deciency","Reiters syndrome","Remicade","ReoPro","Revlimid","Rhucin","Ro antibodies","Ruconest","Samters triad","Satoyoshi syndrome","Schmidts syndrome","Seckel syndrome","Seemanova syndrome","Shewart chart","Shulmans syndrome","Simponi","Simulect","Sneddons syndrome","Soliris","Sp antibodies","Stelara","Sweets syndrome","Takayasus disease","Turner syndrome","Tysabri","Network (UKPIN)","Velcade","Waardenburg syndrome","Waldmanns disease","Westgard rules","Xolair","Zenapax","Yervoy","Youden chart"]
	end

	def title_processor(line)
		section_name = nil
		
		if line.strip =~ //

		end

		line.strip.scan(/^(?<title>[A-Z][a-z][A-Za-z\s\)\:\,\-\(\–\,\)0-9\+]+\n?$)/) do |title|

			applicable_topics = topics.select{|c| title[0].strip == c}

			if applicable_topics.size > 0
				#puts "got TITLE--------------"
				#puts title[0]
				return ["on",clear_numbers_newlines_and_excess_spaces(title[0])]
			else
				return ["off",title[0]]
			end
		end
		return ["off",line]
	end


	# Immunological tests
	# Diagnosis
	def diagnosis_processor(line)
		line.strip.scan(/^(Diagnosis|Immunological tests)$/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	# Aetiology and immunopathogenesis
	# Aetiology
	def aetiology_processor(line)
		line.strip.scan(/^(Aetiology and immunopathogenesis|Aetiology)$/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	# Cause
	# Causes
	def cause_processor(line)
		line.strip.scan(/^(Cause|Causes)$/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	## Clinical Features
	def clinical_features_processor(line)
		line.strip.scan(/^(Clinical Features)$/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	## Clinical Features
	def presentation_processor(line)
		line.strip.scan(/^(Presentation)$/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

	## Clinical Features
	def treatment_processor(line)
		line.strip.scan(/^(Treatment)$/) do |match|
			return ["on",line.strip]
		end
		return ["off",line.strip]
	end

end