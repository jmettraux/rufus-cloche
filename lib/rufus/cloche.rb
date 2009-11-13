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

  class Cloche

    attr_reader :dir

    def initialize (opts={})

      @dir = File.expand_path(opts[:dir] || 'cloche')
    end

    def put (doc)

      doc['_rev'] ||= "0"

      type, key = doc['type'], doc['_id']

      cur = get(type, key)

      return cur if cur && cur['_rev'] != doc['_rev']

      doc['_rev'] = (doc['_rev'].to_i + 1).to_s

      d, f = path_for(type, key)

      FileUtils.mkdir_p(d) unless File.exist?(d)

      fn = File.join(d, f)

      FileUtils.touch(fn)

      lock(fn) do |f|
        File.open(f, 'wb') { |ff| ff.write(Yajl::Encoder.encode(doc)) }
      end

      nil
    end

    def get (type, key)

      lock(type, key) { |f| do_get(f) }
    end

    def delete (doc)

      type, key = doc['type'], doc['_id']

      cur = get(type, key)

      return nil unless cur
      return cur if cur['_rev'] != doc['_rev']

      lock(type, key) { |f| File.delete(f.path) }

      nil
    end

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

    def self.neutralize (s)

      s.to_s.strip.gsub(/[ \/:;\*\\\+\?]/, '_')
    end

    protected

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

