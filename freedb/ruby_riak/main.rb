#file name is disc id
# '#' are comments

require 'riak'

client = Riak::Client.new({:host=>'192.168.1.47', :http_port => 10018})

genres = []
artistsalbums = {}

songs_bucket = client.bucket('songs')
genres_bucket = client.bucket('genres')
artists_bucket = client.bucket('artists')
albums_bucket = client.bucket('albums')

def processFile(file)
	discId = albumArtist = albumTitle = genre = year = ''

	puts "opppening #{file}"
	IO.foreach(file) do |line|
		line = line.strip

		if line.include?("DISCID")
			discId = line.split('DISCID=')[1]
		elsif line.include?('DTITLE') # artist / title
			albumArtist, albumTitle = line.split('DTITLE=')[1].split(' / ')
		elsif line.include?('DGENRE')
			genre = line.split('DGENRE=')[1]
		elsif line.include?('DYEAR=')
			year = line.split('DYEAR=')[1]
		end
	end

	puts "discId: #{discId}\nalbumArtist: #{albumArtist}\nalbumTitle: #{albumTitle}\ngenre: #{genre}\nyear: #{year}\n"
end

def processdDirectory(name, count)
	Dir.open(name) do |dir|
		dir.each do |file|
			next if file == '.' or file == '..' or file == 'COPYING' or file == 'README'

			newName = name + '/' + file

			if File.directory?(newName)
				processdDirectory(newName, count)
			else
				processFile newName

				count = count + 1
				if(count >= 20)
					exit
				end
			end
		end
	end
end


system('clear')
#processdDirectory('/home/alwalker/code')
processdDirectory('/home/alwalker/Downloads/freedb-complete-20140301', 0)
