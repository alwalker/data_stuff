import groovy.io.FileType

def count = 0
def dir = new File('/home/alwalker/Downloads/freedb-complete-20140301')

dir.eachFileRecurse (FileType.FILES) { file ->
	processFile(file, null)
	return
}

def void processFile(file, error_file) {
	def discId = albumArtist = albumTitle = genre = year = ''
	def tracks = []

	println "opening ${file.path}"

	file.eachLine {		
		if(it.contains('DISCID')) {
			discId = it.split('DISCID=')[1]
		}
		else if(it.contains('DTITLE')) { // artist / title
			(albumArtist, albumTitle) = it.split('DTITLE=')[1].split(' / ')
		}
		else if(it.contains('DGENRE') && it.trim().size() > 7) {
			genre = it.split('DGENRE=')[1]
		}
		else if(it.contains('DYEAR=') && it.trim().size() > 6) {
			year = it.split('DYEAR=')[1]
		}
		else if(it.contains('TTITLE')) {
			def match = it =~ /(.*) \/ (.*)/
			if (match.size() > 0) {
				tracks << ['title':match[0][1], 'artist':match[0][0]]
			}
			else {
				tracks << ['title':it.split(/TTITLE\d+=/)[1]]
			}
		}
	}
}
