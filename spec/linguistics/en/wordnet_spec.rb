#!/usr/bin/env spec -cfs

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent.parent

	libdir = basedir + "lib"

	$LOAD_PATH.unshift( basedir.to_s ) unless $LOAD_PATH.include?( basedir.to_s )
	$LOAD_PATH.unshift( libdir.to_s ) unless $LOAD_PATH.include?( libdir.to_s )
}

require 'rspec'
require 'spec/lib/helpers'

require 'linguistics'
require 'linguistics/en'
require 'linguistics/en/wordnet'


describe Linguistics::EN::WordNet do

	before( :all ) do
		setup_logging()
		Linguistics.use( :en )
	end

	after( :all ) do
		reset_logging()
	end


	it "adds EN::WordNet to the list of English language modules" do
		Linguistics::EN::MODULES.include?( Linguistics::EN::WordNet )
	end


	describe "on a system that has the 'wordnet' library installed" do

		before( :each ) do
			pending "installation of the wordnet library" unless
				Linguistics::EN.has_wordnet?
		end

		it "can create a WordNet::Synset from a word" do
			"jackal".en.synset.should be_a( WordNet::Synset )
		end

		it "can load all synsets for a word" do
			result = "appear".en.synsets
			result.should have( 7 ).members
			result.should include( WordNet::Synset[200422090] )
		end

	end


	describe "on a system that doesn't have the 'wordnet' library" do
		before( :all ) do
			# If the system *does* have wordnet support, pretend it doesn't.
			if Linguistics::EN.has_wordnet?
				@had_wordnet = true
				error = LoadError.new( "no such file to load -- wordnet" )
				Linguistics::EN::WordNet.instance_variable_set( :@has_wordnet, false )
				Linguistics::EN::WordNet.instance_variable_set( :@wn_error, error )
			end
		end

		after( :all ) do
			if @had_wordnet
				Linguistics::EN::WordNet.instance_variable_set( :@has_wordnet, true )
				Linguistics::EN::WordNet.instance_variable_set( :@wn_error, nil )
			end
		end

		it "raises the appropriate LoadError when you try to use wordnet functionality" do
			expect {
				"persimmon".en.synset
			}.to raise_error( LoadError, %r{wordnet}i )
		end

	end

end

