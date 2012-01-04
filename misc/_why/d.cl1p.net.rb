#http://redhanded.hobix.com/bits/stowingYerLibrariesOffInTheCutNPaste.html
#http://d.cl1p.net/.rb
require 'open-uri'
require 'tempfile'

$HTTP_LOAD_PATH = []

module UriRequire
    Version = '0.2.0'

    SUPPORTED_URLS = /^(http|https|ftp):\/\//

    @@orig_require = Kernel.method :require

    def self.orig_require(*a); @@orig_require[*a]; end

    def self.new_require( library_name )
        library_name += '.rb' unless library_name =~ /\.rb$/
        return false if $LOADED_FEATURES.include? library_name
        open(library_name) do |uri|
            tmp_name = Tempfile.new( File.basename(library_name) ).path + ".rb"
            File.open(tmp_name, "w") do |libf|
                while chunk = uri.read(4096)
                    libf << chunk
                end
            end
            puts "** Downloaded #{library_name}"
            $LOADED_FEATURES << library_name
            library_name = tmp_name
        end
        orig_require(library_name)
        return true
    end
end

module Kernel
def require( library_name )
    if library_name =~ UriRequire::SUPPORTED_URLS
        begin
            return UriRequire.new_require(library_name)
        rescue OpenURI::HTTPError => e
            raise LoadError, "no such URL to load -- #{library_name}"
        end
    else
        begin
            UriRequire.orig_require library_name
        rescue LoadError => load_error
            $HTTP_LOAD_PATH.each do |url|
                begin
                    return UriRequire.new_require(File.join(url, library_name))
                rescue OpenURI::HTTPError => e
                end
            end
            raise load_error
        end
    end
end
end
