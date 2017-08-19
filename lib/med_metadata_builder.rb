## => this module parses the pubmed metadata files, which are in an xml format into a 
module MedMetadataBuilder

	def self.parse_metadata_xml_file
		#"#{Rails.root}/vendor/MESH_ASCII_2017.bin"
		proc = Proc.new { |item|

		}
		handler = Yielder.new(proc,MetaData)

		io = StringIO.new(%{
		<top name="sample">
		  Go away
		  <middle name="second">
		  	Hi there how are you
		    <bottom name="third"/>
		  </middle>
		</top>
		})

		
		Ox.sax_parse(handler, io)
		
		##so first step is to know when an article has started
		##and know when an article has ended.

	end

end