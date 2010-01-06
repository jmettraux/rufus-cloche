#--
# Copyright (c) 2009-2010, John Mettraux, jmettraux@gmail.com
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

require 'thread'
require 'fileutils'

begin
  require 'yajl'
rescue LoadError
  require 'json'
end
require 'rufus/json'
Rufus::Json.detect_backend


module Rufus

  #
  # A cloche is a local JSON hashes store.
  #
  # Warning : cloches are process-safe but not thread-safe.
  #
  class Cloche

    VERSION = '0.1.11'

    attr_reader :dir

    # Currently, the only known option is :dir
    #
    def initialize (opts={})

      @dir = File.expand_path(opts[:dir] || 'cloche')
      @mutex = Mutex.new
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
    def put (doc, opts={})

      doc = Rufus::Json.dup(doc) unless opts[:update_rev]
        # work with a copy, don't touch orgiinal

      type, key = doc['type'], doc['_id']

      raise(
        ArgumentError.new("missing values for keys 'type' and/or '_id'")
      ) if type.nil? || key.nil?

      rev = (doc['_rev'] ||= -1)

      raise(
        ArgumentError.new("values for '_rev' must be positive integers")
      ) if rev.class != Fixnum && rev.class != Bignum

      lock(true, type, key) do |file|

        cur = do_get(file)

        return cur if cur && cur['_rev'] != doc['_rev']
        return true if cur.nil? && doc['_rev'] != -1

        doc['_rev'] = doc['_rev'] + 1

        File.open(file.path, 'wb') { |io| io.write(Rufus::Json.encode(doc)) }
      end

      nil
    end

    # Gets a document (or nil if not found (or corrupted)).
    #
    def get (type, key)

      r = lock(false, type, key) { |f| do_get(f) }

      r == false ? nil : r
    end

    # Attempts at deleting a document. You have to pass the current version
    # or at least the { '_id' => i, 'type' => t, '_rev' => r }.
    #
    # Will return nil if the deletion is successful.
    #
    # If the deletion failed because the given doc has an older revision number
    # that the one currently stored, the doc in its freshest version will be
    # returned.
    #
    # Returns true if the deletion failed.
    #
    def delete (doc)

      drev = doc['_rev']

      raise ArgumentError.new('cannot delete doc without _rev') unless drev

      type, key = doc['type'], doc['_id']

      r = lock(false, type, key) do |f|

        cur = do_get(f)

        return nil unless cur
        return cur if cur['_rev'] != drev

        begin
          File.delete(f.path)
          nil
        rescue
          false
        end
      end

      r == false ? true : nil
    end

    # Given a type, this method will return an array of all the documents for
    # that type.
    #
    # A optional second parameter may be used to select, based on a regular
    # expression, which documents to include (match on the key '_id').
    #
    # Will return an empty Hash if there is no documents for a given type.
    #
    # == opts
    #
    # The only option know for now is :limit, which limits the number of
    # documents returned.
    #
    def get_many (type, key_match=nil, opts={})

      d = dir_for(type)

      return [] unless File.exist?(d)

      docs = []
      limit = opts[:limit]

      files = Dir[File.join(d, '**', '*.json')].sort { |p0, p1|
        File.basename(p0) <=> File.basename(p1)
      }

      files.each do |fn|

        key = File.basename(fn, '.json')

        if (not key_match) || key.match(key_match)

          doc = get(type, key)
          docs << doc if doc

          break if limit && (docs.size >= limit)
        end
      end

      # WARNING : there is a twist here, the filenames may have a different
      #           sort order from actual _ids...

      #docs.sort { |doc0, doc1| doc0['_id'] <=> doc1['_id'] }
        # let's trust filename order

      docs
    end

    protected

    def self.neutralize (s)

      s.to_s.strip.gsub(/[ \/:;\*\\\+\?]/, '_')
    end

    def do_get (file)

      Rufus::Json.decode(file.read) rescue nil
    end

    def dir_for (type)

      File.join(@dir, Cloche.neutralize(type || 'no_type'))
    end

    def path_for (type, key)

      nkey = Cloche.neutralize(key)

      subdir = (nkey[-2, 2] || nkey).gsub(/\./, 'Z')

      [ File.join(dir_for(type), subdir), "#{nkey}.json" ]
    end

    def lock (create, type, key, &block)

      @mutex.synchronize do
        begin

          d, f = path_for(type, key)
          fn = File.join(d, f)

          if create && ( ! File.exist?(fn))
            FileUtils.mkdir_p(d) unless File.exist?(d)
            FileUtils.touch(fn) unless File.exist?(fn)
          end

          file = File.new(fn) rescue nil

          return false if file.nil?

          file.flock(File::LOCK_EX)
          block.call(file)

        ensure
          begin
            file.flock(File::LOCK_UN)
          rescue Exception => e
            #p [ :lock, @fpath, e ]
            #e.backtrace.each { |l| puts l }
          end
          file.close rescue nil
        end
      end
    end
  end
end

