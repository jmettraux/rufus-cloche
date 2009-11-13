#--
# Copyright (c) 2009-2009, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++

require 'yajl'
require 'fileutils'


module Rufus

  #
  # A cloche is a local JSON store.
  #
  class Cloche

    attr_reader :dir

    # Currently, the only known option is :dir
    #
    def initialize (opts={})

      @dir = File.expand_path(opts[:dir] || 'cloche')
    end

    # Puts a document (Hash) under the cloche.
    #
    # If the document is brand new, it will be given a revision number '_rev'
    # of 0.
    #
    # If the document already exists in the cloche and the version to put
    # has an older (different) revision number than the one currently stored,
    # put will fail and return the current version of the doc.
    #
    # If the put is successful, nil is returned.
    #
    def put (doc)

      doc['_rev'] ||= 0

      type, key = doc['type'], doc['_id']

      cur = get(type, key)

      return cur if cur && cur['_rev'] != doc['_rev']

      doc['_rev'] = doc['_rev'] + 1

      d, f = path_for(type, key)

      FileUtils.mkdir_p(d) unless File.exist?(d)

      fn = File.join(d, f)

      FileUtils.touch(fn)

      lock(fn) do |f|
        File.open(f, 'wb') { |ff| ff.write(Yajl::Encoder.encode(doc)) }
      end

      nil
    end

    # Gets a document (or nil if not found (or corrupted)).
    #
    def get (type, key)

      lock(type, key) { |f| do_get(f) }
    end

    # Attempts at deleting a document. You have to pass the current version
    # or at least the { '_id' => i, 'type' => t, '_rev' => r }.
    #
    # Will return nil if the document wasn't found or if sucessful.
    #
    # If the deletion failed (older revision number ?), the current version
    # of the document will be returned.
    #
    def delete (doc)

      type, key = doc['type'], doc['_id']

      cur = get(type, key)

      return nil unless cur
      return cur if cur['_rev'] != doc['_rev']

      lock(type, key) { |f| File.delete(f.path) }

      nil
    end

    # Given a type, this method will return an array of all the documents for
    # that type.
    #
    # A optional second parameter may be used to select, based on a regular
    # expression, which documents to include (match on the key '_id').
    #
    # Will return an empty Hash if there is no documents for a given type.
    #
    def get_many (type, key_match=nil)

      d = dir_for(type)

      return [] unless File.exist?(d)

      Dir[File.join(d, '*.json')].inject([]) do |a, fn|

        key = File.basename(fn, '.json')

        if (not key_match) || key.match(key_match)

          doc = get(type, key)
          a << doc if doc
        end

        a
      end
    end

    protected

    def self.neutralize (s)

      s.to_s.strip.gsub(/[ \/:;\*\\\+\?]/, '_')
    end

    def do_get (file)

      Yajl::Parser.parse(file.read) rescue nil
    end

    def dir_for (type)

      File.join(@dir, self.class.neutralize(type || 'no_type'))
    end

    def path_for (type, key)

      [ dir_for(type), "#{self.class.neutralize(key)}.json" ]
    end

    def file_for (type_or_doc, key=nil)

      fn = if key
        File.join(*path_for(type_or_doc, key))
      elsif type_or_doc.is_a?(String)
        type_or_doc
      else # it's a doc (Hash)
        File.join(*path_for(type_or_doc['type'], type_or_doc['_id']))
      end

      File.exist?(fn) ? File.new(fn) : nil
    end

    def lock (*args, &block)

      file = file_for(*args)

      return nil unless file

      begin
        file.flock(File::LOCK_EX)
        block.call(file)
      ensure
        begin
          file.flock(File::LOCK_UN)
        rescue Exception => e
          #p [ :lock, @fpath, e ]
          #e.backtrace.each { |l| puts l }
        end
      end
    end
  end
end

