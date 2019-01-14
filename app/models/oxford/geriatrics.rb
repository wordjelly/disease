class Oxford::Geriatrics < Oxford::Oxford

	EXCLUSIONS = ["part","chapter","introduction","treatment","investigations","history","diagnosis","management","causes","pathophysiology","clinical","assessment","features","imaging","epidemiology","diagnostic","procedures","overview","background","complications","anatomy","physiology","indications","contraindications","terminology","symptoms"]

	def topics
		["The ageing person","Theories of ageing","Demographics: life expectancy","Demographics: population age structure","Demographics: ageing and illness","Illness in older people","Using geriatric services","Acute services for older people","The older patient in intensive care","The great integration debate","Admission avoidance schemes","Day hospitals","Specialty clinics","Intermediate care","The National Service Framework for Older People","Community hospitals","Care homes","Funding of care homes","Delayed discharge","Home care","Informal carers","Other services","Primary care","Careers in UK geriatric medicine","The GP contract was introduced in","Consultation skills","Multiple pathology and aetiology","Other sources of information","Problem lists","General physical examination","Common blood test abnormalities","Diagnosed in","The process of rehabilitation","Aims and objectives of rehabilitation","Measurement tools in rehabilitation","Measurement instruments","Selecting patients for inpatient rehabilitation","Patients unlikely to benet from rehabilitation","Physiotherapy","Walking aids","Occupational therapy","Doctors in the rehabilitation team","Nurses in the rehabilitation team","Other members of the rehabilitation team","Community nurses and health visitors","Falls and fallers","Interventions to prevent falls","Syncope and presyncope","Balance and dysequilibrium","Dizziness","example","Drop attacks","Postprandial hypotension","Carotid sinus syndrome","Falls clinics","Pharmacology in older patients","Prescribing rules","Drug sensitivity","Adverse drug reactions","ACE inhibitors","Amiodarone","dysfunction","Analgesia","Steroids","Warfarin","Proton pump inhibitors","Herbal medicines","Breaking the rules","Week","The ageing brain and nervous system","Tremor","Parkinsons disease: presentation","who cannot take oral medication","Parkinsons disease","Diseases masquerading as Parkinsons disease","Epilepsy","Neuroleptic malignant syndrome","Motor neuron disease","Peripheral neuropathies","Subdural haematoma","Sleep and insomnia","Other sleep disorders","Denition and classication","Predisposing factors","Stroke units","Thrombolysis","Transient ischaemic attack clinics","Cognitive ageing","Impairments in cognitive function without dementia","Dementia: common diseases","Dementia and parkinsonism","Normal pressure hydrocephalus","Dementia: less common diseases","Dementia: prevention","Dementia: acetylcholinesterase inhibitors","Dementia: managing behavioural problems","Psychosis","Confusion and alcohol","Squalor syndrome","Depression: presentation","pseudodementia","Suicide and attempted suicide","The ageing cardiovascular system","Chest pain","Stable angina","Acute coronary syndromes","Myocardial infarction","Hypertension","comorbid conditions","Arrhythmia: presentation","Atrial brillation","Atrial brillation: stroke prevention","Bradycardia and conduction disorders","Common arrhythmias and conduction abnormalities","failure","Acute heart failure","Chronic heart failure","Dilemmas in heart failure","Diastolic heart failure","Valvular heart disease","Peripheral oedema","Preventing venous thromboembolism in an older person","Peripheral vascular disease","Gangrene in peripheral vascular disease","Vascular secondary prevention","The ageing lung","Respiratory infections","Inuenza","Pneumonia","Vaccinating against pneumonia and inuenza","Pulmonary brosis","Rib fractures","Pleural effusions","Pulmonary embolism","Chronic cough","Lung cancers","Tuberculosis: presentation","Tuberculosis: investigation","skin test","Oxygen therapy","The ageing gastrointestinal system","The elderly mouth","Nutrition","Enteral feeding","Oesophageal disease","Dysphagia","Peptic ulcer disease","nausea and vomiting","The liver and gallbladder","function tests","Constipation","Diverticular disease","Inammatory bowel disease","Diarrhoea in older patients","Other colonic conditions","The acute surgical abdomen","Obstructed bowel in older patients","Obesity in older people","population so many screening programmes stop at age","The ageing kidney","Acute kidney injury","Chronic kidney disease","Renal replacement therapy: dialysis","Renal replacement therapy: transplantation","Nephrotic syndrome","Glomerulonephritis","Renal artery stenosis","Volume depletion and dehydration","Hypernatraemia","The ageing endocrine system","Diabetes mellitus","care homes","Diabetic emergencies","ill patient","Hyperthyroidism: investigation","Primary adrenal insufciency","Hormone replacement therapy and the menopause","The ageing haematopoietic system","Investigating anaemia in older people","Macrocytic anaemia","Anaemia of chronic disease","Paraproteinaemias","Multiple myeloma","Myelodysplasia and myelodysplastic syndrome","Chronic lymphocytic leukaemia","concentration gradually declines from age","High ESRusually above","Osteoarthritis","Osteoporosis","Polymyalgia rheumatica","Giant cell arteritis","arteritis","Pagets disease","Gout","Pseudogout","Contractures","Cervical spondylosis and myelopathy","Osteomyelitis","The elderly foot","The elderly hand","The painful hip","The painful back","The painful shoulder","Pressure sores","Compression mononeuropathy","Rhabdomyolysis","The ageing genitourinary system","Benign prostatic hyperplasia: presentation","Prostatic cancer: presentation","Postmenopausal vaginal bleeding","Vaginal prolapse","Prolapse: illustrations","Vulval disorders","Sexual function","HIV in older people","Catheters","a catheter","Deafness and the ageing ear","Audiology","Hearing aids","Tinnitus","Vertigo","Usually detectable from age","The ageing eye","Visual impairment","Blind registration","Visual hallucinations","Cataract","Glaucoma","macular pathology","The eye and systemic disease","Drugs and the eye","Eyelid disorders","The ageing skin","Photoageing","Cellulitis","Other bacterial skin infections","Fungal skin infections","Chronic venous insufciency","Leg ulcers","Pruritus","Pruritic conditions","Blistering diseases","Other skin lesions","The ageing immune system","patient","Antibiotic use in older patients","Disease caused by MRSA","culture","Asymptomatic bacteriuria","Urinary tract infection","Recurrent urinary tract infection","Varicella zoster infection","Malignancy in older people","An approach to malignancy","Presentation of malignancy","Treating malignancy in older people","Cancer with an unknown primary","Breaking bad news","Bereavement","Palliative care","Symptom control in the terminally ill","palliative care","Documentation after death","Other issues after death","The coroner","Capacity","Deprivation of Liberty Safeguards","Making nancial decisions","Making medical decisions","Making social decisions","home against advice","Advance directives","applicable","without hope","Making complex decisions","Cardiopulmonary resuscitation","The process of CPR decision making","Rationing and ageism","Elder abuse","Capacity Act","The Mental Capacity Act","This was introduced in the Mental Incapacity Act in April","Making a will","Taxation","Pensions","Benets","Free prescriptions for all over the age of","Dermatomes","Geriatric Depression Scale","Barthel Index","The abbreviated mental test score","Glasgow Coma Scale","War","Count from","Step","Score"]
	end

	def self.get_contents(allergy_book_file_path_and_name,contents_file_path_and_name)
		titles = []
		## first manage the character conversion to utf 8.
		s = IO.read(allergy_book_file_path_and_name)
		s.force_encoding('UTF-8')
		s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
		s.split(/\r|\n|\t/).each do |line|
			
			line.scan(/^(?<title>[A-Za-z\s\:]+)\s\d+$/) do |title|
				unless EXCLUSIONS.include? title[0].strip.downcase
					unless EXCLUSIONS.select{|c| title[0].strip.downcase =~ /#{c}/i}.size > 0
						titles << title
					end
				end
			end
		end
		titles = titles.flatten.uniq.compact.map{|c| c.gsub(/\d+/,'').strip}
		puts titles.size
		IO.write(contents_file_path_and_name,JSON.generate(titles))
	end

	## here we have only a title processor, we don't go for subsections.
	def title_processor(line)
		section_name = nil
		
		line.strip.scan(/^(?<title>[A-Za-z\s\:]+)$/) do |title|

			applicable_topics = topics.select{|c| title[0].strip == c}

			if applicable_topics.size > 0
				return ["on",clear_numbers_newlines_and_excess_spaces(title[0])]
			else
				return ["off",title[0]]
			end
		end
		return ["off",line]
	end

end