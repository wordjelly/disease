class Oxford::Nephrology < Oxford::Oxford
		EXCLUSIONS = ["part","chapter","introduction","treatment","investigations","history","diagnosis","management","causes","pathophysiology","clinical","assessment","features","imaging","epidemiology","diagnostic","procedures","overview","background","complications","anatomy","physiology","indications","contraindications","terminology","symptoms"]

	def topics
		["X Some advocate haemodialysis for patients with stage","x","Age","Urine cytology x","Denition","Biomarkers of AKI","Prevention of AKI","AKI: recognition","AKI: priorities","Assessing AKI: urinalysis","Assessing AKI: blood tests","Assessing AKI: histology","Rhabdomyolysis","AKI in cirrhosis","Tumour lysis syndrome","AKI in the developing world","AKI in sepsis","Managing septic shock and AKI","Renal replacement therapy in AKI","RRT in AKI: modalities","RRT in AKI: prescription","RRT in AKI: anticoagulation","RRT in AKI: citrate regional anticoagulation","Article ID","Step","Prevalence of CKD","Cardiovascular disease in CKD","Pathogenesis of CKD","Progression of CKD: general","Progression of CKD: antihypertensives in CKD","Progression of CKD: miscellaneous","Advanced CKD: the uraemic syndrome","Anaemia and CKD","EPO and the kidney","Prescribing ESAs","ESAs: additional benets","ESAs: target haemoglobin","Diet and nutrition in CKD","Malnutrition in CKD","Endocrine problems in CKD","Advanced CKD care","of ESRD","Stage","Calcium","CKD stages","Clonazepam","Pergolide","Haemodialysis apparatus","Dialysate","Dialysers and membranes","Dialysis prescription and adequacy","Anticoagulation","Haemodialysis access: lines","Fluid balance on dialysis","Intradialytic hypotension","Types of PD","PD uids","Prescribing PD","Peritonitis","PD adequacy","The well PD patient","CHD:","SDHD:","INHD:","NHD:","Transplantation: benets and challenges","Transplantation outcomes","Basic transplant immunology","Compatibility: matching donor and recipient","Live donor transplantation","Immunosuppression: induction","Immunosuppression: maintenance","Perioperative care","The transplant operation","Graft dysfunction","Acute rejection","Chronic allograft dysfunction","Recurrent disease","BK virus nephropathy","Kidneypancreas transplantation","Signal","Asymptomatic patients with any of the risk factors listed should","Up to","months","Hypertension facts and gures","Pathogenesis: general","Pathogenesis: RAS and other factors","BP measurement","Lifestyle measures","Secondary hypertension","Primary hyperaldosteronism","Other hyperaldosteronism syndromes","Calcium channel blockers","Other antihypertensive agents","Resistant hypertension","Hypertensive urgencies and emergencies","Assessing urgencies and emergencies","Orthostatic hypotension","Withdraw agents that markedly affect ARR for at least","Diuretics","DIURETICS","Approaching glomerular disease","Histology of glomerular disease","Acute nephritic syndrome","IgA nephropathy","Mesangiocapillary glomerulonephritis","The nephrotic syndrome","Minimal change disease","Hereditary nephropathies","Miscellaneous mesangioproliferative glomerulonephritides","Thrombotic microangiopathies","Acute tubulointerstitial nephritis","Chronic tubulointerstitial disease","Analgesic nephropathy","Renovascular disease","Other renovascular diseases","Other cystic kidney diseases","Diabetic nephropathy","progression","pathology","tract disorders","Plasma cell dyscrasias","Myeloma: cast nephropathy","disease","Renal amyloid: AL amyloid","amyloidosis","Renal amyloid: other forms","Cryoglobulinaemia","Sickle cell nephropathy","vasculitis","predicting relapse","HenochSchnlein purpura","Polyarteritis nodosa","ChurgStrauss syndrome","Lupus nephritis","Systemic sclerosis","Rheumatoid arthritis","Sarcoidosis","Fabrys disease","HIV and renal disease","HIVAN","lesions","Hepatitis B","HBV and ESRD","HCV and ESRD","endocarditis","Renal tuberculosis","in patients with ESRD","Schistosomiasis","Malaria","Standard initial therapy for most with classes III and IV disease is","Urinary tract infection: miscellaneous","Reux nephropathy","Congenital abnormalities of the kidney and urinary tract","Nephrolithiasis","Stone disease: evaluation","Acute renal colic","How to approach obstruction","Investigation of a renal mass","Renal cell carcinoma: general","Tumours of the renal pelvis and ureter","Benign prostatic enlargement: general","Prostate cancer: general","Prostate cancer: investigation","Prostate cancer: screening","Sodium: salt and water balance","Hyponatraemiaapproach","Hyponatraemia with encephalopathy","Hypernatraemia","Potassium","Hyperkalaemia","Hypokalaemia","Hypocalcaemia","Hypercalcaemia","Hypomagnesaemia","Hypermagnesaemia","Hyperphosphataemia","Hypophosphataemia","Acidbase","Excretion: the kidney in acidbase","Metabolic acidosis","Renal tubular acidosis","Lactic acidosis","Alkalosis","Mixed disturbances","Tubular rarities","Physiological changes during pregnancy","Urinary tract infection","AKI during pregnancy","Hypertension during pregnancy","Disorders of the urinary tract in pregnancy","Pregnancy on dialysis","Transplant function and pregnancy","Prescribing in renal impairment","Prescribing for dialysis patients","Sepsis and antimicrobials","Cardiovascular drugs","Prescribing in specic situations","NSAIDs and the kidney","Lithium and the kidney","Salicylate poisoning","Ethylene glycol poisoning","Oral:","dose:","Prophylaxis:","Renal structure and function","The glomerulus","Regulation of GFR","The proximal convoluted tubule","The loop of Henle","The loop of Henle: the countercurrent system","The distal nephron","Insertion of temporary haemodialysis catheters","Preparing renal patients for theatre","Plasma exchange","Useful resources","CKD"]
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