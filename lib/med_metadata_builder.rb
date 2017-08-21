## => this module parses the pubmed metadata files, which are in an xml format into a 
module MedMetadataBuilder

	def self.parse
		#"#{Rails.root}/vendor/MESH_ASCII_2017.bin"
		proc = Proc.new { |item|

		}
		handler = Yielder.new(proc,MetaData)




		puts "starting to read"
		io = IO.read("#{Rails.root}/vendor/medsample1.xml")
		puts "finished reading."

=begin
		io = StringIO.new(%{
		<top dog="text" dog_attr="text y">
		  <middle>
		    <bottom/>
		  </middle>
		</top>
		})
=end
		Ox.sax_parse(handler, io)
		
		##so first step is to know when an article has started
		##and know when an article has ended.

	end

end